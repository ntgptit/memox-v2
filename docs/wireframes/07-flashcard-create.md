---
last_updated: 2026-05-26
route: /library/deck/:deckId/flashcards/new
source_specs:
  - docs/business/flashcard/flashcard-management.md
  - docs/business/tags/tag-system.md
---

# 07 — Flashcard Create

> **Shared implementation note (V1).** This route is implemented by the shared
> Flashcard Editor surface at
> `lib/presentation/features/flashcards/screens/flashcard_editor_screen.dart`.
> Create mode is selected by the presence of `deckId` and the absence of
> `flashcardId`; edit mode is documented separately in
> `docs/wireframes/08-flashcard-edit.md`.

## Purpose

Create a single flashcard in the current deck. Optimized for repeated entry — common path is "add many cards in a row".

## Layout

```
┌───────────────────────────────────────┐
│ ✕   New flashcard          [Save] ⋮   │  ← ✕ closes; Save = primary
├───────────────────────────────────────┤
│ Korean N5                             │  ← Deck context
├───────────────────────────────────────┤
│                                       │
│ Front *                               │  ← Required marker
│ ┌───────────────────────────────────┐ │
│ │  안녕하세요                        │ │
│ │                                   │ │  ← Multi-line text field
│ └───────────────────────────────────┘ │
│                                       │
│ Back *                                │
│ ┌───────────────────────────────────┐ │
│ │  Hello                            │ │
│ │                                   │ │
│ └───────────────────────────────────┘ │
│                                       │
│ Tags                                  │
│ ┌───────────────────────────────────┐ │
│ │ #greet  #N5  + Add tag            │ │  ← Chips + add input
│ └───────────────────────────────────┘ │
│                                       │
│ ▾ More fields (optional)              │  ← Collapsed by default
│   ┌─────────────────────────────────┐ │
│   │ Note                             │ │
│   │                                  │ │
│   ├──────────────────────────────────┤ │
│   │ Example                          │ │
│   ├──────────────────────────────────┤ │
│   │ Pronunciation                    │ │
│   ├──────────────────────────────────┤ │
│   │ Hint                             │ │
│   └──────────────────────────────────┘ │
│                                       │
│ ☐ Save and add another                │  ← Persistent toggle
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `deckId` (required path param) | URL | destination deck |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Deck detail (name, target_language) | `decks` lookup | once on screen open |
| Tag autocomplete suggestions | top tags from `flashcard_tags` matching input prefix | live, debounced 200ms |
| "Save and add another" toggle | session memory (NotifierState) | local |

## Shared Flashcard Editor contract (V1)

| Aspect | Create route | Edit route |
| --- | --- | --- |
| Runtime widget | `FlashcardEditorScreen(deckId: ..., flashcardId: null)` | `FlashcardEditorScreen(deckId: ..., flashcardId: ...)` |
| Route input | `deckId` required | `deckId` + `flashcardId` required |
| Initial content | Blank front/back/note/example/pronunciation/hint; empty tags | Loaded from the existing card |
| Destination deck | Deck pill can open a destination picker before first save | Read-only; moving a saved card belongs to flashcard list row/bulk actions |
| Save action | Creates one card in the selected deck | Updates the same card |
| Save and add another | Available only in create mode | Hidden |
| Starting status | Available only in create mode and maps to initial SRS box | Hidden; normal edit keeps current progress unless the explicit learning-content policy dialog resets it |
| Delete/history/suspend/bury actions | Not shown | Not shown in the editor in V1; see `docs/wireframes/08-flashcard-edit.md` for current owners |

## Forbidden

- ❌ Auto-correct or normalize user typing in front/back. Save as typed.
- ❌ Persist "Save and add another" across screen open/close. Intentionally ephemeral.
- ❌ Commit comma in tag silently. Reject inline with error.
- ❌ Submit form when Save button is disabled (programmer error if reached).
- ❌ Reset form on save failure. Keep dirty state.
- ❌ Focus tag input on screen open. Focus FRONT field.
- ❌ Allow `Enter` in tag input to submit the whole form. Enter commits the tag chip only.

## Components

| Component | Spec |
| --- | --- |
| App bar | ✕ close (with unsaved-changes warning), title, [Save] primary action button, overflow. |
| Deck context strip | Shows which deck this card goes into. Tap → open deck picker to change destination before saving. |
| Front / Back fields | Multi-line; auto-grow; required validation on save. |
| Tags input | Chip input. Type to add. Comma key triggers validation error inline. Backspace on empty input removes last chip. |
| More fields expander | Collapsed by default. Tapping expands inline (note/example/pronunciation/hint). |
| Save and add another | Toggle. When on, save returns to a blank form instead of popping. Preference persisted in session memory only (not SharedPreferences). |
| Overflow ⋮ | Discard / Change deck. |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Empty | Just opened | All fields blank. Save disabled until front+back filled. |
| Editing | User typing | Save enabled when front+back non-empty after trim. |
| Validation error | Tap save with bad data | Inline error under offending field. Save remains enabled to allow retry. |
| Saving | Save tapped | Save button shows spinner; fields disabled. |
| Saved (save-and-add ON) | Success | Toast "Card added"; form resets; focus returns to Front. |
| Saved (save-and-add OFF) | Success | Return to the selected destination deck's flashcard list with toast "Card added". |
| Tag comma error | User types comma in tag input | Inline error "Tags cannot contain commas." Comma not accepted. |
| Tag too long | > 50 chars after trim | Inline error "Tag too long (max 50 chars)." |
| Save error | Repository failure | Error banner at top with retry. Form NOT reset. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap ✕ close | Tap | If unsaved changes, show "Discard changes?" dialog. Else pop or fall back to the selected destination deck's flashcard list. |
| Browser/system back | Back gesture / browser back | Same discard-confirm behavior as ✕ close when unsaved changes exist. |
| Tap Save | Tap | Validate → save → behave per "Save and add another" toggle. |
| Tap deck context | Tap | Open deck picker bottom-sheet (`docs/wireframes/25-shared-bottom-sheets.md` §deck-picker). |
| Tap "Add tag" | Tap | Tag input becomes editable; show keyboard. |
| Type in tag input | Type | Live validation. Enter / space / tab commits tag. |
| Tap tag chip × | Tap × | Remove tag. |
| Tap More fields | Tap | Toggle expander. Persisted within this session (collapsed at next entry). |
| Toggle "Save and add another" | Tap toggle | Toggle state. |

## Dialogs and bottom-sheets used

- Discard changes dialog — `docs/wireframes/24-shared-dialogs.md` §discard-changes.
- Deck picker — `docs/wireframes/25-shared-bottom-sheets.md` §deck-picker.

## Validation rules (from `docs/business/flashcard/flashcard-management.md` and `docs/business/tags/tag-system.md`)

| Rule | Inline message |
| --- | --- |
| Front empty after trim | "Front is required." |
| Back empty after trim | "Back is required." |
| Front > field max chars | "Front exceeds {N} chars." |
| Back > field max chars | "Back exceeds {N} chars." |
| Tag contains comma | "Tags cannot contain commas." |
| Tag > 50 chars after trim | "Tag too long (max 50 chars)." |
| Tag empty after trim | (silently rejected, not added as chip) |
| Duplicate tag on same card (case-insensitive) | (silently deduped, not added again) |

## Navigation in

- FAB action sheet from flashcard list → "New flashcard".
- FAB action sheet from Library → "New flashcard" (after picking a deck).
- Empty state CTA in flashcard list.

## Navigation out

- ✕ or back → selected destination deck's flashcard list (with confirm if unsaved).
- Save (with save-and-add OFF) → selected destination deck's flashcard list.
- Save (with save-and-add ON) → stays here with blank form and keeps the selected destination deck.

## Responsive

- ≥600dp: Side panel layout. Front + Back side-by-side; tag input full width below.
- Note/example/pronunciation/hint stack vertically in expanded section even on tablet.

## Performance

- Save uses single transaction.
- Tag autocomplete query against `flashcard_tags` (LIKE) limited to top 20 suggestions; debounced 200ms.

## Accessibility

- Required fields announced with "Required" in label.
- Save button announces "Save flashcard, disabled" when fields empty.
- Validation errors associated with their field via aria-describedby pattern.

## Rules

- Save MUST be disabled until required fields valid. Don't allow tap-and-show-error pattern.
- Tag comma rejection MUST be inline and prevent the comma being added — not strip silently.
- "Save and add another" toggle MUST reset front/back/tags after save, keep More fields collapsed, and keep the selected destination deck for the next card.
- Discard confirmation MUST trigger on any non-empty field, tag, non-default starting status, or destination deck change, not just "dirty" flag pollution.

## Agent rule

- Do NOT auto-uppercase or auto-correct front/back. User content stays as typed.
- Do NOT persist "Save and add another" across sessions; it's intentional ephemeral.
- Default focus on screen open MUST be Front field.
- Tags input MUST commit on Enter, Tab, OR space (whichever is convenient for the platform). Comma NEVER commits — it triggers error.

## Implementation refs

**Business specs:**

- `docs/business/flashcard/flashcard-management.md`
- `docs/business/tags/tag-system.md` (validation rules)

**Decision rows:**

- Flashcard validation, TG9 (comma rejection), TG10 (max 50)

**Schema / storage:**

- INSERT `flashcards` + `flashcard_tags` in one transaction
- "Save and add another" toggle = session memory (NOT persisted)

**Contracts:** `docs/contracts/usecase-contracts/flashcard.md` §CreateFlashcardUseCase, `docs/contracts/usecase-contracts/tag.md` §TagValidator

**Code paths:**

- `lib/presentation/features/flashcards/screens/flashcard_editor_screen.dart`
- `lib/presentation/features/flashcards/viewmodels/flashcard_editor_viewmodel.dart`
- `lib/presentation/features/flashcards/widgets/flashcard_editor_form.dart`
- `lib/domain/usecases/flashcard_usecases.dart` → `CreateFlashcardUseCase`
- `lib/app/router/route_names.dart` → `RouteNames.flashcardCreate`

**Related wireframes:**

- `docs/wireframes/06-flashcard-list.md` (caller)
- `docs/wireframes/08-flashcard-edit.md` (shares form structure)
- `docs/wireframes/24-shared-dialogs.md` §discard-changes
- `docs/wireframes/25-shared-bottom-sheets.md` §deck-picker, §tag-picker
