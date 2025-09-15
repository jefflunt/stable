# Agent Instructions

This document provides instructions for AI agents operating in this repository.

## Build, Lint, and Test

- **Build:** This is a Ruby gem:
  - `gem build stable.gemspec`
- **Lint:** No linter is configured.
- **Test:**
  - Run example rake task file: `rake stable:example`
- **Release:**
  - bump the gem version to the one supplied by the user
  - re-test the gem
  - rebuild the gem

## Code Style Guidelines

- **Formatting:**
  - Use 2-space indentation.
  - Use standard Ruby hash syntax (e.g., `key: value`).
- **Naming Conventions:**
  - `snake_case` for methods and variables.
  - `CamelCase` for classes and modules.
  - Prefix private/protected helper methods with `_`.
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

## Planning

- The `TODO.md` file contains tasks to be completed in this repository
  - do not start a task until asked to start
  - Top-level tasks show up with a task ID ('Txxx', e.g. `T001`), followed by a general description
  - sub-tasks start on a newline and a dash ('-'), followed by a general description
  - when I ask you to complete a task I'll refer to it by its top-level task ID (e.g. "please complete task T003")
  - when you complete one or more sub-tasks, replace the dash ('-') with a pipe ('|') to indicate that you believe that subtask is done
