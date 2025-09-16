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
3.  **Store:** The recording is saved as a `.fact` file, creating a verifiable
    "fact" about that specific interaction.
4.  **Verify:** You can replay these facts at any time to verify that the
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

### 1. Recording Facts

To record interactions with the `Calculator#add` method, we first need to
`watch` it. Then, we can wrap our application code in a `Stable.recording`
block. By default, `stable` will save facts to the `facts/` directory.

```ruby
require 'stable'
require_relative 'calculator'

# Configure stable to save facts to a specific file
Stable.configure do |config|
  config.storage_path = 'facts/calculator.fact'
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

After running this code, `facts/calculator.fact` will contain:

```json
{"class":"Calculator","method":"add","args":[2,2],"result":4,"uuid":"...","signature":"...","name":"..."}
{"class":"Calculator","method":"add","args":[5,3],"result":8,"uuid":"...","signature":"...","name":"..."}
```

### 2. Verifying Facts

Once you have recorded facts, you can use the provided Rake task to verify
them. This will replay the inputs from each fact and compare the new output
with the recorded output.

```bash
$ rake stable:verify
```

If the behavior of `Calculator#add` has not changed, the output will look
like this:

```
uuid        / sig    name                 st call
-------------------- -------------------- -- -----------------------------------
d171f8670b44/9a1ebf5 adds two numbers      P N Calculator#add(5, 3)
e109cff2711a/eb9b4f4 subtracts two number  P N Calculator#subtract(10, 4)

2 facts, 2 passing, 0 pending, 0 failing
```

If we introduce a bug into `Calculator#add` (e.g., `a - b` instead of `a + b`),
the verification will fail:

```
uuid        / sig    name                 st call
-------------------- -------------------- -- -----------------------------------
d171f8670b44/9a1ebf5 adds two numbers      F N Calculator#add(5, 3)
  Expected: 8
  Actual:   2
e109cff2711a/eb9b4f4 subtracts two number  F N Calculator#subtract(10, 4)
  Expected: 6
  Actual:   14

2 facts, 0 passing, 0 pending, 2 failing
```

This tells you exactly which interactions have regressed.

### 3. Updating Facts

When a fact fails, it often means the underlying code has changed. If the new behavior is correct, you can use the `rake stable:update` task to interactively update your recorded facts.

```bash
$ rake stable:update
```

This task will run through all your facts. For each one that fails, it will display the difference and prompt you to accept the new result.

```
uuid        / sig    name                 st call
-------------------- -------------------- -- -----------------------------------
d171f8670b44/9a1ebf5 adds two numbers      F N Calculator#add(5, 3)
  Expected: 8
  Actual:   2
  update this fact? (y/n): y
  updated.

1 fact(s) updated.
```

If you enter `y`, the `.fact` file will be permanently updated with the new result. If you enter `n` or anything else, the original fact will be kept. This workflow makes it easy to review and approve changes to your system's behavior.

## Deep Dive: The Fact File

Each line in a `.fact` file represents a single recorded interaction, parsed
into a `Stable::Fact` object. Understanding the attributes of this object can
be helpful for debugging or manually inspecting your facts.

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
- **`uuid`**: A universally unique identifier (UUID) for the fact. This ID is
  generated once and remains with the fact for its entire lifetime. It allows
  `stable` to track the history of a specific interaction, even if its inputs
  or outputs change over time.
- **`signature`**: A SHA256 hash of the fact's `class`, `method`, and `args`.
  `stable` uses this signature to deduplicate facts and avoid recording the
  exact same interaction multiple times.
- **`name`**: A short, human-readable identifier derived from the `uuid`. This
  is the ID you see in the output of the `rake stable:verify` task. It provides
  a convenient way to reference a specific fact. You can also assign your own
  name to a fact to make it even easier to identify.

