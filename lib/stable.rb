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
              unless Stable.send(:_spec_exists?, spec.signature)
                Stable.storage.puts(spec.to_jsonl)
                Stable.send(:_recorded_specs) << spec
              end
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
              unless Stable.send(:_spec_exists?, spec.signature)
                Stable.storage.puts(spec.to_jsonl)
                Stable.send(:_recorded_specs) << spec
              end
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

    private

    def _recorded_specs
      @_recorded_specs ||= begin
        return [] unless storage.respond_to?(:path) && File.exist?(storage.path)
        File.foreach(storage.path).map { |line| Spec.from_jsonl(line) }
      end
    end

    def _spec_exists?(signature)
      _recorded_specs.any? { |spec| spec.signature == signature }
    end
  end
end
