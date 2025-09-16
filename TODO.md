T009: add test suite integration
- provide helpers for RSpec and/or Minitest

T012: create an interactive `rake stable:update` task
- should run verification for all specs
- for failures, it should prompt the user to update the spec
  - if the user accepts the update, then update the related JSONL file
  - if the user rejects the update, then the standard failure is tracked
- after an interactive update session, rewrite the storage file with the changes


T021: Extract verification formatting to `Stable::Formatters::Verbose`
| create the `Stable::Formatters::Verbose` class
| the formatter should manage a collection of facts
| move the `to_s` logic for a single fact from `Stable::Fact` to the formatter
| create a `header` method in the formatter to generate the column headers
| create a `summary` method to generate the final count of passed/failed/pending facts
| update all rake tasks to use the new formatter for all output

T022: create an interactive console for exploring specs
- `rake stable:console` should load all specs into an IRB session
- the console should provide a `specs` variable containing all loaded specs
