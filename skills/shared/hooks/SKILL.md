---
name: hooks
description: Rules for custom hooks — naming, logic extraction, and separation of view and logic. Use when creating or refactoring hooks. Triggers on: custom hook, use prefix, extract logic into hook, separate view and logic, move state out of component.
---

# Hooks

- All custom hooks must start with `use`.
- When it improves readability, extract logic into a dedicated hook.
- Move state, effects, queries, and handlers out of the component into hooks when appropriate.
- Keep view and logic separated.
