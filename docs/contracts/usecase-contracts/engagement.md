---
last_updated: 2026-05-26
status: contract
---

# Engagement Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Daily goal, streak, reminder, recent decks, dashboard aggregate.

## GetDashboardStateUseCase

```dart
Future<Either<Failure, DashboardState>> call();
```

Aggregates: resumable session, streak, daily goal progress, today's due, recent decks (top 3), onboarding flag.

In practice, this is a coordinator that fires sub-use-cases in parallel via Riverpod providers. Use case form documented here as the conceptual unit.

## GetDailyGoalUseCase

```dart
Future<DailyGoalSettings> call();
```

Reads SharedPreferences. Returns `{ enabled, target (5-200), streakEnabled }`.

## UpdateDailyGoalUseCase

```dart
Future<Either<Failure, Unit>> call({bool? enabled, int? target, bool? streakEnabled});
```

**Rules:**

- If `target` provided: assert 5 ≤ target ≤ 200 AND target % 5 == 0. Else `ValidationFailure(code: outOfRange)`.
- Persist to SharedPreferences.
- Side effect: if `enabled` toggled off → freeze streak (do NOT reset).

**Errors:** `ValidationFailure`, `StorageFailure`.

## ComputeStreakUseCase

```dart
Future<StreakInfo> call();
```

**Rules:**

- READ `lastGoalMetDate`, `currentStreak`, `longestStreak` from SharedPreferences.
- If `lastGoalMetDate < today - 1 day` AND `goalEnabled` AND `currentStreak > 0`:
  - Detect broken streak. Return `StreakInfo { currentStreak: 0, brokenStreakInfo: { previousStreak: N, brokenDate } }`.
  - Side effect: update SharedPreferences (reset currentStreak to 0). One-time banner shown by UI.
- Else return current streak as-is.

## RecordGoalProgressUseCase

```dart
Future<Either<Failure, GoalProgress>> call({required int cardsAnsweredToday});
```

Called by `FinalizeSessionUseCase` and any other point where attempts complete.

**Rules:**

- If `cardsAnsweredToday >= dailyGoal` AND today != `lastGoalMetDate`:
  - Increment `currentStreak`. Update `lastGoalMetDate = today`. Update `longestStreak = max(longest, current)`.

**Errors:** `StorageFailure`.

## ScheduleReminderUseCase

```dart
Future<Either<Failure, Unit>> call({required TimeOfDay time});
```

**Rules:**

- Request OS notification permission if not granted.
- Schedule daily local notification at `time` in user's local timezone.
- Cancel previous reminder before scheduling new.

**Errors:** `AuthFailure` (permission denied), platform error → `StorageFailure`.

## CancelReminderUseCase

```dart
Future<Either<Failure, Unit>> call();
```

Cancels any scheduled reminder.

## GetRecentDecksUseCase

```dart
Future<Either<Failure, List<Deck>>> call({int limit = 3});
```

`decks ORDER BY updated_at DESC LIMIT :limit`.

## MarkFirstLaunchCompletedUseCase

```dart
Future<void> call();
```

Set SharedPreferences `firstLaunchCompletedAt = now`.

## Forbidden patterns

- ❌ Daily goal outside 5-200 or not multiple of 5.
- ❌ Reset streak on goal-off. Freeze instead.
- ❌ Schedule reminder before permission granted.
- ❌ Multiple reminders per day. Cancel previous on reschedule.
- ❌ Streak computation based on `study_attempts` scan. Use `lastGoalMetDate` flag.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Repositories used:** `docs/contracts/repository-contracts/study-repository.md` (read attempts for goal progress), `docs/contracts/repository-contracts/deck-repository.md` (recent decks). Engagement preferences live in SharedPreferences (not a Drift repository); see `docs/database/storage-boundaries.md`.

**Business spec:** `docs/business/engagement/dashboard-engagement.md`
**Wireframes:** `docs/wireframes/01-dashboard.md`, `docs/wireframes/20-settings-learning.md`, `docs/wireframes/18-study-result.md`
**Decision table:** rows under "Dashboard engagement"
**Code paths:** `lib/domain/usecases/engagement/**`, `lib/data/datasources/local/preferences/engagement_preferences.dart`, `lib/core/notifications/reminder_scheduler.dart`
