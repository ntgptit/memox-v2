---
last_updated: 2026-05-26
status: contract
---

# History Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.


Read-only timeline of per-card attempts + lifetime stats.

## GetCardHistoryUseCase

```dart
Future<Either<Failure, CardHistoryPage>> call({
  required FlashcardId id,
  DateTime? before,  // cursor
  int limit = 50,
});
```

**Rules:**
- READ `study_attempts WHERE flashcard_id = :id` ORDER BY `attempted_at DESC` LIMIT :limit (with cursor on `attempted_at < :before` if provided).
- Cursor pagination (NOT offset).

**Returns:** `CardHistoryPage { attempts: List<StudyAttempt>, nextCursor: DateTime? }`.

**Errors:** `NotFoundFailure` (card), `StorageFailure`.

**Test refs:** H1.

## GetCardLifetimeStatsUseCase

```dart
Future<Either<Failure, LifetimeStats>> call({required FlashcardId id});
```

**Rules:**
- READ counters from `flashcard_progress` directly. Do NOT scan attempts.
- Return `LifetimeStats` value object (see types-catalog.md).

**Errors:** `NotFoundFailure`, `StorageFailure`.

**Test refs:** H4.

## GetCardResetMarkerUseCase

```dart
Future<Either<Failure, DateTime?>> call({required FlashcardId id});
```

Returns `flashcard_progress.last_reset_at`. Used by timeline to position the reset divider row.

**Test refs:** H5, H7.

## Forbidden patterns

- ❌ Compute lifetime accuracy by scanning attempts. Use stored counters.
- ❌ Use OFFSET pagination. Cursor only.
- ❌ Allow inline edit of attempts (read-only).
- ❌ Render `Box 0` for pre-migration rows (box_before=0 or box_after=0). Render `—` instead.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`

**Business spec:** `docs/business/history/card-history.md`
**Repository:** `docs/contracts/repository-contracts/progress-repository.md` (attempts methods)
**Wireframes:** `docs/wireframes/09-flashcard-history.md`
**Decision table:** H1-H8
**Code paths:** `lib/domain/usecases/history/**`
