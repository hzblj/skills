---
"skills": minor
---

Drop all `framer-motion` / `motion/react` usage from the UI skills — the web animation stack is CSS/Tailwind (state transitions) and GSAP (sequenced/staggered/exit motion), with Reanimated on mobile. In `ui-motion`, the staggered-enter and exit examples are now GSAP, the icon cross-fade is the CSS-only version (no `<motion.span>`/`<AnimatePresence>`), and the icon timing spec is stated platform-neutrally. In `ui-interactions`, press feedback drops the `<motion.button whileTap>` equivalent (Tailwind `active:scale-[0.96]` is the web way), and skip-animation-on-first-load is reframed around CSS transitions not replaying plus gating one-shot GSAP enters behind a mounted ref.
