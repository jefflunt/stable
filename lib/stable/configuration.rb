# lib/stable/configuration.rb
module Stable
  class Configuration
    attr_accessor :storage_path, :enabled

    def initialize
      @storage_path = nil
      @enabled = false
    end
  end
end
