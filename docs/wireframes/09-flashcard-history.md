---
last_updated: 2026-05-29
status: Future Proposal — not V1 scope
route: future /library/deck/:deckId/flashcards/:flashcardId/history
source_specs:
  - docs/business/history/card-history.md
  - docs/business/study-actions/bury-suspend.md
related_decision: docs/checklist/product-decisions-pending-2026-05-29.md
---

# 09 — Flashcard History

## V1 decision

This screen is a **Future Proposal** for V1. Do not implement the route, screen, use cases, repository queries, or entry links during V1.

If a UI surface still contains `View history`, hide it or keep it disabled until this feature is promoted.

Promotion requires schema migration for `flashcard_progress.last_reset_at`, `study_attempts.box_before`, and `study_attempts.box_after`, plus route/use case/repository/test work.

## Purpose

Per-card timeline showing every study attempt. Helps user spot patterns ("always struggling with this card") and decide on actions (suspend, reset).

## Layout

```
┌───────────────────────────────────────┐
│ ←   Card history                ⋮     │
├───────────────────────────────────────┤
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 안녕하세요                         │ │  ← Front preview (truncated)
│ │ Hello                             │ │     back as subtitle
│ │                                   │ │
│ │ Box 3 of 8 · Due in 2 days        │ │  ← Current state
│ │                                   │ │
│ │ Reviewed 50 times · Forgot 5      │ │  ← Lifetime stats
│ │ Accuracy 90%                      │ │
│ │ ⓘ Includes attempts before last   │ │  ← Shown when last_reset_at != null
│ │   reset on 2026-04-12.            │ │
│ └───────────────────────────────────┘ │
│                                       │
│ Timeline                              │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ Today 14:30                       │ │
│ │ ✓ Perfect           Box 4 → 5     │ │
│ ├───────────────────────────────────┤ │
│ │ Today 14:20                       │ │
│ │ ✗ Forgot            Box 5 → 1     │ │
│ ├───────────────────────────────────┤ │
│ │ Today 14:18                       │ │
│ │ ✗ Forgot            Box 5 → 1     │ │
│ ├═══════════════════════════════════┤ │
│ │ ─── Progress reset on 2026-04-12  │ │  ← DIVIDER ROW
│ ├═══════════════════════════════════┤ │
│ │ 2026-03-21 09:10                  │ │
│ │ ✓ Perfect           Box 5 → 5     │ │
│ ├───────────────────────────────────┤ │
│ │ 2026-03-15 09:05                  │ │
│ │ ✓ Perfect           Box 4 → 5     │ │
│ ├───────────────────────────────────┤ │
│ │ 2026-03-10 14:00                  │ │
│ │ ⚠ Recovered         Box 4 → 4     │ │
│ │     mode: recall                  │ │  ← Mode label optional
│ └───────────────────────────────────┘ │
│                                       │
│      [ Load more (12) ]               │  ← Pagination
│                                       │
└───────────────────────────────────────┘
```

## Layout — empty state

```
┌───────────────────────────────────────┐
│ ←   Card history                      │
├───────────────────────────────────────┤
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 안녕하세요                         │ │
│ │ Hello                             │ │
│ │                                   │ │
│ │ Box 1 of 8 · Due now              │ │
│ │ No reviews yet                    │ │
│ └───────────────────────────────────┘ │
│                                       │
│           📊                           │
│                                       │
│      No study history yet.            │
│                                       │
│   Start a study session on this deck  │
│   to see this card's progress here.   │
│                                       │
│   [ Start study ]                     │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `deckId` (required path param) | URL | parent deck |
| `flashcardId` (required path param) | URL | card whose history to show |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Card preview (front, back truncated) | `flashcards` lookup | once |
| Current SRS state (current_box, due_at, is_suspended) | `flashcard_progress` lookup | once |
| Lifetime stats (review_count, lapse_count, accuracy, last_reset_at) | `flashcard_progress` counters | once |
| First page of attempts (LIMIT 50 ORDER BY attempted_at DESC) | `study_attempts WHERE flashcard_id = :id` | cursor pagination |
| Divider position | computed from `last_reset_at` vs row timestamps | derived from above |

## Forbidden

- ❌ Compute lifetime accuracy by scanning all attempts. Use stored counters.
- ❌ Allow inline edit of attempts. Read-only.
- ❌ Use OFFSET pagination. Use cursor on `attempted_at DESC`.
- ❌ Show "Box 0" — render `—` for box_before=0 or box_after=0 (pre-migration rows).
- ❌ Show divider when `last_reset_at` is null OR there are no attempts.
- ❌ Reset progress without updating `last_reset_at = now`.
- ❌ Auto-refresh timeline on every attempt insert; refresh only on screen visibility change OR explicit pull-to-refresh.

## Components

| Component | Spec |
| --- | --- |
| App bar | Back, title "Card history", overflow ⋮ (Edit card / Suspend / Reset progress / Delete). |
| Header card | Front preview, back subtitle, current state line, lifetime stats. Sub-label visible only when `last_reset_at != null`. |
| Timeline | Vertical list, newest first. 50 per page. Tap → opens session result (if completed). |
| Divider row | Visual separator inserted at `last_reset_at` position. Non-tappable. Wider stroke. |
| Load more | Button at bottom when more pages available. |
| Empty state | When zero attempts, replaces timeline section. CTA opens deck study. |

## Timeline row shape

```
{relative or absolute date/time}
{result icon} {result label}      Box {before} → {after}
[mode: {mode}]   optional, smaller text
```

Result label mapping:

| `result` | Icon | Label |
| --- | --- | --- |
| `perfect` | ✓ green | Perfect |
| `initial_passed` | ✓ green | Passed |
| `recovered` | ⚠ yellow | Recovered |
| `forgot` | ✗ red | Forgot |

When `box_before = 0` or `box_after = 0` (pre-migration data), render `—` instead of `Box 0`.

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Initial fetch | Skeleton header + timeline rows. |
| Populated | Has attempts | Header + timeline visible. |
| Empty | Zero attempts | Empty layout. |
| Loading more | Tap Load more | Inline spinner; append on success. |
| Card not found | Card deleted | "Card no longer exists" error + back. |
| Reset done | After reset progress | Header updates; divider appears at top of timeline. |
| Error | Query failure | Inline error card with retry. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap back | Back | Pop. |
| Tap overflow ⋮ | Tap | Menu: Edit card / Suspend (or Unsuspend) / Reset progress / Delete. |
| Tap "Start study" (empty) | Tap | Navigate to deck study entry gate. |
| Tap timeline row | Tap | Open session result screen if session is `completed`. No-op otherwise. |
| Tap Load more | Tap | Fetch next page. |

## Dialogs and bottom-sheets used

- Reset progress dialog — `docs/wireframes/24-shared-dialogs.md` §reset-progress.
- Delete card dialog — `docs/wireframes/24-shared-dialogs.md` §delete-confirm.

## Navigation in

- "View history" action in flashcard edit screen.
- "View history of this card" overlay action in study session.
- Long-press card → context sheet → "View history" (if available).

## Navigation out

- Back → flashcard edit or list (depending on source).
- "Start study" empty CTA → study entry gate.
- Timeline row tap → session result.
- Overflow actions → confirm dialogs then back.

## Responsive

- ≥600dp: header card and timeline side-by-side; timeline scrollable in right column.

## Performance

- Initial query: paginated 50 rows.
- Lifetime stats: pre-aggregated from `flashcard_progress.review_count` / `lapse_count`.
- Divider position determined client-side via single `last_reset_at` field comparison.

## Accessibility

- Each timeline row labeled "{date}, {result}, box {before} to {after}".
- Divider row labeled "Section divider: progress reset on {date}" with role=separator.
- Empty state CTA focusable.

## Rules

- Timeline is read-only.
- Divider only renders when `last_reset_at` is non-null AND there are attempts both above (newer) and below (older) the reset point.
- If reset happened but no attempts existed before reset, no divider needed (timeline starts post-reset).
- `box_before` / `box_after` from `study_attempts`. If 0, render `—`.

## Agent rule

- V1: Do NOT implement this screen.
- V1: Do NOT wire a live `View history` action.
- Future: implement only after the schema migration and scope promotion are approved.

- Do NOT recalculate accuracy on every render; use stored counters.
- Do NOT add inline edit of attempts. Read-only.
- Reset progress from this screen MUST update `last_reset_at = now` AND refresh the timeline so divider appears.
- "Load more" pagination uses cursor based on `attempted_at DESC`; do NOT use offset (perf reason).

## Implementation refs

**Business specs:**

- `docs/business/history/card-history.md`
- `docs/business/srs/srs-review.md` (box transitions)

**Decision rows:**

- H1-H8 (history rendering, divider, pre-migration row handling, header sub-label)

**Schema / storage:**

- READ `study_attempts` (box_before, box_after, result, attempted_at) paginated DESC
- READ `flashcard_progress.last_reset_at`, lifetime counters
- Cursor-based pagination on `attempted_at DESC`

**Contracts:** `docs/contracts/usecase-contracts/history.md`, `docs/contracts/repository-contracts/progress-repository.md`

**Code paths:**

- `lib/presentation/features/history/screens/card_history_screen.dart`
- `lib/presentation/features/history/notifiers/card_history_notifier.dart`
- `lib/presentation/features/history/widgets/timeline_row.dart`
- `lib/presentation/features/history/widgets/reset_divider.dart`
- `lib/domain/usecases/history/get_card_history_usecase.dart`
- `lib/domain/usecases/history/get_lifetime_stats_usecase.dart`
- `lib/app/router/route_names.dart` → `RouteNames.flashcardHistory`

**Related wireframes:**

- `docs/wireframes/08-flashcard-edit.md` (entry point), `docs/wireframes/18-study-result.md` (timeline row tap target if completed)
