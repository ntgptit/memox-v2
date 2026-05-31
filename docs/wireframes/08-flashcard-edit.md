---
last_updated: 2026-05-31
route: /library/deck/:deckId/flashcards/:flashcardId/edit
source_specs:
  - docs/business/flashcard/flashcard-management.md
  - docs/business/tags/tag-system.md
  - docs/business/history/card-history.md
---

# 08 — Flashcard Edit

> **Shared implementation note (V1).** This route is implemented by the shared
> Flashcard Editor surface at
> `lib/presentation/features/flashcards/screens/flashcard_editor_screen.dart`.
> Edit mode is selected by the presence of `flashcardId`. The V1 editor is an
> edit-and-save form only; card deletion/move/export live on the flashcard list
> row/bulk action surfaces, and bury/suspend live on the study-session
> card-actions sheet.

## Purpose

Edit an existing flashcard. Same shared form structure as create, with
pre-populated values and an explicit progress-policy dialog only when learned
front/back content changes.

## Layout

```text
┌───────────────────────────────────────┐
│ ←   Edit card              [Save]     │
├───────────────────────────────────────┤
│ Library / ... / Deck / Edit card      │
├───────────────────────────────────────┤
│                                       │
│ [Deck pill: read-only in edit mode]   │
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
│ Example sentence · optional           │
│ Tags · optional                       │
│ ▾ Show advanced fields                │
│   Pronunciation / Hint / Note         │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `deckId` (required path param) | URL | parent deck context |
| `flashcardId` (required path param) | URL | card to edit |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Deck context (name + breadcrumb) | `decks` / folder breadcrumb lookup | once on screen open |
| Flashcard detail (front, back, note, example, pronunciation, hint, tags) | `flashcards` + `flashcard_tags` lookup | once on screen open |
| Tag validation | `TagValidator` | on add-tag input / save boundary |

## Shared Flashcard Editor contract (V1)

| Aspect | Create route | Edit route |
| --- | --- | --- |
| Runtime widget | `FlashcardEditorScreen(deckId: ..., flashcardId: null)` | `FlashcardEditorScreen(deckId: ..., flashcardId: ...)` |
| Route input | `deckId` required | `deckId` + `flashcardId` required |
| Initial content | Blank front/back/note/example/pronunciation/hint; empty tags | Loaded from the existing card |
| Destination deck | Deck pill can open a destination picker before first save | Read-only |
| Save action | Creates one card in the selected deck | Updates the same card |
| Save and add another | Available only in create mode | Hidden |
| Starting status | Available only in create mode and maps to initial SRS box | Hidden |
| Delete/history/suspend/bury actions | Not shown | Not shown in the editor in V1 |

## Forbidden

- ❌ Save while required front/back content is invalid.
- ❌ Skip discard-confirm dialog on back when form is dirty.
- ❌ Lose tag list or typed content on save failure.
- ❌ Expose a live `View history` action in V1.
- ❌ Add bury/suspend/delete/move actions inside the editor unless this wireframe and the matrix are promoted first.
- ❌ Update progress from UI directly; the editor only passes `FlashcardProgressEditPolicy` through the use case/repository path.

## Components

| Component | Spec |
| --- | --- |
| Header | Back/close, title "Edit card", no live History action. |
| Breadcrumb | Shows Library → folder trail → deck → edit context. |
| Deck pill | Read-only in edit mode; no move picker chevron. |
| Front / Back fields | Pre-populated; required after trim. |
| Example / Tags / Advanced fields | Shared editor fields. Note can be cleared; empty optional fields persist as null. |
| Progress policy dialog | Appears only after Save when a card with learning progress has changed front/back content. Options: Keep progress or Reset. |
| Save bar | Single primary "Save changes" button. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Fetching deck/card context | Retained async loading shell. |
| Loaded | Fetch success | Form pre-populated. |
| Dirty | User edits any field or tag list | Save can run when front/back are non-empty after trim. |
| Saving | Save tapped | Action state prevents double submit. |
| Learned content changed | User edits front/back on a card with learning progress | Save asks Keep vs Reset before repository update. |
| Saved | Success | Toast "Flashcard updated." and return to flashcard list. |
| Save error | Repository/use case failure | Error snackbar; form content remains intact. |
| Not found | Card deleted by another flow | Shared error state; back goes to a safe ancestor. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap back/close | Tap | If dirty, show discard dialog. Else pop or go to the deck flashcard list fallback. |
| Browser/system back | Back gesture / browser back | Same discard-confirm behavior as back/close when dirty. |
| Tap Save changes | Tap | Validate → maybe ask progress policy → update → toast → pop. |
| Choose Keep in progress-policy dialog | Save after learned front/back content changed | Update content and keep existing SRS progress. |
| Choose Reset in progress-policy dialog | Save after learned front/back content changed | Update content and reset the card's learning progress to the V1 fresh-card state. |
| Add/remove tag | Tag input sheet / chip remove | Mutates draft only; persisted on Save. |

## Current V1 action owners

| Action | V1 owner | Notes |
| --- | --- | --- |
| Move card | Flashcard list row/bulk actions | Preserves progress and tags. |
| Delete card | Flashcard list row/bulk actions | Requires confirmation and cascades through persistence. |
| Export card | Flashcard list row/bulk actions | Selection/single-row export surface. |
| Bury/Suspend | Study-session card-actions sheet | See `docs/wireframes/25-shared-bottom-sheets.md` §card-actions. |
| View history | Future Proposal | Do not expose live in V1. Requires promotion of `docs/wireframes/09-flashcard-history.md`. |

## Dialogs and bottom-sheets used

- Discard changes dialog — `docs/wireframes/24-shared-dialogs.md` §discard-changes.
- Progress policy dialog — inline `MxDialog` composition in the editor.
- Tag input sheet — shared tag input sheet from `MxTagInput`.

## Validation rules

Same as create (front/back required, tag rules). Apply on Save and at the
repository boundary.

## Navigation in

- Tap card row in flashcard list.
- Tap Edit from the flashcard list row action sheet.

## Navigation out

- Back → card's deck flashcard list (with confirm if dirty).
- Save → card's deck flashcard list with toast.

## Responsive

- ≥600dp: form content may use the shared editor responsive constraints, but no
  separate action rail is shown in V1 edit mode.

## Performance

- Single fetch on open.
- Save = single transaction for `flashcards` + `flashcard_tags`, with optional
  `flashcard_progress` reset when the explicit policy is chosen.

## Accessibility

- Required fields announced with "Required" in label.
- Progress policy dialog actions announce whether progress will be kept or reset.
- No live Future action is announced for History.

## Rules

- Save MUST be gated by required front/back content after trim.
- Discard confirmation triggered by any change including optional field and tag list edits; preloaded optional fields/tags are not dirty until changed.
- Normal edit MUST keep progress unless the user explicitly chooses Reset in the learned-content policy dialog.
- V1 editor MUST NOT expose a live History route/action.

## Agent rule

- Do NOT clear the form on Save if save fails. Keep dirty state.
- Do NOT add History, Bury/Suspend, Move, or Delete inside the editor unless this wireframe and the matrix are promoted first.
- Do NOT implement standalone reset-progress/history semantics that require `last_reset_at` unless the migration task is explicitly approved.

## Implementation refs

**Business specs:**

- `docs/business/flashcard/flashcard-management.md`
- `docs/business/tags/tag-system.md`
- `docs/business/history/card-history.md` (Future Proposal; no live V1 editor action)

**Decision rows:**

- Flashcard edit, validation, learned-content progress policy

**Schema / storage:**

- UPDATE `flashcards` + `flashcard_tags` atomically.
- If the user chooses Reset in the learned-content policy dialog, reset `flashcard_progress` to the current V1 fresh-card state.
- Standalone reset-progress/history semantics that require `last_reset_at` remain Future Proposal.

**Contracts:** `docs/contracts/usecase-contracts/flashcard.md`, `docs/contracts/usecase-contracts/tag.md`

**Code paths:**

- `lib/presentation/features/flashcards/screens/flashcard_editor_screen.dart`
- `lib/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart`
- `lib/presentation/features/flashcards/widgets/flashcard_editor_form.dart`
- `lib/domain/usecases/flashcard_usecases.dart` → `UpdateFlashcardUseCase`
- `lib/app/router/route_names.dart` → `RouteNames.flashcardEdit`

**Related wireframes:**

- `docs/wireframes/06-flashcard-list.md` (caller and row/bulk action owner)
- `docs/wireframes/07-flashcard-create.md` (same shared editor surface)
- `docs/wireframes/09-flashcard-history.md` (Future Proposal; no live V1 action)
- `docs/wireframes/24-shared-dialogs.md` §discard-changes, §delete-confirm
- `docs/wireframes/25-shared-bottom-sheets.md` §card-actions
