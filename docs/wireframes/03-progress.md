---
last_updated: 2026-05-31
route: /progress
source_specs:
  - docs/business/engagement/dashboard-engagement.md
  - docs/business/srs/srs-review.md
  - docs/business/system/overview.md
---

# 03 — Progress

## Purpose

Long-form analytics surface. Dashboard shows "today"; Progress shows trends and totals. Read-only.

Status in `docs/business/system/overview.md`: "Progress tracking — Partially specified (data only)". As of Prompt 20 (2026-05-31), the shipped V1 screen is a read-only Progress Overview focused on library summary metrics and active session recovery. The chart-heavy analytics layout below remains a target/Future analytics specification unless explicitly listed as Current in the V1 table.

## V1 verification status

| Section / behavior | Status | Current owner | Notes |
| --- | --- | --- | --- |
| `/progress` route | Current | `RouteNames.progress` / `RoutePaths.progress` in `lib/app/router/route_names.dart`; `progressBranchRoutes()` | Direct route opens `ProgressScreen` inside the shell. No new top-level route was added. |
| Bottom/app navigation to Progress | Current | `AppNavigation.goProgress()` + shell branch | Covered by router tests; shell navigation stays visible on `/progress`. |
| Read-only screen | Current | `lib/presentation/features/progress/screens/progress_screen.dart` | No edit actions, no Flashcard History, no Global Search, no Drive sync, no Settings mutation, no tag-scoped study. |
| Initial loading | Current | `MxRetainedAsyncState` in `ProgressOverviewSection` | First load shows shared loading UI, not a blank screen. |
| Error / retry | Current | `MxRetainedAsyncState` + `MxErrorState` | Repository/provider failure maps to safe shared error state with Try again; raw exception text is not shown by default. |
| Empty state | Current | `ActiveSessionsEmptyState` | Empty means no active/resumable study sessions. It does not invent fake analytics data. CTA opens Library. |
| Due/new/mastery summary | Current | `progressOverviewProvider` → `WatchLibraryOverviewUseCase.execute(ContentQuery())` | Renders Due now, New cards available, and Mastery from the same library overview read model used by the app's content layer. |
| Total cards | Current (data loaded), not directly labeled | `ProgressOverviewState.cardCount` | Loaded from `LibraryOverviewReadModel.cardCount`; V1 UI uses it indirectly through library/mastery context and does not display a separate "Total cards" stat. |
| Active / ready / failed session counts | Current | `ResumeStudySessionUseCase.listActiveSessions()` | Renders active session summary plus per-session cards. |
| Recent active session list | Current | `StudySessionCard` | Shows active/ready/failed sessions ordered by repository result, with localized status, current card when present, formatted started date/time, progress steps, Continue/Finalize/Retry/Cancel actions. This is not historical completed-session analytics. |
| Cards-studied chart | Future | Not implemented | No daily attempt aggregate use case/repository exists in V1. |
| Accuracy chart / review accuracy | Future | Not implemented | No range accuracy aggregate is rendered. |
| Box distribution | Future | Not implemented | `flashcard_progress.current_box` exists for SRS, but Progress does not render the 1-8 distribution yet. |
| Streak / daily goal / engagement widgets | Future | Not implemented | Engagement remains out of Prompt 20 scope. Do not implement from this wireframe target block. |
| Suspended / buried links | Future | Not implemented | No `/library/search?filter=...` Global Search route is available in V1. |
| Flashcard History / study history list | Future | Not implemented | Flashcard History remains Future Proposal and must not be exposed from Progress. |

## V1 metric semantics

| Metric | Empty value | Calculation / source | Test coverage |
| --- | --- | --- | --- |
| Due now | `0` | `overdueCount + dueTodayCount` from `LibraryOverviewReadModel` | `test/presentation/progress_session_notifier_test.dart`, `test/presentation/progress_screen_test.dart` |
| New cards available | `0` | `newCardCount` from `LibraryOverviewReadModel` | Same as above |
| Mastery | `0%` | `masteryPercent` from `LibraryOverviewReadModel` | Same as above |
| Active sessions | `0` | `sessions.length` from `ResumeStudySessionUseCase.listActiveSessions()` | Same as above + integration flow tests |
| Ready sessions | `0` | Count of `SessionStatus.readyToFinalize` snapshots | Same as above |
| Failed sessions | `0` | Count of `SessionStatus.failedToFinalize` snapshots | Same as above |
| Per-session progress | `0` when total steps are `0` | `completedAttempts / max(summary.totalCards, sessionFlashcards.length) * totalModeCount`, clamped to `0..1` | `test/presentation/progress_screen_test.dart` |

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

## Target analytics data to load (Future)

The following table describes the analytics target, not the current V1 data path. V1 currently loads `LibraryOverviewReadModel` for due/new/mastery/card counts and `StudySessionSnapshot` rows for active session recovery.

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
| Tap time range chip | Tap | Future analytics target. Not rendered in V1. |
| Tap suspended link | Tap | Future target. Not rendered in V1 because Global Search / global filtered list is Future. |
| Tap buried link | Tap | Future target. Not rendered in V1 because Global Search / global filtered list is Future. |
| Tap any chart bar/point | Tap | Future/optional target. Not rendered in V1. |
| Tap View library empty-state CTA | Tap | Current V1: navigate to Library via `AppNavigation.goLibrary()`. |
| Tap Continue on active session | Tap | Current V1: push study session route for the selected session. |
| Tap Finalize / Retry / Cancel | Tap | Current V1: call study use case through `ProgressSessionActionController`, then refresh study-session revision. Cancel requires confirmation. |

## Dialogs and bottom-sheets used

Current V1 uses `MxConfirmationDialog` for cancelling an active/ready/failed study session from a Progress session card. No bottom sheet is native to this screen. Future analytics chart interactions do not add dialogs unless promoted by a later scope decision.

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

- Progress Overview section, Resume sessions section, shared UI loading/error rows, Engagement section for Future streak/daily-goal, SRS section for Future box distribution.

**Schema / storage:**

- Current V1: library overview counts are read through existing content queries; active-session recovery reads persisted `study_sessions`, `study_session_items`, and related flashcard data through `ResumeStudySessionUseCase`.
- Future analytics: `study_attempts` (range aggregates) and `flashcard_progress` (box distribution snapshot, `is_suspended`, `buried_until`).

**Contracts:** `docs/contracts/usecase-contracts/srs.md`, `docs/contracts/usecase-contracts/engagement.md`. A dedicated progress repository/use-case contract does not exist in V1; current summary metrics are owned by `WatchLibraryOverviewUseCase` and active-session recovery is owned by `ResumeStudySessionUseCase`.

**Code paths:**

- `lib/presentation/features/progress/screens/progress_screen.dart`
- `lib/presentation/features/progress/providers/progress_session_notifier.dart`
- `lib/presentation/features/progress/widgets/progress_content.dart`
- `lib/presentation/features/progress/widgets/progress_overview_section.dart`
- `lib/presentation/features/progress/widgets/active_session_section.dart`
- `lib/presentation/features/progress/widgets/study_session_card.dart`
- `lib/domain/usecases/content_query_usecases.dart` (`WatchLibraryOverviewUseCase`)
- `lib/domain/study/usecases/study_usecases.dart` (`ResumeStudySessionUseCase`, finalize/cancel/retry use cases)
- `lib/app/router/route_names.dart` → `RouteNames.progress`

**Related wireframes:**

- `docs/wireframes/01-dashboard.md` — Dashboard streak chip uses same source of truth
- `docs/wireframes/06-flashcard-list.md` — suspended/buried links navigate here (filtered)
