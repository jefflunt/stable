# lib/stable/formatters/colors.rb
module Stable
  module Formatters
    module Colors
      extend self

      def green(text)
        "\e[32m#{text}\e[0m"
      end

      def red(text)
        "\e[31m#{text}\e[0m"
      end

      def yellow(text)
        "\e[33m#{text}\e[0m"
      end

      def light_blue(text)
        "\e[94m#{text}\e[0m"
      end
    end
  end
end
