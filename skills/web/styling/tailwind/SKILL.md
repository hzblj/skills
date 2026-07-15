---
name: tailwind
description: Tailwind CSS rules — utility-first approach, class ordering, responsive design, dark mode, theme extension, and component patterns with cn(). Use when styling web components.
---

# Styling (Tailwind CSS)

## Rules

- Tailwind is the primary styling method. Do not use inline styles or CSS modules unless necessary.
- Follow utility-first approach - compose small utilities, avoid `@apply` in most cases.
- No arbitrary values (`w-[137px]`) unless truly one-off. Extend theme config instead.
- Keep class lists readable - group by concern with logical ordering.

## Class Ordering

Follow consistent ordering:

1. Layout (`flex`, `grid`, `block`, `hidden`)
2. Positioning (`relative`, `absolute`, `z-10`)
3. Box model (`w-`, `h-`, `p-`, `m-`, `gap-`)
4. Typography (`text-`, `font-`, `leading-`, `tracking-`)
5. Visual (`bg-`, `border-`, `rounded-`, `shadow-`)
6. Effects (`opacity-`, `blur-`, `backdrop-`)
7. Transitions (`transition-`, `duration-`, `ease-`)
8. State variants (`hover:`, `focus:`, `active:`)
9. Responsive (`sm:`, `md:`, `lg:`, `xl:`)

```tsx
<div className="flex items-center gap-4 p-6 text-sm font-medium bg-white rounded-xl shadow-sm transition-shadow duration-200 hover:shadow-md md:p-8" />
```

## Responsive Design

- Mobile-first approach - base styles are mobile, add `sm:`, `md:`, `lg:` for larger screens.
- Use consistent breakpoints from theme config.
- Do not mix responsive approaches (no media queries alongside Tailwind breakpoints).

## Dark Mode

- Use `dark:` variant consistently.
- Define color pairs for every surface and text color.
- Test both modes - do not leave dark mode as afterthought.

## Theme Extension

- Extend `tailwind.config.ts` for project-specific tokens (colors, spacing, fonts).
- Use CSS variables for dynamic theming.
- Keep design tokens in one place.

```ts
theme: {
  extend: {
    colors: {
      brand: {
        50: 'var(--color-brand-50)',
        500: 'var(--color-brand-500)',
        900: 'var(--color-brand-900)',
      },
    },
  },
}
```

## Component Patterns

- Use `cn()` (clsx + twMerge) for conditional and mergeable classes.
- Extract repeated class combinations into component props, not `@apply`.
- Keep variant logic in the component, not in CSS.

```ts
import { cn } from '@/utils'

type ButtonProps = {
  variant: 'primary' | 'secondary'
  size: 'sm' | 'md' | 'lg'
}

const BUTTON_VARIANTS = {
  primary: 'bg-brand-500 text-white hover:bg-brand-600',
  secondary: 'bg-gray-100 text-gray-900 hover:bg-gray-200',
} as const

const BUTTON_SIZES = {
  sm: 'px-3 py-1.5 text-sm',
  md: 'px-4 py-2 text-base',
  lg: 'px-6 py-3 text-lg',
} as const
```
