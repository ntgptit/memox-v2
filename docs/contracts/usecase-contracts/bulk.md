---
last_updated: 2026-05-26
status: contract
---

# Bulk Operations Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

All bulk operations snapshot selected IDs at confirmation time, run as single atomic transactions, and return result for undo where applicable.

## BulkDeleteFlashcardsUseCase

```dart
Future<Either<Failure, int>> call({required List<FlashcardId> ids});
```

**Rules:**

- Atomic cascade over all ids. See `docs/contracts/repository-contracts/flashcard-repository.md`.
- Return deleted count.

**Caution:** Destructive. NO undo. Confirm via §bulk-delete.

**Errors:** `StorageFailure`.

## BulkMoveFlashcardsUseCase

```dart
Future<Either<Failure, BulkMoveResult>> call({
  required List<FlashcardId> ids,
  required DeckId targetDeckId,
});
```

**Rules:**

- Validate target deck exists.
- Atomic batch UPDATE + `sort_order` recompute. See `docs/contracts/repository-contracts/flashcard-repository.md`.
- Return `BulkMoveResult { movedCount, previousDeckIds: Map<FlashcardId, DeckId> }` for undo.

**Errors:** `NotFoundFailure`, `StorageFailure`.

## BulkAddTagsUseCase

```dart
Future<Either<Failure, BulkTagResult>> call({
  required List<FlashcardId> ids,
  required List<String> tags,
});
```

**Rules:**

- Validate each tag.
- Atomic per-card INSERT with dedup. See `docs/contracts/repository-contracts/flashcard-repository.md`.

**Errors:** `ValidationFailure`, `StorageFailure`.

## BulkRemoveTagsUseCase

```dart
Future<Either<Failure, BulkTagResult>> call({
  required List<FlashcardId> ids,
  required List<String> tags,
});
```

**Rules:**

- Atomic DELETE across all ids. See `docs/contracts/repository-contracts/flashcard-repository.md`.

**Errors:** `StorageFailure`.

## BulkSuspendUseCase / BulkUnsuspendUseCase

```dart
Future<Either<Failure, int>> suspend({required List<FlashcardId> ids});
Future<Either<Failure, int>> unsuspend({required List<FlashcardId> ids});
```

**Rules:**

- Atomic UPDATE of `is_suspended` only. SRS state UNCHANGED. See `docs/contracts/repository-contracts/progress-repository.md`.

**Errors:** `StorageFailure`.

## BulkResetProgressUseCase

```dart
Future<Either<Failure, int>> call({required List<FlashcardId> ids});
```

**Rules:**

- Atomic UPDATE: `current_box = 1`, `due_at = now`, `last_reset_at = now`. Counters and attempts UNCHANGED. See `docs/contracts/repository-contracts/progress-repository.md`.

**Caution:** Confirm via §reset-progress (bulk variant).

**Errors:** `StorageFailure`.

**Test refs:** B section + H rows.

## Forbidden patterns

- ❌ Iterate updates per card outside a transaction.
- ❌ Apply bulk action to cards not in the snapshot (snapshot at confirmation time).
- ❌ Provide undo for destructive operations (bulk delete, bulk reset).
- ❌ Skip target deck validation for bulk move.
- ❌ Snapshot IDs at button render time instead of confirmation time.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business spec:** `docs/business/bulk/bulk-operations.md`
**Repository:** `docs/contracts/repository-contracts/flashcard-repository.md` (bulk repository methods)
**Wireframes:** `docs/wireframes/06-flashcard-list.md` (selection mode + bulk action bar), `docs/wireframes/24-shared-dialogs.md` §bulk-delete, §reset-progress, `docs/wireframes/25-shared-bottom-sheets.md` §undo-toast
**Decision table:** rows under "Bulk operations"
**Code paths:** `lib/domain/usecases/bulk/**`
