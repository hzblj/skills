---
"skills": minor
---

Ship through two install channels. Add `.claude-plugin/marketplace.json` (marketplace `hzblj`, plugin `hzblj-skills`) so the repo installs via `/plugin marketplace add hzblj/skills`, and enumerate all 33 skills explicitly in `plugin.json` so both the plugin loader and the [skills.sh](https://skills.sh/hzblj/skills) installer (`npx skills add hzblj/skills`) discover the deeply-nested skills that a default scan misses.

Move `agents/` and `commands/` to the repo root (the plugin-default locations) so they auto-load — custom `agents`/`commands` path arrays in `plugin.json` are silently ignored by the loader. Rename the plugin from `skills` to `hzblj-skills`. README documents both install paths; CLAUDE.md documents the discovery rules.
