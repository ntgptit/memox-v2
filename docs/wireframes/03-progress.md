---
last_updated: 2026-05-26
route: /progress
source_specs:
  - docs/business/engagement/dashboard-engagement.md
  - docs/business/srs/srs-review.md
  - docs/business/system/overview.md
---

# 03 — Progress

## Purpose

Long-form analytics surface. Dashboard shows "today"; Progress shows trends and totals. Read-only.

Status in `docs/business/system/overview.md`: "Progress tracking — Partially specified (data only)". This wireframe is the visual contract for what we render from existing tables.

## Layout

```
┌───────────────────────────────────────┐
│ Progress                              │  ← App bar, no actions
├───────────────────────────────────────┤
│                                       │
│ ┌─[ Week ]─[ Month ]─[ All ]─────────┐│  ← Time range chips
│ └───────────────────────────────────┘│
│                                       │
│ ┌───────────────────────────────────┐ │
│ │  Cards studied                    │ │
│ │  ┌──────────────────────────────┐ │ │
│ │  │   ▁▂▄▇▇▆▃        bar chart   │ │ │  ← daily totals
│ │  └──────────────────────────────┘ │ │
│ │  124 this week  (avg 17/day)      │ │
│ └───────────────────────────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │  Accuracy                         │ │
│ │  ┌──────────────────────────────┐ │ │
│ │  │   ── line ──                 │ │ │
│ │  └──────────────────────────────┘ │ │
│ │  88% this week  ↑ 3% vs prev      │ │
│ └───────────────────────────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │  Box distribution                 │ │
│ │  Box 1  ████░░░░░  120            │ │  ← Per-box card count
│ │  Box 2  ███░░░░░░   95            │ │
│ │  Box 3  █████░░░░  140            │ │
│ │  Box 4  ██░░░░░░░   55            │ │
│ │  Box 5  ███░░░░░░   80            │ │
│ │  Box 6  ████░░░░░  110            │ │
│ │  Box 7  █████░░░░  150            │ │
│ │  Box 8  ███░░░░░░   88            │ │
│ └───────────────────────────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │  Streak                           │ │
│ │  🔥 7 days current                │ │
│ │  ⭐ 14 days longest                │ │
│ └───────────────────────────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │  Suspended cards            42 ▸  │ │  ← Tap → /library/.../?filter=suspended
│ │  Buried cards (today)        8 ▸  │ │
│ └───────────────────────────────────┘ │
│                                       │
├───────────────────────────────────────┤
│ 🏠 Home  📚 Library  📈 Progress  ⚙️  │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `range` (optional query param) | URL or in-memory | `week` / `month` / `all`; default `week` |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Daily attempt counts in range | `study_attempts` GROUP BY local-day, filtered by attempted_at | range chip change + new attempt |
| Daily accuracy in range | `study_attempts` aggregated (perfect+initial_passed) / total | same |
| Previous-range accuracy (for delta) | same query offset by range length | range change |
| Box distribution (1-8 counts) | `flashcard_progress` GROUP BY current_box | invalidate on flashcard_progress change |
| Current streak | `engagement_preferences` | watch |
| Longest streak | `engagement_preferences` | watch |
| Suspended count | `flashcard_progress WHERE is_suspended = 1` | watch |
| Buried today count | `flashcard_progress WHERE buried_until > now` | watch |

All queries are independent providers; UI fills in progressively.

## Forbidden

- ❌ Add edit actions. Progress is strictly read-only.
- ❌ Compute charts from scratch on every paint. Cache aggregates 60s.
- ❌ Use one shared empty state for all charts; each chart handles empty independently.
- ❌ Bury count copy says "this week" — buried is daily by definition.
- ❌ Sort box distribution by count; sort by box number (1→8) for predictable scan.

## Components

| Component | Spec |
| --- | --- |
| Time range chips | Three chips: Week (last 7 local-days), Month (last 30), All. Default: Week. |
| Cards studied chart | Bar chart, one bar per day in range. Y-axis = attempts count. |
| Accuracy chart | Line chart, daily accuracy %. Sub-label compares to previous range. |
| Box distribution | Static horizontal bars, one per box (1-8). Shows current card count per box. Doesn't filter by range. |
| Streak card | Current and longest. Mirror of Dashboard but in cumulative context. |
| Suspended/buried links | Tap → flashcard list with appropriate filter (note: "suspended" is global across all decks; this link opens a global suspended view if implementable, else falls back to deck list). |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Initial fetch | Skeletons per card. |
| Empty | Zero attempts in range | Show empty state per chart: "No data yet. Start studying to see trends." |
| Populated | Normal | Charts visible. |
| Insufficient data | < 2 days of data | Charts show single point/bar with hint "Track for more days to see trends". |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap time range chip | Tap | Re-fetch and re-render charts. |
| Tap suspended link | Tap | Navigate to flashcard list filtered to "suspended" — but suspended is global; route convention: `/library/search?filter=suspended` OR if not implemented, go to library with hint. |
| Tap buried link | Tap | Same pattern, filter=buried. |
| Tap any chart bar/point | Tap | Optional: show that day's detail toast. Skip if implementation effort is high. |

## Dialogs and bottom-sheets used

None native to this screen. Read-only.

## Navigation in

- Bottom nav tap "Progress".

## Navigation out

- Tabs → other top-level destinations.
- Suspended/buried row → flashcard list (filtered).

## Responsive

- ≥600dp: charts arranged in 2 columns. Box distribution stays full-width below.

## Performance

- Each chart: separate stream query. Don't block on slowest.
- Cache aggregates per range for 60s; invalidate on new attempt.
- Box distribution uses `flashcard_progress` aggregate, very cheap.

## Accessibility

- Charts have textual summary above (e.g., "124 this week, average 17 per day").
- Time range chips selectable via keyboard.
- Box distribution announces each box: "Box 1, 120 cards".

## Rules

- Range chips default Week.
- Box distribution does NOT filter by range (it's a snapshot).
- Charts MUST handle empty data gracefully (no NaN, no crash).
- Suspended/buried counts include all decks (account-scoped global).

## Agent rule

- Do NOT add edit actions here. Progress is read-only.
- Do NOT compute charts from scratch on every paint; cache.
- Empty state per chart, not one shared empty state across all charts (each chart fails independently).
- Buried count uses `buried_until > now` filter; "today" copy is correct only because bury duration is fixed to next-midnight.

## Implementation refs

**Business specs:**
- `docs/business/engagement/dashboard-engagement.md` (streak, goal)
- `docs/business/srs/srs-review.md` (box distribution semantics)

**Decision rows:**
- Engagement section, SRS section

**Schema / storage:**
- `study_attempts` (range aggregates)
- `flashcard_progress` (box distribution snapshot, `is_suspended`, `buried_until`)

**Contracts:** `docs/contracts/usecase-contracts/srs.md`, `docs/contracts/usecase-contracts/engagement.md`, `docs/contracts/repository-contracts/progress-repository.md`

**Code paths:**
- `lib/presentation/features/progress/screens/progress_screen.dart`
- `lib/presentation/features/progress/notifiers/progress_notifier.dart`
- `lib/domain/usecases/progress/get_range_aggregates_usecase.dart`
- `lib/domain/usecases/progress/get_box_distribution_usecase.dart`
- `lib/app/router/route_names.dart` → `RouteNames.progress`

**Related wireframes:**
- `docs/wireframes/01-dashboard.md` — Dashboard streak chip uses same source of truth
- `docs/wireframes/06-flashcard-list.md` — suspended/buried links navigate here (filtered)
