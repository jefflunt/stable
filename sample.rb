# sample.rb

require_relative 'lib/stable_spec'
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
puts "Starting StableSpec session: #{session_id}"

# 5. Stores the results to a temporary file
file_id = rand(100..999)
storage_path = "/tmp/stable_spec-#{file_id}.jsonl"
puts "Capturing calls to: #{storage_path}"

storage_file = File.open(storage_path, 'w')
StableSpec.storage = storage_file

# 4. Enables and captures invocations on each of those instance methods
StableSpec.capture(Calculator, :add)
StableSpec.capture(Calculator, :subtract)
StableSpec.capture(Calculator, :divide)

StableSpec.enable!

puts "\n--- CAPTURING ---"
calculator = Calculator.new
calculator.add(5, 3)
calculator.subtract(10, 4)
calculator.divide(10, 2)
begin
  calculator.divide(5, 0)
rescue ZeroDivisionError => e
  puts "Captured an expected error: #{e.class}"
end

StableSpec.disable!
storage_file.close
puts "--- FINISHED CAPTURING ---\n"


# 6. Replays the JSONL file it just created, printing the output to the console
puts "\n--- REPLAYING ---"
File.foreach(storage_path) do |line|
  record = JSON.parse(line)
  StableSpec.replay(record)
end
puts "--- FINISHED REPLAYING ---"
