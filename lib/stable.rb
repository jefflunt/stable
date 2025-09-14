# `stable` is a library for recording and replaying method calls.
# See README.md for detailed usage instructions.
require_relative 'stable/spec'

module Stable
  class << self
    def enable!
      Thread.current[:stable_enabled] = true
    end

    def disable!
      Thread.current[:stable_enabled] = false
    end

    def enabled?
      Thread.current[:stable_enabled] || false
    end

    def storage=(io)
      @storage = io
    end

    def storage
      @storage || raise("Stable.storage must be set to an IO-like object")
    end

    def record(klass, method_name)
      original_method = klass.instance_method(method_name)
      wrapper_module = Module.new do
        define_method(method_name) do |*args, &block|
          if Stable.enabled?
            begin
              result = original_method.bind(self).call(*args, &block)
              spec = Spec.new(
                class_name: klass.name,
                method_name: method_name,
                args: args,
                result: result
              )
              Stable.storage.puts(spec.to_jsonl)
              result
            rescue => e
              spec = Spec.new(
                class_name: klass.name,
                method_name: method_name,
                args: args,
                error: {
                  class: e.class.name,
                  message: e.message,
                  backtrace: e.backtrace
                }
              )
              Stable.storage.puts(spec.to_jsonl)
              raise e
            end
          else
            original_method.bind(self).call(*args, &block)
          end
        end
      end
      klass.prepend(wrapper_module)
    end

    def verify(record_hash)
      Spec.from_jsonl(record_hash.to_json).run!
    end
  end
end
