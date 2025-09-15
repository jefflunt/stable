# lib/tasks/stable.rake
require_relative '../stable'

namespace :stable do
  desc "Verify all recorded specs"
  task :verify do
    require_relative '../../sample'
    puts "\n--- VERIFYING ---"
    puts "#{'uuid        / sig'.ljust(20)} #{'name'.ljust(20)} st call"
    puts "#{'-' * 20} #{'-' * 20} -- #{'-' * 35}"

    # This will need to be updated when T019 is implemented
    spec_path = Stable.configuration.storage_path || raise("Stable.configuration.storage_path must be set")

    File.foreach(spec_path) do |line|
      record = JSON.parse(line)
      batch = Stable.verify(record)
      puts batch.to_s
    end
    puts "--- FINISHED VERIFYING ---"
  end
end
