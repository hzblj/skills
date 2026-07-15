---
name: error-handling
description: Clean-code error handling — exceptions over error codes, wrap third-party APIs at a boundary, don't use catch as an if. Use when designing failure paths and error boundaries. Triggers on: error handling, exceptions, try catch, error codes, wrap library, throw.
---

# Error Handling

Error handling matters, but it must not take over the code. When the happy path disappears under a hedge of `if (err)` checks, the reader can no longer see what the code is *for*. The goal is to let the main algorithm breathe: keep the logic in one place and the error handling in another, translate other people's failures into your own at the boundary, and never reach for `try/catch` when a plain check would do.

This pairs with [functions](../functions/SKILL.md) (an error handler is a function that does one thing — handling errors) and [objects-and-data](../objects-and-data/SKILL.md) (the wrapper below is an object that hides a library behind a contract). Error and result types follow [type-safety](../../type-safety/SKILL.md).

> Out of scope: returning `null` and the Null Object pattern are intentionally **not** covered by this skill. This file is about exceptions, boundaries, and control flow.

## Use exceptions, not return/error codes

When a function signals failure with a return code, every caller has to check it, right now, inline — and the actual algorithm drowns in branching. Worse, the codes leak upward: each layer re-checks and re-returns. Throw instead. An exception lets the happy path read top-to-bottom as one clean story, and pushes the recovery logic out to the one place equipped to handle it.

```ts
// Bad — error codes. The enrollment logic is buried under status checks.
type Status = 'ok' | 'no-vault' | 'insufficient-galleons' | 'owl-lost'

const enrollStudent = (student: Student): Status => {
  const vault = gringotts.findVault(student.vaultId)
  if (vault === undefined) return 'no-vault'

  const charged = vault.charge(TUITION)
  if (charged !== 'ok') return 'insufficient-galleons'

  const sent = owlPost.sendAcceptance(student)
  if (sent !== 'ok') return 'owl-lost'

  return 'ok'
}

// ...and the caller re-branches on every code, forwarding failures by hand.
const status = enrollStudent(student)
if (status === 'no-vault') { /* ... */ }
else if (status === 'insufficient-galleons') { /* ... */ }
else if (status === 'owl-lost') { /* ... */ }
```

```ts
// Good — exceptions. The algorithm reads as three steps; errors leave via throw.
const enrollStudent = (student: Student): void => {
  const vault = gringotts.requireVault(student.vaultId) // throws VaultNotFoundError
  vault.charge(TUITION) // throws InsufficientGalleonsError
  owlPost.sendAcceptance(student) // throws OwlPostError
}

// Recovery lives in one place, separated from the logic.
try {
  enrollStudent(student)
  showToast('Welcome to Hogwarts!')
} catch (error) {
  reportEnrollmentFailure(error)
}
```

The `try/catch` marks a clean seam: everything inside is "what we're trying to do", everything in `catch` is "what we do when it fails". Keep the `try` body small — ideally a single call to a well-named function — so the two concerns never tangle.

## Wrap third-party APIs — don't catch a library's exceptions directly

An external dependency — an owl-post delivery API, a Gringotts payments SDK — throws *its* errors, in *its* shape, with *its* naming. If you `catch` those library errors scattered across your codebase, you've bonded your whole app to that library: its error types appear in dozens of files, and swapping it (or upgrading past a breaking change) means editing all of them. Instead, put a **thin wrapper** around the dependency. Catch and translate its failures into *your* domain error type at that one boundary. Everything above the wrapper only ever sees your errors.

```ts
// Bad — the Gringotts SDK's own error type leaks into feature code everywhere.
import { GringottsClient, GringottsApiError } from '@gringotts/sdk'

const payForBooks = async (order: Order): Promise<void> => {
  try {
    await new GringottsClient().charge(order.vaultId, order.total)
  } catch (error) {
    // Every call site must know GringottsApiError and its numeric `.status` codes.
    if (error instanceof GringottsApiError && error.status === 402) {
      throw new Error('Not enough galleons')
    }
    throw error
  }
}
```

```ts
// Good — one wrapper owns the SDK. It catches GringottsApiError and re-throws
// domain errors. The rest of the app imports neither the SDK nor its error type.
import { GringottsClient, GringottsApiError } from '@gringotts/sdk'

class InsufficientGalleonsError extends Error {}
class PaymentDeclinedError extends Error {}

class GringottsGateway {
  constructor(private readonly client = new GringottsClient()) {}

  async charge(vaultId: string, galleons: number): Promise<void> {
    try {
      await this.client.charge(vaultId, galleons)
    } catch (error) {
      if (error instanceof GringottsApiError && error.status === 402) {
        throw new InsufficientGalleonsError('Not enough galleons', { cause: error })
      }
      throw new PaymentDeclinedError('Payment declined', { cause: error })
    }
  }
}
```

```ts
// Feature code depends only on GringottsGateway and your domain errors.
const payForBooks = async (order: Order, gateway: GringottsGateway): Promise<void> => {
  await gateway.charge(order.vaultId, order.total) // throws your errors, never the SDK's
}
```

The wrapper is also the natural seam for testing (mock the gateway, not the network) and the only file you touch when you replace Gringotts with a rival goblin bank. This is the same principle as *program to a contract* in [objects-and-data](../objects-and-data/SKILL.md): the gateway is your contract, the SDK is a hidden implementation detail.

## Don't use `catch` as an `if`

Exceptions are for **exceptional** conditions — the things you can't reasonably prevent (the owl never arrives, Gringotts is down). They are not a control-flow mechanism. If you can check a condition directly, check it. Wrapping a routine question in `try/catch` hides the intent ("is this student enrolled?" masquerades as "did something explode?") and, far worse, the `catch` swallows *real* errors — a network fault, a bug — right alongside the "expected" one, and you never find out.

```ts
// Bad — catch used as an if. This asks "is the student enrolled?" but will also
// silently swallow a database outage, a null bug, anything getRoster() throws.
const isEnrolled = (student: Student, course: Course): boolean => {
  try {
    course.getRoster().assertContains(student) // throws when absent
    return true
  } catch {
    return false // was the student absent, or did the roster fail to load?
  }
}
```

```ts
// Good — just ask the question. No exception, no ambiguity, no swallowed faults.
const isEnrolled = (student: Student, course: Course): boolean => {
  return course.roster.includes(student.id)
}
```

When you *do* need a real `catch`, keep it honest — TypeScript specifics:

- **Catch narrowly, act on type.** In TS every `catch` binding is `unknown`. Narrow with `instanceof` before you touch it; never assume it's an `Error`, and never `as`-cast it (see [type-safety](../../type-safety/SKILL.md)). Re-throw what you didn't mean to handle.
- **Never swallow.** An empty `catch {}` (or one that only returns a default) erases the failure. At minimum log it; usually, re-throw or translate it.
- **Preserve the cause.** When you translate an error, pass the original as `new DomainError('...', { cause: original })` so the stack trace and root cause survive up the chain.

```ts
// Good — narrow, don't swallow, preserve the cause.
try {
  await owlPost.deliver(letter)
} catch (error) {
  if (error instanceof OwlLostError) {
    throw new DeliveryFailedError('Owl never returned', { cause: error })
  }
  throw error // not ours to handle — let it propagate untouched
}
```

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Returning status codes that every caller must check and forward | Throw exceptions; let the happy path read top-to-bottom |
| A large `try` body mixing logic and recovery | Shrink `try` to one well-named call; do the work behind it |
| `catch`ing a library's own error type (`GringottsApiError`) in feature code | Wrap the dependency; translate to a domain error at one boundary |
| The SDK's error types imported across many files | Only the wrapper imports the SDK — swapping it touches one file |
| `try/catch` to test something you could check (`isEnrolled`) | Ask directly; reserve exceptions for exceptional conditions |
| Broad `catch` that also swallows real faults | Narrow with `instanceof`; re-throw what you didn't intend to handle |
| Empty `catch {}` or silently returning a default | Never swallow — log, translate, or re-throw |
| Treating the `catch` binding as `Error` / `as`-casting it | It's `unknown`; narrow before use, no casts |
| Translating an error but dropping the original | Preserve it: `new DomainError(msg, { cause: original })` |
