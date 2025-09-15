# lib/tasks/stable.rake
require_relative '../stable'

namespace :stable do
  desc "run the example verification"
  task :example do
    require_relative '../../lib/example/calculator'

    spec_path = File.expand_path('../../lib/example/calculator.jsonl', __dir__)
    Stable.configure do |config|
      config.storage_path = spec_path
    end

    puts "#{'uuid        / sig'.ljust(20)} #{'name'.ljust(20)} st call"
    puts "#{'-' * 20} #{'-' * 20} -- #{'-' * 35}"

    File.foreach(Stable.configuration.storage_path) do |line|
      record = JSON.parse(line)
      batch = Stable.verify(record)
      puts batch.to_s
    end
  end

  desc "verify specs"
  task :verify, [:filter] do |t, args|
    spec_files = Dir.glob('**/stable-*.jsonl') + Dir.glob('spec/stable/**/*.jsonl') + Dir.glob('test/stable/**/*.jsonl')
    if spec_files.empty?
      puts "no stable specs found"
    else
      puts "#{'uuid        / sig'.ljust(20)} #{'name'.ljust(20)} st call"
      puts "#{'-' * 20} #{'-' * 20} -- #{'-' * 35}"

      specs = spec_files.flat_map do |file|
        File.foreach(file).map { |line| Stable::Spec.from_jsonl(line) }
      end

      filter = args[:filter].to_s.strip.downcase
      specs.each do |spec|
        if filter.empty? || spec.uuid.include?(filter) || spec.class_name.downcase.include?(filter) || spec.name.downcase.include?(filter)
          spec.run!
          puts spec.to_s
        end
      end
    end
  end

  desc "delete all stable spec files"
  task :clear do
    spec_files = Dir.glob('**/stable-*.jsonl') + Dir.glob('spec/stable/**/*.jsonl') + Dir.glob('test/stable/**/*.jsonl')
    if spec_files.empty?
      puts "no stable specs found to clear"
    else
      puts "found the following spec files:"
      spec_files.each { |f| puts "- #{f}" }
      print "are you sure you want to delete them? type 'DELETE SPECS' to confirm: "
      answer = STDIN.gets.chomp
      if answer == 'DELETE SPECS'
        spec_files.each { |f| File.delete(f) }
        puts "deleted #{spec_files.count} spec file(s)."
      else
        puts "aborted."
      end
    end
  end
end
