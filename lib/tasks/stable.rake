# lib/tasks/stable.rake
require_relative '../stable'
require_relative '../stable/formatters/verbose'

namespace :stable do
  desc "run the example verification"
  task :example do
    require_relative '../../lib/example/calculator'

    fact_path = File.expand_path('../../../facts/calculator.fact.example', __FILE__)
    Stable.configure do |config|
      config.storage_path = fact_path
    end

    facts = []
    File.foreach(Stable.configuration.storage_path) do |line|
      facts << Stable::Fact.from_jsonl(line)
    end

      formatter = Stable.configuration.formatter.new(facts)
    puts formatter.header
    facts.each do |fact|
      fact.run!
      puts formatter.to_s(fact)
    end
    puts formatter.summary
  end

  desc "verify facts"
  task :verify, [:filter] do |t, args|
    fact_files = Dir.glob(Stable.configuration.fact_paths)
    facts = fact_files.flat_map do |file|
      File.foreach(file).map { |line| Stable::Fact.from_jsonl(line) }
    end

    formatter = Stable.configuration.formatter.new(facts)

    if facts.empty?
      puts "no stable facts found"
      puts formatter.summary
    else
      puts formatter.header

      filter = args[:filter].to_s.strip.downcase
      facts.each do |fact|
        if filter.empty? || fact.uuid.include?(filter) || fact.class_name.downcase.include?(filter) || fact.name.downcase.include?(filter)
          fact.run!
          puts formatter.to_s(fact)
        end
      end
      puts formatter.summary
    end
  end

  desc "delete all stable fact files"
  task :clear do
    fact_files = Dir.glob(Stable.configuration.fact_paths)
    if fact_files.empty?
      puts "no stable facts found to clear"
    else
      puts "found the following fact files:"
      fact_files.each { |f| puts "- #{f}" }
      print "are you sure you want to delete them? type 'DELETE FACTS' to confirm: "
      answer = STDIN.gets.chomp
      if answer == 'DELETE FACTS'
        fact_files.each { |f| File.delete(f) }
        puts "deleted #{fact_files.count} fact file(s)."
      else
        puts "aborted."
      end
    end
  end

  desc "start an interactive console with all facts loaded"
  task :console do
    require 'irb'

    def facts
      @facts ||= begin
        fact_files = Dir.glob(Stable.configuration.fact_paths)
        fact_files.flat_map do |file|
          File.foreach(file).map { |line| Stable::Fact.from_jsonl(line) }
        end
      end
    end

    puts "loaded #{facts.count} facts into the `facts` method"
    binding.irb
  end
end
