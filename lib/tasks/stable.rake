# lib/tasks/stable.rake
require_relative '../stable'

namespace :stable do
  desc "Run the example verification"
  task :example do
    require_relative '../../lib/example/calculator'

    session_id = rand(100_000..999_999)
    storage_path = "/tmp/stable-#{session_id}.jsonl"
    Stable.configure do |config|
      config.storage_path = storage_path
    end

    Stable.watch(Calculator, :add)
    Stable.watch(Calculator, :subtract)
    Stable.watch(Calculator, :divide)

    Stable.recording do
      calculator = Calculator.new
      calculator.add(5, 3)
      calculator.subtract(10, 4)
      calculator.divide(10, 2)
      begin
        calculator.divide(5, 0)
      rescue ZeroDivisionError => e
        # no-op
      end
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
end
