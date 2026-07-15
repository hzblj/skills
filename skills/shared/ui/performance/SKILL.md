---
name: performance
description: Enforces rendering performance best practices — memoization, stable references, and avoiding unnecessary re-renders. Use when optimizing component performance.
---

# Performance Discipline

- Prefer `useMemo` and `useCallback` when values or handlers are passed to children.
- No anonymous arrow functions in JSX.
- No inline object literals in props.
- Keep function references stable.
- Avoid unnecessary re-renders.
- Avoid recreating style objects on each render.
- Performance is a default mindset.
