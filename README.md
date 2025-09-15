<p align="center"><img src="logo.png" width="200"></p>

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

## Deep Dive: The Spec File

Each line in a `.jsonl` file represents a single recorded interaction, parsed
into a `Stable::Spec` object. Understanding the attributes of this object can
be helpful for debugging or manually inspecting your specs.

Here is a breakdown of each attribute in the JSON record:

- **`class`**: The name of the class containing the watched method.
- **`method`**: The name of the method that was called.
- **`args`**: An array of the arguments that were passed to the method during
  the recording.
- **`result`**: The value returned by the method. This key is omitted if an
  error was raised.
- **`error`**: An object containing details about an exception that was raised
  during the method call. It includes the `class`, `message`, and `backtrace`.
  This key is omitted if no error occurred.
- **`uuid`**: A universally unique identifier (UUID) for the spec. This ID is
  generated once and remains with the spec for its entire lifetime. It allows
  `stable` to track the history of a specific interaction, even if its inputs
  or outputs change over time.
- **`signature`**: A SHA256 hash of the spec's `class`, `method`, and `args`.
  `stable` uses this signature to deduplicate specs and avoid recording the
  exact same interaction multiple times.
- **`name`**: A short, human-readable identifier derived from the `uuid`. This
  is the ID you see in the output of the `rake stable:verify` task. It provides
  a convenient way to reference a specific spec. You can also assign your own
  name to a spec to make it even easier to identify.

