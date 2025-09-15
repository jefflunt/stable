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

    puts "\n--- VERIFYING ---"
    puts "#{'uuid        / sig'.ljust(20)} #{'name'.ljust(20)} st call"
    puts "#{'-' * 20} #{'-' * 20} -- #{'-' * 35}"

    File.foreach(Stable.configuration.storage_path) do |line|
      record = JSON.parse(line)
      batch = Stable.verify(record)
      puts batch.to_s
    end
    puts "--- FINISHED VERIFYING ---"
  end

  desc "verify specs"
  task :verify, [:filter] do |t, args|
    require_relative '../../lib/example/calculator'

    puts "#{'uuid        / sig'.ljust(20)} #{'name'.ljust(20)} st call"
    puts "#{'-' * 20} #{'-' * 20} -- #{'-' * 35}"

    # This will need to be updated when T019 is implemented
    spec_path = Stable.configuration.storage_path || raise("Stable.configuration.storage_path must be set")

    File.foreach(spec_path) do |line|
      record = JSON.parse(line)
      spec = Stable::Spec.from_jsonl(line)

      if args[:filter].nil? || spec.uuid.include?(args[:filter])
        batch = Stable.verify(record)
        puts batch.to_s
      end
    end
  end
end
