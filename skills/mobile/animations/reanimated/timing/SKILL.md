---
name: reanimated-timing
description: >-
  Reanimated timing — withTiming vs withSpring vs withDecay, Easing, spring configs, withSequence/withDelay/withRepeat, cancelAnimation, reduced motion, recommended constant configs. Triggers on: withSpring, withTiming, easing, damping stiffness, withRepeat, reduced motion.
---

# Timing, Springs & Easing

The three animation drivers — `withTiming`, `withSpring`, `withDecay` — plus composition helpers, easing, and reduced motion. Choosing the right one is most of what makes motion feel native.

## Which driver?

| Driver | Motion | Use for |
| --- | --- | --- |
| `withSpring` | Physical, settles naturally, velocity-aware | Interactive/physical motion: press, drag release, toggles, sheets, anything the user "pushes" |
| `withTiming` | Precise, fixed duration + easing | UI chrome: opacity, color, progress bars, exact-duration reveals |
| `withDecay` | Momentum that decelerates from a velocity | Fling/scroll/pan release (see [gestures](../gestures/SKILL.md)) |

**Rule of thumb:** if a finger or a physical metaphor is involved, spring. If it's chrome or you need an exact duration, time. If it's a flick off a gesture, decay.

```tsx
// Good — spring for the thing the user pressed, timing for its label fading in
scale.value = withSpring(0.96, SPRING);
labelOpacity.value = withTiming(1, TIMING);
```

```tsx
// Bad — timing on a draggable release feels robotic; spring on a progress bar overshoots
translateX.value = withTiming(0, { duration: 300 });  // ❌ use withSpring
progress.value = withSpring(1);                        // ❌ progress shouldn't bounce
```

## `withSpring` — physical vs duration-based

Two ways to configure a spring. Prefer **physical** config for control and reuse.

### Physical (recommended)

```tsx
scale.value = withSpring(1, { damping: 18, stiffness: 180, mass: 1 });
```

| Param | Higher value | Lower value |
| --- | --- | --- |
| `damping` | Less bounce, settles faster | More bounce, oscillates longer |
| `stiffness` | Faster, snappier | Slower, looser |
| `mass` | Heavier, more sluggish | Lighter, quicker |

Recommended presets (define once, import everywhere):

```tsx
export const SPRING       = { damping: 18, stiffness: 180, mass: 1 } as const; // snappy UI
export const SPRING_SOFT  = { damping: 22, stiffness: 120, mass: 1 } as const; // sheets, cards
export const SPRING_BOUNCY = { damping: 10, stiffness: 150, mass: 1 } as const; // playful accents
```

### Duration-based spring

When you need a spring *look* but a predictable length, use `duration` + `dampingRatio` (0–1; 1 = critically damped, no overshoot).

```tsx
scale.value = withSpring(1, { duration: 400, dampingRatio: 0.7 });
```

Don't mix `damping`/`stiffness` with `duration`/`dampingRatio` in the same config — pick one model.

## `withTiming` and `Easing`

```tsx
import { withTiming, Easing } from 'react-native-reanimated';

opacity.value = withTiming(1, { duration: 250, easing: Easing.out(Easing.cubic) });
```

| Easing | Feel | Use for |
| --- | --- | --- |
| `Easing.out(Easing.cubic)` | Fast start, gentle stop | **Default for enters** — decelerating |
| `Easing.in(Easing.cubic)` | Gentle start, fast end | Exits — accelerating away |
| `Easing.inOut(Easing.cubic)` | Ease both ends | Symmetric moves, loops |
| `Easing.linear` | Constant | Spinners, progress that maps to real progress |
| `Easing.bezier(x1,y1,x2,y2)` | Custom curve | Match a design spec exactly |

Default configs:

```tsx
export const TIMING      = { duration: 250, easing: Easing.out(Easing.cubic) } as const;
export const TIMING_FAST = { duration: 150, easing: Easing.in(Easing.cubic) } as const; // exits
```

## Composition helpers

### `withSequence` — run animations back-to-back

```tsx
// Good — a shake: nudge right, left, right, settle
offsetX.value = withSequence(
  withTiming(8,  { duration: 60 }),
  withTiming(-8, { duration: 60 }),
  withTiming(4,  { duration: 60 }),
  withTiming(0,  { duration: 60 }),
);
```

### `withDelay` — wait, then animate

```tsx
opacity.value = withDelay(120, withTiming(1, TIMING));
```

### `withRepeat` — loop, with yoyo

Signature: `withRepeat(animation, numberOfReps, reverse, callback)`. `numberOfReps = -1` is infinite. `reverse = true` yoyos (plays forward then backward) — essential for pulses so they don't snap back.

```tsx
// Good — infinite pulsing dot (yoyo, so it eases both ways)
scale.value = withRepeat(
  withTiming(1.2, { duration: 700, easing: Easing.inOut(Easing.cubic) }),
  -1,    // infinite
  true,  // reverse → yoyo
);
```

```tsx
// Good — continuous spinner (linear, no reverse)
rotation.value = withRepeat(withTiming(360, { duration: 1000, easing: Easing.linear }), -1, false);
```

Always `cancelAnimation` an infinite repeat on unmount:

```tsx
useEffect(() => {
  scale.value = withRepeat(withTiming(1.2, TIMING), -1, true);
  return () => cancelAnimation(scale);
}, []);
```

```tsx
// Bad — infinite loop never cancelled: keeps running after unmount, wastes UI-thread cycles
useEffect(() => {
  scale.value = withRepeat(withTiming(1.2, TIMING), -1, true);
}, []);
```

## Completion callbacks

Every driver takes a callback `(finished, current) => {}` (a worklet). Use `runOnJS` to reach the JS thread. `finished` is `false` when the animation was interrupted (e.g. a new value took over) — check it before firing side effects.

```tsx
opacity.value = withTiming(0, TIMING_FAST, (finished) => {
  if (finished) runOnJS(onHidden)();
});
```

## Interruptibility

`withSpring`/`withTiming` automatically retarget from the current value (and, for springs, current velocity) when a new animation is assigned. Do **not** gate re-triggering behind an `isAnimating` flag — that breaks reversal.

```tsx
// Good — toggling mid-flight smoothly reverses
const toggle = () => { open.value = withSpring(open.value > 0.5 ? 0 : 1, SPRING); };
```

```tsx
// Bad — flag blocks the reverse until the first animation "finishes"
const toggle = () => {
  if (isAnimating) return;      // ❌ kills interruptibility
  setIsAnimating(true);
  open.value = withTiming(1, TIMING, () => runOnJS(setIsAnimating)(false));
};
```

## Reduced motion

Respect the OS "Reduce Motion" setting. Reanimated has this built in — pass `reduceMotion` in any config.

```tsx
import { ReduceMotion, withSpring } from 'react-native-reanimated';

scale.value = withSpring(1, { ...SPRING, reduceMotion: ReduceMotion.System });
```

| `ReduceMotion` value | Behavior |
| --- | --- |
| `System` | Follow the OS setting (**recommended default**) |
| `Never` | Always animate (use only for essential feedback) |
| `Always` | Always jump to the end value, no motion |

Bake `reduceMotion: ReduceMotion.System` into the shared constants so every animation inherits it.

For branching logic (e.g. skip a big parallax but keep a fade), read the setting:

```tsx
import { useReducedMotion } from 'react-native-reanimated';

const reduced = useReducedMotion();               // reactive hook, JS thread
const distance = reduced ? 0 : 40;
entering = FadeInDown.springify();                 // still fades; no travel when reduced
```

```tsx
// One-shot check outside React
import { AccessibilityInfo } from 'react-native';
const enabled = await AccessibilityInfo.isReduceMotionEnabled();
```

## Recommended constant configs (copy into a shared module)

```tsx
import { Easing, ReduceMotion } from 'react-native-reanimated';

export const SPRING        = { damping: 18, stiffness: 180, mass: 1, reduceMotion: ReduceMotion.System } as const;
export const SPRING_SOFT   = { damping: 22, stiffness: 120, mass: 1, reduceMotion: ReduceMotion.System } as const;
export const SPRING_BOUNCY = { damping: 10, stiffness: 150, mass: 1, reduceMotion: ReduceMotion.System } as const;
export const TIMING        = { duration: 250, easing: Easing.out(Easing.cubic), reduceMotion: ReduceMotion.System } as const;
export const TIMING_FAST   = { duration: 150, easing: Easing.in(Easing.cubic),  reduceMotion: ReduceMotion.System } as const;
```

## Target 60fps / 120fps — avoid layout jank

Animate `transform` and `opacity`, which composite on the UI thread. Avoid animating layout props (`width`, `height`, `margin`, `top`/`left`) — those trigger a layout pass every frame. Use `transform: [{ scale }]` / `{ translateX }` instead.

## Gotchas

| Mistake | Fix |
| --- | --- |
| `withTiming` on draggable release | Use `withSpring` — timing feels robotic for physical motion |
| `withSpring` on a progress bar / color | Use `withTiming` — springs overshoot chrome |
| Mixing `damping`/`stiffness` with `duration`/`dampingRatio` | Pick one spring model per config |
| Pulse snaps back at loop boundary | `withRepeat(anim, -1, true)` (reverse/yoyo) |
| Infinite repeat never cancelled | `cancelAnimation(sv)` on unmount |
| Side effect fires on interrupted animation | Guard with `if (finished)` in the callback |
| Re-trigger blocked by `isAnimating` flag | Remove the flag; let animations retarget |
| Ignoring reduced motion | Add `reduceMotion: ReduceMotion.System` to configs |
| Magic numbers scattered across files | Import `SPRING`/`TIMING` constants |
