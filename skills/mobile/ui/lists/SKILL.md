---
name: lists
description: Strict performance rules for lists — FlashList, stable renderItem, extracted item components, and naming patterns. Use when building or optimizing list views.
---

# Lists (Strict Performance Rules)

- Always use `FlashList`.
- Do not use `FlatList` unless strongly justified.
- `estimatedItemSize` must be provided.
- `renderItem` must be stable.
- No anonymous arrow functions in list rendering.
- Extract list items into dedicated components.
- No inline JSX inside `.map()`.

List feature naming pattern:

- `SpellList.tsx`
- `SpellListCard.tsx`
- `SpellListEmpty.tsx`
- `SpellListSkeleton.tsx`
- `SpellListHeader.tsx`

Prefix related files with the feature name.
