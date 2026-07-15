# skills

## 1.3.0

### Minor Changes

- [`ac2cdc8`](https://github.com/hzblj/skills/commit/ac2cdc8c64471022470a40a98eef7ca0190bce18) - error-handling: cover returning `null` vs. empty collections vs. throwing — add a "Don't return `null`" section (empty array for lists, `T | undefined`/`requireX` for single values, don't pass `null`) and drop the out-of-scope note. Trim maintainer-only "Local development" and "Releasing" sections from the README.

## 1.2.0

### Minor Changes

- [#3](https://github.com/hzblj/skills/pull/3) [`ea0a67c`](https://github.com/hzblj/skills/commit/ea0a67c3e422627efb1adc16cec7d7ea35f374cc) Thanks [@hzblj](https://github.com/hzblj)! - Ship through two install channels. Add `.claude-plugin/marketplace.json` (marketplace `hzblj`, plugin `hzblj-skills`) so the repo installs via `/plugin marketplace add hzblj/skills`, and enumerate all 33 skills explicitly in `plugin.json` so both the plugin loader and the [skills.sh](https://skills.sh/hzblj/skills) installer (`npx skills add hzblj/skills`) discover the deeply-nested skills that a default scan misses.

  Move `agents/` and `commands/` to the repo root (the plugin-default locations) so they auto-load — custom `agents`/`commands` path arrays in `plugin.json` are silently ignored by the loader. Rename the plugin from `skills` to `hzblj-skills`. README documents both install paths; CLAUDE.md documents the discovery rules.

## 1.1.0

### Minor Changes

- [#1](https://github.com/hzblj/skills/pull/1) [`7a7c7f9`](https://github.com/hzblj/skills/commit/7a7c7f9c26b39e83432673559ef98b419e4c8b9f) Thanks [@hzblj](https://github.com/hzblj)! - Fix invalid YAML frontmatter in 25 `SKILL.md` files — inline `description:` values containing `: ` (from the "Triggers on:" convention) parsed as a mapping and failed to load; they are now block scalars.

  Restructure the `project` skill's monorepo model: `platform-*` is now a `packages/` family (platform-specific building blocks — native modules, RN UI, device APIs), apps are the bare deployables `mobile`/`web`/`backend`/`e2e`, and the dependency direction is `apps/* → feature-* → platform-* → core-*`. Example scope renamed `@logram` → `@hogwarts`. `monorepo-architect`, `audit-imports`, `new-feature`, and `CLAUDE.md` updated to match.

- [#1](https://github.com/hzblj/skills/pull/1) [`7a7c7f9`](https://github.com/hzblj/skills/commit/7a7c7f9c26b39e83432673559ef98b419e4c8b9f) Thanks [@hzblj](https://github.com/hzblj)! - Add a tiered model-orchestration layer. New `deep-reasoner` (Fable) and `fast-worker` (Haiku) agents, an `/orchestrate` command that plans then delegates across the tiers, and an `orchestration` skill documenting the routing rules and cost model. The build and review agents (`web-developer`, `mobile-developer`, `monorepo-architect`, `animation-specialist`, `code-refactorer`, `clean-code-reviewer`) are upgraded to Opus.

This changelog is managed by [Changesets](https://github.com/changesets/changesets).
Run `npm run changeset` to record a change; `npm run version` writes the entries below.
