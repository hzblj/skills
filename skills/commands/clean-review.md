---
description: Review the current git diff against the repo's clean-code + type-safety standards
argument-hint: [optional path to scope the review]
allowed-tools: Bash(git diff:*), Bash(git status:*), Read, Grep, Glob
---

Review the changes below against this repo's clean-code standards. Use the skills as the rubric: `meaningful-names`, `functions`, `comments`, `formatting`, `objects-and-data`, `error-handling`, and `type-safety` — plus the repo conventions: **`const` arrow functions** (never `function`), **named exports only**, **guard clauses / early returns**, **`cn()` for conditional classNames**, and **`type` over `interface`**.

Current status:
!`git status --short`

Diff:
!`git diff HEAD`

If `$ARGUMENTS` names a path, focus the review there.

Report findings as markdown **Before / After** tables, grouped by principle under a heading, **most-severe first** (correctness and error-handling before style). Cite `file:line` in each row and show the concrete fix. Omit principles with no findings. End with a one-line verdict (e.g. "2 must-fix, 4 nits"). Do not edit any files — this is a review.
