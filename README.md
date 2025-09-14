# stable

`stable` is a library for recording and replaying method calls. the idea of
this is to reduce the amount of manual unit tests you need to write, while
keeping the stability/notification system that unit tests provide.

## usage

```ruby
require 'stable'

# stable uses an IO-like object to write the captured inputs/outputs.
# if you don't set this, the default it to print the interaction records to
# $stdout, so you could also pipe the result to another place.
Stable.storage = File.open('captured_calls.jsonl', 'a')

# wrap a method on a given class
Stable.watch(MyClass, :my_method)

# enable runtime input/output capture
Stable.enable!

MyClass.my_metehod  # this will be recorded by stable

# disable input/output capture
Stable.disable!

# verify captured calls, which gives you a unit test-list pass/fail
record = JSON.parse(File.read('captured_calls.jsonl').lines.first)
Stable.verify(record)
```
