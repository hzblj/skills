---
"skills": minor
---

Restructure `type-safety` and add the `why` skill, both adapted from [cursor/plugins](https://github.com/cursor/plugins) `pstack` (MIT).

`type-safety` splits into a thin `SKILL.md` (22-row rule table + review checklist) and `references/patterns.md` holding every worked `// Good` / `// Bad` example, so the loaded context stays small and the examples stay complete. Seven rules are new: constructive modeling (`[T, ...T[]]`, pairs, start + duration instead of runtime guards), simplest total type, the narrowing hierarchy, type guards that must verify their own claim, boundary validation, schema-derived types (`z.infer`, `Pick<Generated, …>`), object args over positional, plus real-tests-over-mocks and structured telemetry.

`why` (`skills/shared/why`) is a code-archaeology skill: it anchors the question in `git blame` / `gh pr view`, enumerates the session's MCP servers, maps them to seven evidence categories (source control, tickets, docs, chat, observability, error tracking, analytics warehouse), fans out one investigator per category in parallel, and synthesizes a confidence-calibrated, fully cited answer with the gaps named. Ships with `references/epistemics.md`, `references/investigator-prompt.md`, and `references/synthesizer-prompt.md`.

Adds a **Credits** section to the README and an attribution convention to CLAUDE.md.
