# stable is a library for recording and replaying method calls. the idea of
# this is to reduce the amount of manual unit tests you need to write, while
# keeping the stability/notification system that unit tests provide.
#
# usage:
#
#   require 'stable'
#
#   # stable uses an IO-like object to write the captured inputs/outputs.
#   # if you don't set this, the default it to print the interaction records to
#   # $stdout, so you could also pipe the result to another place.
#   Stable.storage = File.open('captured_calls.jsonl', 'a')
#
#   # wrap a method on a given class
#   Stable.capture(MyClass, :my_method)
#
#   # enable runtime input/output capture
#   Stable.enable!
#
#   MyClass.my_metehod  # this will be captures by stable
#
#   # disable input/output capture
#   Stable.disable!
#
#   # replay captured calls, which gives you a unit test-list pass/fail
#   record = JSON.parse(File.read('captured_calls.jsonl').lines.first)
#   Stable.replay(record)
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

    def capture(klass, method_name)
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

    def replay(record_hash)
      spec = Spec.from_jsonl(record_hash.to_json)
      klass = Object.const_get(spec.class_name)
      instance = klass.new
      description = "#{spec.class_name}##{spec.method_name}(#{spec.args.join(', ')})"

      begin
        actual_result = instance.public_send(spec.method_name, *spec.args)
        if spec.error
          puts "FAILED: #{description}"
          puts "  Expected error: #{spec.error['class']}"
          puts "  Actual result: #{actual_result.inspect}"
        elsif actual_result == spec.result
          puts "PASSED: #{description}"
        else
          puts "FAILED: #{description}"
          puts "  Expected: #{spec.result.inspect}"
          puts "  Actual:   #{actual_result.inspect}"
        end
      rescue => e
        if spec.error && e.class.name == spec.error["class"]
          puts "PASSED: #{description} (error)"
        elsif spec.error
          puts "FAILED: #{description}"
          puts "  Expected error: #{spec.error['class']}"
          puts "  Actual error:   #{e.class.name}: #{e.message}"
        else
          puts "FAILED: #{description}"
          puts "  Expected result: #{spec.result.inspect}"
          puts "  Actual error:    #{e.class.name}: #{e.message}"
        end
      end
    end
  end
end

