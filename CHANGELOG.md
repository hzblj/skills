# skills

## 1.7.1

### Patch Changes

- [#24](https://github.com/hzblj/skills/pull/24) [`1aa7d5f`](https://github.com/hzblj/skills/commit/1aa7d5f67813e5578c4f7a1082c063c1f03a853e) Thanks [@hzblj](https://github.com/hzblj)! - `vendor-skills.sh` now rewrites cross-links in every markdown file of a vendored skill, not just its `SKILL.md`. A link from `references/patterns.md` to a sibling skill was left pointing at the repo's nested layout and dangled in the flattened destination. Files in a skill's subfolder also get one extra `../` so the rewritten path resolves from their own depth.

## 1.7.0

### Minor Changes

- [#22](https://github.com/hzblj/skills/pull/22) [`1b45c4f`](https://github.com/hzblj/skills/commit/1b45c4fcbf63eb31bcf33bbcbfa5241c10265cac) Thanks [@hzblj](https://github.com/hzblj)! - Add the `how` skill (`skills/shared/how`), taken verbatim from [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack/skills/how) (MIT), together with its four `references/` prompt templates. It answers "how does X work": parallel explorers map a subsystem, an explainer turns that into an onboarding-level mental model, and an optional critique mode spawns independent architectural critics. It is the companion `teach` calls alongside `why`.

  The subagent config is retargeted from Cursor's agent types and model ids to Claude Code's: explorers run as the built-in read-only `Explore` agent, the explainer and synthesizer run as `deep-reasoner` on Fable, and the critique panel is `fable` / `opus` / `sonnet` on `general-purpose`. Cursor's `readonly` flag has no Claude Code equivalent, so the read-only posture is stated in the prompt instead. Everything else, including the four `references/` prompts, is verbatim.

  `scripts/gen-openai-yaml.mjs` and `scripts/gen-readmes.mjs` now unescape backslash escapes inside a double-quoted YAML `description:` scalar.

- [#22](https://github.com/hzblj/skills/pull/22) [`1b45c4f`](https://github.com/hzblj/skills/commit/1b45c4fcbf63eb31bcf33bbcbfa5241c10265cac) Thanks [@hzblj](https://github.com/hzblj)! - Add the `teach` skill (`skills/shared/teach`), taken verbatim from [cursor/plugins](https://github.com/cursor/plugins/tree/main/pstack/skills/teach) (MIT). It explains a change or subsystem so it actually lands: pick the few things the reader should walk away with, let `why` do the digging, start with a plain definition, and build diagrams up one part at a time instead of dropping one crowded picture at the end. It is user-invoked only (`disable-model-invocation: true`).

  `scripts/gen-openai-yaml.mjs` and `scripts/gen-readmes.mjs` now strip the quotes from a quoted YAML `description:` scalar, and the OpenAI config honours `disable-model-invocation` by emitting `allow_implicit_invocation: false`.

- [#22](https://github.com/hzblj/skills/pull/22) [`1b45c4f`](https://github.com/hzblj/skills/commit/1b45c4fcbf63eb31bcf33bbcbfa5241c10265cac) Thanks [@hzblj](https://github.com/hzblj)! - Add the `unslop` skill (`skills/shared/unslop`): a writing pass that strips AI tells from prose and puts a human voice back in. Covers puffery, AI vocabulary, em dashes and connector colons, inline-header lists, chatbot artifacts, filler, abstract-metaphor jargon, and plain-speech rules (active voice, no adverb crutches, say what it does instead of how it feels), plus a common-mistakes table for over-correcting and a review checklist. Applies to READMEs, docs, commit messages, PR descriptions, and changelog entries.

- [#22](https://github.com/hzblj/skills/pull/22) [`1b45c4f`](https://github.com/hzblj/skills/commit/1b45c4fcbf63eb31bcf33bbcbfa5241c10265cac) Thanks [@hzblj](https://github.com/hzblj)! - Restructure `type-safety` and add the `why` skill, both adapted from [cursor/plugins](https://github.com/cursor/plugins) `pstack` (MIT).

  `type-safety` splits into a thin `SKILL.md` (22-row rule table + review checklist) and `references/patterns.md` holding every worked `// Good` / `// Bad` example, so the loaded context stays small and the examples stay complete. Seven rules are new: constructive modeling (`[T, ...T[]]`, pairs, start + duration instead of runtime guards), simplest total type, the narrowing hierarchy, type guards that must verify their own claim, boundary validation, schema-derived types (`z.infer`, `Pick<Generated, …>`), object args over positional, plus real-tests-over-mocks and structured telemetry.

  `why` (`skills/shared/why`) is a code-archaeology skill: it anchors the question in `git blame` / `gh pr view`, enumerates the session's MCP servers, maps them to seven evidence categories (source control, tickets, docs, chat, observability, error tracking, analytics warehouse), fans out one investigator per category in parallel, and synthesizes a confidence-calibrated, fully cited answer with the gaps named. Ships with `references/epistemics.md`, `references/investigator-prompt.md`, and `references/synthesizer-prompt.md`.

  Adds a **Credits** section to the README and an attribution convention to CLAUDE.md.

## 1.6.2

### Patch Changes

- [`127d78b`](https://github.com/hzblj/skills/commit/127d78bcbba2a2b936b27e4bd235f8eed1d8e207) - Fix the `compound-components` composer example to follow its own `state` / `actions` / `meta` convention: the reactive `isRevealed` flag moves from `actions.reveal` into `state`, `actions.reveal` keeps only the `show` / `hide` callbacks, and the `Provider` merges its internal UI state into the `state` bucket (props narrow to the caller-suppliable `Pick<WizardCardState, 'wizard'>`).

## 1.6.1

### Patch Changes

- [#18](https://github.com/hzblj/skills/pull/18) [`094d476`](https://github.com/hzblj/skills/commit/094d4763d4e1b96bb7301f5d91f99682b5078357) Thanks [@hzblj](https://github.com/hzblj)! - Keep `.claude-plugin/plugin.json`'s `version` in sync with `package.json`. Changesets only bumps `package.json`, so the plugin manifest's version — the one `/plugin` users see — had drifted (stuck at `1.0.0` while the package was `1.6.0`). Add `scripts/sync-plugin-version.mjs`, wire it into `changeset:version` (so every release, local and in CI, updates the manifest automatically), and bump the manifest to the current version. The manifest's `version` is now derived — never hand-edited.

## 1.6.0

### Minor Changes

- [#16](https://github.com/hzblj/skills/pull/16) [`5f9b610`](https://github.com/hzblj/skills/commit/5f9b610675dab1c3f4d13ab613ca6ffd81fc45de) Thanks [@hzblj](https://github.com/hzblj)! - Add an `atomic-design` skill (`shared/ui`) for structuring the `core-ui` library as atoms / molecules / organisms / templates, with composition flowing one way (higher composes lower, never the reverse). Documents which level a component belongs to, the file/folder conventions (kebab-case files, co-located stories, single `index.ts` public API), and — the key policy — **promotion on the second use**: obvious primitives (`Button`, `Input`) go straight into `core-ui/atoms`, but a feature-specific component stays local to its feature until a second place needs it, at which point it's promoted _down_ into `core-ui` and generalized rather than copied or cross-imported. Complements the `project` skill (the package graph) and `component-architecture` (a single component's internals).

## 1.5.0

### Minor Changes

- [#12](https://github.com/hzblj/skills/pull/12) [`698d3ee`](https://github.com/hzblj/skills/commit/698d3ee7366c2c6e77128cec8bbed3e78ec3449d) Thanks [@hzblj](https://github.com/hzblj)! - Drop all `framer-motion` / `motion/react` usage from the UI skills — the web animation stack is CSS/Tailwind (state transitions) and GSAP (sequenced/staggered/exit motion), with Reanimated on mobile. In `ui-motion`, the staggered-enter and exit examples are now GSAP, the icon cross-fade is the CSS-only version (no `<motion.span>`/`<AnimatePresence>`), and the icon timing spec is stated platform-neutrally. In `ui-interactions`, press feedback drops the `<motion.button whileTap>` equivalent (Tailwind `active:scale-[0.96]` is the web way), and skip-animation-on-first-load is reframed around CSS transitions not replaying plus gating one-shot GSAP enters behind a mounted ref.

- [#15](https://github.com/hzblj/skills/pull/15) [`7c5373a`](https://github.com/hzblj/skills/commit/7c5373a97cbf94a91b0242c165bb256c1d3e7e34) Thanks [@hzblj](https://github.com/hzblj)! - Rework the `tailwind` skill into the house style and make it the authoritative home for `cn()`. New guidance: style against **semantic theme tokens** (`bg-surface`, `text-foreground`) defined as CSS variables and flipped once for dark mode, instead of scattering `bg-white … dark:bg-neutral-900` pairs across every element; express component variants with **`tv()`** (tailwind-variants) — `base`/`variants`/`defaultVariants`/`compoundVariants`, typed via `VariantProps` — rather than hand-rolled `cn()` chains; and a full `cn()` section covering twMerge conflict resolution (last-wins, so `className` props can override). Plus no-arbitrary-values, `size-*`, `group`/`peer`, `data-*` variants, avoiding `@apply`, and letting `prettier-plugin-tailwindcss` order classes. A Common Mistakes table and Review Checklist round it out.

  The `formatting` skill's `cn()` section is trimmed to the string-hygiene rule and now cross-links `tailwind` for the Tailwind-specific depth (twMerge, `tv()`).

### Patch Changes

- [#13](https://github.com/hzblj/skills/pull/13) [`9f37ee7`](https://github.com/hzblj/skills/commit/9f37ee715698738ac46402384370c9721861b6a8) Thanks [@hzblj](https://github.com/hzblj)! - Make the README's `interactions` catalog line general — drop the specific "(scale 0.96)" value from the one-line index (the exact value stays in the skill itself).

## 1.4.1

### Patch Changes

- [#10](https://github.com/hzblj/skills/pull/10) [`650a2f3`](https://github.com/hzblj/skills/commit/650a2f389124e11a4ff126d6dabd136218e75d46) Thanks [@hzblj](https://github.com/hzblj)! - Sync the root README catalog with the repo. Add the `compound-components` skill to the UI list, the missing `deep-reasoner` and `fast-worker` agents to the Agents list, and the `/make-composer` and `/orchestrate` commands to the Commands list — so all 8 agents and 8 commands are documented. (The per-folder README indexes are generated by `gen-readmes.mjs`, but the root README's hand-curated catalog is not, and `agents/`/`commands/` intentionally have no README files since every `.md` there loads as a component.)

## 1.4.0

### Minor Changes

- [#8](https://github.com/hzblj/skills/pull/8) [`3e5e533`](https://github.com/hzblj/skills/commit/3e5e53305a3f2c2026a537718281ae32ef1922cb) Thanks [@hzblj](https://github.com/hzblj)! - Expand `type-safety` from a bullet list into a full skill: narrow string-literal and discriminated unions, exhaustive `switch` + `never` (`assertNever`) so extending a union becomes a compile error, composing complex types from small named pieces (with `Pick`/`Omit`/`Partial`/`Record`), deriving types from values (`as const` + `typeof`/`keyof`), `satisfies` vs a widening annotation, safe indexing under `noUncheckedIndexedAccess`, branded types, plus a Common Mistakes table and Review Checklist.

  Add a new `compound-components` skill (`shared/ui`) documenting the compound/composer pattern: the context + throwing guard-hook, a memoized context value, the controlled/uncontrolled hybrid, why composition beats a wall of layout props, the `state` / `actions` / `meta` context convention (with `meta` holding refs and non-reactive handles), and exposing the `Provider` so the state source can be lifted all the way up to a global hook. Add a `/make-composer` command that refactors a prop-heavy component into a composer.

  Fix invalid YAML frontmatter in 8 `SKILL.md` files whose inline `description:` values contained `: ` (from the "Triggers on:" convention) and parsed as a mapping — `type-safety`, `component-architecture`, `performance`, `hooks`, `nextjs-routing`, `tailwind`, `lists`, and `react-navigation` are now block scalars, matching the rest of the repo.

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
