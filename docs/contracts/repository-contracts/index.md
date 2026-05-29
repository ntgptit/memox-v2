---
last_updated: 2026-05-26
status: contract
---

# Repository Contracts Index

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Repositories are the data-layer boundary. Domain layer interfaces, data layer implementations.

| File | Covers |
| --- | --- |
| `docs/contracts/repository-contracts/folder-repository.md` | Folder hierarchy, content_mode, recursive ops |
| `docs/contracts/repository-contracts/deck-repository.md` | Deck CRUD, recent decks, counts |
| `docs/contracts/repository-contracts/flashcard-repository.md` | Flashcards + progress + tags as a unit; bulk; import chunked |
| `docs/contracts/repository-contracts/study-repository.md` | Sessions + session items + status transitions |
| `docs/contracts/repository-contracts/progress-repository.md` | flashcard_progress + study_attempts (SRS state) |
| `docs/contracts/repository-contracts/tag-repository.md` | flashcard_tags global ops, rename, merge, delete |
| `docs/contracts/repository-contracts/sync-repository.md` | Drive App Folder, fingerprint, snapshot, restore |

## Conventions across all repository contracts

- **Signature:** `Future<Either<Failure, T>>` or `Stream<T>` for watches (NOT `Stream<Either<...>>` — UI subscribes to either side via Riverpod AsyncValue).
- **Interface in domain:** `lib/domain/repositories/{name}_repository.dart`.
- **Implementation in data:** `lib/data/repositories/{name}_repository_impl.dart`.
- **DAO usage:** Repositories own DAOs; DAOs MUST NOT be referenced outside data layer.
- **Mapper usage:** Each repo has a mapper file in `lib/data/mappers/` for entity ↔ row conversion.
- **Transaction:** declared per method in each contract.

## Forbidden across all repositories

- ❌ Return Drift row types to domain layer.
- ❌ Reference `BuildContext` or any presentation type.
- ❌ Throw business exceptions (use `Either<Failure, T>`).
- ❌ Call other repositories directly (composition happens in use cases).
- ❌ Skip mapper layer.
- ❌ Perform business rule validation here. Validation lives in domain (use cases / validators).
- ❌ Cross account scope: repository operates on the active account's DB only.

## Test contract

Each repository has a `*_repository_test.dart` using real Drift `NativeDatabase.memory()`. Seed via fixtures from `test/fixtures/`. See `docs/testing/test-strategy.md`.

## Related

**Architecture:** `docs/architecture/clean-architecture-contract.md`
**Schema:** `docs/database/schema-contract.md`
**Use cases:** `docs/contracts/usecase-contracts/index.md`
**Code style:** `docs/contracts/code-style.md`
**Test strategy:** `docs/testing/test-strategy.md`
