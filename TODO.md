T009: add test suite integration
- provide helpers for RSpec and/or Minitest

T010: add `rake stable:verify` task
| add `rake` as a runtime dependency
- `rake stable:verify` should run all verifications found in the configured spec paths
- support running a single spec by UUID: `rake stable:verify[uuid]`
- support running a subset of specs by fuzzy class name: `rake stable:verify[search_term]`
- support running a subset of specs by fuzzy name: `rake stable:verify[search_term]`

T012: create an interactive `rake stable:update` task
- should run verification for all specs
- for failures, it should prompt the user to update the spec

T013: implement persistence for spec updates
- after an interactive update session, rewrite the storage file with the changes

T015: add `rake stable:clear` task
- `rake stable:clear` to delete stored specs
- should require the user to type `DELETE` to confirm

T019: Establish spec file location standards
- add `config.spec_paths` to `Stable.configure` to support glob patterns
- establish a sensible default path (e.g., `spec/stable/**/*.jsonl`)
- all rake tasks must scan and operate on all found spec files
