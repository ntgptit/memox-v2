---
last_updated: 2026-05-28
status: contract
---

# SRS Use Cases Contract

Pure domain logic for box transitions and due-date computation. These are NOT use cases in the orchestration sense — they are deterministic pure functions / services consumed by `GradeAttemptUseCase`. Documented here for AI agent reference.

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

**Source (target):** `lib/domain/srs/box_intervals.dart`.
**Source (current):** not yet extracted into a dedicated file. Logic is inlined in `lib/domain/study/usecases/study_usecases.dart` and is a candidate for extraction. The contract above is still authoritative; implementations must satisfy it wherever they live today.

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

**Source (target):** `lib/domain/srs/box_transition.dart`.
**Source (current):** not yet extracted; transition logic is inlined in `lib/domain/study/usecases/study_usecases.dart` (`Answer*UseCase` family). Same contract applies wherever the function lives.

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

**Source:** `lib/domain/srs/due_date_computer.dart`.

## NextCardSelector

```dart
class NextCardSelector {
  List<Flashcard> orderQueue(List<Flashcard> candidates, StudyType studyType);
}
```

**Rules:**
- For `srsReview`: order by `due_at ASC`, then `current_box ASC` (oldest-due first, lowest box first as tiebreak).
- For `newCards`: order by `flashcards.created_at ASC` among cards in box 1 with no attempts.
- Stable sort.

**Source:** `lib/domain/srs/next_card_selector.dart`.

## LifetimeStatsComputer

```dart
class LifetimeStatsComputer {
  LifetimeStats compute(FlashcardProgress progress);
}
```

**Rules:**
- `accuracy = (review_count - lapse_count) / review_count` if review_count > 0, else 0.0.
- Uses counters on `flashcard_progress` directly. Does NOT scan `study_attempts`.

**Source:** `lib/domain/srs/lifetime_stats_computer.dart`.

## Forbidden patterns

- ❌ Hardcode interval days outside `BoxIntervals`.
- ❌ Box transition computed inline in a notifier or widget.
- ❌ Different transition rules per study mode (mode does NOT affect transition).
- ❌ Use `DateTime.now()` directly. Always via injected `Clock`.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Repositories used:** None (pure domain logic). Consumed by `docs/contracts/repository-contracts/progress-repository.md` (which writes the box transition results).

**Business spec:** `docs/business/srs/srs-review.md`
**Caller:** `docs/contracts/usecase-contracts/study.md` §GradeAttemptUseCase
**Wireframes:** `docs/wireframes/13-study-session-review.md` through `docs/wireframes/17-study-session-fill.md`
**Decision table:** rows under "SRS"
**Code paths:** `lib/domain/srs/**`
