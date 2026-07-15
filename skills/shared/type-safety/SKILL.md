---
name: type-safety
description: Enforces strict TypeScript typing — use type over interface, no any, no enum, narrow types. Use when defining types or reviewing type safety.
---

# Type Safety (Strict)

- Use `type` instead of `interface` everywhere.
- Do not introduce `interface`.
- Do not use `enum`.
- Use descriptive string literal union types.
- No `any`.
- No `as unknown as`.
- Avoid overly generic types.
- Prefer narrow types over broad types.
- Props must use explicit `type`.
- Do not inline prop types inside component definitions.

```ts
type House = 'gryffindor' | 'slytherin' | 'ravenclaw' | 'hufflepuff'
```
