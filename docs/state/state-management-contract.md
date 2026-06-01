---
last_updated: 2026-05-26
applies_to: Riverpod providers, viewmodels, notifiers
---

# State Management Contract

## Source files to inspect

- `lib/presentation/features/**/viewmodels/**`
- `lib/presentation/features/**/providers/**`
- `lib/presentation/shared/viewmodels/**`
- `lib/app/di/**`

## Tool

Use Riverpod annotation v3.

## Rules

- `ref.watch` for render state (inside `build`).
- `ref.read` inside callbacks.
- Do not use `ref.watch` inside callbacks.
- Do not trigger multi-step business logic from widgets.
- Do not store persistent data only in provider memory.
- Query providers must reload from database/repository.
- Action controllers must handle async state consistently.
- Use shared async action runner where existing convention requires it.

## Provider roles

| Role | Naming | Responsibility |
| --- | --- | --- |
| DI provider | `<name>Provider` | Create/wire dependencies |
| Query provider | `<name>QueryProvider` or `@riverpod Stream<T>` | Load read state |
| Action controller | `<name>Controller` | Execute commands |
| UI-state notifier | `<name>UiStateNotifier` | Hold temporary UI state |

## Mutation flow

```text
UI event
-> action controller/viewmodel
-> use case
-> repository
-> database
-> refresh/invalidate (or stream auto-emits)
-> UI re-render
```

## Async state pattern

For action controllers:

- Expose `AsyncValue<T>` or equivalent state.
- Wrap command in `AsyncValue.guard` or shared runner.
- Map `Failure` to user-facing state in this layer.
- Notify side effects (e.g., navigation request) via a separate channel, not by throwing.

## Auto-dispose rule

- Prefer auto-dispose providers for screen-scoped state.
- Use `keepAlive` only with justification.
- Cancel subscriptions in `onDispose`.

## Anti-patterns

- ❌ `ref.watch(provider)` inside `onPressed`.
- ❌ Calling repository directly from notifier (must go through use case).
- ❌ Storing draft form state across app restarts in provider (use database).
- ❌ Mutating provider state from another provider's build (causes infinite loops).
- ❌ Using `Notifier.state = ...` outside the notifier class.
- ❌ Holding `BuildContext` in a provider.

## Navigation from state

Notifiers must NOT call `context.push` directly. Instead:

- Expose navigation intent via state (e.g., `redirectTo: RouteNames.x`).
- Widget reacts to state and calls `context.push`.
- OR use a navigation channel/event stream that widget listens to.

## Agent rule

If a provider starts owning persistence logic, the architecture is wrong. Move it to a use case + repository.

If a widget starts orchestrating multi-step business logic, the architecture is wrong. Move it to a notifier + use case.

## Per-notifier contracts

Each table row defines a notifier's role, what it loads from DB/preferences, what mutations it triggers (via use case), and what is forbidden.

> **Provider name resolution.** Each `Notifier` class generates a Riverpod provider via `@riverpod` annotation codegen. The provider exposed to widgets is named `{lowerCamelCaseOfClass}Provider`. Example: `class DashboardNotifier extends _$DashboardNotifier { ... }` → widgets use `ref.watch(dashboardNotifierProvider)`. The tables below refer to the class name; the provider name is derived mechanically and not duplicated per row. See `docs/contracts/code-style.md` §Providers for the full pattern.

### Top-level + library

| Notifier | Loads from | Mutates via | Forbidden |
| --- | --- | --- | --- |
| `DashboardNotifier` | resumable session, streak, goal progress, today due count, recent decks, content count (parallel sub-providers) | n/a (read-only aggregator) | Stash data > 30s in memory; refresh whole screen on partial change |
| `LibraryNotifier` | root folders + decks streams, sort pref | `FolderRepository.reorder`, `DeckRepository.reorder` | Compute aggregate counts per render; mix folders/decks in manual sort |
| `ProgressNotifier` | range aggregates (parallel: cards/day, accuracy, box distribution, streak) | n/a (read-only) | Recompute on every range tick; share empty state across charts |

### Library tree

| Notifier | Loads | Mutates via | Forbidden |
| --- | --- | --- | --- |
| `FolderDetailNotifier` | folder detail, breadcrumb, children (subfolders or decks based on mode), resume banner for folder scope, recursive counts | `FolderUseCases`, `DeckUseCases` (for FAB) | Bypass mode lock; allow create that violates content_mode |
| `FlashcardListNotifier` | flashcards filtered + tagged with state, tag list for deck, resume banner | `FlashcardUseCases` (single), `BulkUseCases` (multi) | Persist selection across nav; "select all" beyond filter; long-press → context sheet directly (must enter selection mode) |
| `FlashcardFormNotifier` (create/edit shared) | flashcard detail (edit only), deck context, tag autocomplete | `CreateFlashcardUseCase`, `UpdateFlashcardUseCase`, `MoveFlashcardUseCase`, `DeleteFlashcardUseCase`, `ResetFlashcardProgressUseCase` | Auto-correct input; persist "Save and add another" across sessions; reset form on save failure |
| `CardHistoryNotifier` | card preview, lifetime stats, paginated attempts (cursor), reset marker | n/a (read-only) | OFFSET pagination; recompute lifetime by scanning attempts |
| `ImportNotifier` | parsed preview + duplicate detection | `ImportFlashcardsUseCase` (preview + commit) | Inline edit preview; commit when issues exist; commit on main isolate for large files |
| `LibrarySearchNotifier` | folders/decks/flashcards/tags results parallel, recent searches, popular tags | `SaveRecentSearchUseCase`, `RemoveRecentSearchUseCase` | Fire query < 2 chars; cache results across queries; flat/recursive toggle |

### Study tree

| Notifier | Loads | Mutates via | Forbidden |
| --- | --- | --- | --- |
| `StudyEntryNotifier` | scope resolution + resumable session (parallel) | `CreateSessionUseCase`, `CancelSessionUseCase` (start-over path) | Create session before resume confirmation; show resume dialog AND empty state simultaneously |
| `StudySessionNotifier` | active session state, current card, pre-fetched next card | `GradeAttemptUseCase`, `BuryCardUseCase`, `SuspendCardUseCase`, `CancelSessionUseCase`, `FinalizeSessionUseCase` | Update current_box from notifier; play TTS on back; persist grade before UI advances |
| `StudyResultNotifier` | session aggregate (read once) | `RetryFinalizationUseCase` (only on failed_to_finalize) | Re-route via push; recompute aggregate every render |

### Settings tree

| Notifier | Loads | Mutates via | Forbidden |
| --- | --- | --- | --- |
| `SettingsHubNotifier` | sub-screen subtitles (parallel: account status, daily goal, voice label, tag count, app version) | n/a (read-only) | Host any actual setting here |
| `AccountSettingsNotifier` | auth state, device label, fingerprint, manifest, in-flight op state | `SignInWithGoogleUseCase`, `SignOutUseCase`, `SwitchOrRemoveAccountUseCase`, `UploadToDriveUseCase`, `RestoreFromDriveUseCase`, `UpdateDeviceLabelUseCase` | Auto-restore on sign-in; skip pre-restore snapshot; single-tap restore confirmation when fingerprint differs |
| `LearningSettingsNotifier` | goalEnabled, dailyGoal, streakEnabled, reminderEnabled, reminderTime, notification permission | `UpdateDailyGoalUseCase`, `ScheduleReminderUseCase`, `CancelReminderUseCase` | Save button (auto-save); allow value outside 5-200; schedule before permission |
| `AudioSpeechSettingsNotifier` | per-language settings (rate, pitch, volume, voice), available voices per tab | `UpdateTtsSettingsUseCase`, `SpeakFrontUseCase` (preview only) | Couple Korean and English settings; speak back; use different engine in preview |
| `TagManagementNotifier` | all tags with count, sort preference, search filter | `RenameTagUseCase`, `MergeTagUseCase`, `DeleteTagUseCase` | Auto-merge on rename collision; bypass validation on rename |

### Cross-cutting

| Notifier | Loads | Mutates via | Forbidden |
| --- | --- | --- | --- |
| `OnboardingNotifier` | Future proposal only: firstLaunchCompletedAt flag, content count | Future full onboarding only; V1 must reuse existing create/import/account restore flows without adding this notifier | Multi-step tutorial; show welcome twice; auto-restore on sign-in; exposing a standalone onboarding route in V1 |
| `UndoToastController` | in-flight undo timer (5s) | inverse-op use case bound at undo registration | Allow undo for destructive ops; queue with stacking; tweak duration per action |

## Refresh and invalidation rules

| Trigger | Effect |
| --- | --- |
| Successful mutation in notifier | Mutation use case writes DB; Drift stream invalidates watchers; UI reflects automatically |
| Account switch / DB swap | Invalidate ALL providers via `ref.invalidate(rootProvider)` at app shell |
| Sign in / Sign out (no account switch) | Invalidate auth + sync providers only |
| Restore success | Invalidate ALL data providers (DB content fully replaced) |
| Foreground app | Re-evaluate streak (broken streak check), recompute fingerprint (debounced) |

## Per-notifier "refresh after mutation" rule

After a mutation use case returns success, the notifier MUST NOT manually update local state with the new value if a stream-based watcher exists for the same data. The stream invalidation will deliver the new state. Manual state push = duplication = bug source.

Exception: state owned only by the notifier (e.g., selection mode IDs, current page index, ephemeral toggles) is locally managed and never persisted.

**Architecture:**

- `docs/architecture/clean-architecture-contract.md` — notifier orchestrates, use case decides

**Storage:**

- `docs/database/storage-boundaries.md` — provider memory is NOT a persistence layer

**Wireframes touching async state heavily:**

- `docs/wireframes/12-study-entry-gate.md` — parallel scope+resume checks
- `docs/wireframes/13-study-session-review.md` through `docs/wireframes/17-study-session-fill.md` — session state machine
- `docs/wireframes/19-settings-account.md` — sync state (idle / uploading / restoring)

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows under "State" (provider invalidation, AsyncValue handling)

**Source files to inspect:**

- `lib/presentation/features/**/notifiers/**`
- `lib/presentation/features/**/providers/**`
