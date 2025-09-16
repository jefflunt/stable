T009: add test suite integration
- provide helpers for RSpec and/or Minitest

T012: create an interactive `rake stable:update` task
- should run verification for all specs
- for failures, it should prompt the user to update the spec
  - if the user accepts the update, then update the related JSONL file
  - if the user rejects the update, then the standard failure is tracked
- after an interactive update session, rewrite the storage file with the changes


T021: Extract verification formatting to `Stable::VerboseFormatter`
- Create `Stable::VerboseFormatter` class
- Move `to_s` logic from `Stable::Spec` to the formatter
- Formatter should accept a spec object in its initializer
- Formatter's `to_s` method should produce the current output

T022: create an interactive console for exploring specs
- `rake stable:console` should load all specs into an IRB session
- the console should provide a `specs` variable containing all loaded specs
