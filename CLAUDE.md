# CLAUDE.md

Guidance for working in this repo. This is **not** an app — it is a collection of
Claude Code **skills**, **agents**, and **commands** for building React and React
Native (Expo) apps in TypeScript. The deliverable is documentation quality, not
runtime code.

## Layout

```
skills/          # All plugin components
  agents/        # Custom subagents (agent-*.md)
  commands/      # Slash commands (one .md per command)
  shared/        # both platforms — clean-code/, ui/, hooks/, project/, type-safety/
  mobile/        # React Native / Expo — animations/, ui/, navigation/, styling/
  web/           # Next.js / React — animations/, navigation/, styling/
.claude-plugin/  # plugin.json manifest — points agents/commands into skills/
scripts/         # link-skills.sh, list-skills.sh
.changeset/      # Changesets config (auto changelog)
```

Because `agents/` and `commands/` live under `skills/` (not the default plugin
roots), `.claude-plugin/plugin.json` declares their paths so Claude Code still
discovers them.

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

Consumers' apps use a Turborepo layout: `packages/core-*` (platform-agnostic
foundation) → `packages/feature-*` (product features) → `apps/platform-*`
(`platform-mobile` Expo/RN, `platform-web` Next.js, `platform-backend`).
Dependency direction is strict: `platform-* → feature-* → core-*`, never the
reverse; import only from a package's public entry, never a deep path.

## Adding things

- **New skill:** create `skills/<platform>/<category>/<name>/SKILL.md` with
  frontmatter + the house style above. Keep it a leaf.
- **New agent:** `skills/agents/agent-<name>.md` with `name`, `description` (with
  `<example>` blocks), `tools`, `model`. Match the existing agents' shape.
- **New command:** `skills/commands/<name>.md` with `description` (+ optional
  `argument-hint`, `allowed-tools`), then the prompt body using `$ARGUMENTS`.
  Reference skills by **name** so they load when installed as a plugin.

## Housekeeping

- Verify cross-links resolve and `name`s stay unique after any restructure.
- After adding, removing, or renaming a skill, run `yarn readmes` to regenerate the
  per-folder `README.md` indexes ([scripts/gen-readmes.mjs](./scripts/gen-readmes.mjs)).
- Changelog is automated with Changesets: `yarn changeset` to record a change,
  `yarn changeset:version` to apply it. See [.changeset/README.md](.changeset/README.md).
- `yarn link-skills` symlinks every skill into `~/.claude/skills` for local use.
