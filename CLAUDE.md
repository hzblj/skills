# CLAUDE.md

Guidance for working in this repo. This is **not** an app — it is a collection of
Claude Code **skills**, **agents**, and **commands** for building React and React
Native (Expo) apps in TypeScript. The deliverable is documentation quality, not
runtime code.

## Layout

```
skills/          # Leaf skills, organized by platform/category (see below)
  shared/        # both platforms — clean-code/, ui/, hooks/, project/, type-safety/
  mobile/        # React Native / Expo — animations/, ui/, navigation/, styling/
  web/           # Next.js / React — animations/, navigation/, styling/
agents/          # Custom subagents (agent-*.md) — plugin-root default location
commands/        # Slash commands (one .md per command) — plugin-root default location
.claude-plugin/  # plugin.json (component manifest) + marketplace.json (catalog)
scripts/         # gen-readmes.mjs, link-skills.sh, list-skills.sh
.changeset/      # Changesets config (auto changelog)
```

## Distribution — how the two install channels discover components

This repo ships both as a **[skills.sh](https://skills.sh/hzblj/skills)** source
(`npx skills add hzblj/skills`) and as a native **Claude Code plugin / marketplace**
(`/plugin marketplace add hzblj/skills`). Two rules make discovery work for both:

- **Skills are enumerated explicitly** in `plugin.json`'s `skills` array. The skills
  nest 3–4 levels deep (`skills/mobile/animations/reanimated/core/`), but the default
  `skills/` scan and skills.sh's catalog scan only look ~1–2 levels down, so a bare
  scan silently misses most of them. The explicit list is depth-proof, and skills.sh
  reads it from the manifest. **Every new skill MUST be added to this array** or it
  won't ship.
- **Agents and commands use the plugin-root default directories** `agents/` and
  `commands/`. Custom `agents`/`commands` path arrays in `plugin.json` are silently
  ignored by the plugin loader (verified on Claude Code 2.1.x), so these live at the
  repo root and are auto-discovered — no manifest entry, and none needed. Keep them
  free of stray `.md` files: **every `.md` in `agents/`/`commands/` loads as a
  component**, so there are no `README.md` index files in those two folders (unlike
  the `skills/` tree, where per-folder READMEs are harmless).

`.claude-plugin/marketplace.json` is the catalog: one plugin entry (`hzblj-skills`,
`source: "./"`) pointing at this repo. Marketplace name `hzblj`, plugin name
`hzblj-skills` — both are public-facing and break existing installs if renamed.

## Skill authoring conventions

- **One folder = one skill = one `SKILL.md`.** Leaf skills only; group related
  skills into a category folder (e.g. `clean-code/`, `animations/gsap/`). There are
  **no hub/umbrella `SKILL.md` files** — every `SKILL.md` is a real, standalone
  skill so consumers can enable exactly what they want.
- **Frontmatter** on every `SKILL.md`:
  ```md
  ---
  name: kebab-case-unique-name
  description: What it covers + when to use it, ending with "Triggers on: <keywords>".
  ---
  ```
  `name` must be unique across the whole repo (prefix where a bare word would
  collide or be too generic, e.g. `gsap-timelines`, `reanimated-core`, `ui-motion`).
- **House style:** comparison tables, `// Good` / `// Bad` labelled TypeScript
  blocks, "when to use which" tables, a **Common Mistakes** table, and a **Review
  Checklist** where it fits. Be opinionated — give exact values, not hedges.
- **Examples use the Harry Potter theme** (wizards, houses, spells, potions,
  Quidditch, Hogwarts) — matching the rest of the repo. No `foo`/`bar`.
- **Cross-link** sibling skills with relative links: `[name](../sibling/SKILL.md)`.

## Code standard (enforced by the `clean-code` skills)

All code examples — and any code you write — follow these:

- **`const` arrow functions**, never the `function` keyword.
- **Named exports only** — no default exports.
- **`type` over `interface`**, no `any`, no `enum`, narrow string-literal unions;
  explicit prop types (never inline in the signature).
- **Guard clauses / early returns**; keep the happy path flat at the bottom. No
  nested ternaries, no clever one-liners.
- **Meaningful names** — intention-revealing, boolean prefixes (`is`/`has`/
  `should`/`can`/`are`), `UPPER_SNAKE_CASE` constants, no magic numbers.
- **`cn()`** for conditional classNames — never template-literal concatenation.
- Small functions that do one thing; command-query separation; Tell, Don't Ask.

## Monorepo model (`skills/shared/project`)

Consumers' apps use a Turborepo layout: `packages/` holds `core-*` (platform-
agnostic foundation), `platform-*` (platform-specific building blocks — native
modules, RN UI, device APIs), and `feature-*` (product features); `apps/` holds
the deployables (`mobile` Expo/RN, `web` Next.js, `backend`, `e2e`). Dependency
direction is strict: `apps/* → feature-* → platform-* → core-*`, never the
reverse; import only from a package's public entry, never a deep path.

## Adding things

- **New skill:** create `skills/<platform>/<category>/<name>/SKILL.md` with
  frontmatter + the house style above. Keep it a leaf. **Then add its directory path
  to the `skills` array in [`.claude-plugin/plugin.json`](./.claude-plugin/plugin.json)**
  — otherwise it won't ship via the plugin or skills.sh (see Distribution above).
- **New agent:** `agents/agent-<name>.md` (repo root) with `name`, `description` (with
  `<example>` blocks), `tools`, `model`. Match the existing agents' shape. Auto-loaded
  from `agents/` — no manifest entry. Don't drop a `README.md` in this folder.
- **New command:** `commands/<name>.md` (repo root) with `description` (+ optional
  `argument-hint`, `allowed-tools`), then the prompt body using `$ARGUMENTS`.
  Reference skills by **name** so they load when installed as a plugin. Auto-loaded
  from `commands/` — no manifest entry. Don't drop a `README.md` in this folder.

## Housekeeping

- Verify cross-links resolve and `name`s stay unique after any restructure.
- Keep `plugin.json`'s `skills` array in sync with the `skills/` tree, then run
  `claude plugin validate .` to check both manifests before pushing.
- After adding, removing, or renaming a skill, run `yarn readmes` to regenerate the
  per-folder `README.md` indexes ([scripts/gen-readmes.mjs](./scripts/gen-readmes.mjs)).
  It walks `skills/` only, so it never touches `agents/`/`commands/`.
- Changelog is automated with Changesets: `yarn changeset` to record a change,
  `yarn changeset:version` to apply it. See [.changeset/README.md](.changeset/README.md).
- `yarn link-skills` symlinks every skill into `~/.claude/skills` for local use.
