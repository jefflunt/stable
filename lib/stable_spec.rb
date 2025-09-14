# stable_spec is a library for recording and replaying method calls. the idea of
# this is to reduce the amount of manual unit tests you need to write, while
# keeping the stability/notification system that unit tests provide.
#
# usage:
#
#   require 'stable_spec'
#
#   # stable_spec uses an IO-like object to write the captured inputs/outputs.
#   # if you don't set this, the default it to print the interaction records to
#   # $stdout, so you could also pipe the result to another place.
#   StableSpec.storage = File.open('captured_calls.jsonl', 'a')
#
#   # wrap a method on a given class
#   StableSpec.capture(MyClass, :my_method)
#
#   # enable runtime input/output capture
#   StableSpec.enable!
#
#   MyClass.my_metehod  # this will be captures by stable_spec
#
#   # disable input/output capture
#   StableSpec.disable!
#
#   # replay captured calls, which gives you a unit test-list pass/fail
#   record = JSON.parse(File.read('captured_calls.jsonl').lines.first)
#   StableSpec.replay(record)
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

    def replay(record)
      klass = Object.const_get(record["class"])
      instance = klass.new
      method_name = record["method"]
      args = record["args"]
      description = "#{klass.name}##{method_name}(#{args.join(', ')})"

      begin
        actual_result = instance.public_send(method_name, *args)
        if record.key?("error")
          puts "FAILED: #{description}"
          puts "  Expected error: #{record['error']['class']}"
          puts "  Actual result: #{actual_result.inspect}"
        elsif actual_result == record["result"]
          puts "PASSED: #{description}"
        else
          puts "FAILED: #{description}"
          puts "  Expected: #{record['result'].inspect}"
          puts "  Actual:   #{actual_result.inspect}"
        end
      rescue => e
        if record.key?("error") && e.class.name == record["error"]["class"]
          puts "PASSED: #{description} (error)"
        elsif record.key?("error")
          puts "FAILED: #{description}"
          puts "  Expected error: #{record['error']['class']}"
          puts "  Actual error:   #{e.class.name}: #{e.message}"
        else
          puts "FAILED: #{description}"
          puts "  Expected result: #{record['result'].inspect}"
          puts "  Actual error:    #{e.class.name}: #{e.message}"
        end
      end
    end
  end
end
