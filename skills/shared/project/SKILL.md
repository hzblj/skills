---
name: project
description: Monorepo project structure — Turborepo layout with packages/core-*, packages/feature-*, and apps/platform-* (mobile/web/backend), dependency direction, package boundaries, public-API exports, and per-package internal structure. Use when creating packages/features/apps, wiring dependencies, or structuring a module. Triggers on: monorepo, turborepo, package, core-, feature-, platform-, app structure, index.ts, public API, deep import, dependency direction, workspace.
---

# Project Structure (Monorepo)

The repo is a Turborepo monorepo split into two workspaces: `packages/` holds the shared, versionless building blocks, and `apps/` holds the deployable platform apps. Everything lives in one of three package families — `core-*`, `feature-*`, or `apps/platform-*` — and each family has a fixed job and a fixed place in the dependency graph. Get the family and the direction right and the graph stays acyclic, features stay swappable, and a change to one feature can never ripple sideways into another.

Two rules hold the whole thing together: **dependencies only ever point downward** (`platform-* → feature-* → core-*`), and **every package is a black box** reached only through its published entry point. The rest of this file is those two rules plus the naming and internal-structure conventions that keep them enforceable.

```
packages/
  core-*/          foundation — reusable, platform-agnostic (core-ui, core-utils,
                   core-hooks, core-trpc, core-store, core-config, core-i18n, core-types …)
  feature-*/       product features — one capability each (feature-quidditch,
                   feature-sorting-hat, feature-auth …), sub-features via feature-x-y
apps/
  platform-mobile/    Expo / React Native app
  platform-web/       Next.js app
  platform-backend/   API / server
```

## Quick Reference

| Family | Location | Role | May depend on | Never depends on |
| --- | --- | --- | --- | --- |
| `core-*` | `packages/core-*` | Platform-agnostic foundation | other `core-*` only | `feature-*`, `platform-*` |
| `feature-*` | `packages/feature-*` | One self-contained product capability | `core-*`, its own sub-features | other features' internals, `platform-*` |
| `platform-*` | `apps/platform-*` | Deployable app; wires features together | `feature-*`, `core-*` | — (nothing depends on an app) |

## The Three Package Families

### `core-*` — the foundation

`core-*` packages are the reusable, **platform-agnostic** foundation the rest of the repo is built on: `core-ui`, `core-utils`, `core-hooks`, `core-trpc` (the API layer), `core-store`, `core-config`, `core-i18n`, `core-types`, `core-theme` / `core-tailwind-config`, `core-services`, and so on. They contain no product logic and no knowledge of any single feature — a `core-ui` `Button` doesn't know the Sorting Hat exists.

Core sits at the bottom of the graph. A core package **may build on other core packages** (`core-ui` can use `core-utils`), but it must never import a `feature-*` or a `platform-*` package. If a core package finds itself needing something from a feature, that thing was misplaced — it belongs in core, or the dependency is pointing the wrong way.

### `feature-*` — one product capability

A `feature-*` package is a single, self-contained product capability — `feature-auth`, `feature-quidditch`, `feature-sorting-hat` — composed out of `core-*` pieces. It owns its screens, its hooks, its local state, and its slice of the API surface, and it exposes a small public API for apps to mount.

Large features decompose into **sub-features** through naming, not nesting: `feature-project`, `feature-project-create`, `feature-project-create-detail`. A parent feature may depend on its own sub-features (`feature-project` → `feature-project-create`), but one feature must never reach into an *unrelated* feature's internals. If two features need to share code, that shared code moves **down into core** — it does not travel sideways.

### `apps/platform-*` — the deployable apps

The `platform-*` apps are the deployable targets, and the only place platform-specific code lives:

| App | Stack | Holds |
| --- | --- | --- |
| `platform-mobile` | Expo / React Native | native navigation, mobile shell, device APIs |
| `platform-web` | Next.js | routing/pages, web shell, SSR concerns |
| `platform-backend` | API / server | server entrypoint, deployment wiring |

An app is a **composition root**: it imports features, mounts them into routes/screens, and supplies platform wiring. It should be thin — mostly wiring, little logic. Nothing depends on an app; apps are the top of the graph and the leaves of the dependency tree.

## Dependency Direction (Strict)

Dependencies flow in exactly one direction:

```
platform-*  →  feature-*  →  core-*
```

- `core-*` never imports `feature-*` or `platform-*`.
- `feature-*` composes `core-*`; it never reaches into another feature's internals (only its own sub-features).
- `platform-*` composes `feature-*` and `core-*`.
- No circular dependencies, ever — not between packages, not between features.

```jsonc
// Bad — a core package reaching UP into a feature (arrow points the wrong way)
// packages/core-ui/package.json
{
  "name": "@logram/core-ui",
  "dependencies": {
    "@logram/feature-sorting-hat": "workspace:*", // core must not know features
    "@logram/core-utils": "workspace:*"
  }
}
```

```jsonc
// Good — the feature depends on core; core stays a pure foundation
// packages/feature-sorting-hat/package.json
{
  "name": "@logram/feature-sorting-hat",
  "dependencies": {
    "@logram/core-ui": "workspace:*",
    "@logram/core-hooks": "workspace:*",
    "@logram/core-utils": "workspace:*"
  }
}
```

If a feature needs logic from another feature, that is the signal to push the shared logic **down into `core-*`**, never to add a sideways `feature → feature` edge.

## Package Boundaries & Public API

Every package is a **black box**. It exposes its public API through a single entry point — its root `index.ts`, declared in `package.json` `exports` — and everything else is private. Consumers import from the **package name**, never from a file path inside it.

```jsonc
// packages/feature-quidditch/package.json — the entry point IS the public API
{
  "name": "@logram/feature-quidditch",
  "private": true,
  "type": "module",
  "exports": { ".": "./index.ts" }
}
```

```ts
// Bad — deep import reaches past the boundary into private internals
import { Snitch } from '@logram/feature-quidditch/src/components/Snitch/Snitch'
import { formatScore } from '@logram/core-utils/src/score/formatScore'
```

```ts
// Good — import from the package name; only what it chose to export is reachable
import { QuidditchPitch } from '@logram/feature-quidditch'
import { formatScore } from '@logram/core-utils'
```

A deep import is a boundary violation: it couples you to another package's internal layout, so any refactor there silently breaks you, and it lets you reach code the author never meant to publish. If you need something that isn't exported, add it to that package's `index.ts` on purpose — don't tunnel around the boundary.

## Naming Conventions

Package names are **kebab-case** and follow a fixed shape per family:

| Pattern | Example | Meaning |
| --- | --- | --- |
| `core-<domain>` | `core-ui`, `core-utils`, `core-trpc` | a foundation domain |
| `feature-<name>` | `feature-quidditch`, `feature-sorting-hat` | one product capability |
| `feature-<name>-<subfeature>` | `feature-project-create`, `feature-project-create-detail` | a sub-feature of a feature |
| `platform-<target>` | `platform-mobile`, `platform-web`, `platform-backend` | a deployable app |

The scoped workspace name mirrors the folder: `packages/feature-quidditch` publishes as `@logram/feature-quidditch`.

## Named Exports Only

**No default exports anywhere.** Always use named exports — for components, hooks, utilities, and types alike. Named exports keep the name stable across the codebase, make re-exporting from `index.ts` explicit, and let tooling find and rename symbols reliably.

```ts
// Bad — default export; the import name is a free-for-all and re-exports are fuzzy
export default function SortingHat() {}
import Hat from './SortingHat' // could be named anything
```

```ts
// Good — named export; one canonical name everywhere
export const SortingHat = () => {}
import { SortingHat } from './SortingHat'
```

## Inside a Package or Feature

The same structural discipline applies *within* a package. Each feature or component is a folder that behaves like a mini-package — a strict API boundary with its own `index.ts`.

- Each feature or component has its own folder.
- The main file name matches the feature/component name (`SortingHat/SortingHat.tsx`).
- Each folder has an `index.ts` that re-exports its public API.
- Treat each folder as a strict API boundary — do not import deep internal files from outside the folder.
- No cross-feature deep imports.
- No circular dependencies.
- Keep the structure flat and predictable.
- The only allowed internal subfolders are `components`, `hooks`, and `consts`.

```
packages/feature-sorting-hat/
  index.ts                    // export * from './src'
  package.json                // "exports": { ".": "./index.ts" }
  src/
    index.ts                  // re-exports the feature's public API
    SortingHat.tsx            // main file — matches the feature name
    SortingHatSkeleton.tsx
    components/               // internal building blocks
    hooks/                    // internal hooks
    consts/                   // internal constants
```

```ts
// packages/feature-sorting-hat/src/index.ts — the public API, made of named re-exports
export { SortingHat } from './SortingHat'
export { SortingHatSkeleton } from './SortingHatSkeleton'
```

```ts
// Bad — reaching into another feature's private file
import { HouseBadge } from '@logram/feature-quidditch/src/components/HouseBadge/HouseBadge'
```

```ts
// Good — go through the boundary; shared UI belongs in core anyway
import { HouseBadge } from '@logram/core-ui'
```

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| `core-*` importing a `feature-*` or `platform-*` | Reverse the arrow — move the shared code down into core |
| Sharing code by importing `feature-a` into `feature-b` | Extract the shared piece into a `core-*` package |
| Deep import into another package's internal file | Import from the package name; export it from that package's `index.ts` |
| Business logic living in a `platform-*` app | Push it into a `feature-*` (or `core-*`); apps only wire and mount |
| Default export | Named export everywhere |
| `PascalCase` / `camelCase` package name | kebab-case: `core-ui`, `feature-sorting-hat` |
| Nesting a sub-feature folder inside its parent | Make it a sibling package via `feature-x-y` naming |
| Folder without an `index.ts` boundary | Add `index.ts` re-exporting the public API |
| Internal subfolder other than `components`/`hooks`/`consts` | Flatten it into one of the three allowed subfolders |
| Circular dependency between packages/features | Break the cycle — extract the shared code down a layer |

## Review Checklist

- [ ] New code lives in the right family: foundation → `core-*`, one capability → `feature-*`, deployable/platform-specific → `apps/platform-*`.
- [ ] Dependencies only point downward: `platform-* → feature-* → core-*`; no sideways `feature → feature` edges and no cycles.
- [ ] `core-*` imports only other `core-*` — never a feature or app.
- [ ] All imports use the package name; no deep imports past any package's `index.ts`.
- [ ] Package/folder is reached only through its public `index.ts` / `exports`.
- [ ] Names are kebab-case and match their family pattern (`core-`, `feature-`, `feature-x-y`, `platform-`).
- [ ] Named exports only — no default exports.
- [ ] Each feature/component folder has an `index.ts`, a main file matching its name, and only `components`/`hooks`/`consts` subfolders.
