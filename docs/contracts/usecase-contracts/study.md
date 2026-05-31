---
last_updated: 2026-05-28
status: contract
---

# Study Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Session lifecycle, scope resolution, grading, finalization.

## ResolveScopeUseCase

```dart
Future<Either<Failure, ResolvedScope>> call({
  required EntryType entryType,
  required EntryRefId entryRefId,
  required StudyType studyType,
});
```

**Returns:** list of candidate flashcards in scope, post-filter (excludes suspended, excludes buried if `buried_until > now`), and the empty-scope variant code if list is empty.

**Errors:** `NotFoundFailure` (deck/folder doesn't exist), `ValidationFailure` (invalid entry_ref_id for tag type), `StorageFailure`.

## FindResumableSessionUseCase

```dart
Future<Either<Failure, ResumableSession?>> call({required StudyScope scope});
```

**Rules:**

- Match `study_sessions` where `(entry_type, entry_ref_id)` equals scope AND `status IN (draft, in_progress)` AND `started_at > now - 30 days`.
- Return most recent match (or null).

**Errors:** `StorageFailure`.

## CreateSessionUseCase

```dart
Future<Either<Failure, Session>> call({
  required StudyScope scope,
  required List<FlashcardId> flashcardIds,
});
```

**Rules:**

- Atomic insert session + per-card session_items (order preserved). See `docs/contracts/repository-contracts/study-repository.md`.

**Errors:** `StorageFailure`.

## ResumeSessionUseCase

```dart
Future<Either<Failure, Session>> call({required SessionId id});
```

**Rules:**

- LOAD session. Validate `status IN (draft, in_progress)`. Else `UnsupportedActionFailure`.
- Return session + remaining items.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure`, `StorageFailure`.

## CancelSessionUseCase

```dart
Future<Either<Failure, Unit>> call({required SessionId id});
```

**Rules:**

- UPDATE `study_sessions.status = cancelled`.
- Already-recorded `study_attempts` preserved.

**Errors:** `NotFoundFailure`, `StorageFailure`.

## GradeAttemptUseCase

```dart
Future<Either<Failure, FlashcardProgress>> call({
  required SessionId sessionId,
  required FlashcardId flashcardId,
  required AttemptResult result,
  required StudyMode studyMode,
  String? userInput,  // for fill mode only (recall in v1 has no input)
  bool overrideApplied = false,
});
```

**Rules:**

- LOAD session. Validate status=`in_progress` or transitioning from `draft` → `in_progress`.
- LOAD current `flashcard_progress`. Compute `box_before = current_box`, `box_after` per SRS rules:
  - `perfect` / `initialPassed` → `min(current+1, 8)`
  - `recovered` → `current` (stay)
  - `forgot` → `1`
- Compute `due_at` from the box-interval table for `box_after` (current runtime helper: `_intervalForBox` in `lib/data/repositories/study_repo_impl_mapping_helpers.dart`; see `docs/business/srs/srs-review.md` §Interval table for the pending ladder decision).
- Atomic: insert `study_attempts` (sessionId, flashcardId, result, studyMode, box_before, box_after, attempted_at=now, optional userInput) + update `flashcard_progress` (current_box=box_after, due_at, review_count++, lapse_count++ if forgot, last_studied_at=now, last_result=result) + advance session status `draft → in_progress` if needed. See `docs/contracts/repository-contracts/progress-repository.md`.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure` (session completed), `StorageFailure`.

**Test refs:** GA1-GA10, SRS rows.

## FinalizeSessionUseCase

```dart
Future<Either<Failure, SessionAggregate>> call({required SessionId id});
```

**Rules:**

- LOAD session. Validate all `study_session_items` answered. Else `ValidationFailure(code: incompleteSession)`.
- Compute aggregate from `study_attempts`.
- Atomic: mark session completed + engagement counter updates. On partial failure (attempts saved, aggregate write failed): mark `failed_to_finalize`, return `FinalizationFailure`. See `docs/contracts/repository-contracts/study-repository.md`.

**Errors:** `NotFoundFailure`, `ValidationFailure`, `FinalizationFailure`, `StorageFailure`.

## RetryFinalizationUseCase

```dart
Future<Either<Failure, SessionAggregate>> call({required SessionId id});
```

Idempotent. Re-runs finalization on a `failed_to_finalize` session.

## BuryCardUseCase

```dart
Future<Either<Failure, FlashcardProgress>> call({required FlashcardId id});
```

**Rules:**

- UPDATE `flashcard_progress.buried_until = next local midnight`.
- SRS state (current_box, due_at) UNCHANGED.

**Errors:** `NotFoundFailure`, `StorageFailure`.

**Test refs:** BS1.

## SuspendCardUseCase / UnsuspendCardUseCase

```dart
Future<Either<Failure, FlashcardProgress>> suspend({required FlashcardId id});
Future<Either<Failure, FlashcardProgress>> unsuspend({required FlashcardId id});
```

**Rules:**

- Toggle `flashcard_progress.is_suspended`.
- SRS state UNCHANGED.

**Errors:** `NotFoundFailure`, `StorageFailure`.

**Test refs:** BS2.

## GetSessionStateUseCase

```dart
Future<Either<Failure, SessionState>> call({required SessionId id});
```

Returns session + answered count + total + next pending item.

## WatchDueCountsUseCase

```dart
Stream<Either<Failure, DueCounts>> call();
```

Returns due counts grouped (all / per deck / per folder) — used by Dashboard Today CTA and Library row badges.

## Forbidden patterns

- ❌ Update `current_box` outside `GradeAttemptUseCase` or `ResetFlashcardProgressUseCase`.
- ❌ Compute `due_at` outside the interval table.
- ❌ Finalize a session with unanswered items.
- ❌ Allow grade on a `completed`/`cancelled` session.
- ❌ Bury/suspend modify `current_box` or `due_at`.
- ❌ Delete `study_attempts` on cancel.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business specs:** `docs/business/study/study-flow.md`, `docs/business/srs/srs-review.md`, `docs/business/study-actions/bury-suspend.md`, `docs/business/resume/resume-session.md`
**Repository:** `docs/contracts/repository-contracts/study-repository.md`, `docs/contracts/repository-contracts/progress-repository.md`
**Wireframes:** `docs/wireframes/12-study-entry-gate.md` through `docs/wireframes/18-study-result.md`
**Decision table:** rows S*, BS*, GA*, H3, F4*
**Code paths (verified 2026-05-28):** `lib/domain/study/usecases/study_usecases.dart` (canonical owner of all study lifecycle + grading use cases — `StartStudySessionUseCase`, `ResumeStudySessionUseCase`, `RestartStudySessionUseCase`, `AnswerFlashcardUseCase`, `AnswerCurrentModeBatchUseCase`, `AnswerCurrentModeItemGradesBatchUseCase`, `AnswerCurrentMatchModeBatchUseCase`, `SkipFlashcardUseCase`, `CancelStudySessionUseCase`, `FinalizeStudySessionUseCase`, `RetryFinalizeUseCase`); `lib/domain/study/strategy/` (per-flow strategy + mode-skip rules); `lib/data/repositories/study_repo_impl.dart` (+ helpers). The `lib/domain/usecases/study/**` and `lib/domain/srs/**` directories do NOT exist in the current codebase.
