---
last_updated: 2026-05-28
status: contract
---

# SRS Use Cases Contract

Pure SRS transition and due-date contracts. The target architecture is deterministic domain functions/services, but the current runtime owners are repository finalization helpers. Documented here for AI agent reference so future extraction does not change behavior accidentally.

> No `fpdart` / `Either<Failure, T>` disclaimer in this file. All functions here are pure synchronous logic that returns plain values or throws `AssertionError` on programmer error. They do not perform IO and therefore never return `Either`. Error/result wrapping concerns apply at the calling layer (`GradeAttemptUseCase`), not here. If a future change introduces IO into this layer, add the disclaimer per `docs/contracts/error-contract.md` and update this note.

## BoxIntervals

```dart
class BoxIntervals {
  static const Map<int, Duration> daysPerBox = {
    1: Duration(days: 1),
    2: Duration(days: 2),
    3: Duration(days: 3),
    4: Duration(days: 4),
    5: Duration(days: 5),
    6: Duration(days: 12),
    7: Duration(days: 30),
    8: Duration(days: 60),
  };

  static Duration forBox(BoxNumber box);
}
```

**Rules:**

- Returns Duration for a given box (1-8 inclusive).
- Asserts box in 1..8. Out-of-range = programmer error.

**Source (target/future extraction):** a future extracted domain helper if approved; no current `lib/domain/srs/box_intervals.dart` file exists.
**Source (current):** `_intervalForBox` in `lib/data/repositories/study_repo_impl_mapping_helpers.dart`. Prompt 12/13 identified a P2 product/docs mismatch between this table and runtime values; code owns runtime behavior until the canonical interval ladder is chosen.

## BoxTransition

```dart
class BoxTransition {
  static BoxNumber computeNext({required BoxNumber current, required AttemptResult result});
}
```

**Rules:**

| Current | Result | Next |
| --- | --- | --- |
| 1..7 | perfect, initialPassed | current+1 |
| 8 | perfect, initialPassed | 8 (capped) |
| 1..8 | recovered | current (no change) |
| 1..8 | forgot | 1 |

**Source (target/future extraction):** a future extracted domain helper if approved; no current `lib/domain/srs/box_transition.dart` file exists.
**Source (current):** `_reviewOutcome` in `lib/data/repositories/study_repo_impl_helpers.dart`, reached through `FinalizeStudySessionUseCase` -> `StudyRepository.finalizeSession` -> `_commitSrs`. The `Answer*UseCase` family records attempts and re-queues failed cards; it does not own final box transitions.

## DueDateComputer

```dart
class DueDateComputer {
  DueDateComputer(this._clock);
  final Clock _clock;

  DateTime computeFromBox(BoxNumber box);
}
```

**Rules:**

- `computeFromBox(box) = clock.now() + BoxIntervals.forBox(box)`.
- Uses injected `Clock` for testability.

**Source (target/future extraction):** a future extracted domain helper if approved.
**Source (current):** no dedicated `DueDateComputer` implementation exists. Runtime due dates are computed during study finalization by `_reviewOutcome` in `lib/data/repositories/study_repo_impl_helpers.dart`, using `_intervalForBox` in `lib/data/repositories/study_repo_impl_mapping_helpers.dart`.

## NextCardSelector

```dart
class NextCardSelector {
  List<Flashcard> orderQueue(List<Flashcard> candidates, StudyType studyType);
}
```

**Rules:**

- Target `srsReview`: order due candidates deterministically, with oldest-due cards first.
- Target `newCards`: order new candidates deterministically before applying any configured shuffle.
- Stable sort unless study settings explicitly shuffle.

**Source (target/future extraction):** a future extracted domain helper if approved.
**Source (current):** no dedicated `NextCardSelector` implementation exists. Runtime selection is implemented by `StudyRepoImpl.loadNewCards` and `StudyRepoImpl.loadDueCards` in `lib/data/repositories/study_repo_impl.dart`, backed by `_eligibleFlashcards` in `lib/data/repositories/study_repo_impl_helpers.dart`. Current due-card SQL orders by `p.due_at ASC, f.sort_order ASC`; new-card SQL orders by `f.sort_order ASC`; repository settings may then shuffle the loaded batch.

## LifetimeStatsComputer

```dart
class LifetimeStatsComputer {
  LifetimeStats compute(FlashcardProgress progress);
}
```

**Rules:**

- `accuracy = (review_count - lapse_count) / review_count` if review_count > 0, else 0.0.
- Uses counters on `flashcard_progress` directly. Does NOT scan `study_attempts`.

**Source (target/future extraction):** a future extracted domain helper if approved.
**Source (current):** no dedicated `LifetimeStatsComputer` implementation exists. Current runtime does not expose this standalone lifetime-stats abstraction; existing SRS counters are persisted on `flashcard_progress`, while result-screen accuracy is session-scoped rather than lifetime-scoped.

## Forbidden patterns

- ❌ Hardcode interval days outside the current runtime owner (`_intervalForBox`) or a future approved `BoxIntervals` extraction.
- ❌ Box transition computed inline in a notifier or widget.
- ❌ Different transition rules per study mode (mode does NOT affect transition).
- ❌ Use `DateTime.now()` directly. Always via injected `Clock`.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Repositories used:** Target/future extracted helpers would be pure domain logic. Current runtime behavior is inside `StudyRepoImpl` finalization and query/load helpers.

**Business spec:** `docs/business/srs/srs-review.md`
**Caller:** `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase
**Wireframes:** `docs/wireframes/13-study-session-review.md` through `docs/wireframes/17-study-session-fill.md`
**Decision table:** rows under "SRS"
**Code paths:** current SRS finalization lives in `lib/data/repositories/study_repo_impl_helpers.dart`, interval mapping lives in `lib/data/repositories/study_repo_impl_mapping_helpers.dart`, and due/new selection lives in `lib/data/repositories/study_repo_impl.dart` plus `lib/data/repositories/study_repo_impl_helpers.dart`. Target extracted domain paths may be added by a future refactor.
