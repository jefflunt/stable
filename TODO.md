T009: add test suite integration
- provide helpers for RSpec and/or Minitest

T010: add `rake stable:verify` task
- `rake stable:verify` to run all verifications

T012: create an interactive `rake stable:update` task
- should run verification for all specs
- for failures, it should prompt the user to update the spec

T013: implement persistence for spec updates
- after an interactive update session, rewrite the storage file with the changes

T015: add `rake stable:clear` task
- `rake stable:clear` to delete stored specs
- should require the user to type `DELETE` to confirm

T016: remove timestamp from spec
- remove `timestamp` field from `Stable::Spec`
- remove `timestamp` from `to_jsonl` output

T018: consolidate test status output
| status should be a two-character code
| first char: P/F/? (pass/fail/pending)
| second char: E (red) for error, N (green) for no error
