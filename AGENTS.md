# Agent Instructions

This document provides instructions for AI agents operating in this repository.

## Build, Lint, and Test

- **Build:** This is a Rails application, so there is no explicit build step.
- **Lint:** No linter is configured.
- **Test:**
  - Run sample file: `ruby sample.rb`

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
- **Error Handling:**
  - Use methods that raise exceptions (e.g., `save!`, `create!`).
- **General:**
  - Follow standard Ruby on Rails conventions.

## Planning

- The `TODO.md` file contains tasks to be completed in this repository
  - Top-level tasks show up with a task ID ('Txxx', e.g. `T001`), followed by a general description
  - sub-tasks start on a newline and a dash ('-'), followed by a general description
  - when I ask you to complete a task I'll refer to it by its top-level task ID (e.g. "please complete task T003")
  - when you complete one or more sub-tasks, replace the dash ('-') with a pipe ('|') to indicate that you believe that subtask is done
