---
"skills": patch
---

Fix the `compound-components` composer example to follow its own `state` / `actions` / `meta` convention: the reactive `isRevealed` flag moves from `actions.reveal` into `state`, `actions.reveal` keeps only the `show` / `hide` callbacks, and the `Provider` merges its internal UI state into the `state` bucket (props narrow to the caller-suppliable `Pick<WizardCardState, 'wizard'>`).
