---
last_updated: 2026-05-26
route: /settings/learning
source_specs:
  - docs/business/engagement/dashboard-engagement.md
  - docs/business/srs/srs-review.md
---

# 20 — Settings: Learning

## Purpose

Current V1 configures study defaults and provides the Manage tags route. Daily goal, streak, reminder, and other engagement controls are target settings only; they are not implemented in the current V1 Learning settings screen.

## V1 verification status

Prompt 21 (2026-05-31) treats this screen as route-safe sub-screen coverage only. Current code implements study defaults, not the full engagement settings target shown in the original layout.

| Aspect | V1 status | Notes |
| --- | --- | --- |
| Route `/settings/learning` | Current | Reachable from Settings Hub; hides shell navigation; back returns to hub when pushed from the hub. |
| New-study defaults | Current | Edits new-study batch size and shared study defaults through `StudyDefaultsSettings`. |
| SRS-review defaults | Current | Edits review batch size and shared study defaults through `StudyDefaultsSettings`. |
| Interval table | Current | Read-only display based on current runtime interval source. |
| Manage tags entry | Current | Pushes `/settings/learning/tags`. |
| Daily goal / streak / reminder controls | Future/Target | Not implemented in this screen's current V1 code. Do not add in a Settings Hub parity task. |

The layout/data/components/states sections below describe the target engagement settings design unless a row is explicitly marked Current in the V1 verification table.

## Layout

Target/reference layout. Current V1 renders study defaults, the interval table, and Manage tags; the daily-goal/reminder blocks below are not shipped Current controls.

```
┌───────────────────────────────────────┐
│ ←   Learning                          │
├───────────────────────────────────────┤
│                                       │
│ DAILY GOAL                            │
│ ┌───────────────────────────────────┐ │
│ │ Goal enabled              [●━━]   │ │  ← Toggle; when off, streak frozen
│ ├───────────────────────────────────┤ │
│ │ Cards per day                     │ │
│ │     ◀── ━━━●━━━━━━━━━━━ ──▶       │ │  ← Slider 5–200, step 5
│ │              20 cards             │ │
│ ├───────────────────────────────────┤ │
│ │ Streak counter            [●━━]   │ │  ← Show/hide streak chip
│ └───────────────────────────────────┘ │
│ ⓘ When goal is off, streak does not   │
│   advance and the chip is hidden.     │
│                                       │
│ REMINDER                              │
│ ┌───────────────────────────────────┐ │
│ │ Daily reminder            [○━━]   │ │  ← Off by default; opt-in
│ ├───────────────────────────────────┤ │
│ │ Time                              │ │
│ │ 8:00 PM                  [Edit]   │ │  ← Disabled when reminder off
│ └───────────────────────────────────┘ │
│ ⓘ One reminder per day in your local  │
│   timezone.                           │
│                                       │
│ TAGS                                  │
│ ┌───────────────────────────────────┐ │
│ │ 🏷  Manage tags          42  ▸    │ │  → /settings/learning/tags
│ └───────────────────────────────────┘ │
│                                       │
│ STUDY DEFAULTS  (future)              │
│ ┌───────────────────────────────────┐ │
│ │ Show swipe hint footer    [●━━]   │ │  ← Toggle: show "» Swipe left for the next
│ │                                   │ │     card" footer in Review mode
│ ├───────────────────────────────────┤ │
│ │ Auto-advance delay (correct)      │ │
│ │     ◀── ━━━●━━━ ──▶  1.0s         │ │
│ ├───────────────────────────────────┤ │
│ │ Auto-advance delay (wrong)        │ │
│ │     ◀── ━━━━━━●━ ──▶  2.0s        │ │
│ └───────────────────────────────────┘ │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| (none) | route | |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Current study defaults | `StudySettingsStore` via study settings providers | watch |
| SRS interval table | Runtime interval source | on screen open |
| Tag count / tags entry data | Tag providers / `flashcard_tags` aggregate | watch when rendered |
| Target/Future: `goalEnabled`, `dailyGoal` | SharedPreferences | watch when engagement settings are implemented |
| Target/Future: `streakEnabled` | SharedPreferences | watch when engagement settings are implemented |
| Target/Future: `reminderEnabled`, `reminderTime` | SharedPreferences | watch when engagement settings are implemented |
| Target/Future: OS notification permission state | platform channel | on focus + after toggle when reminders are implemented |
| Target/Future: show swipe hint / auto-advance delays | SharedPreferences | watch when implemented |

## Forbidden

- ❌ Target/Future engagement controls: add a Save button. Auto-save with 500ms debounce.
- ❌ Target/Future engagement controls: allow `dailyGoal` value outside 5-200 via any code path.
- ❌ Target/Future reminder controls: schedule reminder before OS permission granted.
- ❌ Target/Future streak controls: reset streak when user toggles goal off. Freeze (do not advance), keep value.
- ❌ Show unimplemented toggles as enabled.
- ❌ Target/Future reminder controls: reschedule notification on every slider tick. Reschedule on commit only.

## Components

| Component | Spec |
| --- | --- |
| Current: New-study defaults | Current V1 section for new-study batch size and shared study defaults. |
| Current: SRS-review defaults | Current V1 section for review batch size and shared study defaults. |
| Current: Interval table | Current V1 read-only SRS interval display. |
| Current: Manage tags link | Quick access to tag management screen. |
| Target/Future: Goal enabled toggle | Master switch. When off: streak frozen, goal ring hidden on Dashboard. |
| Target/Future: Cards per day slider | Range 5-200, step 5. Default 20. Live preview number below. |
| Target/Future: Streak counter toggle | Show/hide streak chip on Dashboard. Independent of goal. |
| Target/Future: Daily reminder toggle | Opt-in. Triggers OS notification permission request on first enable. |
| Target/Future: Reminder time | Time picker. Disabled when reminder off. Default 8:00 PM. |
| Target/Future: Additional study defaults | Show swipe hint / auto-advance controls may remain hidden until implemented. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Current: Study defaults loaded | Screen opens | Render current study default controls, interval table, and Manage tags entry. |
| Current: Saving study defaults | Current V1 setting change | Persist through study settings store; no explicit Save button. |
| Target/Future: Goal off | Toggle off | Slider disabled. Streak counter row still shown but greyed. Hint copy visible. |
| Target/Future: Goal on | Toggle on | Slider editable. |
| Target/Future: Reminder permission denied | OS denies notification permission | Show inline error: "Notifications are blocked. Open device settings." with deep-link. |
| Target/Future: Reminder enabled, permission granted | Normal | Time picker enabled. |
| Target/Future: Saving engagement settings | Engagement setting change | Auto-save with debounced 500ms write. No explicit Save button. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Change current study defaults | Tap / input | Persist current V1 study default settings. |
| Tap Manage tags | Tap | Navigate to `/settings/learning/tags`. |
| Target/Future: Toggle Goal enabled | Tap | Update preference. If turning off, show hint copy and let user manage streak separately. |
| Target/Future: Drag goal slider | Drag | Live value update. Persist on release. |
| Target/Future: Toggle streak counter | Tap | Update preference. |
| Target/Future: Toggle reminder | Tap | If turning on, request OS permission. On grant: schedule reminder. On deny: revert toggle + show inline error. |
| Target/Future: Tap time picker | Tap | Open time picker dialog/sheet. On confirm: reschedule reminder. |
| Target/Future: Toggle show swipe hint | Tap | Update preference when implemented. |
| Target/Future: Drag delay sliders | Drag | Live value; persist on release when implemented. |

## Dialogs and bottom-sheets used

- Current V1: none required for the study defaults controls.
- Target/Future: Time picker (platform-native or `docs/wireframes/25-shared-bottom-sheets.md` §reminder-time).

## Validation

| Rule | Behavior |
| --- | --- |
| Current study defaults | Validated by current study settings controls/store. |
| Target/Future: Cards per day range | Slider hardware-clamped to 5-200. Out-of-range impossible via UI. |
| Target/Future: Reminder time | Any valid local time. |
| Target/Future: Auto-advance delay (correct) range | 0.5-3.0s, step 0.1s. |
| Target/Future: Auto-advance delay (wrong) range | 0.5-5.0s, step 0.5s. |

## Navigation in

- Settings hub → Learning row.

## Navigation out

- Back → Settings hub.
- Manage tags → tag management screen.

## Responsive

- ≥600dp: still linear; section widths capped at 600dp center-aligned.

## Performance

- Current V1 study default writes must avoid unnecessary rebuilds and persist through the current study settings store.
- Target/Future engagement auto-save is debounced 500ms with a single SharedPreferences write per change.
- Target/Future reminder rescheduling happens on commit; not on every drag tick.

## Accessibility

- Current V1 study default controls announce their labels and values.
- Target/Future sliders announce value on every step.
- Target/Future toggles announce on/off state.
- Target/Future time picker reads selected time.

## Rules

- Current V1 keeps study defaults and Manage tags separate from engagement settings.
- Target/Future: Daily goal default = 20.
- Target/Future: Range 5-200, step 5.
- Target/Future: Reminder is opt-in only. Default off.
- Target/Future: Single reminder per day; do not allow multiple.
- Target/Future: Goal-off freezes streak and does not reset it.

## Agent rule

- Do NOT promote daily goal, streak, reminder, or notification permission controls to Current in a Settings route/parity task.
- Current V1 study defaults must not add a Save button unless the implementation already uses one.
- Target/Future: Do NOT add a Save button. Auto-save with debounce.
- Target/Future: Do NOT allow goal value outside 5-200 via deep-link or backdoor.
- Target/Future: Reminder permission flow MUST handle "permanently denied" state with deep-link to device settings.
- Target/Future study-default controls may remain hidden until implemented; do not show unimplemented toggles.

## Implementation refs

**Business specs:**

- `docs/business/engagement/dashboard-engagement.md`

**Decision rows:**

- Current V1: settings route/action coverage and study defaults tests.
- Target/Future engagement: goal range 5-200 step 5, single reminder, goal-off freezes streak.

**Schema / storage:**

- Current V1: study defaults store and providers listed in Code paths.
- Target/Future SharedPreferences keys: `goalEnabled`, `dailyGoal`, `streakEnabled`, `reminderEnabled`, `reminderTime`
- Target/Future: `study.showSwipeHint`, `study.autoAdvanceCorrect`, `study.autoAdvanceWrong`

**Contracts:** `docs/contracts/usecase-contracts/engagement.md`

**Code paths:**

- `lib/presentation/features/settings/screens/learning_settings_screen.dart`
- `lib/presentation/features/settings/widgets/study_settings_group.dart`
- `lib/presentation/features/settings/viewmodels/study_settings_defaults_viewmodel.dart`
- `lib/app/di/study/study_settings_providers.dart`
- `lib/app/router/route_names.dart` → `RouteNames.settingsLearning`

**Related wireframes:**

- `docs/wireframes/04-settings-hub.md` (entry), `docs/wireframes/22-settings-tag-management.md` (Manage tags row)
- `docs/wireframes/25-shared-bottom-sheets.md` §reminder-time
