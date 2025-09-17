
T030: add comprehensive method watching support
- Phase 1: Enhance Stable::Fact
- | add `method_type` attribute to the Fact class
- | verify backward compatibility by running `rake stable:example`
- Phase 2: Enhance Stable.watch
- | modify `Stable.watch` to accept a `type:` parameter
- | handle `UnboundMethod` vs. `Method` logic correctly
- | create a new `class_methods.rb` example and fact file
- | create and run a temporary `rake stable:class_example` to verify
- Phase 3: Implement watch_all and Clean Up
- - implement the `Stable.watch_all` method with an `:except` option
- - create a new example and temporary Rake task to test `watch_all`
- - merge new examples into the main `stable:example` task
- - remove all temporary tasks and fact files
- - update `README.md` with documentation for the new features