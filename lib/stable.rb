# `stable` is a library for recording and replaying method calls.
# See README.md for detailed usage instructions.
require_relative 'stable/version'
require_relative 'stable/fact'
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
    # facts. It ensures that recording is turned on for the duration of the
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

    def watch(klass, method_name, type: :instance)
      original_method = type == :instance ? klass.instance_method(method_name) : klass.method(method_name)
      target = type == :instance ? klass : klass.singleton_class

      wrapper_module = Module.new do
        define_method(method_name) do |*args, **kwargs, &block|
          if Stable.enabled?
            begin
              result = original_method.is_a?(UnboundMethod) ? original_method.bind(self).call(*args, **kwargs, &block) : original_method.call(*args, **kwargs, &block)
              fact = Fact.new(
                class_name: klass.name,
                method_name: method_name,
                method_type: type,
                args: args,
                kwargs: kwargs,
                result: result
              )
              unless Stable.send(:_fact_exists?, fact.signature)
                Stable.storage.puts(fact.to_jsonl)
                Stable.storage.flush
                Stable.send(:_recorded_facts) << fact
              end
              result
            rescue => e
              fact = Fact.new(
                class_name: klass.name,
                method_name: method_name,
                method_type: type,
                args: args,
                kwargs: kwargs,
                error: {
                  class: e.class.name,
                  message: e.message,
                  backtrace: e.backtrace
                }
              )
              unless Stable.send(:_fact_exists?, fact.signature)
                Stable.storage.puts(fact.to_jsonl)
                Stable.storage.flush
                Stable.send(:_recorded_facts) << fact
              end
              raise e
            end
          else
            original_method.is_a?(UnboundMethod) ? original_method.bind(self).call(*args, **kwargs, &block) : original_method.call(*args, **kwargs, &block)
          end
        end
      end
      target.prepend(wrapper_module)
    end

    def watch_all(klass, except: [])
      klass.public_instance_methods(false).each do |method_name|
        next if except.include?(method_name)
        watch(klass, method_name, type: :instance)
      end

      klass.public_methods(false).each do |method_name|
        next if except.include?(method_name)
        watch(klass, method_name, type: :class)
      end
    end

    def verify(record_hash)
      Fact.from_jsonl(record_hash.to_json).run!
    end

    private

    def _recorded_facts
      @_recorded_facts ||= begin
        return [] unless storage.respond_to?(:path) && File.exist?(storage.path)
        storage.rewind
        facts = storage.each_line.map { |line| Fact.from_jsonl(line) }
        storage.seek(0, IO::SEEK_END)
        facts
      end
    end

    def _fact_exists?(signature)
      _recorded_facts.any? { |fact| fact.signature == signature }
    end
  end
end
