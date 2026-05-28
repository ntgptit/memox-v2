---
last_updated: 2026-05-26
route: implicit (first launch, no dedicated route)
source_specs:
  - docs/business/system/overview.md
  - docs/business/account-sync/account-sync.md
  - docs/business/engagement/dashboard-engagement.md
---

# 23 — Onboarding

## Purpose

First-launch experience when user has zero content. Lightweight: no carousel, no required tutorial. Three paths: create first deck, import from file, or sign in and restore.

Onboarding is NOT a separate route. It IS the empty state of the Dashboard. This document specifies the flow and the secondary screens triggered from onboarding.

## Entry condition

User reaches Dashboard with `decks.count == 0 AND flashcards.count == 0`. The empty-state Dashboard layout (see `docs/wireframes/01-dashboard.md`) IS the onboarding entry point.

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| (none) | route | onboarding has no dedicated route; it is the empty state of `/home` |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| `firstLaunchCompletedAt` flag | SharedPreferences | once on app boot |
| Content count (`COUNT(*) FROM decks` + `COUNT(*) FROM flashcards`) | DB | watch (determines if user is back to empty state after wipe) |
| Drive manifest (after sign-in) | Drive App Folder | once after sign-in completes |
| OS notification permission (relevant later, not in onboarding) | platform channel | n/a here |

## Forbidden

- ❌ Multi-step tutorial carousel. One welcome screen, then Dashboard.
- ❌ Show welcome screen again after `firstLaunchCompletedAt` set.
- ❌ Block onboarding with sign-in requirement. Sign-in is opt-in.
- ❌ Auto-trigger restore on sign-in. Always prompt.
- ❌ Use the full §restore-warning flow in onboarding (no local data to lose; lightweight prompt only).
- ❌ Set `firstLaunchCompletedAt` before the welcome screen actually shows.
- ❌ Persist a half-created deck if the user closes the "Create deck for import" inline form.

## Path 1: Create first deck

```
Onboarding Dashboard
  → tap "Create your first deck"
  → opens deck create bottom-sheet (25-shared-bottom-sheets.md §deck-create)
  → user fills name + target_language
  → on save: deck created in root, Dashboard re-renders with non-empty state
  → primary CTA on dashboard now: "Add flashcards" (smart redirect to new deck's flashcard list)
```

### Optional welcome step (single-screen, dismissible)

On very first app launch (tracked via `firstLaunchCompletedAt` SharedPreferences key), show a one-screen welcome before Dashboard renders:

```
┌───────────────────────────────────────┐
│                                       │
│           ╱─────────╲                 │
│          │  MemoX   │                 │
│           ╲─────────╱                 │
│                                       │
│        Build vocabulary               │
│        with spaced repetition.        │
│                                       │
│   You'll learn cards 8 times across   │
│   a few months — when you're about    │
│   to forget them.                     │
│                                       │
│   Your data stays on this device      │
│   unless you choose to back up.       │
│                                       │
│   ┌──────────────────────────────┐   │
│   │ Let's start                  │   │
│   └──────────────────────────────┘   │
│                                       │
│   [ Skip ]                            │
│                                       │
└───────────────────────────────────────┘
```

Tap "Let's start" or "Skip" → set `firstLaunchCompletedAt = now` → navigate to Dashboard.

After this single welcome, the welcome screen is NEVER shown again, regardless of future empty states (e.g., user wipes account).

## Path 2: Import from file

```
Onboarding Dashboard
  → tap "Import from CSV or Excel"
  → must pick a destination deck (none exists yet)
  → so flow first shows "Create deck for import" inline:
       inline form: deck name + target_language
       → tap Continue
       → navigate to /library/deck/:newDeckId/import with format=file
  → standard import flow (see 10-deck-import.md)
  → on complete: Dashboard shows non-empty state with imported deck
```

### Inline "Create deck for import" form

```
┌───────────────────────────────────────┐
│ ←   New deck for import               │
├───────────────────────────────────────┤
│                                       │
│  Name *                               │
│  ┌─────────────────────────────────┐  │
│  │  Korean N5                      │  │
│  └─────────────────────────────────┘  │
│                                       │
│  Target language *                    │
│  ◉ Korean                              │
│  ○ English                             │
│  ○ Unsupported (no TTS)               │
│                                       │
│  [ Cancel ]            [ Continue ▸ ] │
│                                       │
└───────────────────────────────────────┘
```

On Continue: create deck + navigate to import screen.

## Path 3: Sign in and restore

```
Onboarding Dashboard
  → tap "Sign in to Google" (signed-out hint)
  → OS OAuth flow
  → after sign-in:
       if Drive has a manifest → show "Restore from your last backup?" prompt
       else → return to Dashboard signed-in, still empty
```

### Restore prompt

```
┌───────────────────────────────────────┐
│  ☁️  Backup found                     │
├───────────────────────────────────────┤
│                                       │
│  We found a backup from:              │
│    Pixel 7 · 2026-04-12 · 15.2 MB     │
│                                       │
│  Restore it to this device?           │
│                                       │
│  ⓘ Since this device has no data yet, │
│    no safety snapshot is needed.      │
│                                       │
│  ┌──────────────────────────────┐    │
│  │ ⬇ Restore now                │    │
│  └──────────────────────────────┘    │
│                                       │
│  [ Not now ]                          │
│                                       │
└───────────────────────────────────────┘
```

If user picks Restore now → run download + replace (no snapshot needed since DB is empty/fresh).

If "Not now" → return to onboarding Dashboard signed-in. The restore option remains available later in `/settings/account`.

## States across onboarding

| State | Trigger | Behavior |
| --- | --- | --- |
| Welcome (one-time) | First app launch ever | Single screen as above. |
| Empty Dashboard | After welcome, zero content | Empty-state layout per `docs/wireframes/01-dashboard.md`. |
| Sign-in in progress | OAuth flow active | Spinner overlay on Dashboard CTAs. |
| Restore prompt | Sign-in success + manifest exists | Modal dialog. |
| Restoring | Restore confirmed | Modal progress; app effectively offline. |
| Restore complete | Success | Dashboard re-renders with restored data; show toast "Backup restored." |
| Restore failed | Network/parse error | Toast error; Dashboard stays empty + signed-in. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap "Let's start" / "Skip" (welcome) | Tap | Persist `firstLaunchCompletedAt = now`; show Dashboard. |
| Tap "Create your first deck" | Tap | Open deck create bottom-sheet. |
| Tap "Import from CSV or Excel" | Tap | Push inline "Create deck for import" form. |
| Tap "Sign in to Google" | Tap | Launch OAuth flow. |
| Tap "Restore now" | Tap | Run restore (no snapshot needed since DB empty). |
| Tap "Not now" | Tap | Dismiss prompt; remain on Dashboard. |
| Skip "Sign in to Google" hint | Tap (just ignore) | No-op; Dashboard remains empty. |

## Dialogs and bottom-sheets used

- Welcome screen (custom, one-time).
- Deck create — `docs/wireframes/25-shared-bottom-sheets.md` §deck-create.
- Restore prompt — defined here (lightweight; not the full restore-warning since DB is empty).
- Standard restore warning is NOT used in onboarding because there's no local data to overwrite.

## Navigation in

- App launch when content count = 0 (Dashboard auto-routes through empty state).

## Navigation out

- After first deck created → flashcard list of new deck (smart redirect) OR back to Dashboard depending on path.
- After import → flashcard list of imported deck.
- After restore → Dashboard with content.

## Responsive

- Welcome screen center-aligned content with max-width 600dp.
- Empty Dashboard same as `docs/wireframes/01-dashboard.md`.

## Performance

- Welcome screen renders instantly; no async needed.
- Sign-in flow blocks until OS returns.
- Restore "no snapshot needed" path skips snapshot creation entirely.

## Accessibility

- Welcome screen heading → CTA → Skip focus order.
- Sign-in button labeled "Sign in with Google".
- Restore prompt clearly distinguishes Restore vs Not now.

## Rules

- Welcome screen shown EXACTLY ONCE per install (tracked via `firstLaunchCompletedAt`).
- Empty Dashboard IS the onboarding hub; no separate route.
- Restore in onboarding context skips snapshot (no data to lose).
- Import flow requires a destination deck; create one inline if user has none.
- Sign-in is OPTIONAL — user can fully use MemoX without an account.

## Agent rule

- Do NOT add a multi-step tutorial carousel. One welcome screen, then Dashboard.
- Do NOT show the welcome screen again after `firstLaunchCompletedAt` set.
- Do NOT auto-trigger restore on sign-in. Always prompt.
- Do NOT block onboarding with sign-in requirement. Sign-in is opt-in.
- Smart redirect after first deck creation MAY route to flashcard list rather than Dashboard, to reduce taps for the next obvious action (Add card).

## Implementation refs

**Business specs:**
- `docs/business/engagement/dashboard-engagement.md` (empty Dashboard = onboarding)
- `docs/business/account-sync/account-sync.md` (sign-in / restore path)
- `docs/business/flashcard/flashcard-management.md` (import path needs deck created first)

**Decision rows:**
- Onboarding: welcome shown once (firstLaunchCompletedAt), restore in onboarding skips snapshot

**Schema / storage:**
- SharedPreferences: `firstLaunchCompletedAt`
- Restore path: no snapshot needed when DB is empty

**Contracts:** `docs/contracts/usecase-contracts/engagement.md` §MarkFirstLaunchCompletedUseCase, `docs/contracts/usecase-contracts/deck.md`, `docs/contracts/usecase-contracts/flashcard.md` §ImportFlashcardsUseCase, `docs/contracts/usecase-contracts/account-sync.md`

**Code paths:**
- `lib/presentation/features/onboarding/screens/welcome_screen.dart`
- `lib/presentation/features/onboarding/notifiers/onboarding_notifier.dart`
- `lib/presentation/features/dashboard/widgets/empty_dashboard.dart`
- `lib/domain/usecases/onboarding/should_show_welcome_usecase.dart`
- Reuses: `create_deck_usecase`, `import_flashcards_usecase`, `google_auth`, `drive_restore_service`

**Related wireframes:**
- `docs/wireframes/01-dashboard.md` (empty state)
- `docs/wireframes/10-deck-import.md`, `docs/wireframes/19-settings-account.md`, `docs/wireframes/25-shared-bottom-sheets.md` §deck-create
