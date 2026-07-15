---
description: Audit the monorepo against the project structure boundaries and dependency direction
argument-hint: [optional package or path to scope]
allowed-tools: Bash(git grep:*), Grep, Glob, Read
---

Audit the workspace (or `$ARGUMENTS` if provided) against the `project` skill's rules and report violations.

Check for:
- **Deep imports** — any import that reaches past a package entry into its internals (e.g. `@scope/feature-x/src/...`). Imports must target the package name / its public entry only.
- **Dependency direction** — `platform-* → feature-* → core-*`. Flag any `core-*` importing `feature-*` or `platform-*`, and any `feature-*` importing another feature's internals.
- **Circular dependencies** between packages.
- **Default exports** — the repo uses named exports only.

Use grep/glob across the workspace to find offenders. Report as a table with `file:line`, the rule violated, and the fix. If everything is clean, say so explicitly. Do not edit — this is an audit (hand fixes to `monorepo-architect` or `/refactor`).
