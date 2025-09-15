T009: add test suite integration
- provide helpers for RSpec and/or Minitest

T012: create an interactive `rake stable:update` task
- should run verification for all specs
- for failures, it should prompt the user to update the spec
  - if the user accepts the update, then update the related JSONL file
  - if the user rejects the update, then the standard failure is tracked
- after an interactive update session, rewrite the storage file with the changes

T015: add `rake stable:clear` task
| `rake stable:clear` to delete stored specs
| should require the user to type `DELETE SPECS` (case sensitive) to confirm

T019: Establish spec file location standards
- add `config.spec_paths` to `Stable.configure` to support glob patterns
- establish a sensible default path (e.g., `spec/stable/**/*.jsonl`)
- all rake tasks must scan and operate on all found spec files

T021: Extract verification formatting to `Stable::VerboseFormatter`
- Create `Stable::VerboseFormatter` class
- Move `to_s` logic from `Stable::Spec` to the formatter
- Formatter should accept a spec object in its initializer
- Formatter's `to_s` method should produce the current output
