---
last_updated: 2026-05-29
applies_to: future per-card study history view, attempt timeline
status: Future Proposal — Migration Required
related_decision: docs/checklist/product-decisions-pending-2026-05-29.md
---

# Card History

> **Status: Future Proposal — Migration Required.** This is not V1 implementation scope. Do not build the screen, route, use cases, repository queries, or entry links until the feature is promoted in `docs/checklist/v1-implementation-scope-2026-05-29.md`.
>
> **Migration dependency.** This spec depends on the following columns from `docs/database/schema-contract.md` §Pending schema changes:
>
> - `flashcard_progress.last_reset_at INTEGER NULL`
> - `study_attempts.box_before INTEGER NOT NULL DEFAULT 0`
> - `study_attempts.box_after INTEGER NOT NULL DEFAULT 0`
>
> Migration MUST run before card-history view, reset progress, or any attempt insert that needs box transition. Backfill: pre-migration `study_attempts` rows get `box_before=0`, `box_after=0`; UI renders `0` as `—`. Blocks: card history screen, reset progress (single + bulk), study result box-change aggregates, progress screen box-distribution chart.

## V1 decision

Card History is downgraded to Future Proposal for V1. The data model is still documented so the future implementation remains clear, but V1 must not expose a live `View history` action.

## Purpose

When a user repeatedly forgets a card, they need to see the pattern: "Have I always struggled with this?" or "When did I last get it right?". Today, `study_attempts` stores every answer but there is no UI surface to inspect it. This doc specs the per-card history view.

## Data source

`study_attempts` (existing table, see `docs/database/schema-contract.md`).

Per-card query:

```sql
SELECT a.* FROM study_attempts a
INNER JOIN study_session_items i ON a.session_item_id = i.id
WHERE i.flashcard_id = :flashcardId
ORDER BY a.attempted_at DESC;
```

No new table required.

## Future surfaces

These are proposal entry points only. V1 must keep these triggers hidden or
disabled until Card History is promoted and the required migration is approved.

| Surface | Trigger |
| --- | --- |
| Card detail or flashcard editor | Future "View history" action |
| Suspended/buried card list | Future "View history" action |
| Search result (flashcard) | Future long-press → "View history" |
| Study session (current card) | Future action menu → "View history of this card" (opens overlay, does not exit session) |

## Card history screen

Route: suggested `/library/deck/:deckId/flashcards/:flashcardId/history` (verify in router; update `docs/business/navigation/navigation-flow.md` when wiring).

### Header section

| Element | Source |
| --- | --- |
| Front preview | `flashcards.front` (truncated) |
| Current SRS state | "Box {n} of 8 • Due {relativeTime}" or "Suspended" or "Buried until tomorrow" |
| Lifetime stats | "Reviewed {reviewCount} times • Forgotten {lapseCount} times • Accuracy {x}%" |

Accuracy = `(reviewCount - lapseCount) / reviewCount` when `reviewCount > 0`, else "—".

### Timeline section

Chronological list (newest first) of attempts:

| Column | Source |
| --- | --- |
| Date/time | `attempted_at` (formatted as relative or absolute toggle) |
| Result | `result` value with visual indicator (✓ perfect, ✓ initial_passed, ⚠ recovered, ✗ forgot) |
| Mode | `study_mode` used at the time (review/match/guess/recall/fill) |
| Box transition | "Box {box_before} → {box_after}" from `study_attempts.box_before` / `box_after` columns |
| Session link | Tap → opens session result screen (if session is `completed`) |

Pagination: 50 attempts per page; infinite scroll. Cards rarely have more than 50 attempts but heavy users may.

Divider rows are inserted at positions matching `last_reset_at` timestamp (see "Progress reset divider" below).

### Visualizations (optional, lightweight)

Below the timeline, a small section:

- Heatmap: last 90 days, dots colored by accuracy that day. Skipped days greyed out.
- Box progression graph: line chart of `box_after` over time.

If implementing graphs increases scope significantly, defer to a later iteration. Timeline alone is the minimum value.

## Actions from history view

| Action | Behavior |
| --- | --- |
| Edit card | Opens flashcard edit screen |
| Suspend / unsuspend | Toggles `is_suspended` (see `docs/business/study-actions/bury-suspend.md`) |
| Reset progress | Confirmation → reset SRS state (box=1, counters=0, due=now). Attempts retained. |
| Delete card | Confirmation → delete cascade |

"Reset progress" is potentially useful when a card was placed in a wrong box (e.g., user accidentally answered correctly while distracted, then card moved to high box). Confirmation must clarify "Attempts history is kept; only SRS state is reset."

## Rules

- History MUST be read-only with respect to `study_attempts`. No edit/delete of attempt rows.
- Box transitions in the timeline come from `study_attempts.box_before` and `study_attempts.box_after` — both columns required. See `docs/database/schema-contract.md` for the migration.
- Lifetime stats come from `flashcard_progress` (current view) plus `study_attempts` (historical), not recomputed across all attempts every load.
- Reset progress MUST NOT delete attempts.
- Reset progress MUST insert a synthetic divider row OR be reconstructible from `flashcard_progress` history; see "Progress reset divider" below.
- History view is account-scoped (current active account database only).
- A card with zero attempts shows "No study history yet" empty state and links to "Start study" on the deck.

## Progress reset divider

When the user (or a bulk operation) resets a card's SRS progress, the history timeline MUST show a visual divider so the user can distinguish post-reset attempts from prior history.

### Implementation

Store reset events on `flashcard_progress` history or on a dedicated table — either approach works. Recommended: add a lightweight log table `flashcard_progress_resets` with `(flashcard_id, reset_at)` rows. Each row produces one divider.

Alternative (lower complexity): persist a single `last_reset_at INTEGER NULL` field on `flashcard_progress`. Drawback: only the most recent reset is shown. Acceptable for personal-use scale.

This doc recommends the `last_reset_at` field; revisit if multiple resets per card become common.

### Timeline rendering

Timeline (newest first) intersperses divider rows where applicable:

```
[Today 14:30] result=perfect    Box 4 → 5
[Today 14:20] result=forgot     Box 5 → 1
[Today 14:18] result=forgot     Box 5 → 1
—— Progress reset on 2026-04-12 ——
[2026-03-21 09:10] result=perfect Box 5 → 5 (max)
[2026-03-15 09:05] result=perfect Box 4 → 5
...
```

Divider is non-interactive. Tap is a no-op.

### Lifetime stats clarification

Lifetime stats remain cumulative across resets (preserve "total times reviewed" sense). Header copy must clarify this so the user understands why box=1 can coexist with reviewCount=50:

- "Reviewed 50 times • Forgotten 5 times • Accuracy 90%"
- Sub-label (small text): "Includes attempts before last reset on {date}." (shown only when `last_reset_at` is not null)

## Edge cases

| Case | Behavior |
| --- | --- |
| Card has thousands of attempts | Paginate; do not load all into memory |
| Card was deleted then recreated | Different `flashcard.id`; history is per-id, so this is a fresh card |
| Card moved via deck change | Attempts retained; history persists across deck changes (per-card not per-deck) |
| Session was `cancelled` mid-card | Attempts within that session still appear with cancelled-session label |
| Card reset multiple times (with `last_reset_at` field approach) | Only the most recent reset divider is shown. Acceptable trade-off; revisit if needed. |
| Reset progress then immediately study | Header shows `box=1, due=now`; lifetime stats still cumulative; divider sits at top of history below the new attempts |
| Reset on a card with zero attempts | `last_reset_at` set but timeline still empty state. Divider not rendered when no attempts above it. |
| Stats lookup when `last_reset_at != null` | Header sub-label visible: "Includes attempts before last reset on {date}." |

## Performance

- Timeline query: indexed on `study_session_items(flashcard_id)` and `study_attempts(session_item_id)`. Add compound index if necessary.
- Lifetime stats: single aggregate query.
- Heatmap data: 90-day aggregate, single query grouped by date.

## Required UI states

- Loading.
- Empty (no attempts).
- Error.
- Normal (with timeline).
- Card deleted while viewing → error state + back navigation.

## Agent rule

- Do NOT delete from `study_attempts` for any reason except cascade from session/item deletion.
- "Reset progress" only touches `flashcard_progress`, not `study_attempts`. It MUST also update `last_reset_at` so the timeline can render the divider.
- `study_attempts.box_before` and `box_after` are required for every new attempt insert. Backfill on migration: see `docs/database/schema-contract.md`.
- History is per-card. Do not create a parallel "session history" surface in this doc.
- Divider row is purely a UI affordance. Do not persist divider rows in `study_attempts`.

## Related

**Wireframes:**

- `docs/wireframes/09-flashcard-history.md` — full timeline screen with divider row and lifetime stats
- `docs/wireframes/08-flashcard-edit.md` — V1 editor explicitly does not expose a live "View history" action
- `docs/wireframes/24-shared-dialogs.md` §reset-progress (single + bulk variants)

**Schema:**

- `docs/database/schema-contract.md` → `study_attempts` with NEW columns `box_before` and `box_after` (both in 6 pending migrations)
- `flashcard_progress.last_reset_at INTEGER NULL` (in 6 pending migrations)
- Recommended index: `study_attempts(box_after)` (after profiling)

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows H1-H8 (history rendering, divider rules, pre-migration row handling)

**Glossary terms:**

- `docs/business/glossary.md` → "card history", "progress reset", "reset divider", `last_reset_at`, `box_before`, `box_after`

**Related business specs:**

- `docs/business/srs/srs-review.md` — attempt insert MUST populate box_before/box_after
- `docs/business/study/study-flow.md` — attempts written during study session
- `docs/business/flashcard/flashcard-management.md` — reset progress action
- `docs/business/bulk/bulk-operations.md` — bulk reset progress sets last_reset_at per card

**Source files to inspect:**

- `lib/domain/usecases/history/get_card_history_usecase.dart`
- `lib/domain/usecases/history/reset_progress_usecase.dart`
- `lib/data/repositories/study_attempt_repository.dart`
- `lib/presentation/features/history/**`
