---
name: type-safety
description: >-
  Strict TypeScript typing — type over interface, no any, narrow string-literal and discriminated unions, exhaustive switch with never, composing complex types from small pieces, deriving types from values with as const / typeof / keyof, satisfies, branded types, and safe array indexing. Use when defining, composing, or reviewing types. Triggers on: type over interface, no any, no enum, narrow types, string-literal union, discriminated union, exhaustiveness, never, assertNever, switch never, satisfies, as const, const assertion, keyof, typeof, utility types, Pick, Omit, Record, noUncheckedIndexedAccess, array indexing, branded type, type safety.
---

# Type Safety (Strict)

The type system is a proof engine: model the domain precisely enough and whole classes of bugs stop compiling. The goal is to make **illegal states unrepresentable** — a value that can't exist in the domain shouldn't be expressible in the types. Every `any`, every broad `string`, every unchecked index is a hole where a runtime crash leaks back in.

This assumes a strict `tsconfig.json`. These are non-negotiable:

```jsonc
// tsconfig.json — the floor for every app
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true, // array/record access yields T | undefined
    "exactOptionalPropertyTypes": true, // `x?: T` ≠ `x: T | undefined`
    "noImplicitOverride": true
  }
}
```

House rules at a glance:

- Use `type`, never `interface`. Never `enum`.
- No `any`. No `as` casting, no `as unknown as`. Accept `unknown` and narrow.
- Prefer narrow types over broad ones — string-literal unions over `string`.
- Model "one of several shapes" as a **discriminated union**.
- Make every `switch` over a union **exhaustive** with a `never` guard.
- Compose big types from small named pieces; derive variants with utility types.
- Derive types from values (`as const` + `typeof`/`keyof`) — one source of truth.
- Validate object literals with `satisfies`, not a widening `: T` annotation.
- Props use an explicit named `type` — never inline in the signature.

Pairs with [meaningful-names](../clean-code/meaningful-names/SKILL.md) (a type name is a promise), [objects-and-data](../clean-code/objects-and-data/SKILL.md) (a `type` is a contract), and [error-handling](../clean-code/error-handling/SKILL.md) (error/result types, `unknown` in `catch`).

## `type`, not `interface` — and never `enum`

`type` does everything `interface` does and composes with unions, intersections, and mapped/conditional types that `interface` can't express. Pick one and stay consistent; we pick `type`.

```ts
// Bad
interface Wizard {
  id: string
  name: string
}

// Good
type Wizard = {
  id: string
  name: string
}
```

`enum` emits runtime code, isn't a subtype of the values it wraps, and behaves surprisingly (numeric enums are bidirectional maps). A string-literal union is lighter, narrower, and needs no import to reference a member.

```ts
// Bad — a runtime object, awkward to serialize, values aren't plain strings.
enum House {
  Gryffindor = 'gryffindor',
  Slytherin = 'slytherin',
}

// Good — zero runtime cost; the values are the type.
type House = 'gryffindor' | 'slytherin' | 'ravenclaw' | 'hufflepuff'
```

## No `any` — accept `unknown`, then narrow

`any` doesn't add a type; it **deletes** the type-checker for that value and everything derived from it. One `any` at an API boundary silently propagates through your whole call graph. When a value is genuinely unknown (a fetch response, `JSON.parse`, a `catch` binding), type it `unknown` and narrow with a type guard — the compiler then forces you to prove the shape before you use it.

```ts
// Bad — any disables checking; the typo and the missing field both compile.
const toSpell = (raw: any): Spell => ({ name: raw.naem, power: raw.power })

// Good — unknown forces a guard; nothing is readable until the shape is proven.
const isSpell = (value: unknown): value is Spell =>
  typeof value === 'object' &&
  value !== null &&
  'name' in value &&
  typeof (value as Record<string, unknown>).name === 'string'

const toSpell = (raw: unknown): Spell => {
  if (!isSpell(raw)) throw new InvalidSpellError()
  return raw // narrowed to Spell here
}
```

Likewise, never launder a wrong type through `as` (`value as Spell`) or the double-cast escape hatch `as unknown as Spell` — both assert a lie the compiler will believe. The one benign cast is `as const` (below), which narrows rather than widens.

## Prefer narrow types — string-literal unions

A type should permit exactly the values the domain allows and nothing more. `string` for a house accepts `''`, `'Hogwarts'`, and every typo; a union of the four real houses rejects all of them at the call site.

```ts
// Bad — every string typechecks; the bug surfaces at runtime, far away.
type Student = { house: string; year: number }
awardPoints({ house: 'gryffndor', year: 13 }) // compiles 😱

// Good — only real houses and a narrow year union typecheck.
type House = 'gryffindor' | 'slytherin' | 'ravenclaw' | 'hufflepuff'
type Year = 1 | 2 | 3 | 4 | 5 | 6 | 7
type Student = { house: House; year: Year }
awardPoints({ house: 'gryffndor', year: 13 }) // ✗ two compile errors
```

| Broad (avoid) | Narrow (prefer) | Why |
| --- | --- | --- |
| `string` | `'gryffindor' \| 'slytherin' \| …` | Rejects typos and impossible values |
| `number` | `1 \| 2 \| 3 \| 4 \| 5 \| 6 \| 7` | Encodes the real domain range |
| `boolean` flags ×2 | one union `'idle' \| 'loading' \| 'error'` | Two booleans allow impossible combos (see below) |
| `object` / `{}` | an explicit `type` | `{}` means "anything non-nullish" |
| `any` | `unknown` + guard | Keeps checking on; forces proof of shape |

## Discriminated unions — "one of several shapes"

When a value is one of several *shapes* (not just several values), give each variant a shared literal **discriminant** field. TypeScript then narrows the whole object once you check that field — and it makes contradictory combinations impossible to construct.

```ts
// Bad — optional fields allow illegal combinations the compiler can't catch:
// a "success" with an error, a "loading" that also has data.
type RequestState = {
  status: 'idle' | 'loading' | 'success' | 'error'
  data?: Spell[]
  error?: Error
}

// Good — each state carries exactly the fields it has, and no others.
type RequestState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: Spell[] }
  | { status: 'error'; error: Error }

const render = (state: RequestState): string => {
  if (state.status === 'success') return `${state.data.length} spells` // .data exists
  if (state.status === 'error') return state.error.message // .error exists
  return 'Loading…' // .data / .error not even accessible here
}
```

Accessing `state.data` in the `idle` branch is a **compile error**, not a runtime `undefined`. This is the payoff of narrow modelling: illegal states can't be built, so they can't be rendered.

## Exhaustiveness — `switch` + `never` so extending a union is a compile error

Handle a union with a `switch` whose `default` funnels into a `never` guard. Because only `never` is assignable to `never`, the code compiles *only while every case is handled*. The moment you add a member to the union, the unhandled value is no longer `never`, and **every** switch that forgot it fails to compile — the type-checker hands you an exact to-do list.

```ts
// One shared helper — the compiler proves a value can never reach it.
export const assertNever = (value: never): never => {
  throw new Error(`Unhandled case: ${JSON.stringify(value)}`)
}
```

```ts
type House = 'gryffindor' | 'slytherin' | 'ravenclaw' | 'hufflepuff'

export const houseColor = (house: House): string => {
  switch (house) {
    case 'gryffindor':
      return 'scarlet'
    case 'slytherin':
      return 'emerald'
    case 'ravenclaw':
      return 'sapphire'
    case 'hufflepuff':
      return 'amber'
    default:
      return assertNever(house) // ✓ house is `never` — all cases handled
  }
}
```

Now extend the union and watch it break in exactly the right place:

```ts
type House = 'gryffindor' | 'slytherin' | 'ravenclaw' | 'hufflepuff' | 'durmstrang'
// ❌ houseColor: Argument of type 'string' is not assignable to parameter of type 'never'.
//    → 'durmstrang' reaches `default`; the compiler flags the missing case.
```

The same pattern discriminates a union by its `kind`/`status` field:

```ts
const describe = (spell: Spell): string => {
  switch (spell.kind) {
    case 'charm':
      return `Charm: ${spell.incantation}`
    case 'curse':
      return `Curse: ${spell.incantation}`
    case 'potion':
      return `Potion, ${spell.brewMinutes}m`
    default:
      return assertNever(spell)
  }
}
```

> **Why not `if / else if`?** A chain of `if`s has no `never` backstop — add a union member and it silently falls through to the last `else`, shipping wrong behavior with zero compiler help. The `switch` + `never` pattern is what turns "I extended the type" into "the build tells me every place to update."

## Compose complex types from small named pieces

Don't hand-write one wide type and repeat its fields everywhere. Name the small, reusable shapes, then combine them with `&` (intersection) and `|` (union). Small pieces get individual names, get reused, and read like the domain.

```ts
// Bad — one flat wall of fields; the shared bits can't be reused or named.
type Wizard = {
  id: string
  createdAt: string
  updatedAt: string
  name: string
  house: House
  wandWood: string
  wandCore: string
}

// Good — small building blocks compose into the whole.
type Id = { id: string }
type Timestamps = { createdAt: string; updatedAt: string }
type Wand = { wood: string; core: string }

type Wizard = Id &
  Timestamps & {
    name: string
    house: House
    wand: Wand
  }
```

Then **derive** related shapes with utility types instead of duplicating them — one canonical `Wizard`, everything else computed from it, so they can never drift apart.

```ts
type NewWizard = Omit<Wizard, keyof Id | keyof Timestamps> // create payload
type WizardPreview = Pick<Wizard, 'id' | 'name' | 'house'> // list-row shape
type WizardPatch = Partial<Omit<Wizard, 'id'>> // PATCH body — everything but id, optional
type PointsByHouse = Record<House, number> // one entry per house, checked
```

| Utility | Produces | Reach for it when |
| --- | --- | --- |
| `Pick<T, K>` | T with only keys `K` | A view/preview needs a few fields |
| `Omit<T, K>` | T without keys `K` | Dropping server-owned fields (`id`, timestamps) |
| `Partial<T>` | all keys optional | PATCH / update payloads |
| `Required<T>` | all keys required | Tightening a loose config after defaults |
| `Record<K, V>` | object keyed by `K` | A lookup with one entry per union member |
| `ReturnType<F>` / `Parameters<F>` | a function's result / args | Typing around an existing function |

Compose broadly, but keep each piece **narrow** — composition doesn't excuse a stray `string` inside a building block.

## Derive types from values — `as const`, `typeof`, `keyof`

When you already have the data as a value (the list of houses, a config map), don't also maintain a parallel hand-written type that can silently fall out of sync. Freeze the value with `as const` and derive the type from it. One source of truth; the type follows the value automatically.

```ts
// Bad — two sources of truth. Add a house to one, forget the other, and they drift.
const HOUSES = ['gryffindor', 'slytherin', 'ravenclaw', 'hufflepuff']
type House = 'gryffindor' | 'slytherin' | 'ravenclaw' | 'hufflepuff'

// Good — the array is the single source; the type is derived from it.
const HOUSES = ['gryffindor', 'slytherin', 'ravenclaw', 'hufflepuff'] as const
type House = (typeof HOUSES)[number]
// 'gryffindor' | 'slytherin' | 'ravenclaw' | 'hufflepuff'
```

Without `as const`, `HOUSES` is `string[]` and `(typeof HOUSES)[number]` collapses to `string` — the narrowness is gone. `as const` makes it a `readonly` tuple of literals, so the derived union is exact. The same trick derives keys and values from an object map:

```ts
const HOUSE_COLORS = {
  gryffindor: 'scarlet',
  slytherin: 'emerald',
  ravenclaw: 'sapphire',
  hufflepuff: 'amber',
} as const

type House = keyof typeof HOUSE_COLORS // 'gryffindor' | 'slytherin' | …
type HouseColor = (typeof HOUSE_COLORS)[House] // 'scarlet' | 'emerald' | …
```

## `satisfies` — validate a literal without widening it

A type annotation (`const x: T = …`) **widens** the value to `T`, throwing away the precise inferred type. `satisfies` does the opposite: it *checks* the value conforms to `T` — catching missing keys and wrong value types — while keeping the exact narrow type you wrote. Best of both: the guarantee of `T`, the precision of the literal.

```ts
// Bad — the annotation widens every value back to string.
const HOUSE_COLORS: Record<House, string> = {
  gryffindor: 'scarlet',
  slytherin: 'emerald',
  ravenclaw: 'sapphire',
  hufflepuff: 'amber',
}
const c = HOUSE_COLORS.gryffindor // type: string — literal lost

// Good — satisfies checks the shape but preserves the literal types.
const HOUSE_COLORS = {
  gryffindor: 'scarlet',
  slytherin: 'emerald',
  ravenclaw: 'sapphire',
  hufflepuff: 'amber',
} satisfies Record<House, string>
const c = HOUSE_COLORS.gryffindor // type: 'scarlet'
// Omit a house → compile error; add an unknown house → compile error.
```

| Form | Conformance to `T` checked? | Resulting type | Use when |
| --- | --- | --- | --- |
| `x: T = …` | ✓ | `T` (widened) | You want the variable typed exactly as `T` |
| `x = … as T` | ✗ (unsafe assertion) | `T` | Almost never — it asserts, it doesn't check |
| `x = … satisfies T` | ✓ | the narrow inferred type | You want `T`'s guarantee **and** literal precision |

## Safe array & record indexing (`noUncheckedIndexedAccess`)

By default TypeScript assumes every index is in bounds — `students[0]` is typed `Student` even for an empty array, so `.castSpell()` compiles and crashes at runtime. Turn on `noUncheckedIndexedAccess` and every index access becomes `T | undefined`, forcing you to handle the empty/missing case.

```ts
// With noUncheckedIndexedAccess on:
const first = students[0] // Student | undefined
first.castSpell() // ✗ 'first' is possibly 'undefined'

// Good — narrow first (guard clause), then use it.
const first = students[0]
if (first === undefined) return
first.castSpell() // Student here
```

The same applies to open-keyed records, where a lookup really can miss:

```ts
const enrollment: Record<string, Student> = loadRoster()
const student = enrollment[id] // Student | undefined — handle the miss
```

This pairs with [error-handling](../clean-code/error-handling/SKILL.md): don't paper over the `undefined` with a non-null assertion (`students[0]!`) — narrow it, or throw a `requireX` error when absence is truly exceptional.

## Branded types — IDs that can't be mixed up

When several things are all `string` (a wizard id, a house id, a raw incantation), the compiler happily lets you pass one where another is expected. A **brand** — an intersection with a phantom marker — makes each a distinct type without any runtime cost.

```ts
type WizardId = string & { readonly __brand: 'WizardId' }
type SpellId = string & { readonly __brand: 'SpellId' }

const asWizardId = (value: string): WizardId => value as WizardId

const findWizard = (id: WizardId): Wizard | undefined => /* … */ undefined

findWizard(asWizardId(raw)) // ✓
findWizard(someSpellId) // ✗ SpellId is not assignable to WizardId
```

Use this for identifiers and units (`Galleons`, `Minutes`) that would otherwise silently swap. The brand exists only in the type system; at runtime it's still a plain string. The lone `as` cast lives inside the smart constructor (`asWizardId`) — that one controlled boundary is the accepted exception to the no-cast rule, because there's no other way to attach a phantom brand.

## Explicit prop types — never inline

Every component's props get a named `type` declared above the component, never an inline annotation in the signature. The name documents the contract, is reusable, and keeps the signature readable.

```ts
// Bad — props inlined; unreadable and unreusable.
const HouseBadge = ({ house, points }: { house: House; points: number }) => null

// Good — a named prop type.
type HouseBadgeProps = {
  house: House
  points: number
}

const HouseBadge = ({ house, points }: HouseBadgeProps) => null
```

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| `any` at a boundary, silently spreading downstream | Type it `unknown`; narrow with a type guard before use |
| `as Spell` / `as unknown as Spell` to silence an error | Don't assert a lie — narrow, or fix the real type |
| `string` / `number` where the domain is a fixed set | A string-literal / numeric-literal union |
| Optional fields (`data?`, `error?`) encoding a state machine | A discriminated union — one variant per state |
| `if / else if` over a union with no fallthrough guard | `switch` + `default: return assertNever(x)` |
| Adding a union member and hunting call sites by hand | The `never` guard flags every unhandled `switch` for you |
| One giant flat type with repeated field groups | Name small pieces; compose with `&`; derive with `Pick`/`Omit` |
| A hand-written type kept in sync with a value list | Derive it: `as const` + `(typeof X)[number]` / `keyof typeof X` |
| `: Record<K, string>` that widens literals away | `satisfies Record<K, string>` — checks shape, keeps literals |
| `arr[0].foo` assuming the element exists | Enable `noUncheckedIndexedAccess`; narrow the `T \| undefined` |
| `arr[0]!` non-null assertion to dodge the check | Guard it, or throw via a `requireX` helper |
| Passing a `WizardId` where a `SpellId` is meant (both `string`) | Brand the ids so the compiler separates them |
| `interface` or `enum` | `type`; a string-literal union instead of `enum` |
| Props inlined in the component signature | A named `type XProps` above the component |

## Review Checklist

- [ ] No `any`, no `as` casts, no `as unknown as` (only `as const` allowed).
- [ ] `strict` **and** `noUncheckedIndexedAccess` on; index results are guarded.
- [ ] Domain values use narrow literal unions, not `string` / `number`.
- [ ] "One of several shapes" is a discriminated union, not optional fields.
- [ ] Every `switch` over a union ends in `default: return assertNever(x)`.
- [ ] Big types are composed from small named pieces; variants derived with utilities.
- [ ] Value + type share one source (`as const` + `typeof`/`keyof`), no parallel copies.
- [ ] Object literals validated with `satisfies`, not a widening annotation.
- [ ] `type` throughout (no `interface`), no `enum`.
- [ ] Props declared as a named `type`, not inline.
