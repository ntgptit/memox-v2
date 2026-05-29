---
last_updated: 2026-05-26
status: contract
---

# Use Case Contracts Index

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Use case = domain-layer orchestration unit. Each file in this folder enumerates use cases for one entity / capability.

| File | Covers |
| --- | --- |
| `docs/contracts/usecase-contracts/folder.md` | Folder CRUD, mode lock, hierarchy |
| `docs/contracts/usecase-contracts/deck.md` | Deck CRUD, target_language, recursive counts |
| `docs/contracts/usecase-contracts/flashcard.md` | Flashcard CRUD, reset progress, import |
| `docs/contracts/usecase-contracts/study.md` | Session lifecycle, grading, finalization, bury/suspend |
| `docs/contracts/usecase-contracts/srs.md` | Pure domain: box transitions, intervals, due-date computation |
| `docs/contracts/usecase-contracts/tag.md` | Tag validation, rename, merge, delete, study-by-tag ref id |
| `docs/contracts/usecase-contracts/bulk.md` | Multi-card transactional operations |
| `docs/contracts/usecase-contracts/history.md` | Read-only timeline + lifetime stats |
| `docs/contracts/usecase-contracts/search.md` | Global recursive search |
| `docs/contracts/usecase-contracts/engagement.md` | Daily goal, streak, reminder, dashboard aggregate |
| `docs/contracts/usecase-contracts/account-sync.md` | Google sign-in, account-scoped DB, Drive backup/restore |
| `docs/contracts/usecase-contracts/tts.md` | TTS playback, settings, voice listing |

## Conventions across all use case contracts

- **Signature:** `Future<Either<Failure, T>> call(...)` or `Stream<Either<Failure, T>> call(...)` for watch.
- **No throwing.** All errors via `Failure`.
- **Transactional integrity:** any state-mutating use case **notes** that it requires a single transaction. **Full transaction detail (which tables, which order) lives in the corresponding repository contract.** Use case docs MUST NOT duplicate the table list.
- **Idempotency:** noted where applicable. Default = NOT idempotent.
- **Caller responsibility:** confirmation dialogs are caller's responsibility (notifier triggers dialog before invoking use case for destructive actions).

## Ownership rule (source of truth)

| Concern | Source of truth |
| --- | --- |
| Business behavior, edge cases | `docs/business/**` |
| UI states, copy, layout | `docs/wireframes/**` |
| Use case signature, preconditions, rules, errors | This folder (`usecase-contracts/`) |
| Tables touched per mutation, exact transaction span, index dependencies | `repository-contracts/` |
| Failure type definitions | `docs/contracts/error-contract.md` |
| Enum / value object definitions | `docs/contracts/types-catalog.md` |
| Naming, file layout | `docs/contracts/code-style.md` |

When repository contract and use case contract contradict on transaction detail, the **repository contract wins**.

## Forbidden across all use cases

- ❌ Calling DAO directly (must go through repository).
- ❌ Calling other use cases without explicit composition (avoid hidden coupling).
- ❌ Use case taking `BuildContext` or any presentation-layer type.
- ❌ Use case returning Drift row type (must map to entity).
- ❌ Use case writing to logs directly without going through `core/logging`.

## Related

**Architecture:** `docs/architecture/clean-architecture-contract.md`
**Error contract:** `docs/contracts/error-contract.md`
**Types:** `docs/contracts/types-catalog.md`
**Code style:** `docs/contracts/code-style.md`
**Test strategy:** `docs/testing/test-strategy.md`
**Repository contracts:** `docs/contracts/repository-contracts/index.md`
