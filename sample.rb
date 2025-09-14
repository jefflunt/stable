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
puts "Recording calls to: #{storage_path}"

storage_file = File.open(storage_path, 'w+')
Stable.storage = storage_file

# 4. Enables and records invocations on each of those instance methods
Stable.record(Calculator, :add)
Stable.record(Calculator, :subtract)
Stable.record(Calculator, :divide)

Stable.enable!

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

Stable.disable!
storage_file.close
puts "--- FINISHED RECORDING ---\n"


# 6. Verifies the JSONL file it just created, printing the output to the console
puts "\n--- VERIFYING ---"
File.foreach(storage_path) do |line|
  record = JSON.parse(line)
  batch = Stable.verify(record)
  puts batch.to_s
end
puts "--- FINISHED VERIFYING ---"
