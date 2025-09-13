require "json"

# StableSpec is a library for recording and replaying method calls.
# This allows for the automatic generation of unit tests based on real
# application usage.
#
# Usage:
#
#   require 'stable_spec'
#
#   # Configure storage to an IO-like object
#   StableSpec.storage = File.open('captured_calls.jsonl', 'a')
#
#   # Wrap a method to capture its calls
#   StableSpec.capture(MyClass, :my_method)
#
#   # Enable capturing
#   StableSpec.enable!
#
#   # ... call MyClass#my_method ...
#
#   # Disable capturing
#   StableSpec.disable!
module StableSpec
  class << self
    def enable!
      Thread.current[:stable_spec_enabled] = true
    end

    def disable!
      Thread.current[:stable_spec_enabled] = false
    end

    def enabled?
      Thread.current[:stable_spec_enabled] || false
    end

    def storage=(io)
      @storage = io
    end

    def storage
      @storage || raise("StableSpec.storage must be set to an IO-like object")
    end

    def capture(klass, method_name)
      original_method = klass.instance_method(method_name)
      wrapper_module = Module.new do
        define_method(method_name) do |*args, &block|
          if StableSpec.enabled?
            begin
              result = original_method.bind(self).call(*args, &block)
              record = {
                class: klass.name,
                method: method_name,
                args: args,
                result: result,
                timestamp: Time.now.iso8601
              }
              StableSpec.storage.puts(record.to_json)
              result
            rescue => e
              record = {
                class: klass.name,
                method: method_name,
                args: args,
                error: {
                  class: e.class.name,
                  message: e.message,
                  backtrace: e.backtrace
                },
                timestamp: Time.now.iso8601
              }
              StableSpec.storage.puts(record.to_json)
              raise e
            end
          else
            original_method.bind(self).call(*args, &block)
          end
        end
      end
      klass.prepend(wrapper_module)
    end
  end
end
