
T030: add comprehensive method watching support
- enhance `Stable.watch` to support class and module methods (e.g., via a `type` option)
- update the `Fact` class to distinguish between instance and class/module methods
- ensure the `run!` method can correctly replay class/module methods
- implement `Stable.watch_all(klass, options = {})` to discover and watch all public methods
- add an `except:` option to `watch_all` to exclude specific methods
- create a new class/module example to demonstrate the new functionality
- create a new `.fact.example` file for the new example
- update `README.md` to document `watch_all` and class/module method support