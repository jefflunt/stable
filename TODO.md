T009: add test suite integration
- provide helpers for RSpec and/or Minitest

T026: refactor rake task filtering logic
- create a helper method to encapsulate the filtering logic
- it should accept a list of facts, and return a list of facts
- reuse this helper method in both the `verify` and `update` tasks
- this will reduce code duplication and make the tasks easier to maintain

T027: refactor rake task fact loading
- create a helper method to encapsulate the fact loading logic
- this helper should be responsible for finding and parsing all `.fact` files
- reuse this helper method across all relevant rake tasks
