---
"skills": minor
---

Add an `atomic-design` skill (`shared/ui`) for structuring the `core-ui` library as atoms / molecules / organisms / templates, with composition flowing one way (higher composes lower, never the reverse). Documents which level a component belongs to, the file/folder conventions (kebab-case files, co-located stories, single `index.ts` public API), and — the key policy — **promotion on the second use**: obvious primitives (`Button`, `Input`) go straight into `core-ui/atoms`, but a feature-specific component stays local to its feature until a second place needs it, at which point it's promoted *down* into `core-ui` and generalized rather than copied or cross-imported. Complements the `project` skill (the package graph) and `component-architecture` (a single component's internals).
