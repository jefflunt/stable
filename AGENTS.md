# Agent Instructions

This document provides instructions for AI agents operating in this repository.

## Build, Lint, and Test

- **Build:** This is a Ruby gem:
  - `gem build stable.gemspec`
- **Lint:** No linter is configured.
- **Test:**
  - Run example rake task file: `rake stable:example`
- **Release:**: `./release <version>`

## Code Style Guidelines

- **Formatting:**
  - Use 2-space indentation.
  - Use standard Ruby hash syntax (e.g., `key: value`).
- **Naming Conventions:**
  - `snake_case` for methods and variables.
  - `CamelCase` for classes and modules.
  - Prefix private/protected helper methods with `_`, and don't actually use the `private` keyword at all
  - Suffix methods that modify the object in place or raise exceptions with `!`.
  - Suffix methods that return a boolean value with `?`.
  - rake task descriptions should be all lower case text, except where referring to a constant or proper noun
- **Error Handling:**
  - Use methods that raise exceptions (e.g., `save!`, `create!`).
- **Documentation:**
  - focus the documentation on runnable examples of how to use the class/module at hand
  - limit the text width of the documentation to 80 colums
- **General:**
  - Follow standard Ruby conventions.
  - minimize the use of temporary variables
  - make ample use of method chaining when possible
  - helper methods should be:
    - prefixed with an underscore
    - not be defined as `private`
    - placed below the tasks that use them

## Planning

- The `TODO.md` file contains tasks to be completed in this repository
  - do not start a task until asked to start
  - top-level tasks are defined by a task ID ('Txxx', e.g. `T001`), followed by a short description
  - sub-tasks start on a newline and a dash ('-'), followed by a general description
  - when I ask you to complete a task I'll refer to it by its top-level task ID (e.g. "please complete task T003")
  - when you complete one or more sub-tasks, replace the dash ('-') with a pipe ('|') to indicate that you believe that subtask is done
  - there should be exactly one blank line between top-level tasks

  - When starting a new task:
    - check the current state of the repo, and make sure that there aren't any uncommitted changes. if there are uncommitted changes, simply abort and let me know.
    - create a new branch named after the task, and make sure to branch off of `main`
    - commit your changes as you go: that is, do an incremental commit with every subtask, even if the code isn't fully working yet
    - at the end of the task, test the code again to ensure it looks like it's working correctly
