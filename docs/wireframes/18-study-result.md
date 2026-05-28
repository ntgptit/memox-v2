---
last_updated: 2026-05-26
route: /library/study/session/:sessionId/result
source_specs:
  - docs/business/study/study-flow.md
  - docs/business/srs/srs-review.md
  - docs/business/engagement/dashboard-engagement.md
---

# 18 — Study Result

## Purpose

End-of-session summary. Celebrate completion, show what improved, motivate next action (continue streak, study more, view history). Auto-routed after final card answered.

## Layout

```
┌───────────────────────────────────────┐
│                                       │
│              🎉                        │  ← Celebrate icon
│                                       │
│      Session complete!                │
│                                       │
│   Korean N5 · 24 cards reviewed       │  ← Scope + counts
│   in 12 minutes                       │
│                                       │
├───────────────────────────────────────┤
│ ┌─────────────────────────────────┐   │
│ │ Accuracy                  92%   │   │  ← Top-line stat
│ └─────────────────────────────────┘   │
│                                       │
│ Results                                │
│ ┌─────────────────────────────────┐   │
│ │  ✓ Perfect           18  ▮▮▮▮▮  │   │  ← Per-result breakdown with
│ │  ✓ Passed             3  ▮      │   │     mini-bar
│ │  ⚠ Recovered          2  ▮      │   │
│ │  ✗ Forgot             1  ▮      │   │
│ └─────────────────────────────────┘   │
│                                       │
│ Box changes                            │
│ ┌─────────────────────────────────┐   │
│ │  Advanced              18 cards │   │
│ │  Stayed                 3 cards │   │
│ │  Reset to box 1         1 card  │   │
│ │  Reached box 8          0 cards │   │
│ └─────────────────────────────────┘   │
│                                       │
│ ┌─────────────────────────────────┐   │
│ │  🔥 7-day streak                 │   │  ← Streak update (if applicable)
│ │  Daily goal: 24 / 20 ✓           │   │     daily goal met indicator
│ └─────────────────────────────────┘   │
│                                       │
│ ┌─────────────────────────────────┐   │
│ │ Tough cards (3)              ▸  │   │  ← Link to forgot/recovered list
│ └─────────────────────────────────┘   │
│                                       │
│  [    Done    ]                       │  ← Primary; back to caller
│  [ Study more ]                       │  ← Secondary; opens scope picker
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `sessionId` (required path param) | URL | finalized session |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Session aggregate (per-result counts, accuracy, duration) | `study_attempts` aggregated WHERE session_id = :id | once |
| Box change counts (advanced / stayed / reset / reached box 8) | derived from `box_before` vs `box_after` columns | once |
| Tough cards (forgot/recovered this session) | `study_attempts WHERE session_id = :id AND result IN (forgot, recovered)` | once |
| Streak / goal update (if completed today) | engagement preferences post-finalization | once on entry |
| Session status (`completed` / `failed_to_finalize`) | `study_sessions.status` | once |

## Forbidden

- ❌ Route to Dashboard via `push`. Use `go` (per nav-flow contract); result MUST NOT remain in stack.
- ❌ Show "Hard / Easy" breakdowns. Only 4 result types.
- ❌ Show streak/goal block when `goalEnabled == false`.
- ❌ Block Done button on finalize retry failure. User should always be able to leave.
- ❌ Re-enter this screen after Done (back from caller should not return here).
- ❌ Compute box change counts from `current_box` snapshot. Use `box_before` / `box_after` columns.
- ❌ Show celebration emoji per Design System voice.

## Components

| Component | Spec |
| --- | --- |
| Celebrate header | Icon + heading + scope summary line. |
| Accuracy block | `(perfect + initial_passed) / total * 100`. Rounded to nearest integer. |
| Results breakdown | Each result type with count and visual bar. |
| Box changes | Counts of how many cards advanced, stayed, were reset, or maxed out (reached box 8). |
| Streak / goal block | Show only if engagement metrics moved. Hide if user has goal disabled. |
| Tough cards link | Tap → list of cards answered as `forgot` or `recovered` this session. |
| Primary CTA | Done → pop back to Dashboard or caller. |
| Secondary CTA | Study more → opens scope picker for next session. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Briefly while reading session aggregate | Skeleton. |
| Populated | Normal | Full layout. |
| Goal disabled | `goalEnabled = false` | Hide streak/goal block. |
| Failed to finalize | `session.status = failed_to_finalize` | Show error banner top: "Some data couldn't be saved. Please retry." with Retry button. |
| Empty result (shouldn't happen but defensive) | Zero answers somehow | Show "No cards answered" notice + Done. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap Done | Tap | Per nav-flow contract: `go` to origin route. Result screen is NOT kept in stack. (Practically: navigate to Dashboard or the deck/folder the session was entered from.) |
| Tap Study more | Tap | Open scope picker bottom-sheet (`docs/wireframes/25-shared-bottom-sheets.md` §scope-picker). |
| Tap Tough cards | Tap | Navigate to a filtered flashcard list showing cards answered forgot/recovered this session. |
| Tap accuracy / box change blocks | Tap | No-op (informational). |
| Tap streak | Tap | Open streak history bottom-sheet. |
| Tap Retry (failure state) | Tap | Re-run finalize use case. |

## Dialogs and bottom-sheets used

- Scope picker — `docs/wireframes/25-shared-bottom-sheets.md` §scope-picker.
- Streak history — `docs/wireframes/25-shared-bottom-sheets.md` §streak-history.

## Navigation in

- Auto-redirect from study session after last card answered (via `pushReplacement` from session route).

## Navigation out

- Done → origin (deck list / folder / Dashboard) via `go`.
- Study more → scope picker → study entry gate.
- Tough cards → flashcard list (filtered).

## Responsive

- ≥600dp: two-column layout. Accuracy + Results on left; Box changes + streak on right.

## Performance

- All data computed from `study_session_items` + `study_attempts` of this session, one aggregate query each.
- Tough cards list pre-computed and cached for the screen lifecycle.

## Accessibility

- Heading announced on screen open.
- Stats grouped by accessibility region so screen reader walks them as a unit.
- Done button is default focus.

## Rules

- Streak chip in result MUST match Dashboard's streak (same source of truth).
- Done MUST use `go` (not push or pop) per nav-flow contract. Result screen MUST NOT remain in the back stack.
- Result screen MUST NOT be re-entered for the same session (back from caller doesn't return here).
- Box changes counts MUST come from `box_before` vs `box_after` columns on `study_attempts`.

## Agent rule

- Done MUST use `context.go(...)` not `context.push(...)` and not `context.pop()`. Per nav-flow contract, the result screen is not stacked.
- Pick the origin route: if entry came from a deck (`entry_type=deck`), go to that deck's flashcard list; if from Dashboard's Today, go to Dashboard; else go to Dashboard.
- Do NOT show "Hard / Easy" breakdowns. We only have 4 result types per spec.
- Show streak block ONLY when goal feature enabled.
- Do NOT block Done button on retry failure; user should always be able to leave even if finalization is broken (data is preserved via `failed_to_finalize` status).

## Implementation refs

**Business specs:**
- `docs/business/study/study-flow.md` (finalization)
- `docs/business/srs/srs-review.md` (box change aggregates)
- `docs/business/engagement/dashboard-engagement.md` (streak/goal update on completion)

**Decision rows:**
- Session finalization: failed_to_finalize handling, box change aggregates, Done uses go (not pop/push)

**Schema / storage:**
- READ aggregates from `study_attempts` (box_before vs box_after counts, result counts)
- UPDATE `study_sessions.status = completed`
- UPDATE engagement preferences (currentStreak, lastGoalMetDate)

**Contracts:** `docs/contracts/usecase-contracts/study.md` §FinalizeSessionUseCase, §RetryFinalizationUseCase, `docs/contracts/usecase-contracts/engagement.md` §RecordGoalProgressUseCase

**Code paths:**
- `lib/presentation/features/study/screens/study_result_screen.dart`
- `lib/presentation/features/study/notifiers/study_result_notifier.dart`
- `lib/domain/usecases/study/finalize_session_usecase.dart`
- `lib/domain/usecases/engagement/record_completion_usecase.dart`
- `lib/app/router/route_names.dart` → `RouteNames.studyResult`

**Related wireframes:**
- `docs/wireframes/12-study-entry-gate.md` → `13-17` → here (full session flow)
- `docs/wireframes/25-shared-bottom-sheets.md` §scope-picker, §streak-history
