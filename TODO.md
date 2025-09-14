T006: add a `Stable::replay_list` method
- this method should accept an array of `Hash`, and should run `::verify` for each `Hash` in the array
- results should be aggregated

T007: add a `Stable.configure` block
- should allow setting storage_path and enabled status

T008: add a `Stable.recording` block
- should ensure recording is scoped and automatically disabled

T009: add test suite integration
- provide helpers for RSpec and/or Minitest

T010: add rake tasks
- `rake stable:verify` to run all verifications
- `rake stable:clear` to delete stored specs

T011: implement a dual-ID system for specs
- add a `signature` field to `Stable::Spec` (a hash of class, method, and args) for deduplication
- add a `uuid` field to `Stable::Spec` (a random, stable ID) to track lineage over time
- ensure `record` logic prevents creating specs with duplicate signatures

T012: create an interactive `rake stable:update` task
- should run verification for all specs
- for failures, it should prompt the user to update the spec

T013: implement persistence for spec updates
- after an interactive update session, rewrite the storage file with the changes
