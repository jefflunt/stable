T009: add test suite integration
- provide helpers for RSpec and/or Minitest

T028: the verbose formatter doesn't need a copy of all facts
- remove the `@facts` instance varaible
- instead, keep track of the count of passed, failed, pending, and total in order to populate the summary
- the counts should be incremented in the `#to_s` method as they're handled
