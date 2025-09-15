# sample.rb

require_relative 'lib/stable'
require 'json'

# 2. Defines a test class that has a couple of example methods
class Calculator
  def add(a, b)
    a + b
  end

  def subtract(a, b)
    a - b
  end

  def divide(a, b)
    raise ZeroDivisionError, "Cannot divide by zero" if b.zero?
    a.to_f / b
  end
end

# 3. Generates a random number between 100,000-999,999 (inclusive), and
#    uses that as the test session ID
session_id = rand(100_000..999_999)
puts "Starting Stable session: #{session_id}"

# 5. Stores the results to a temporary file
storage_path = "/tmp/stable-#{session_id}.jsonl"
Stable.configure do |config|
  config.storage_path = storage_path
end
puts "Recording calls to: #{storage_path}"

# 4. Enables and records invocations on each of those instance methods
Stable.watch(Calculator, :add)
Stable.watch(Calculator, :subtract)
Stable.watch(Calculator, :divide)

Stable.recording do
  puts "\n--- RECORDING ---"
  calculator = Calculator.new
  calculator.add(5, 3)
  calculator.subtract(10, 4)
  calculator.divide(10, 2)
  begin
    calculator.divide(5, 0)
  rescue ZeroDivisionError => e
    puts "Recorded an expected error: #{e.class}"
  end
end

puts "--- FINISHED RECORDING ---\n"


# 6. Verifies the JSONL file it just created, printing the output to the console
puts "\n--- VERIFYING ---"
File.foreach(Stable.configuration.storage_path) do |line|
  record = JSON.parse(line)
  batch = Stable.verify(record)
  puts batch.to_s
end
puts "--- FINISHED VERIFYING ---"
