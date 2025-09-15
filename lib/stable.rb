# `stable` is a library for recording and replaying method calls.
# See README.md for detailed usage instructions.
require_relative 'stable/spec'
require_relative 'stable/configuration'

if defined?(Rake)
  load File.expand_path('../tasks/stable.rake', __FILE__)
end

module Stable
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def enable!
      Thread.current[:stable_enabled] = true
    end

    def disable!
      Thread.current[:stable_enabled] = false
    end

    def enabled?
      Thread.current[:stable_enabled] || configuration.enabled || false
    end

    def storage=(io)
      @storage = io
    end

    def storage
      @storage ||= (configuration.storage_path && File.open(configuration.storage_path, 'a+')) || raise("Stable.storage must be set to an IO-like object")
    end

    # this method is a block-based way to enable and disable recording of
    # specs. It ensures that recording is turned on for the duration of the
    # block and is automatically turned off afterward, even if an error occurs.
    #
    # example:
    #
    #   Stable.recording do
    #     # code in here will be recorded
    #   end
    #
    def recording
      enable!
      yield if block_given?
    ensure
      disable!
      storage.close if storage.respond_to?(:close)
      @storage = nil
    end

    def watch(klass, method_name)
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
                Stable.storage.flush
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
                Stable.storage.flush
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
        storage.rewind
        specs = storage.each_line.map { |line| Spec.from_jsonl(line) }
        storage.seek(0, IO::SEEK_END)
        specs
      end
    end

    def _spec_exists?(signature)
      _recorded_specs.any? { |spec| spec.signature == signature }
    end
  end
end
