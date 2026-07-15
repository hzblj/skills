---
"skills": minor
---

Fix invalid YAML frontmatter in 25 `SKILL.md` files — inline `description:` values containing `: ` (from the "Triggers on:" convention) parsed as a mapping and failed to load; they are now block scalars.

Restructure the `project` skill's monorepo model: `platform-*` is now a `packages/` family (platform-specific building blocks — native modules, RN UI, device APIs), apps are the bare deployables `mobile`/`web`/`backend`/`e2e`, and the dependency direction is `apps/* → feature-* → platform-* → core-*`. Example scope renamed `@logram` → `@hogwarts`. `monorepo-architect`, `audit-imports`, `new-feature`, and `CLAUDE.md` updated to match.
