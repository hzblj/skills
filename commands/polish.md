---
description: Apply an interface-polish pass to a component (web or React Native)
argument-hint: <path>
---

Apply an interface-polish pass to `$ARGUMENTS` using the UI-polish skills — `ui-typography`, `ui-surfaces`, `ui-motion`, and `ui-interactions`. Detect whether the file is web (React/CSS/Tailwind) or React Native and apply the platform-correct variant of each rule.

Check and fix:
- **Surfaces** — concentric border radius (`outer = inner + padding`), optical alignment, shadows/elevation over hard borders, image outlines, minimum 44×44 hit area (`hitSlop` on mobile).
- **Typography** — tabular numbers for dynamic values; `text-wrap: balance`/`pretty` (web) or `numberOfLines` + Dynamic Type (mobile).
- **Motion** — interruptible animations; split & staggered enter (~100ms); subtle exit (`-12px`, shorter duration); contextual icon cross-fade (scale 0.25→1, opacity 0→1, blur 4px→0, spring bounce 0).
- **Interactions** — press feedback (`scale(0.96)`, never below 0.95) + haptics on meaningful mobile taps; hover/focus (web); disabled/loading states; skip-animation-on-first-load.

Report the changes as Before/After tables grouped by principle, and apply the safe ones. For deep animation mechanics defer to the `gsap` (web) or `reanimated` (mobile) skills.
