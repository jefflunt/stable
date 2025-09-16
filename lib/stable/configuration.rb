# lib/stable/configuration.rb
require_relative 'formatters/verbose'

module Stable
  class Configuration
    attr_accessor :storage_path, :enabled, :fact_paths, :formatter

    def initialize
      @storage_path = nil
      @enabled = false
      @fact_paths = ['facts/**/*.fact']
      @formatter = Stable::Formatters::Verbose
    end
  end
end
