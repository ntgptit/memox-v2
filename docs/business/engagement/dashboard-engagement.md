---
last_updated: 2026-06-02
applies_to: daily goal, streak, study reminders, landing screen, Dashboard motivation surfaces
---

# Daily Engagement

## V1 release status

This document is a target engagement spec. For the current V1 release cutline,
daily goal, computed streaks, reminders, engagement settings, streak history,
daily-goal sheets, notification permissions, and engagement persistence remain
Future/Target.

Current V1 Dashboard code may render a simple static streak-like stat such as
`0 days` as a visual summary placeholder. That placeholder is not a Current
engagement feature: it has no streak computation, no `study_attempts` aggregate,
no SharedPreferences engagement keys, no settings controls, no reminders, and
no streak/daily-goal bottom sheet.

## Purpose

A flashcard learning app lives or dies by daily return rate. Pure SRS without motivation layer turns the app into a chore. This document specs the daily engagement primitives: goal, streak, reminders, and the default landing screen.

Scope: personal-use app for now. Decisions favor simplicity and non-intrusiveness.

## Concepts

| Term | Definition |
| --- | --- |
| Daily goal | Number of card answers per day the user targets. Stored as a single integer setting. |
| Daily progress | Count of answers (attempts) recorded today against the goal. |
| Streak | Number of consecutive days the user met the daily goal. |
| Streak day | A calendar day in the user's local timezone, bounded by midnight. |
| Day boundary | Midnight in user's local timezone. Day boundary reset uses local clock, not UTC. |
| Goal-met day | A day where the user recorded at least `dailyGoal` attempts (counted from `study_attempts`). |

## Daily goal

### Storage

Setting lives in user settings (not Drift entity table). Use `study_settings_store.dart` pattern (SharedPreferences-backed) — see `lib/data/settings/study_settings_store.dart` for placement convention.

| Field | Type | Default |
| --- | --- | --- |
| `dailyGoal` | int | 20 |
| `goalEnabled` | bool | `true` |

### Range

- Min: 5
- Max: 200
- Step: 5

Outside range is rejected at validation; values are clamped on read for safety.

### Configuration

Set in Settings → Learning (`/settings/learning`). UI is a slider with current value label. Saving is immediate (no save button), consistent with TTS settings.

When user disables daily goal (`goalEnabled = false`), all engagement surfaces hide. Streak is paused (does not break, but does not advance either).

## Daily progress

### Calculation

```sql
SELECT COUNT(*) FROM study_attempts
WHERE attempted_at >= <todayStartLocalEpochMs>
  AND attempted_at < <tomorrowStartLocalEpochMs>;
```

Day boundaries computed from device's current timezone. Cross-timezone travel: see "Edge cases" below.

### Display

Dashboard shows:

- Progress ring or bar: `progress / goal` (e.g., `12 / 20`).
- Percentage label.
- Pulse animation when goal is met for the first time today.

When `progress >= goal`: visual stays celebratory until midnight (gold ring, checkmark icon). Subsequent answers do not break the celebration.

## Streak

### Calculation rules

- A "goal-met day" is any local-calendar day where `progress >= dailyGoal`.
- Streak = consecutive goal-met days ending at yesterday or today.
- Today does NOT count toward streak until goal is met for today. Once met, today extends streak by 1.
- If yesterday was not a goal-met day, streak is broken (reset to 0). Today starts a new streak when goal is met today.

### Streak data

| Field | Type | Source |
| --- | --- | --- |
| `currentStreak` | int | Computed from `study_attempts` history |
| `longestStreak` | int | Persisted in settings store, updated when `currentStreak > longestStreak` |
| `lastGoalMetDate` | string (YYYY-MM-DD local) | Persisted; used to detect midnight rollover and broken-streak |

Streak is **computed**, not incrementally written. On Dashboard load, run the computation. Caching is acceptable but must invalidate after each new attempt and on app foreground.

### Streak freeze (NOT implemented now)

Not in scope. Future: 1 "freeze" per week to skip a day without breaking streak. For now, missing a day breaks the streak.

### Streak display

Dashboard:

- Flame icon + number: "🔥 7"
- Tap → opens streak history (small calendar showing last 30 days with goal-met days marked).

### Streak break notice

When user opens app and detects last streak broken (last `lastGoalMetDate` is more than 1 day before today and `currentStreak` was > 0):

- Show one-time toast/banner: "Your {n}-day streak ended yesterday. Start a new one today!"
- Reset `currentStreak` to 0.
- Do NOT show this notice every app open; show once per broken streak.

## Reminders (notifications)

### Settings

In Settings → Learning, below daily goal:

| Field | Type | Default |
| --- | --- | --- |
| `reminderEnabled` | bool | `false` (opt-in) |
| `reminderTime` | TimeOfDay | 20:00 (8 PM local) |

User chooses one daily reminder time. Multiple reminders are out of scope.

### Permission

- iOS: must request notification permission on first enable. If denied, show explanation and link to system settings.
- Android 13+: must request notification permission on first enable.
- Web/desktop: feature hidden (no notification primitive used).

If permission is denied or revoked, the toggle remains user-toggleable but stays disabled in effect until permission is granted. Show inline message: "Enable notifications in system settings to receive reminders."

### Reminder content

Scheduled local notification fires at `reminderTime` daily.

Body text varies by state at fire time:

| State | Body |
| --- | --- |
| Goal not met today, no resumable session | "You haven't studied today. {n} cards are due." (n = today's due count) |
| Goal not met today, has resumable session | "Continue your paused session for {scopeName}." |
| Goal already met today | Suppress notification (do not fire). |
| Has streak ≥ 3 days | Append "🔥 {n}-day streak" suffix. |

Tap → deep link:

- Resumable session present → navigate to that session.
- Else → navigate to "Today" view.

### Permission revocation

If app fires a reminder but permission has been revoked, fail silently. Periodic permission check on app open updates the UI toggle state.

## Landing screen

Target/Future engagement behavior: the default screen on app launch is
**Dashboard** with a strong "Today" focus. Current V1 app boot still redirects
`/` to `RouteDefaults.initialLocation = RoutePaths.library`; changing that
default requires a dedicated navigation task with route tests and docs updates.

Order of Dashboard content (top to bottom):

1. Resume card (if resumable session exists) — see `docs/business/resume/resume-session.md`.
2. Streak chip (`🔥 {n}` if streak > 0, hidden otherwise).
3. Daily goal progress (ring/bar with `progress / goal`).
4. "Start today's review" primary CTA — disabled state when no due cards (see `docs/business/study/study-flow.md` empty scope matrix).
5. "Start new learning" secondary CTA → opens deck/folder picker.
6. Quick links: recent decks (last 3 opened).
7. Settings shortcut.

If user has zero content (no decks, no flashcards), Dashboard shows onboarding state instead:

- Title: "Welcome to MemoX"
- CTA: "Create your first deck"
- Subtitle: "Or import an existing deck (CSV/Excel)"

### Why Dashboard, not Library, as landing

Target rationale: Library is a content-management screen. For a learning app,
the default action is "study", not "browse". Library remains one tap away in
bottom nav.

This target decision is explicit, but it is not the current V1 boot behavior.
Do not change the default tab during V1 release-polish work without an explicit
navigation task.

## Data sources

| Surface | Data source |
| --- | --- |
| Daily progress | `study_attempts` aggregate (today's local-day range) |
| Streak | `study_attempts` aggregate (consecutive days) + persisted `longestStreak` |
| Goal | Settings store (SharedPreferences) |
| Reminder time | Settings store |
| Resume card | `study_sessions` where `status IN (in_progress, draft)` |
| Today's due count | `flashcard_progress` where `due_at <= now` |

All queries SHOULD be cheap (indexed on `attempted_at`, `due_at`, `status`). If they become slow with large data, add appropriate indexes; do not denormalize counters.

## Edge cases

| Case | Behavior |
| --- | --- |
| User changes goal mid-day from 20 to 10, already answered 12 | Goal is met (12 >= 10). Streak advances today if not already advanced. |
| User changes goal from 20 to 50, already answered 25 | Goal is no longer met (25 < 50). Today is not yet a goal-met day. If midnight passes without 50 answered, streak breaks. |
| User travels across timezones | Streak uses device current local timezone. Crossing a date line may grant or remove a day. Accept this drift; do not store user-locked timezone. |
| User clock manipulation | App trusts device clock. Power users tweaking clock to game streak is acceptable; not a security concern in a personal-use learning app. |
| Daylight saving | Use timezone-aware local-midnight calculation. Most platforms handle this correctly via `DateTime` API. |
| User disables `goalEnabled` after building a 30-day streak | Streak frozen at 30. Re-enabling: streak resumes only if user has been meeting target each day since disabling (computed from attempts history); otherwise reset to 0 on next goal-met day. |
| Reminder fires while app is foreground | Suppress notification; app already shows the same info. |
| User has multiple devices via Drive sync | Streak computed per-device from local data. After Drive restore, streak recomputes from attempts in the restored DB. Drift: minor; accept it for personal-use scope. |

## Rules

- Daily goal MUST be configurable in Settings → Learning. Default is 20.
- Streak MUST be computed from `study_attempts`, not stored incrementally (except `longestStreak`).
- Day boundary uses device local timezone midnight, not UTC.
- Notifications are opt-in. Default OFF.
- Notification fires at most once per day.
- Reminder body MUST personalize based on session state (resume vs new vs goal already met).
- Goal already met → suppress reminder.
- Target/Future: landing screen is Dashboard. Current V1 still boots `/` to Library.
- Onboarding state replaces Dashboard only when zero decks AND zero flashcards exist.

## Required UI states

| Surface | States |
| --- | --- |
| Daily progress | Below goal, met goal (celebratory), over goal (continued progress shown but not breaking celebration), goal disabled (hidden) |
| Streak chip | Hidden (streak=0), visible (streak >=1), broken-streak notice (one-time on detect) |
| Reminder toggle | Off, on (permission granted), on (permission denied — shows inline help) |
| Onboarding | Active when no content |
| Today's review CTA | Enabled (due cards present), disabled (no due cards, with empty state hint) |

## Performance

- Dashboard load: parallel-fire all queries. Show skeleton on each card independently; do not block on slowest.
- Streak computation: cache result for 60 seconds; invalidate on new attempt and on app foreground transition.
- Reminder scheduling: one-time scheduling on app start; reschedule when settings change.

## Agent rule

- For V1 release-polish tasks, do not treat the static Dashboard `0 days`
  placeholder as implementation of this target spec. Keep it documented as a
  visual/stat placeholder unless a dedicated engagement implementation task
  promotes the feature with code, tests, persistence, and docs.
- Do NOT add a second daily reminder time. Single time only.
- Do NOT auto-enable notifications. Always require explicit user toggle and permission flow.
- Do NOT change the current V1 boot default or promote the target Dashboard
  landing behavior without an explicit navigation task and updated docs.
- Do NOT add streak freezes, leaderboards, social features. Out of scope for personal-use phase.
- Streak break notice fires once per break event. Do not repeat.
- Day boundary calculation MUST use local timezone. Do not use UTC.

## Related

**Wireframes:**

- `docs/wireframes/01-dashboard.md` — Dashboard full layout: resume card, streak chip, goal ring, Today CTA, recent decks, onboarding empty state
- `docs/wireframes/18-study-result.md` — streak/goal block on session result
- `docs/wireframes/20-settings-learning.md` — daily goal slider, streak toggle, reminder configuration
- `docs/wireframes/23-onboarding.md` — empty Dashboard IS the onboarding hub
- `docs/wireframes/25-shared-bottom-sheets.md` §streak-history, §daily-goal, §reminder-time

**Schema:**

- SharedPreferences keys (see `docs/database/storage-boundaries.md`): `goalEnabled`, `dailyGoal`, `streakEnabled`, `reminderEnabled`, `reminderTime`, `lastGoalMetDate`, `currentStreak`, `longestStreak`, `firstLaunchCompletedAt`

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "Dashboard engagement" (goal-off freezes streak, single reminder, streak broken one-time banner)

**Glossary terms:**

- `docs/business/glossary.md` → "daily goal", "streak", "reminder", `today` entry type

**Related business specs:**

- `docs/business/study/study-flow.md` — `today` entry creates global SRS review session
- `docs/business/resume/resume-session.md` — Dashboard surfaces resumable sessions
- `docs/business/navigation/navigation-flow.md` — current V1 boot redirects `/` to Library; Dashboard remains a top-level destination

**Source files to inspect:**

- `lib/domain/usecases/engagement/**`
- `lib/data/datasources/local/preferences/engagement_preferences.dart`
- `lib/presentation/features/dashboard/**`
- `lib/core/notifications/reminder_scheduler.dart`
