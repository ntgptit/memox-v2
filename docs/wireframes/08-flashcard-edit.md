---
last_updated: 2026-05-26
route: /library/deck/:deckId/flashcards/:flashcardId/edit
source_specs:
  - docs/business/flashcard/flashcard-management.md
  - docs/business/tags/tag-system.md
  - docs/business/study-actions/bury-suspend.md
  - docs/business/history/card-history.md
---

# 08 — Flashcard Edit

## Purpose

Edit an existing flashcard. Same structure as create but with single-card actions (delete, suspend, view history) and pre-populated values.

## Layout

```
┌───────────────────────────────────────┐
│ ←   Edit flashcard         [Save] ⋮   │  ← Save enabled only when dirty
├───────────────────────────────────────┤
│ Korean N5 · Box 3 · Due in 2 days     │  ← SRS state badge strip
├───────────────────────────────────────┤
│                                       │
│ Front *                               │
│ ┌───────────────────────────────────┐ │
│ │  안녕하세요                        │ │
│ └───────────────────────────────────┘ │
│                                       │
│ Back *                                │
│ ┌───────────────────────────────────┐ │
│ │  Hello                            │ │
│ └───────────────────────────────────┘ │
│                                       │
│ Tags                                  │
│ ┌───────────────────────────────────┐ │
│ │ #greet  #N5  + Add tag            │ │
│ └───────────────────────────────────┘ │
│                                       │
│ ▾ More fields                         │
│   (note / example / pronunciation /   │
│    hint as in create screen)          │
│                                       │
│ ─── Card actions ───                  │
│                                       │
│ [ View history ▸ ]                    │  ← → /flashcards/:id/history
│ [ Suspend card ⏸ ]                    │  ← Toggle (Unsuspend if suspended)
│ [ Reset progress ↻ ]                  │
│ [ Move to deck 📦 ]                   │
│ [ Delete 🗑 ]                          │  ← Destructive (themed red)
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `deckId` (required path param) | URL | parent deck |
| `flashcardId` (required path param) | URL | card to edit |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Flashcard detail (front, back, note, example, pronunciation, hint) | `flashcards` lookup | once |
| Tag list for this card | `flashcard_tags WHERE flashcard_id = :id` | once |
| SRS state strip (deck name, current_box, due_at or Suspended/Buried label) | `flashcard_progress` joined | watch |
| Tag autocomplete suggestions | as create screen | live |

## Forbidden

- ❌ Save while dirty=false. Save button MUST be disabled.
- ❌ Skip discard-confirm dialog on back when form is dirty.
- ❌ Show only "Suspend" when card is suspended; toggle to "Unsuspend".
- ❌ Hide card actions when card is suspended or buried; show appropriate inverse actions.
- ❌ Reset progress without setting `last_reset_at = now`.
- ❌ Move card to a deck in subfolders mode; picker MUST filter destinations.
- ❌ Lose tag list on save failure.
- ❌ Delete card without confirmation dialog.

## Components

| Component | Spec |
| --- | --- |
| App bar | Back, title "Edit flashcard", Save (disabled until dirty), overflow ⋮. |
| SRS state strip | "{deckName} · Box {n} · Due {relativeTime}" (or "Suspended" / "Buried until tomorrow"). Read-only. |
| Front/Back/Tags/More fields | Same as create screen. Pre-populated. |
| Card actions section | Always visible at bottom. Each is a button row. |
| View history | Tap → navigate to history screen. |
| Suspend card | Toggle button (text swaps Suspend / Unsuspend). |
| Reset progress | Confirm dialog → reset `flashcard_progress` and set `last_reset_at`. |
| Move to deck | Open deck picker; on pick, change card's `deck_id`. |
| Delete | Confirm dialog → cascade delete. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Fetching card | Skeleton form. |
| Loaded | Fetch success | Form pre-populated. Save disabled. |
| Dirty | User edits any field | Save enabled. |
| Saving | Save tapped | Spinner; fields disabled. |
| Saved | Success | Toast "Saved." Pop back to list. |
| Suspended | Card `is_suspended = true` | Strip shows "Suspended"; action button shows "Unsuspend". |
| Buried | Card `buried_until > now` | Strip shows "Buried until tomorrow". No special action button (bury is study-session action only here). |
| Reset done | After reset | Toast "Progress reset." Strip updates to "Box 1 · Due now". |
| Move done | After move | Pop back; if target deck was different, new flashcard list opens. |
| Delete done | After delete | Pop back to list. |
| Not found | Card deleted by another flow | Show error "This card no longer exists." Back button. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap back/← | Back | If dirty, show discard dialog. Else pop. |
| Tap Save | Tap | Validate (same rules as create) → save → toast → pop. |
| Tap View history | Tap | Navigate to flashcard history. |
| Tap Suspend / Unsuspend | Tap | Toggle `is_suspended`. Toast with 5s undo. |
| Tap Reset progress | Tap | Show "Reset progress?" dialog (`docs/wireframes/24-shared-dialogs.md` §reset-progress). On confirm, reset + set `last_reset_at = now`. |
| Tap Move to deck | Tap | Open deck picker bottom-sheet. On pick, transaction-update `deck_id`, recompute `sort_order`. |
| Tap Delete | Tap | Show delete confirm dialog. On confirm, cascade delete. |
| Tap overflow ⋮ | Tap | Same card actions in menu for quick access; redundant but expected. |

## Dialogs and bottom-sheets used

- Discard changes dialog — `docs/wireframes/24-shared-dialogs.md` §discard-changes.
- Reset progress dialog — `docs/wireframes/24-shared-dialogs.md` §reset-progress.
- Delete card dialog — `docs/wireframes/24-shared-dialogs.md` §delete-confirm.
- Deck picker (for Move) — `docs/wireframes/25-shared-bottom-sheets.md` §deck-picker.

## Validation rules

Same as create (front/back required, tag rules). Apply on Save.

## Navigation in

- Tap card row in flashcard list.
- Tap "Edit card" action from card history.
- Tap "Edit" from card context sheet.

## Navigation out

- Back → flashcard list (with confirm if dirty).
- Save → flashcard list with toast.
- View history → flashcard history screen.
- Delete → flashcard list (card removed).
- Move → flashcard list of NEW deck.

## Responsive

- ≥600dp: side-by-side layout. Front/Back in left column; tags + more fields + actions in right.

## Performance

- Single fetch on open.
- Save = single transaction (UPDATE flashcards + flashcard_tags).
- Move = single transaction (UPDATE flashcards.deck_id, recompute sort_order in target).

## Accessibility

- SRS strip announced as supplementary info.
- Destructive action ("Delete") visually distinguished with theme error color.
- Reset progress button announces "Reset SRS progress, keeps history".

## Rules

- Save MUST be disabled when no changes detected (dirty=false).
- Discard confirmation triggered by any change including tag list edits.
- Suspend toggle MUST show 5s undo toast (per bury-suspend spec).
- Reset progress MUST set `last_reset_at = now` and MUST NOT delete attempts.

## Agent rule

- Do NOT clear the form on Save if save fails. Keep dirty state.
- Do NOT hide the card actions section when card is suspended/buried; show appropriate inverse actions.
- Move card MUST validate target deck mode (decks/unlocked) — picker should pre-filter destinations to valid decks.
- "Move to deck" MUST preserve `flashcard_progress` and tags (SRS state and tags transfer with card).

## Implementation refs

**Business specs:**

- `docs/business/flashcard/flashcard-management.md`
- `docs/business/tags/tag-system.md`
- `docs/business/study-actions/bury-suspend.md` (suspend toggle)
- `docs/business/history/card-history.md` (View history action; reset progress sets `last_reset_at`)

**Decision rows:**

- Flashcard edit, validation, reset progress, suspend toggle

**Schema / storage:**

- UPDATE `flashcards`, `flashcard_progress`, `flashcard_tags` (atomic)
- Reset → `box=1`, `due_at=now`, `last_reset_at=now`
- Move → UPDATE `flashcards.deck_id`, recompute `sort_order`

**Contracts:** `docs/contracts/usecase-contracts/flashcard.md`, `docs/contracts/usecase-contracts/study.md` §SuspendCardUseCase, `docs/contracts/usecase-contracts/tag.md`

**Code paths:**

- `lib/presentation/features/flashcard_form/screens/flashcard_edit_screen.dart`
- `lib/presentation/features/flashcard_form/notifiers/flashcard_edit_notifier.dart`
- `lib/domain/usecases/flashcard/update_flashcard_usecase.dart`
- `lib/domain/usecases/flashcard/move_flashcard_usecase.dart`
- `lib/domain/usecases/history/reset_progress_usecase.dart`
- `lib/domain/usecases/study/suspend_card_usecase.dart`
- `lib/app/router/route_names.dart` → `RouteNames.flashcardEdit`

**Related wireframes:**

- `docs/wireframes/06-flashcard-list.md` (caller), `docs/wireframes/09-flashcard-history.md` (action target)
- `docs/wireframes/24-shared-dialogs.md` §discard-changes, §reset-progress, §delete-confirm
- `docs/wireframes/25-shared-bottom-sheets.md` §deck-picker, §undo-toast
