---
last_updated: 2026-05-26
status: contract
---

# Study Repository Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Sessions + session items. Attempts and progress live in `docs/contracts/repository-contracts/progress-repository.md`.

## Methods

```dart
// Queries
Stream<Session?> watchSessionById(SessionId id);
Stream<List<ResumableSession>> watchResumableSessions();
Future<Either<Failure, ResumableSession?>> findResumable(StudyScope scope);
Future<Either<Failure, Session>> findById(SessionId id);
Future<Either<Failure, List<SessionItem>>> getItemsForSession(SessionId id);
Future<Either<Failure, SessionAggregate>> computeAggregate(SessionId id);

// Mutations
Future<Either<Failure, Session>> createSession({
  required StudyScope scope,
  required List<FlashcardId> flashcardIds,
});
Future<Either<Failure, Unit>> markInProgress(SessionId id);
Future<Either<Failure, Unit>> markCompleted(SessionId id);
Future<Either<Failure, Unit>> markCancelled(SessionId id);
Future<Either<Failure, Unit>> markFailedToFinalize(SessionId id);
Future<Either<Failure, Unit>> markItemAnswered(SessionId id, FlashcardId flashcardId);
Future<Either<Failure, int>> expireOldSessions();  // cancel sessions > 30 days old
```

## Transaction requirements

| Operation | Tables touched |
| --- | --- |
| `createSession` | `study_sessions` INSERT + `study_session_items` INSERTs |
| `markCompleted` | `study_sessions` UPDATE + optional engagement update (handled by caller use case) |
| `expireOldSessions` | `study_sessions` UPDATE batch |

## Resumable matching rules

`findResumable(scope)` matches:

- `entry_type` equals scope.entryType
- `entry_ref_id` equals scope.entryRefId (NULL-safe)
- `status` is resumable/active according to the DAO query
- `started_at` > now - 30 days

Order by `started_at DESC`, return first.

Study type and flow are not part of the conflict key. A paused session for the
same scope blocks starting another session even when the requested mode/flow is
different; the Study Entry gate must offer Resume or Start over.

If loading the resume-candidate snapshot fails because the stored session is
stale or corrupt, candidate discovery logs the failure and returns null so the
user can start a new valid session. Explicit `loadSession(sessionId)` remains
strict and must surface the corruption instead of hiding it.

## Constraints

- Session `status` transitions allowed:
  - `draft` → `in_progress` (on first attempt)
  - `draft` / `in_progress` → `completed` (on finalize)
  - `draft` / `in_progress` → `cancelled` (on user action OR auto-expire)
  - `in_progress` → `failed_to_finalize` (partial finalize)
  - `failed_to_finalize` → `completed` (on retry)
- Any other transition is `UnsupportedActionFailure` at use case layer.
- New Study batch loading treats flashcards with missing `flashcard_progress`
  rows as new active cards. This keeps repaired or legacy local databases from
  failing Study Entry after the scope count has already found cards; progress is
  upserted when the session finalizes.

## Forbidden

- ❌ DELETE a session row. Use status=cancelled.
- ❌ Allow concurrent in_progress sessions for same scope (enforced via resume-or-start-over flow at use case).
- ❌ Compute aggregate by re-scanning every time. Cache result for `completed` sessions.

## Test contract

- Create session with N items → verify rows.
- Resumable matching across all 4 entry types.
- Status transitions: allowed and forbidden.
- 30-day expiry.
- Aggregate computation.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`

**Business spec:** `docs/business/study/study-flow.md`, `docs/business/resume/resume-session.md`
**Use cases:** `docs/contracts/usecase-contracts/study.md`
**Schema:** `docs/database/schema-contract.md` `study_sessions`, `study_session_items`
**Code paths:**

- `lib/domain/study/ports/study_repo.dart`
- `lib/data/repositories/study_repo_impl.dart`
- `lib/data/datasources/local/daos/study_session_dao.dart`
- `lib/data/datasources/local/daos/study_session_item_dao.dart`
