# lib/stable/spec.rb
require 'json'
require 'securerandom'
require 'digest'

module Stable
  # a spec is a recording of a single method call, including the inputs and
  # outputs. it's a self-contained, serializable representation of a method's
  # behavior at a specific point in time.
  class Spec
    attr_reader :class_name, :method_name, :args, :result, :error, :actual_result, :actual_error, :status, :uuid, :signature, :name

    def initialize(class_name:, method_name:, args:, result: nil, error: nil, uuid: SecureRandom.uuid, name: nil)
      @class_name = class_name
      @method_name = method_name
      @args = args
      @result = result
      @error = error
      @status = :pending
      @uuid = uuid
      @signature = Digest::SHA256.hexdigest("#{class_name}##{method_name}:#{args.to_json}")
      @name = name || SecureRandom.hex(8)
    end

    def run!
      begin
        klass = Object.const_get(class_name)
        instance = klass.new
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
      short_uuid = uuid.split('-').last
      short_sig = signature[0..6]
      desc = "#{short_uuid}/#{short_sig}"
      name_str = name[..19].ljust(20)
      call = "#{class_name}##{method_name}(#{args.join(', ')})"
      status_code = _status_code
      error_code = _error_code

      case status
      when :passed, :passed_with_error
        "#{desc} #{name_str} #{status_code}#{error_code} #{call}"
      when :failed
        lines = ["#{desc} #{name_str} #{status_code}#{error_code} #{call}"]
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
        "#{desc} #{name_str} #{status_code}#{error_code} #{call}"
      end
    end

    def to_jsonl
      {
        class: class_name,
        method: method_name,
        args: args,
        result: result,
        error: error,
        uuid: uuid,
        signature: signature,
        name: name
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
        uuid: data['uuid'],
        name: data['name']
      )
    end

    def _green(text)
      "\e[32m#{text}\e[0m"
    end

    def _red(text)
      "\e[31m#{text}\e[0m"
    end

    def _yellow(text)
      "\e[33m#{text}\e[0m"
    end

    def _light_blue(text)
      "\e[94m#{text}\e[0m"
    end

    def _status_code
      case status
      when :passed, :passed_with_error
        _green('P')
      when :failed
        _red('F')
      else
        _yellow('?')
      end
    end

    def _error_code
      if error || actual_error
        _light_blue('E')
      else
        _green('N')
      end
    end
  end
end
