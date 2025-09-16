# lib/tasks/stable.rake
require_relative '../stable'

namespace :stable do
  desc "run the example verification"
  task :example do
    require_relative '../../lib/example/calculator'

    fact_path = File.expand_path('../../../facts/calculator.fact.example', __FILE__)
    Stable.configure do |config|
      config.storage_path = fact_path
    end

    puts "#{'uuid        / sig'.ljust(20)} #{'name'.ljust(20)} st call"
    puts "#{'-' * 20} #{'-' * 20} -- #{'-' * 35}"

    File.foreach(Stable.configuration.storage_path) do |line|
      record = JSON.parse(line)
      batch = Stable.verify(record)
      puts batch.to_s
    end
  end

  desc "verify facts"
  task :verify, [:filter] do |t, args|
    fact_files = Dir.glob(Stable.configuration.fact_paths)
    if fact_files.empty?
      puts "no stable facts found"
    else
      puts "#{'uuid        / sig'.ljust(20)} #{'name'.ljust(20)} st call"
      puts "#{'-' * 20} #{'-' * 20} -- #{'-' * 35}"

      facts = fact_files.flat_map do |file|
        File.foreach(file).map { |line| Stable::Fact.from_jsonl(line) }
      end

      filter = args[:filter].to_s.strip.downcase
      facts.each do |fact|
        if filter.empty? || fact.uuid.include?(filter) || fact.class_name.downcase.include?(filter) || fact.name.downcase.include?(filter)
          fact.run!
          puts fact.to_s
        end
      end
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
end
