---
"skills": minor
---

Rework the `tailwind` skill into the house style and make it the authoritative home for `cn()`. New guidance: style against **semantic theme tokens** (`bg-surface`, `text-foreground`) defined as CSS variables and flipped once for dark mode, instead of scattering `bg-white … dark:bg-neutral-900` pairs across every element; express component variants with **`tv()`** (tailwind-variants) — `base`/`variants`/`defaultVariants`/`compoundVariants`, typed via `VariantProps` — rather than hand-rolled `cn()` chains; and a full `cn()` section covering twMerge conflict resolution (last-wins, so `className` props can override). Plus no-arbitrary-values, `size-*`, `group`/`peer`, `data-*` variants, avoiding `@apply`, and letting `prettier-plugin-tailwindcss` order classes. A Common Mistakes table and Review Checklist round it out.

The `formatting` skill's `cn()` section is trimmed to the string-hygiene rule and now cross-links `tailwind` for the Tailwind-specific depth (twMerge, `tv()`).
