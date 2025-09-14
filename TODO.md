T007: add a `Stable.configure` block
- should allow setting storage_path and enabled status

T008: add a `Stable.recording` block
- should ensure recording is scoped and automatically disabled

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
