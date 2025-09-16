T009: add test suite integration
- provide helpers for RSpec and/or Minitest

T012: create an interactive `rake stable:update` task
- should run verification for all specs
- for failures, it should prompt the user to update the spec
  - if the user accepts the update, then update the related JSONL file
  - if the user rejects the update, then the standard failure is tracked
- after an interactive update session, rewrite the storage file with the changes

T019: Refactor from "spec" to "fact" and standardize file locations
| rename `Stable::Spec` to `Stable::Fact` and `lib/stable/spec.rb` to `lib/stable/fact.rb`
| rename `config.spec_paths` to `config.fact_paths` and set the default to `['facts/**/*.fact']`
| create a top-level `facts/` directory for fact files
| move the example `calculator.jsonl` to `facts/calculator.fact`
| update all rake tasks to use the new terminology and file discovery logic
| update the `README.md` to reflect the new "fact" terminology and conventions

T021: Extract verification formatting to `Stable::VerboseFormatter`
- Create `Stable::VerboseFormatter` class
- Move `to_s` logic from `Stable::Spec` to the formatter
- Formatter should accept a spec object in its initializer
- Formatter's `to_s` method should produce the current output

T022: create an interactive console for exploring specs
- `rake stable:console` should load all specs into an IRB session
- the console should provide a `specs` variable containing all loaded specs
