---
description: Refactor a file or area to the repo's clean-code + type-safety standards, preserving behavior
argument-hint: <path>
---

Refactor `$ARGUMENTS` to this repo's standards **without changing behavior**.

Apply the `clean-code` and `type-safety` skills:
- Convert `function` declarations to `const` arrow functions; switch default exports to **named exports**.
- Extract long functions into well-named helpers so the parent reads like a table of contents; one thing, one abstraction level.
- Add **guard clauses / early returns**; keep the happy path flat. No nested ternaries, no clever one-liners.
- Fix names (intention-revealing, boolean prefixes, `UPPER_SNAKE_CASE` constants, no magic numbers, no type encoding).
- Command-query separation; make side effects explicit in the name.
- Tell, Don't Ask; respect the Law of Demeter.
- Exceptions over error codes; wrap third-party APIs at a boundary; never `catch` as an `if`.
- `type` over `interface`, no `any`, narrow unions; `cn()` for conditional classNames.

Work in small, safe steps. When done, run the project's typecheck/tests if they exist (drive the affected flow when practical), then summarize the changes as a Before/After list. Report honestly if anything fails or was skipped.
