---
last_updated: 2026-06-02
route: /home
source_specs:
  - docs/business/engagement/dashboard-engagement.md
  - docs/business/resume/resume-session.md
  - docs/business/study/study-flow.md
---

# 01 — Dashboard

## Purpose

Dashboard top-level screen. Current V1 continues paused sessions and points to the next study action. Full motivation surfaces (computed streak, daily goal, reminders, streak history, and goal sheets) remain Target/Future.

## V1 release status

- Current V1: due/new/mastery summary, recent decks, resume card, paused-sessions sheet, Today CTA, and Start new learning for Today/Deck/Folder.
- Current V1 placeholder: the stats row may show `Streak` / `0 days` as a simple visual/stat placeholder only. It has no streak computation, no engagement persistence, no settings, no reminder, and no streak-history or daily-goal sheet action.
- Target/Future: full streak chip/history, daily-goal ring/settings, reminders/notification permissions, Dashboard zero-content onboarding layout, Global Search route/action, and search icon navigation.
- Current app boot still redirects `/` to `RouteDefaults.initialLocation = RoutePaths.library`; changing launch default to Dashboard requires a dedicated navigation task.

## Layout — populated state

```
┌───────────────────────────────────────┐
│ STATUS BAR                            │
├───────────────────────────────────────┤
│  Good evening, Giap          🔍  ⚙️    │  ← Target app bar; Global Search is not live in V1
├───────────────────────────────────────┤
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ ▶ Continue studying               │ │  ← RESUME CARD (only if resumable
│ │   Korean N5 deck                  │ │     session exists; tap → session)
│ │   12 / 24 cards · 2h ago          │ │
│ │   [Continue]      [Discard]       │ │
│ └───────────────────────────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 🔥 7-day streak                   │ │  ← STREAK CHIP (hidden if streak=0)
│ │   Longest: 14 days       View ▸   │ │     tap → streak history sheet
│ └───────────────────────────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │   Today's goal                    │ │  ← GOAL PROGRESS
│ │      ╱──────────────╲             │ │
│ │     │   12 / 20     │   60%       │ │     ring shows progress
│ │      ╲──────────────╱             │ │
│ │   8 more to keep your streak      │ │     dynamic motivational copy
│ └───────────────────────────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ Start today's review              │ │  ← PRIMARY CTA
│ │ 18 cards due across 3 decks  ▸   │ │     tap → /library/study/today
│ └───────────────────────────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ Start new learning           ▸   │ │  ← SECONDARY CTA
│ │ Pick a deck or folder             │ │     tap → opens "pick scope" sheet
│ └───────────────────────────────────┘ │
│                                       │
│ Recent decks                          │  ← Section header
│ ┌───────────────────────────────────┐ │
│ │ 📚 Korean N5         42 cards  ▸ │ │     tap → /library/deck/:id/flashcards
│ ├───────────────────────────────────┤ │
│ │ 📚 Korean Honorifics  18 cards ▸ │ │
│ ├───────────────────────────────────┤ │
│ │ 📚 English Idioms     30 cards ▸ │ │
│ └───────────────────────────────────┘ │
│                                       │
├───────────────────────────────────────┤
│ 🏠 Home  📚 Library  📈 Progress  ⚙️  │  ← BOTTOM NAV (shell)
└───────────────────────────────────────┘
```

## Layout — onboarding state (zero content)

```
┌───────────────────────────────────────┐
│ Welcome to MemoX          🔍  ⚙️       │
├───────────────────────────────────────┤
│                                       │
│            📚                          │
│      Welcome to MemoX                 │
│                                       │
│   Build your vocabulary with          │
│   spaced repetition.                  │
│                                       │
│   ┌──────────────────────────────┐   │
│   │ Create your first deck    ▸  │   │
│   └──────────────────────────────┘   │
│                                       │
│   ┌──────────────────────────────┐   │
│   │ Import from CSV or Excel  ▸  │   │
│   └──────────────────────────────┘   │
│                                       │
│   Already have a backup? Sign in to   │
│   restore from Google Drive.          │
│   [Sign in to Google]                 │
│                                       │
├───────────────────────────────────────┤
│ 🏠 Home  📚 Library  📈 Progress  ⚙️  │
└───────────────────────────────────────┘
```

Onboarding state replaces the entire body when `decks = 0 AND flashcards = 0`. Resume/streak/goal sections are hidden.

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| (none) | route | Dashboard is a top-level route with no params |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Greeting (time-of-day) | local time via `clock.now()` | once per build |
| Resumable session (most recent + count) | `study_sessions` filtered by `status in (draft, in_progress)` AND `started_at > now - 30d` | stream from DB |
| Current streak | `engagement_preferences` SharedPreferences | watch + foreground event |
| Daily goal target + today's progress | `engagement_preferences` + `study_attempts` today count | stream from DB + prefs |
| Today's due count across all decks | `flashcard_progress` filtered by `due_at <= now AND NOT suspended AND (buried_until IS NULL OR buried_until <= now)` | stream from DB |
| Recent decks (top 3 by updated_at) | `decks` ordered by `updated_at DESC` LIMIT 3 | stream from DB |
| Content count (for empty-state branch) | `COUNT(*) FROM decks` and `COUNT(*) FROM flashcards` | watch + invalidate on change |
| Goal-enabled / streak-enabled flags | SharedPreferences | watch |
| Streak-broken signal (one-time) | derived from `lastGoalMetDate` vs today | computed once per app foreground |

All queries fire in parallel via separate providers; UI shows skeletons per card, NOT blocking on slowest.

## Forbidden

- ❌ Call repositories or DAOs directly from `DashboardScreen` widget. Go through `DashboardNotifier`.
- ❌ Show "Streak: 0" label. Hide streak chip when streak is 0.
- ❌ Show goal ring when `goalEnabled == false`. Hide entirely.
- ❌ Change the current V1 launch default or promote Dashboard as the launch
  default without a dedicated navigation task.
- ❌ Cache resume card more than 30 seconds; it must refresh on session state changes.
- ❌ Refresh entire Dashboard on a single section change (e.g., goal update shouldn't trigger streak query).
- ❌ Compute due count inside widget build; use a provider.
- ❌ Block the screen on Drive sync state. Sync is settings-only.

## Components

| Component | Spec |
| --- | --- |
| Resume card | Visible iff at least one `study_sessions` row has `status IN (in_progress, draft)`. Shows most recent. "{n-1} more paused sessions" link when multiple. |
| Streak chip | Visible iff `currentStreak >= 1`. Tap → streak history bottom-sheet (`docs/wireframes/25-shared-bottom-sheets.md`). |
| Goal progress ring | Visible iff `goalEnabled = true`. Ring color: theme primary when below goal, gold when met. Pulse animation on first goal-met of the day. |
| Today CTA | Primary filled button. Subtitle shows due count. Disabled state when zero due, with copy "All caught up — try studying new cards instead." |
| New learning CTA | Secondary outlined button. Tap → opens scope picker bottom-sheet (pick deck/folder/today). |
| Recent decks list | Last 3 opened decks ordered by `decks.updated_at` desc among rows touched by the user. |

## V1 implementation note (Prompt 04, 2026-05-30)

- **Resume card, recent decks, Today CTA, and "Start new learning"** are implemented and tested (`test/presentation/dashboard_screen_test.dart`).
- **Action density** follows `docs/ui-ux/action-hierarchy-contract.md`: the due/next-action card uses **compact, trailing-aligned, stacked** card actions (`MxActionButton` `cardPrimary`/`cardSecondary`) — not full-width hero CTAs. Exactly one dominant primary per card ("Start review" when due, otherwise "Start new learning"); the companion is a lighter secondary. The resume card uses `MxCardActions` (Continue primary / Discard secondary).
- **"Start new learning"** opens a two-step scope picker (Today / Deck / Folder); see `docs/wireframes/25-shared-bottom-sheets.md` §scope-picker V1 note. **Tag scope is excluded in V1.**
- **Streak chip, daily-goal ring, reminders, streak-history sheet, daily-goal sheet, and streak-broken banner remain `Target`/Future** (blocked on the engagement product decision). The stats row shows a static `0 days` streak placeholder only; no streak/goal source-of-truth use case, persistence, settings control, reminder, or engagement sheet is wired yet.
- **Onboarding (zero-content) layout** is not a dedicated route/screen in V1; thin empty-deck guidance is surfaced by the existing deck empty state (Prompt 01). No onboarding carousel/route is created.
- **Global Search** is not reachable from Dashboard in V1. Inline search remains scope-local on owner screens only.

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Initial fetch on screen open | Show skeleton for each card section. Don't block on slowest query. |
| Populated | Normal | All sections render as shown. |
| Empty (onboarding) | `decks = 0 AND flashcards = 0` | Switch to onboarding layout. |
| Goal disabled | `goalEnabled = false` | Hide goal ring AND streak chip. Streak frozen, not advanced. |
| Resume only, no due | Has resumable but `todayDueCount = 0` | Resume card visible. "Today" CTA disabled with caught-up copy. |
| Streak broken (one-time on detect) | Last streak > 0 AND yesterday not goal-met | Show one-time banner above resume card: "Your N-day streak ended yesterday. Start a new one today!" Dismissed automatically after view. |
| Error (network/db) | Query failure | Show inline error card "Couldn't load Dashboard. [Retry]". |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap resume card "Continue" | Tap | Navigate to `/library/study/session/{sessionId}` (`pushReplacement` from Dashboard not needed — `push` is fine because Dashboard remains in nav stack). |
| Tap resume card "Discard" | Tap | Show "Discard paused session?" dialog (`docs/wireframes/24-shared-dialogs.md` §discard-session). On confirm: `study_sessions.status = cancelled`. |
| Tap "{n-1} more paused sessions" | Tap | Open bottom-sheet listing all resumable sessions (`docs/wireframes/25-shared-bottom-sheets.md` §paused-sessions). |
| Tap streak chip | Target/Future | Open streak history bottom-sheet only after full engagement is promoted. Current V1 static stat has no tap action. |
| Tap goal ring | Target/Future | Open daily-goal slider modal only after full engagement is promoted. Current V1 has no live goal ring. |
| Tap "Start today's review" | Tap | Navigate to `/library/study/today` → routes through study entry gate. |
| Tap "Start new learning" | Tap | Open scope picker bottom-sheet. |
| Tap recent deck row | Tap | Navigate to `/library/deck/:deckId/flashcards`. |
| Tap search icon | Target/Future | Navigate to Global Search only after that route is promoted. Current V1 exposes no Dashboard Global Search action. |
| Tap settings icon | Tap | Navigate to `/settings`. |
| Pull to refresh | Pull down | Re-run all queries; replace skeletons in place. |

## Dialogs and bottom-sheets used

- Discard paused session dialog — see `docs/wireframes/24-shared-dialogs.md` §discard-session.
- Paused sessions list bottom-sheet — see `docs/wireframes/25-shared-bottom-sheets.md` §paused-sessions.
- Streak history bottom-sheet — Target/Future only; see `docs/wireframes/25-shared-bottom-sheets.md` §streak-history.
- Daily-goal slider — Target/Future only; see `docs/wireframes/25-shared-bottom-sheets.md` §daily-goal.
- Scope picker — see `docs/wireframes/25-shared-bottom-sheets.md` §scope-picker.

## Navigation in

- Bottom nav tap "Home".
- Deep link to `/home`.
- Target/Future launch default after a dedicated navigation task. Current V1 app
  boot still redirects `/` to Library.
- Deep link from notification when no resumable session exists.

## Navigation out

- Resume card "Continue" → study session.
- "Start today's review" → study entry gate.
- "Start new learning" → scope picker → study entry gate.
- Recent deck → flashcard list.
- Search icon → Target/Future Global Search only; no live V1 action.
- Settings icon → settings hub.

## Responsive

- ≥600dp: two-column layout. Resume/streak/goal in left column; Today/new/recent in right. Bottom nav becomes side rail.
- ≥1024dp: same as ≥600dp with wider gutters.

## Performance

- All queries fire in parallel on screen open.
- Skeleton per card; don't block on slowest.
- Resume card cached for 30s; invalidated by session state changes.
- Streak chip cached for 60s; invalidated on new attempt or app foreground.

## Accessibility

- All CTAs minimum 48dp tappable height.
- Goal ring announces `{progress} of {goal} cards`.
- Streak chip announces `{n}-day streak`.
- Onboarding state focus order: title → primary CTA → secondary CTA → sign-in.

## Rules

- Target/Future: Dashboard is the intended learning-first landing screen.
  Current V1 app boot still redirects `/` to Library; do not change that in a
  release-docs task.
- Resume card MUST appear above everything else when present.
- Onboarding state MUST replace ALL other Dashboard content when triggered.
- Goal ring MUST be hidden (not greyed) when goal disabled.
- Streak chip MUST be hidden when streak = 0 (avoid "Streak: 0" insult).

## Agent rule

- Do NOT add unrelated widgets here (e.g., weather, random tips).
- Do NOT show a "Streak: 0" label; hide entirely.
- Recent decks list is fixed at 3. Do not parameterize.
- Pull-to-refresh re-runs queries — do not silently no-op.

## Implementation refs

**Business specs:**

- `docs/business/engagement/dashboard-engagement.md` — daily goal, streak, reminder logic
- `docs/business/resume/resume-session.md` — Resume card behavior
- `docs/business/study/study-flow.md` — Today CTA scope

**Decision rows:**

- Engagement section (streak broken banner, goal-off freezes streak, single reminder)
- Resume section (30-day expiry, scope match)

**Schema / storage:**

- SharedPreferences keys: `goalEnabled`, `dailyGoal`, `streakEnabled`, `reminderEnabled`, `reminderTime`, `currentStreak`, `longestStreak`, `lastGoalMetDate`, `firstLaunchCompletedAt`
- `study_sessions` table (status filter)

**Contracts:** `docs/contracts/usecase-contracts/engagement.md`, `docs/contracts/usecase-contracts/study.md` (resume + due), `docs/contracts/repository-contracts/study-repository.md`, `docs/contracts/repository-contracts/deck-repository.md`

**Code paths (where to implement):**

- `lib/presentation/features/dashboard/screens/dashboard_screen.dart`
- `lib/presentation/features/dashboard/notifiers/dashboard_notifier.dart`
- `lib/presentation/features/dashboard/widgets/resume_card.dart`
- `lib/presentation/features/dashboard/widgets/streak_chip.dart`
- `lib/presentation/features/dashboard/widgets/goal_ring.dart`
- `lib/domain/usecases/engagement/get_dashboard_state_usecase.dart`
- `lib/app/router/route_names.dart` → `RouteNames.home`

**Related wireframes:**

- `docs/wireframes/23-onboarding.md` — empty Dashboard state is the onboarding hub
- `docs/wireframes/12-study-entry-gate.md` — Today/Resume CTAs route here
- `docs/wireframes/18-study-result.md` — Done returns to Dashboard via `go`
- `docs/wireframes/25-shared-bottom-sheets.md` §paused-sessions, §streak-history, §daily-goal, §scope-picker
