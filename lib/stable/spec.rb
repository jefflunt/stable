# lib/stable/spec.rb
require 'json'

module Stable
  # a spec is a recording of a single method call, including the inputs and
  # outputs. it's a self-contained, serializable representation of a method's
  # behavior at a specific point in time.
  class Spec
    attr_reader :class_name, :method_name, :args, :result, :error, :timestamp, :actual_result, :actual_error, :status

    def initialize(class_name:, method_name:, args:, result: nil, error: nil, timestamp: Time.now.iso8601)
      @class_name = class_name
      @method_name = method_name
      @args = args
      @result = result
      @error = error
      @timestamp = timestamp
      @status = :pending
    end

    def run!
      klass = Object.const_get(class_name)
      instance = klass.new

      begin
        @actual_result = instance.public_send(method_name, *args)
        if error
          @status = :failed
        elsif actual_result == result
          @status = :passed
        else
          @status = :failed
        end
      rescue => e
        @actual_error = e
        if error && e.class.name == error["class"]
          @status = :passed_with_error
        else
          @status = :failed
        end
      end
      self
    end

    def to_s
      description = "#{class_name}##{method_name}(#{args.join(', ')})"
      case status
      when :passed
        "PASSED: #{description}"
      when :passed_with_error
        "PASSED: #{description} (error)"
      when :failed
        lines = ["FAILED: #{description}"]
        if actual_error
          if error
            lines << "  Expected error: #{error['class']}"
            lines << "  Actual error:   #{actual_error.class.name}: #{actual_error.message}"
          else
            lines << "  Expected result: #{result.inspect}"
            lines << "  Actual error:    #{actual_error.class.name}: #{actual_error.message}"
          end
        else
          if error
            lines << "  Expected error: #{error['class']}"
            lines << "  Actual result: #{actual_result.inspect}"
          else
            lines << "  Expected: #{result.inspect}"
            lines << "  Actual:   #{actual_result.inspect}"
          end
        end
        lines.join("\n")
      else
        "PENDING: #{description}"
      end
    end

    def to_jsonl
      {
        class: class_name,
        method: method_name,
        args: args,
        result: result,
        error: error,
        timestamp: timestamp
      }.compact.to_json
    end

    def self.from_jsonl(jsonl_string)
      data = JSON.parse(jsonl_string)
      new(
        class_name: data['class'],
        method_name: data['method'],
        args: data['args'],
        result: data['result'],
        error: data['error'],
        timestamp: data['timestamp']
      )
    end
  end
end
