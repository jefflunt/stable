# lib/stable/configuration.rb
module Stable
  class Configuration
    attr_accessor :storage_path, :enabled, :fact_paths

    def initialize
      @storage_path = nil
      @enabled = false
      @fact_paths = ['facts/**/*.fact']
    end
  end
end
