---
name: component-architecture
description: Defines component structure, prop typing, responsibility separation, and ref handling patterns. Use when creating or refactoring React components.
---

# Component Architecture

- Define components using `FC` and explicit prop `type`.
- Never use `interface` for props.
- No implicit inline returns.
- Always use braces and explicit `return`.
- Prefer multiple small components over one large component.
- Split by responsibility, not file size.
- Components should focus on rendering.
- Business logic should live in hooks.
- API transformation logic should not live inside render files.

## Ref Handling

- Never pass `ref` via regular props.
- Always use `forwardRef` when exposing refs.
- Ref typing must be explicit.
- No optional ref hacks.
