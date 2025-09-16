# lib/stable/fact.rb
require 'json'
require 'securerandom'
require 'digest'

module Stable
  # a fact is a recording of a single method call, including the inputs and
  # outputs. it's a self-contained, serializable representation of a method's
  # behavior at a specific point in time.
  class Fact
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

    def name=(new_name)
      return if new_name.to_s.strip.empty?
      @name = new_name
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


  end
end
