# stable

`stable` is a library for recording and replaying method calls to prevent
regressions. The goal is to reduce the amount of manual unit tests you need
to write, while keeping the stability and notification system that unit tests
provide.

## How it Works

1.  **Watch:** You tell `stable` to watch a method on a class.
2.  **Record:** When that method is called within a `Stable.recording` block,
    `stable` records the inputs, output, and any errors.
3.  **Store:** The recording is saved as a JSON line (`.jsonl`) file, creating a
    "spec" for that specific interaction.
4.  **Verify:** You can replay these specs at any time to verify that the
    method's behavior has not changed.

## Usage

Let's use a simple `Calculator` class as an example.

```ruby
# lib/calculator.rb
class Calculator
  def add(a, b)
    a + b
  end
end
```

### 1. Recording Specs

To record interactions with the `Calculator#add` method, we first need to
`watch` it. Then, we can wrap our application code in a `Stable.recording`
block.

```ruby
require 'stable'
require_relative 'calculator'

# Configure stable to save specs to a file
Stable.configure do |config|
  config.storage_path = 'specs.jsonl'
end

# Watch the :add method on the Calculator class
Stable.watch(Calculator, :add)

# This block will record any watched method calls
Stable.recording do
  calculator = Calculator.new
  calculator.add(2, 2)
  calculator.add(5, 3)
end
```

After running this code, `specs.jsonl` will contain:

```json
{"class":"Calculator","method":"add","args":[2,2],"result":4,"uuid":"...","signature":"...","name":"..."}
{"class":"Calculator","method":"add","args":[5,3],"result":8,"uuid":"...","signature":"...","name":"..."}
```

### 2. Verifying Specs

Once you have recorded specs, you can use the provided Rake task to verify
them. This will replay the inputs from each spec and compare the new output
with the recorded output.

```bash
$ rake stable:verify
```

If the behavior of `Calculator#add` has not changed, the output will look
like this:

```
P ✓  8f8e19  Calculator#add
P ✓  6a8fb9  Calculator#add

2 specs, 2 passing, 0 pending, 0 failing
```

If we introduce a bug into `Calculator#add` (e.g., `a - b` instead of `a + b`),
the verification will fail:

```
F ✗  8f8e19  Calculator#add (expected 4, got 0)
F ✗  6a8fb9  Calculator#add (expected 8, got 2)

2 specs, 0 passing, 0 pending, 2 failing
```

This tells you exactly which interactions have regressed.
