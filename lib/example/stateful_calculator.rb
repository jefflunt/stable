# lib/example/stateful_calculator.rb

# this class demonstrates a stateful calculator where operations rely on the
# value stored in the `@memory` instance variable.
class StatefulCalculator
  def initialize
    @memory = 0
  end

  def add(number)
    @memory += number
  end

  def subtract(number)
    @memory -= number
  end

  def clear
    @memory = 0
  end

  def memory
    @memory
  end
end
