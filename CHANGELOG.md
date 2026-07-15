# skills

## 1.1.0

### Minor Changes

- [#1](https://github.com/hzblj/skills/pull/1) [`7a7c7f9`](https://github.com/hzblj/skills/commit/7a7c7f9c26b39e83432673559ef98b419e4c8b9f) Thanks [@hzblj](https://github.com/hzblj)! - Fix invalid YAML frontmatter in 25 `SKILL.md` files — inline `description:` values containing `: ` (from the "Triggers on:" convention) parsed as a mapping and failed to load; they are now block scalars.

  Restructure the `project` skill's monorepo model: `platform-*` is now a `packages/` family (platform-specific building blocks — native modules, RN UI, device APIs), apps are the bare deployables `mobile`/`web`/`backend`/`e2e`, and the dependency direction is `apps/* → feature-* → platform-* → core-*`. Example scope renamed `@logram` → `@hogwarts`. `monorepo-architect`, `audit-imports`, `new-feature`, and `CLAUDE.md` updated to match.

- [#1](https://github.com/hzblj/skills/pull/1) [`7a7c7f9`](https://github.com/hzblj/skills/commit/7a7c7f9c26b39e83432673559ef98b419e4c8b9f) Thanks [@hzblj](https://github.com/hzblj)! - Add a tiered model-orchestration layer. New `deep-reasoner` (Fable) and `fast-worker` (Haiku) agents, an `/orchestrate` command that plans then delegates across the tiers, and an `orchestration` skill documenting the routing rules and cost model. The build and review agents (`web-developer`, `mobile-developer`, `monorepo-architect`, `animation-specialist`, `code-refactorer`, `clean-code-reviewer`) are upgraded to Opus.

This changelog is managed by [Changesets](https://github.com/changesets/changesets).
Run `npm run changeset` to record a change; `npm run version` writes the entries below.
