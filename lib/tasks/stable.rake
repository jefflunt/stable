# lib/tasks/stable.rake
require_relative '../stable'
require_relative '../stable/formatters/verbose'

namespace :stable do
  desc "run the example verification"
  task :example, [:filter] do |t, args|
    require_relative '../../lib/example/calculator'

    fact_path = File.expand_path('../../../facts/calculator.fact.example', __FILE__)
    Stable.configure do |config|
      config.storage_path = fact_path
    end

    facts = []
    File.foreach(Stable.configuration.storage_path) do |line|
      facts << Stable::Fact.from_jsonl(line)
    end

    formatter = Stable.configuration.formatter.new
    puts formatter.header

    _filter_facts(facts, args[:filter].to_s.strip.downcase).each do |fact|
      fact.run!
      puts formatter.to_s(fact)
    end

    puts formatter.summary
  end

  desc "verify facts"
  task :verify, [:filter] do |t, args|
    facts = _load_facts(args[:filter])

    formatter = Stable.configuration.formatter.new

    if facts.empty?
      puts "no stable facts found"
      puts formatter.summary
    else
      puts formatter.header

      facts.each do |fact|
        fact.run!
        puts formatter.to_s(fact)
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
      @facts ||= _load_facts
    end

    puts "loaded #{facts.count} facts into the `facts` method"
    binding.irb
  end

  desc "interactively update failing facts"
  task :update, [:filter] do |t, args|
    facts = _load_facts(args[:filter])

    formatter = Stable.configuration.formatter.new

    if facts.empty?
      puts "no stable facts found"
      puts formatter.summary
    else
      puts formatter.header

      updated_facts = []
      _filter_facts(facts, _clean_filter(args[:filter])).each do |fact|
        fact.run!
        if fact.status == :failed
          puts formatter.to_s(fact)
          print "  update this fact? (y/n): "
          answer = STDIN.gets
          if answer && answer.chomp.downcase == 'y'
            fact.update!
            updated_facts << fact
            puts "  updated."
          else
            puts "  skipped."
          end
        end
      end

      if updated_facts.any?
        fact_files.each do |file|
          File.open(file, 'w') do |f|
            facts.each do |fact|
              f.puts fact.to_jsonl if fact.source_file == file
            end
          end
        end
        puts "\n#{updated_facts.count} fact(s) updated."
      else
        puts "\nno facts updated."
      end
    end
  end

  def _load_facts(filter)
    _filter_facts(
      Dir
        .glob(Stable.configuration.fact_paths)
        .flat_map do |file|
          File.foreach(file).map { |line| Stable::Fact.from_jsonl(line, file) }
        end,
      filter.to_s.strip.downcase
    )

  end

  def _filter_facts(facts, filter)
    return facts if filter.empty?
    facts.select do |fact|
      fact.uuid.include?(filter) ||
        fact.class_name.downcase.include?(filter) ||
        fact.name.downcase.include?(filter)
    end
  end
end
