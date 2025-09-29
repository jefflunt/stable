T032: implement automatic state capture for facts
| add `prior` attribute to Stable::Fact
| update `Stable.watch` to capture instance variables before method execution
| update `Fact#run!` to rehydrate object state using `prior` before verification
| create a new example class and fact to verify the implementation
- rename Fact#run! to Fact#verify!
