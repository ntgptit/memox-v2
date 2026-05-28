---
last_updated: 2026-05-26
route: /settings/learning
source_specs:
  - docs/business/engagement/dashboard-engagement.md
  - docs/business/srs/srs-review.md
---

# 20 — Settings: Learning

## Purpose

Configure study defaults: daily goal, streak/reminder behavior, and future learning preferences. Goal and reminder are the only specified ones for now; other rows reserved for future.

## Layout

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
| `goalEnabled`, `dailyGoal` | SharedPreferences | watch |
| `streakEnabled` | SharedPreferences | watch |
| `reminderEnabled`, `reminderTime` | SharedPreferences | watch |
| OS notification permission state | platform channel | on focus + after toggle |
| Tag count (for "Manage tags" row subtitle) | `flashcard_tags` aggregate | watch |
| Future study defaults (show swipe hint, auto-advance delays) | SharedPreferences | watch (when implemented) |

## Forbidden

- ❌ Add a Save button. Auto-save with 500ms debounce.
- ❌ Allow `dailyGoal` value outside 5–200 via any code path.
- ❌ Schedule reminder before OS permission granted.
- ❌ Reset streak when user toggles goal off. Freeze (do not advance), keep value.
- ❌ Show unimplemented toggles as enabled.
- ❌ Reschedule notification on every slider tick. Reschedule on commit only.

## Components

| Component | Spec |
| --- | --- |
| Goal enabled toggle | Master switch. When off: streak frozen, goal ring hidden on Dashboard. |
| Cards per day slider | Range 5–200, step 5. Default 20. Live preview number below. |
| Streak counter toggle | Show/hide streak chip on Dashboard. Independent of goal. |
| Daily reminder toggle | Opt-in. Triggers OS notification permission request on first enable. |
| Reminder time | Time picker. Disabled when reminder off. Default 8:00 PM. |
| Manage tags link | Quick access to tag management screen. |
| Study defaults section | Reserved for future. May be hidden until implemented. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Goal off | Toggle off | Slider disabled. Streak counter row still shown but greyed. Hint copy visible. |
| Goal on | Toggle on | Slider editable. |
| Reminder permission denied | OS denies notification permission | Show inline error: "Notifications are blocked. Open device settings." with deep-link. |
| Reminder enabled, permission granted | Normal | Time picker enabled. |
| Saving | Any setting change | Auto-save with debounced 500ms write. No explicit Save button. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Toggle Goal enabled | Tap | Update preference. If turning off, prompt: "Turn off streak counter too?" (single dialog with two checkboxes? — keep simple: just hint copy and let user manage separately). |
| Drag goal slider | Drag | Live value update. Persist on release. |
| Toggle streak counter | Tap | Update preference. |
| Toggle reminder | Tap | If turning on, request OS permission. On grant: schedule reminder. On deny: revert toggle + show inline error. |
| Tap time picker | Tap | Open time picker dialog/sheet. On confirm: reschedule reminder. |
| Tap Manage tags | Tap | Navigate to `/settings/learning/tags`. |
| Toggle show swipe hint | Tap | Update preference (controls visibility of the Review mode swipe hint footer). |
| Drag delay sliders | Drag | Live value; persist on release. |

## Dialogs and bottom-sheets used

- Time picker (platform-native or `docs/wireframes/25-shared-bottom-sheets.md` §reminder-time).

## Validation

| Rule | Behavior |
| --- | --- |
| Cards per day range | Slider hardware-clamped to 5–200. Out-of-range impossible via UI. |
| Reminder time | Any valid local time. |
| Auto-advance delay (correct) range | 0.5–3.0s, step 0.1s. |
| Auto-advance delay (wrong) range | 0.5–5.0s, step 0.5s. |

## Navigation in

- Settings hub → Learning row.

## Navigation out

- Back → Settings hub.
- Manage tags → tag management screen.

## Responsive

- ≥600dp: still linear; section widths capped at 600dp center-aligned.

## Performance

- Auto-save debounced 500ms. Single SharedPreferences write per change.
- Reminder rescheduling happens on commit; not on every drag tick.

## Accessibility

- Slider announces value on every step.
- Toggles announce on/off state.
- Time picker reads selected time.

## Rules

- Daily goal default = 20 (per spec).
- Range 5–200, step 5 (per spec).
- Reminder is opt-in only. Default off.
- Single reminder per day per spec; do not allow multiple.
- Goal-off freezes streak (does not reset).

## Agent rule

- Do NOT add a Save button. Auto-save with debounce.
- Do NOT allow goal value outside 5–200 via deep-link or backdoor.
- Reminder permission flow MUST handle "permanently denied" state with deep-link to device settings.
- Future "Study defaults" section MAY be hidden until implemented; do not show unimplemented toggles.

## Implementation refs

**Business specs:**
- `docs/business/engagement/dashboard-engagement.md`

**Decision rows:**
- Engagement: goal range 5-200 step 5, single reminder, goal-off freezes streak

**Schema / storage:**
- SharedPreferences keys: `goalEnabled`, `dailyGoal`, `streakEnabled`, `reminderEnabled`, `reminderTime`
- Future: `study.showSwipeHint`, `study.autoAdvanceCorrect`, `study.autoAdvanceWrong`

**Contracts:** `docs/contracts/usecase-contracts/engagement.md`

**Code paths:**
- `lib/presentation/features/settings/learning/screens/learning_settings_screen.dart`
- `lib/presentation/features/settings/learning/notifiers/learning_settings_notifier.dart`
- `lib/data/datasources/local/preferences/engagement_preferences.dart`
- `lib/core/notifications/reminder_scheduler.dart`
- `lib/app/router/route_names.dart` → `RouteNames.settingsLearning`

**Related wireframes:**
- `docs/wireframes/04-settings-hub.md` (entry), `docs/wireframes/22-settings-tag-management.md` (Manage tags row)
- `docs/wireframes/25-shared-bottom-sheets.md` §reminder-time
