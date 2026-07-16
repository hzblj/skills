---
"skills": minor
---

Expand `type-safety` from a bullet list into a full skill: narrow string-literal and discriminated unions, exhaustive `switch` + `never` (`assertNever`) so extending a union becomes a compile error, composing complex types from small named pieces (with `Pick`/`Omit`/`Partial`/`Record`), deriving types from values (`as const` + `typeof`/`keyof`), `satisfies` vs a widening annotation, safe indexing under `noUncheckedIndexedAccess`, branded types, plus a Common Mistakes table and Review Checklist.

Add a new `compound-components` skill (`shared/ui`) documenting the compound/composer pattern: the context + throwing guard-hook, a memoized context value, the controlled/uncontrolled hybrid, why composition beats a wall of layout props, the `state` / `actions` / `meta` context convention (with `meta` holding refs and non-reactive handles), and exposing the `Provider` so the state source can be lifted all the way up to a global hook. Add a `/make-composer` command that refactors a prop-heavy component into a composer.

Fix invalid YAML frontmatter in 8 `SKILL.md` files whose inline `description:` values contained `: ` (from the "Triggers on:" convention) and parsed as a mapping — `type-safety`, `component-architecture`, `performance`, `hooks`, `nextjs-routing`, `tailwind`, `lists`, and `react-navigation` are now block scalars, matching the rest of the repo.
