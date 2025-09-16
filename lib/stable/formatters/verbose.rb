# lib/stable/formatters/verbose.rb
require_relative 'colors'

module Stable
  module Formatters
    class Verbose

      def initialize(facts)
        @facts = facts
      end

      def to_s(fact)
        short_uuid = fact.uuid.split('-').last
        short_sig = fact.signature[0..6]
        desc = "#{short_uuid}/#{short_sig}"
        name_str = fact.name[..19].ljust(20)
        call = "#{fact.class_name}##{fact.method_name}(#{fact.args.join(', ')})"
        status_code = _status_code(fact)
        error_code = _error_code(fact)

        case fact.status
        when :passed, :passed_with_error
          "#{desc} #{name_str} #{status_code}#{error_code} #{call}"
        when :failed
          lines = ["#{desc} #{name_str} #{status_code}#{error_code} #{call}"]
          if fact.actual_error
            if fact.error
              lines << "  Expected error: #{fact.error['class']}"
              lines << "  Actual error:   #{fact.actual_error.class.name}: #{fact.actual_error.message}"
            else
              lines << "  Expected result: #{fact.result.inspect}"
              lines << "  Actual error:    #{fact.actual_error.class.name}: #{fact.actual_error.message}"
            end
          else
            if fact.error
              lines << "  Expected error: #{fact.error['class']}"
              lines << "  Actual result: #{fact.actual_result.inspect}"
            else
              lines << "  Expected: #{fact.result.inspect}"
              lines << "  Actual:   #{fact.actual_result.inspect}"
            end
          end
          lines.join("\n")
        else
          "#{desc} #{name_str} #{status_code}#{error_code} #{call}"
        end
      end

      def header
        header = "#{'uuid        / sig'.ljust(20)} #{'name'.ljust(20)} st call"
        "#{header}\n#{'-' * 20} #{'-' * 20} -- #{'-' * 35}"
      end

      def summary
        passing = @facts.count { |f| f.status == :passed || f.status == :passed_with_error }
        failing = @facts.count { |f| f.status == :failed }
        pending = @facts.count { |f| f.status == :pending }
        "\n#{@facts.count} facts, #{passing} passing, #{pending} pending, #{failing} failing"
      end


      private

      def _status_code(fact)
        case fact.status
        when :passed, :passed_with_error
          Colors.green('P')
        when :failed
          Colors.red('F')
        else
          Colors.yellow('?')
        end
      end

      def _error_code(fact)
        if fact.error || fact.actual_error
          Colors.light_blue('E')
        else
          Colors.green('N')
        end
      end
    end
  end
end
