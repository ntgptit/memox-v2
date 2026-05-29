---
last_updated: 2026-05-26
status: contract
---

# Progress Repository Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

`flashcard_progress` + `study_attempts`. The SRS heart of the data layer.

## Methods

```dart
// Queries
Stream<FlashcardProgress?> watchProgress(FlashcardId id);
Future<Either<Failure, FlashcardProgress>> getProgress(FlashcardId id);
Future<Either<Failure, List<FlashcardProgress>>> getDueInScope(StudyScope scope, {DateTime? asOf});
Future<Either<Failure, int>> countSuspended();
Future<Either<Failure, int>> countBuriedToday();
Future<Either<Failure, Map<BoxNumber, int>>> getBoxDistribution();

// Attempts
Stream<List<StudyAttempt>> watchAttemptsByCard(FlashcardId id, {DateTime? before, int limit = 50});
Future<Either<Failure, List<StudyAttempt>>> getAttemptsBySession(SessionId id);
Future<Either<Failure, Map<DateTime, int>>> getAttemptCountsByDay(DateTime start, DateTime end);
Future<Either<Failure, Map<DateTime, double>>> getAccuracyByDay(DateTime start, DateTime end);
Future<Either<Failure, int>> getAttemptCountToday();

// Mutations
Future<Either<Failure, FlashcardProgress>> recordAttemptAndUpdateProgress({
  required SessionId sessionId,
  required FlashcardId flashcardId,
  required AttemptResult result,
  required StudyMode studyMode,
  required BoxNumber boxBefore,
  required BoxNumber boxAfter,
  required DateTime dueAt,
  String? userInput,
});
Future<Either<Failure, FlashcardProgress>> bury(FlashcardId id, DateTime until);
Future<Either<Failure, FlashcardProgress>> setSuspended(FlashcardId id, bool value);
Future<Either<Failure, FlashcardProgress>> resetProgress(FlashcardId id);
Future<Either<Failure, int>> bulkResetProgress(List<FlashcardId> ids);
```

## Transaction requirements

| Operation | Tables touched |
| --- | --- |
| `recordAttemptAndUpdateProgress` | `study_attempts` INSERT + `flashcard_progress` UPDATE (current_box, due_at, review_count++, lapse_count++ if forgot, last_studied_at, last_result) |
| `resetProgress` | `flashcard_progress` UPDATE: current_box=1, due_at=now, last_reset_at=now (counters UNCHANGED, attempts UNCHANGED) |
| `bulkResetProgress` | Single transaction across N rows |

## Index dependencies

These methods rely on indexes (recommend in `docs/database/schema-contract.md`):

- `getDueInScope` → `flashcard_progress(is_suspended, buried_until, due_at)`
- `watchAttemptsByCard` → `study_attempts(flashcard_id, attempted_at DESC)`
- `getBoxDistribution` → cheap aggregate, no special index
- `countSuspended` / `countBuriedToday` → `flashcard_progress(is_suspended, buried_until, due_at)`

## Constraints

- `current_box` ∈ 1..8.
- `box_before` and `box_after` in `study_attempts` MUST be populated (pending migration default 0; mapper handles pre-migration rows).
- `due_at` always reflects `current_box`.

## Forbidden

- ❌ Update `current_box` without inserting an attempt (unless via `resetProgress`).
- ❌ Insert attempt without updating progress.
- ❌ Delete attempts (history is permanent).
- ❌ Compute lifetime stats by scanning attempts when counters are sufficient.
- ❌ Use OFFSET for attempt pagination. Cursor only.

## Test contract

- `recordAttemptAndUpdateProgress` for each result type.
- Verify lapse_count increment only on `forgot`.
- Verify cap at 8.
- Reset progress → counters unchanged, last_reset_at set, attempts preserved.
- Bulk reset.
- Bury → due_at unchanged, buried_until set.
- Suspend toggle → SRS state unchanged.
- Box distribution aggregate.
- Time-range attempt count aggregate.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`

**Business specs:** `docs/business/srs/srs-review.md`, `docs/business/history/card-history.md`, `docs/business/study-actions/bury-suspend.md`
**Use cases:** `docs/contracts/usecase-contracts/study.md`, `docs/contracts/usecase-contracts/history.md`, `docs/contracts/usecase-contracts/srs.md`
**Schema:** `docs/database/schema-contract.md` `flashcard_progress`, `study_attempts`
**Code paths:**

- `lib/domain/repositories/flashcard_progress_repository.dart`
- `lib/domain/repositories/study_attempt_repository.dart` (may be split or unified)
- `lib/data/repositories/progress_repository_impl.dart`
- `lib/data/datasources/local/daos/flashcard_progress_dao.dart`
- `lib/data/datasources/local/daos/study_attempt_dao.dart`
