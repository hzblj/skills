<p>
  <a href="https://www.janblazej.dev/">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://www.janblazej.dev/png/ai-skills-dark.png">
      <source media="(prefers-color-scheme: light)" srcset="https://www.janblazej.dev/png/ai-skills.png">
      <img alt="AI Skills" src="https://www.janblazej.dev/png/ai-skills.png">
    </picture>
  </a>
</p>

# Skills For Real React/React Native Engineers

Skills for React/React Native Engineers. Straight from my `.claude` directory.

These are the skills I reach for **every day** — my own best practices, distilled
into small, composable `SKILL.md` files. They encode how I build a React and React
Native codebase that stays clean and scalable as it grows, with a heavy focus on
the three things I care about most:

- **Animations** that feel native and hold 60/120fps — GSAP on the web, Reanimated and Skia on mobile.
- **Components** that are well-structured, strictly typed, and genuinely reusable.
- **Clean code** — naming, small functions, comments, formatting, error handling — enforced, not merely suggested.

They're model-agnostic, opinionated, and meant to be forked. Every code example is
in TypeScript and themed around Harry Potter, because reading the same `foo`/`bar`
for the hundredth time is how skills die. Make them your own.

## Install

Two ways to install, two philosophies.

### Quickstart — [skills.sh](https://skills.sh/hzblj/skills)

Copies the skills into your project so you can hack on them and make them your own.
Works with Claude Code, Codex, Cursor, and any Agent-Skills-compatible harness:

```bash
npx skills@latest add hzblj/skills
```

Pick the skills you want and which agents to install them on.

### Claude Code plugin

Prefer a plug-and-play install you don't maintain by hand? These skills also ship as
a native [Claude Code plugin](https://code.claude.com/docs/en/plugins) — a read-only,
always-current bundle that updates when I ship a new version. You subscribe rather
than fork, and you get the [agents](#agents) and [commands](#commands) too.

Inside Claude Code:

```
/plugin marketplace add hzblj/skills
/plugin install hzblj-skills@hzblj
```

Or from your shell:

```bash
claude plugin marketplace add hzblj/skills
claude plugin install hzblj-skills@hzblj
```

- **[skills.sh](https://skills.sh/hzblj/skills)** copies the skills in so you can edit them — skills only.
- **The plugin** keeps them as a managed bundle you don't edit, and ships the agents and commands alongside the skills.

### Local development

Working on the skills themselves? Symlink every skill straight into your agent so a
`git pull` keeps them current:

```bash
corepack enable && yarn install
yarn link-skills   # → ~/.claude/skills and ~/.agents/skills
yarn list-skills   # see everything that's available
```

Or reference the skills you want directly from a project's `CLAUDE.md`.

## How I use them

I don't invoke skills by hand much — I describe the task, and the agent reaches for
the right ones. These are the prompts I actually type, and the skills each one pulls
in:

**Implement this design from Figma.**

```
Implement this design from Figma.
@https://www.figma.com/design/AbC123DeF456/My-Screen?node-id=12-345&m=dev
```

→ [component-architecture](./skills/shared/ui/component-architecture/SKILL.md) ·
[surfaces](./skills/shared/ui/surfaces/SKILL.md) ·
[typography](./skills/shared/ui/typography/SKILL.md) ·
[interactions](./skills/shared/ui/interactions/SKILL.md) ·
[css-animations](./skills/web/animations/css/SKILL.md) ·
[tailwind](./skills/web/styling/tailwind/SKILL.md) ·
[type-safety](./skills/shared/type-safety/SKILL.md)

**Build a hero where the headline reveals on scroll and the image pins.**

→ [gsap-timelines](./skills/web/animations/gsap/timelines/SKILL.md) ·
[gsap-scroll-trigger](./skills/web/animations/gsap/scroll-trigger/SKILL.md) ·
[gsap-text](./skills/web/animations/gsap/text/SKILL.md) ·
[gsap-react](./skills/web/animations/gsap/react/SKILL.md) ·
[motion](./skills/shared/ui/motion/SKILL.md)

**This feed is janky on mobile — make it 60fps.**

→ [lists](./skills/mobile/ui/lists/SKILL.md) ·
[reanimated-core](./skills/mobile/animations/reanimated/core/SKILL.md) ·
[reanimated-timing](./skills/mobile/animations/reanimated/timing/SKILL.md) ·
[native-feel](./skills/mobile/styling/native-feel/SKILL.md)

**A swipeable card stack with a spring snap-back.**

→ [reanimated-gestures](./skills/mobile/animations/reanimated/gestures/SKILL.md) ·
[reanimated-core](./skills/mobile/animations/reanimated/core/SKILL.md) ·
[reanimated-timing](./skills/mobile/animations/reanimated/timing/SKILL.md)

**Review my changes before I open the PR.** — `/clean-review`

→ [clean-code-reviewer](./agents/agent-clean-code-reviewer.md) over
[functions](./skills/shared/clean-code/functions/SKILL.md) ·
[meaningful-names](./skills/shared/clean-code/meaningful-names/SKILL.md) ·
[error-handling](./skills/shared/clean-code/error-handling/SKILL.md)

**Refactor this file to my standards.** — `/refactor <path>`

→ [code-refactorer](./agents/agent-code-refactorer.md) — `const` arrows,
named exports, guard clauses, `cn()`, `type` over `interface`

**Scaffold a new feature package.** — `/new-feature <name>`

→ [monorepo-architect](./agents/agent-monorepo-architect.md) +
[project](./skills/shared/project/SKILL.md)

## Skills

Each skill is a self-contained `SKILL.md`. Related skills are grouped into category
folders; there are no umbrella files, so you can enable exactly what you want.

### Shared — both platforms

**Clean code** — the standards I enforce for readable, maintainable code, with Harry Potter examples:

- [meaningful-names](./skills/shared/clean-code/meaningful-names/SKILL.md) — intention-revealing names, boolean prefixes, UPPERCASE constants, no type encoding
- [functions](./skills/shared/clean-code/functions/SKILL.md) — small, do one thing, few arguments, guard clauses, command-query, DRY
- [comments](./skills/shared/clean-code/comments/SKILL.md) — why over how, no dead comments, self-explaining code
- [formatting](./skills/shared/clean-code/formatting/SKILL.md) — vertical ordering (stepdown), declare near use, `cn()` classNames
- [objects-and-data](./skills/shared/clean-code/objects-and-data/SKILL.md) — Tell Don't Ask, Law of Demeter, objects vs. data, contract-first
- [error-handling](./skills/shared/clean-code/error-handling/SKILL.md) — exceptions over error codes, wrap third-party APIs, no catch-as-if

**UI** — components, architecture, and cross-platform design-engineering polish:

- [component-architecture](./skills/shared/ui/component-architecture/SKILL.md) — component structure, prop typing, responsibility separation
- [performance](./skills/shared/ui/performance/SKILL.md) — memoization, stable references, re-render prevention
- [typography](./skills/shared/ui/typography/SKILL.md) — text wrapping, font smoothing, tabular numbers, Dynamic Type
- [surfaces](./skills/shared/ui/surfaces/SKILL.md) — concentric radius, optical alignment, shadows/elevation, hit areas
- [motion](./skills/shared/ui/motion/SKILL.md) — interruptible animations, stagger enter, subtle exit, icon cross-fade
- [interactions](./skills/shared/ui/interactions/SKILL.md) — press feedback (scale 0.96), haptics, hover, focus, hit area

**Foundations:**

- [hooks](./skills/shared/hooks/SKILL.md) — custom hooks: naming, logic extraction, view/logic separation
- [type-safety](./skills/shared/type-safety/SKILL.md) — strict TypeScript: `type` over `interface`, no `any`, no `enum`, narrow types
- [project](./skills/shared/project/SKILL.md) — Turborepo monorepo: `core-*`/`feature-*` packages, `platform-*` apps, dependency direction

### Mobile — React Native / Expo

**Reanimated (3/4):**

- [reanimated-core](./skills/mobile/animations/reanimated/core/SKILL.md) — shared values, animated styles, worklets, UI vs. JS thread
- [reanimated-layout-animations](./skills/mobile/animations/reanimated/layout-animations/SKILL.md) — entering/exiting, layout transitions, keyframes
- [reanimated-gestures](./skills/mobile/animations/reanimated/gestures/SKILL.md) — gesture-handler v2, pan/swipe/pinch, withDecay, composition
- [reanimated-timing](./skills/mobile/animations/reanimated/timing/SKILL.md) — withTiming/withSpring/withDecay, easing, reduced motion
- [reanimated-text-and-numbers](./skills/mobile/animations/reanimated/text-and-numbers/SKILL.md) — animated counters, ReText, per-character reveals

**Also:**

- [skia](./skills/mobile/animations/skia/SKILL.md) — Canvas API, SkSL shaders, charts, GPU-driven drawing
- [lists](./skills/mobile/ui/lists/SKILL.md) — FlashList, stable renderItem, extracted item components
- [native-feel](./skills/mobile/styling/native-feel/SKILL.md) — iOS/Android conventions, haptics, safe areas, accessibility
- [react-navigation](./skills/mobile/navigation/react-navigation/SKILL.md) — typed routes, navigator structure, deep linking

### Web — Next.js / React

**Animations** — plain CSS by default, GSAP when you need a timeline:

- [css-animations](./skills/web/animations/css/SKILL.md) — pure-CSS transitions & keyframes, staggered enter, icon cross-fade, scale-on-press

**GSAP (3):**

- [gsap-timelines](./skills/web/animations/gsap/timelines/SKILL.md) — sequencing, stagger, labels, control methods
- [gsap-scroll-trigger](./skills/web/animations/gsap/scroll-trigger/SKILL.md) — scrub, pin, toggleActions, batch, matchMedia
- [gsap-text](./skills/web/animations/gsap/text/SKILL.md) — SplitText reveals, line masking, font readiness, a11y revert
- [gsap-react](./skills/web/animations/gsap/react/SKILL.md) — useGSAP, scope, contextSafe, cleanup, SSR
- [gsap-performance](./skills/web/animations/gsap/performance/SKILL.md) — transform/opacity, will-change, reduced motion

**Also:**

- [tailwind](./skills/web/styling/tailwind/SKILL.md) — utility-first, class ordering, dark mode, `cn()`
- [nextjs-routing](./skills/web/navigation/nextjs-routing/SKILL.md) — App Router, server/client components, dynamic routes, metadata

## Agents

Custom subagents in [`agents/`](./agents):

- [animation-specialist](./agents/agent-animation-specialist.md) — motion across web + mobile (GSAP, Reanimated, Skia, gestures)
- [clean-code-reviewer](./agents/agent-clean-code-reviewer.md) — read-only review against clean-code + type-safety; Before/After findings
- [code-refactorer](./agents/agent-code-refactorer.md) — applies the clean-code standards to existing code, preserving behavior
- [monorepo-architect](./agents/agent-monorepo-architect.md) — scaffolds/enforces the Turborepo monorepo
- [mobile-developer](./agents/agent-mobile-developer.md) — senior React Native + Expo engineer
- [web-developer](./agents/agent-web-developer.md) — senior Next.js + React engineer

## Commands

Slash commands in [`commands/`](./commands):

- [`/clean-review`](./commands/clean-review.md) — review the current diff against clean-code + type-safety
- [`/refactor <path>`](./commands/refactor.md) — refactor a file to the standards
- [`/new-feature <name>`](./commands/new-feature.md) — scaffold a `feature-*` package
- [`/new-component <Name>`](./commands/new-component.md) — scaffold a component
- [`/polish <path>`](./commands/polish.md) — interface-polish pass
- [`/audit-imports`](./commands/audit-imports.md) — audit monorepo boundaries

## Releasing

Changelogs are automated with [Changesets](https://github.com/changesets/changesets):

```bash
yarn changeset            # describe the change (bump + summary)
yarn changeset:version    # apply pending changesets → updates CHANGELOG.md
```

## License

[MIT](./LICENSE) © Jan Blazej
