---
name: hooks
description: Rules for custom hooks — naming, logic extraction, and separation of view and logic. Use when creating or refactoring hooks.
---

# Hooks

- All custom hooks must start with `use`.
- When it improves readability, extract logic into a dedicated hook.
- Move state, effects, queries, and handlers out of the component into hooks when appropriate.
- Keep view and logic separated.
