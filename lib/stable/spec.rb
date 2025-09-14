# lib/stable/spec.rb
require 'json'

module Stable
  # a spec is a recording of a single method call, including the inputs and
  # outputs. it's a self-contained, serializable representation of a method's
  # behavior at a specific point in time.
  class Spec
    attr_reader :class_name, :method_name, :args, :result, :error, :timestamp

    def initialize(class_name:, method_name:, args:, result: nil, error: nil, timestamp: Time.now.iso8601)
      @class_name = class_name
      @method_name = method_name
      @args = args
      @result = result
      @error = error
      @timestamp = timestamp
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
