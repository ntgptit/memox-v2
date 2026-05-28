---
last_updated: 2026-05-26
applies_to: SRS algorithm, flashcard_progress, review session finalization
---

# SRS Review

> **Status: Target — Partial Migration Required.** Box transition logic itself is implementable today on `flashcard_progress` and `study_attempts`. However, persisting per-attempt box transitions for history requires the following columns from `docs/database/schema-contract.md` §Pending schema changes:
> - `study_attempts.box_before INTEGER NOT NULL DEFAULT 0`
> - `study_attempts.box_after INTEGER NOT NULL DEFAULT 0`
>
> `GradeAttemptUseCase` MUST populate both columns on every insert. Pre-migration rows are backfilled with `0`. Blocks (until migration): card history timeline, study result box-change aggregates, progress screen box distribution from attempts.

## Source files to inspect

- `lib/domain/**progress**`
- `lib/domain/**study**`
- `lib/data/**progress**`
- `lib/data/**study**`
- `lib/data/datasources/local/tables/flashcard_progress_table.dart`
- `lib/data/datasources/local/tables/study_attempts_table.dart`
- `lib/domain/srs/box_intervals.dart` (interval source)

## Data

SRS state is stored in `flashcard_progress`.

Important fields:

- `flashcard_id`
- `current_box` (1-8)
- `review_count`
- `lapse_count`
- `last_result`
- `last_studied_at` (UTC epoch ms)
- `due_at` (UTC epoch ms)

## Rules

- Box range is 1 to 8 inclusive.
- New flashcard starts at `current_box = 1` with `due_at = now`.
- Due card: `due_at <= now`.
- Deleted flashcards must not appear in due list (foreign key enforced).
- Review result must update progress through domain/use case/repository flow.
- UI must not update SRS box directly.
- SRS review must use study session tables.
- Do not add separate review tables unless schema change is explicitly approved.

## Review results

See `docs/business/glossary.md` for result definitions.

| Result | When it applies |
| --- | --- |
| `initial_passed` | Correct on first attempt for this card in this session |
| `perfect` | Correct without any retry within the session cycle |
| `recovered` | Correct after at least one retry within the session |
| `forgot` | Failed (used up retries or explicit "I don't know") |

## Box transition table

This is the authoritative transition contract. Implementation in `lib/domain/srs/box_transition.dart` must match this table.

| Current box | Result | Next box | Next due |
| --- | --- | --- | --- |
| n (1-7) | `perfect` | n + 1 | now + interval[n + 1] |
| n (1-7) | `initial_passed` | n + 1 | now + interval[n + 1] |
| 8 | `perfect` | 8 (stay) | now + interval[8] |
| 8 | `initial_passed` | 8 (stay) | now + interval[8] |
| n (1-8) | `recovered` | n (stay) | now + interval[n] |
| n (1-8) | `forgot` | 1 | now + interval[1] |

## Interval table

Intervals are defined in `lib/domain/srs/box_intervals.dart`. Current values:

| Box | Interval | Approx | Rationale |
| --- | --- | --- | --- |
| 1 | 1 day | 1 day | Same-day-next retry; force overnight memory consolidation before re-test |
| 2 | 2 days | 2 days | Gentle stretch |
| 3 | 3 days | 3 days | Gentle stretch |
| 4 | 4 days | 4 days | Gentle stretch |
| 5 | 5 days | 5 days | Gentle stretch |
| 6 | 12 days | ~2 weeks | First larger jump after solid short-term retention |
| 7 | 30 days | 1 month | Long-term retention check |
| 8 | 60 days | 2 months | Maintenance |

Design intent: avoid overwhelming the user. Box 1 → 5 increases linearly by one day, so each successive review feels like a small step. Larger jumps reserved for boxes 6+ where the card is already stable.

When implementation differs from this table, the source file wins, but this doc must be updated in the same commit.

## Counter rules

| Counter | When incremented |
| --- | --- |
| `review_count` | Every finalized review (any result) |
| `lapse_count` | Only on `forgot` result |

## Finalization

At session finalization:

1. Persist all attempts (already done during session).
2. Compute final result per item based on attempt history and flow.
3. Update progress: `current_box`, `review_count`, `lapse_count`, `last_result`, `last_studied_at`, `due_at`.
4. Update session status to `completed`.

All steps must be in a single transaction. See `docs/database/storage-boundaries.md`.

On failure:

- Set session status to `failed_to_finalize`.
- Do not partially update progress.
- Allow retry.

## Due query contract

The due query must:

- Filter by `due_at <= now`.
- Exclude deleted flashcards (foreign key, but enforce in query).
- Order by `due_at ASC` then `current_box ASC`.
- Scope correctly (deck / folder recursive / all).

## Agent rule

Any SRS behavior change must update:

- `lib/domain/srs/**` implementation
- This doc (transition table and/or interval table)
- `docs/business/study/study-flow.md` if flow changes
- Decision table S6-S10
- Targeted tests in `test/domain/srs/**`

## Related

**Wireframes:**
- `docs/wireframes/13-study-session-review.md` through `docs/wireframes/17-study-session-fill.md` — every mode persists SRS update via this contract
- `docs/wireframes/18-study-result.md` — Box changes block aggregates from `box_before` / `box_after`
- `docs/wireframes/03-progress.md` — Box distribution chart

**Schema:**
- `docs/database/schema-contract.md` → `flashcard_progress` (current_box 1-8, due_at, review_count, lapse_count, last_studied_at, last_result, last_reset_at), `study_attempts` (box_before, box_after, result)

**Decision table:**
- `docs/decision-tables/memox-core-decision-table.md` rows under "SRS" + history rows H1-H8

**Glossary terms:**
- `docs/business/glossary.md` → `current_box`, `due_at`, `result`, `perfect`, `initial_passed`, `recovered`, `forgot`, `lapse_count`

**Related business specs:**
- `docs/business/study/study-flow.md` — caller of SRS update
- `docs/business/history/card-history.md` — read-only view of attempts
- `docs/business/study-actions/bury-suspend.md` — bury/suspend preserves SRS state (does NOT reset box)
- `docs/business/flashcard/flashcard-management.md` — reset progress sets box=1, last_reset_at=now

**Source files to inspect:**
- `lib/domain/srs/box_intervals.dart`
- `lib/domain/srs/box_transition.dart`
- `lib/domain/srs/srs_service.dart`
- `lib/data/repositories/srs_repository.dart`
- `lib/domain/usecases/study/grade_attempt_usecase.dart`
