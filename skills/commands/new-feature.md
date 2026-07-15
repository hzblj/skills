---
description: Scaffold a new feature-* package following the project (monorepo) skill
argument-hint: <feature-name>
---

Scaffold a new **`feature-$ARGUMENTS`** package following the `project` skill (Turborepo monorepo).

First read the workspace root (`package.json`, `turbo.json`, `pnpm-workspace.yaml` / workspaces) to learn the scope and package manager. If the scope or target location is ambiguous, ask before creating files.

Then create:
- `packages/feature-$ARGUMENTS/` with a `package.json` named `@<scope>/feature-$ARGUMENTS`, `exports` pointing at the entry.
- `index.ts` re-exporting only the public API.
- The allowed internal subfolders as needed: `components`, `hooks`, `consts` — each feature/component in its own folder with a name-matched main file and its own `index.ts` re-export.

Follow the standards: **named exports only**, **`const` arrow functions**, **`type` over `interface`**. Respect dependency direction — a feature may depend on `core-*` packages, **never** on another feature's internals or on `platform-*`. Wire the new package into the workspace and confirm it builds/typechecks.
