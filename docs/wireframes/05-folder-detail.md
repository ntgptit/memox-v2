---
last_updated: 2026-05-31
route: /library/folder/:id
source_specs:
  - docs/business/folder/folder-management.md
  - docs/business/deck/deck-management.md
  - docs/business/resume/resume-session.md
  - docs/business/study/study-flow.md
---

# 05 — Folder Detail

## V1 verification status (2026-06-03, Prompt 45)

This screen is partially Current.

Current V1:

- `/library/folder/:id` opens Folder Detail.
- Invalid/missing `folderId` shows a safe error surface with Retry.
- Breadcrumb/back navigation is Current.
- Subfolder-mode renders subfolders only.
- Deck-mode renders decks only.
- Unlocked mode renders true empty choice flow.
- Inline scope-local search is Current.
- True-empty vs search no-results is Current:
  - true empty = no unfiltered direct children
  - no-results = active search hides existing children
- Sort UI via `MxSearchSortToolbar<ContentSortMode>` is Current.
- Create subfolder/deck by content mode is Current.
- Typed lock-mode snackbar is Current from Prompt 14.
- Row actions currently exposed: folder/deck actions sheet, move/delete/import/duplicate/export according to owner.
- **Study-entry banners are Current from Prompt 45** (`FolderStudyEntrySection`,
  `lib/presentation/features/folders/widgets/folder_study_entry_section.dart`),
  shown above the children list when the recursive folder scope has cards or a
  resumable session:
  - **Resume banner** — visible iff a resumable session with `entry_type=folder,
    entry_ref_id=this.id` exists; Resume opens that session directly
    (`context.goStudySession`), never creating a new one. Discard is not yet
    exposed here (Future).
  - **Today CTA** — visible iff recursive `dueCount > 0`; routes to the Study
    Entry Gate with `entry_type=folder` + `study_type=srs_review` (folder-scoped due
    review). Hidden at zero.
  - **Study folder CTA** — visible iff recursive `totalCardCount > 0`; routes to
    the Study Entry Gate with `entry_type=folder` (new study).
  - The section never starts a session itself; the Study Entry Gate owns
    empty-scope validation, resume conflict, and session creation.
  - Recursive counts + resumable session come from
    `GetFolderStudyEntryUseCase` (reuses `StudyRepo.countFlashcardsInScope` /
    `countDueCardsInScope` / `findResumeCandidate`); no schema added.

Current (Prompt 47):

- Resume banner **Discard** secondary action. Tap → danger confirmation
  (`MxConfirmationDialog`) → on confirm cancels the existing paused session via
  the shared Resume-Discard flow (`confirmAndDiscardResumeSession` →
  `CancelStudySessionUseCase` through `progressSessionActionControllerProvider`,
  which bumps the study-session revision so the banner refreshes away). Cancel
  does nothing. Never creates a new session; no schema/SRS change.

Future / not exposed in V1:

- Mastery ring / "{n} new" subtitle from the mock decks-mode hero card.
- Global Search route.
- Flashcard History.
- tag-scoped study.
- visual redesign.

The layout/components/actions sections below are target design. The Resume
banner (with Resume + Discard) and Study/Today CTAs are now Current (see above);
remaining mock details (mastery ring, new-card subtitle) stay Future and must
not be implemented by ordinary parity work.

## Purpose

Browse a folder's children: either subfolders or decks, never both. V1 focuses on folder/deck browsing, inline search/sort, create actions, and row actions. Folder-level study CTAs (Study folder / Today) and the Resume banner are Current from Prompt 45 and route through the Study Entry Gate.

## Layout — folder in `subfolders` mode

```
┌───────────────────────────────────────┐
│ ← Korean                       🔍  ⋮  │  ← App bar; back to parent
├───────────────────────────────────────┤
│ Library / Korean                      │  ← Breadcrumb
├───────────────────────────────────────┤
│                                       │
│ ⚠ You have a paused study session     │  ← RESUME BANNER (Current; Resume P45, Discard P47)
│   for this folder.                    │
│   [Resume]  [Discard]                 │
├───────────────────────────────────────┤
│                                       │
│ ┌─────────────────┐  ┌─────────────┐ │
│ │ Study folder    │  │ Today (12)  │ │  ← Folder-level CTAs (Future in V1)
│ │ ▸               │  │ ▸           │ │     "Today" shown if due > 0 (Future in V1)
│ └─────────────────┘  └─────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 📁 Grammar          3 decks    ▸ │ │  ← Subfolder rows
│ ├───────────────────────────────────┤ │
│ │ 📁 Vocabulary       5 decks    ▸ │ │
│ ├───────────────────────────────────┤ │
│ │ 📁 Honorifics       2 decks    ▸ │ │
│ └───────────────────────────────────┘ │
│                                       │
│                            ┌───┐      │
│                            │ + │      │  ← FAB → "New subfolder" only
│                            └───┘      │     (decks blocked in subfolders mode)
└───────────────────────────────────────┘
```

## Layout — folder in `decks` mode

```
┌───────────────────────────────────────┐
│ ← Korean                       🔍  ⋮  │
├───────────────────────────────────────┤
│ Library / Korean                      │
├───────────────────────────────────────┤
│                                       │
│ ┌─────────────────┐  ┌─────────────┐ │
│ │ Study folder    │  │ Today (8)   │ │  ← Folder-level CTAs (Future in V1)
│ │ ▸               │  │ ▸           │ │
│ └─────────────────┘  └─────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 📚 Korean N5         42 cards  ▸ │ │  ← Deck rows
│ ├───────────────────────────────────┤ │
│ │ 📚 Korean N4         60 cards  ▸ │ │
│ ├───────────────────────────────────┤ │
│ │ 📚 Common phrases    25 cards  ▸ │ │
│ └───────────────────────────────────┘ │
│                                       │
│                            ┌───┐      │
│                            │ + │      │  ← FAB → "New deck" only
│                            └───┘      │     (subfolders blocked here)
└───────────────────────────────────────┘
```

## Layout — folder in `unlocked` mode (just created, empty)

```
┌───────────────────────────────────────┐
│ ← New folder                   ⋮      │
├───────────────────────────────────────┤
│ Library / New folder                  │
├───────────────────────────────────────┤
│                                       │
│              📁                        │
│                                       │
│      This folder is empty.            │
│                                       │
│   Choose how to fill it:              │
│                                       │
│   ┌──────────────────────────────┐   │
│   │ + New subfolder              │   │  ← Picks subfolders mode
│   └──────────────────────────────┘   │
│   ┌──────────────────────────────┐   │
│   │ + New deck                   │   │  ← Picks decks mode
│   └──────────────────────────────┘   │
│                                       │
│   You can have subfolders OR decks    │  ← Mode-lock explanation
│   inside, not both.                   │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `folderId` (required path param) | URL | resolves to a `folders.id`; 404 if invalid |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Folder detail (name, content_mode, parent chain for breadcrumb) | `folders` lookup + recursive parent join | watch |
| Breadcrumb path | derived from parent chain | follows folder detail |
| Child folders (when mode=subfolders) | `folders WHERE parent_id = :folderId ORDER BY sort_order` | stream |
| Child decks (when mode=decks) | `decks WHERE folder_id = :folderId ORDER BY sort_order` | stream |
| Recursive card count (for Study folder CTA) | **Current (Prompt 45).** `GetFolderStudyEntryUseCase` → `StudyRepo.countFlashcardsInScope` over the folder subtree | re-resolves on content/session revision + folder re-entry |
| Recursive due count (for Today CTA) | **Current (Prompt 45).** `StudyRepo.countDueCardsInScope` over the folder subtree | re-resolves on content/session revision + folder re-entry |
| Resumable session for this scope | **Current (Prompt 45).** `StudyRepo.findResumeCandidate` matched on `entry_type=folder` and `entry_ref_id=:folderId` | re-resolves on session revision + folder re-entry |

## Forbidden

- ❌ Show both "New subfolder" and "New deck" in FAB for a locked folder.
- ❌ Allow tapping past mode-lock without explicit user choice in unlocked mode.
- ❌ Display "Today (0)" — hide the Today CTA when 0 due (Current rule, Prompt 45).
- ❌ Truncate breadcrumb so user loses location. Past 3 levels, use middle ellipsis but keep first and last.
- ❌ Auto-unlock a locked-but-empty folder. Wait for explicit user action.
- ❌ Start a session directly from Folder Detail — Study/Today/Resume must go through the Study Entry Gate (or resume the existing session); the gate owns empty-scope validation and session creation.

## Components

| Component | Spec |
| --- | --- |
| App bar back | Returns to parent folder or Library. |
| Breadcrumb | Full path from Library to current. Tap any segment to jump. |
| Resume banner | **Current (Prompt 45; Discard added Prompt 47).** Visible iff resumable session with `entry_type=folder, entry_ref_id=this.id`. Resume (primary) opens that session (`context.goStudySession`); no new session created. Discard (secondary, destructive) cancels the paused session after confirmation (shared `confirmAndDiscardResumeSession`); never creates a session. |
| Study folder CTA | **Current (Prompt 45).** Tap → study entry gate `study/folder/:folderId` (new study). Shown iff recursive `totalCardCount > 0`. |
| Today CTA | **Current (Prompt 45).** Tap → study entry gate `study/folder/:folderId?study_type=srs_review` (folder-scoped review of due cards). Shown iff recursive `dueCount > 0` (hidden at zero). Note: this is `entry_type=folder` filtered to due via `study_type=srs_review`, NOT `entry_type=today` (which is global). |
| Subfolder row (subfolders mode) | Icon + name + "{n} subfolders" or "{n} decks" subtitle + chevron. |
| Deck row (decks mode) | Icon + name + "{n} cards" + optional "{m} due" badge + chevron. |
| FAB | **Current.** Plus button. Action depends on mode: New subfolder (subfolders mode), New deck (decks mode), choice both (unlocked mode). |
| Empty state | When `unlocked` and zero children: show choice layout. |
| Search + sort toolbar | **Current.** Renders via shared `MxSearchSortToolbar<ContentSortMode>` (`lib/presentation/shared/widgets/mx_search_sort_toolbar.dart`). Combines inline search field + sort menu chip into a single sticky row above the children list. Same widget instance is also used by other browsing surfaces; do NOT fork it. Sort options come from `ContentSortMode` enum (`lib/domain/enums/content_sort_mode.dart`). |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Initial fetch | Skeleton rows. |
| Populated | Has children | List shown. |
| Empty (unlocked) | Zero children | Empty state with mode-choice buttons. |
| Empty (locked) | Locked but empty (shouldn't happen normally; can occur if all children deleted) | Show "This folder is empty" with FAB action only. Don't auto-unlock. |
| Resume present | **Current (Prompt 45).** Folder has resumable session | Show Resume banner above CTAs. |
| Folder not found | `:id` invalid or deleted | Show error "Folder not found" with back button. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap back | Back | Pop to parent. |
| Tap breadcrumb segment | Tap | Go to that segment's folder; deep stack if needed. |
| Tap subfolder row | Tap | **Current.** `push` to `/library/folder/:childId`. |
| Tap deck row | Tap | **Current.** `push` to `/library/deck/:deckId/flashcards`. |
| Long-press row | Long-press | Open item context sheet (Rename / Move / Delete). |
| Tap "Study folder" | Tap | **Current (Prompt 45).** Navigate to `study/folder/:folderId` → study entry gate (new study). |
| Tap "Today (n)" | Tap | **Current (Prompt 45).** Navigate to `study/folder/:folderId?study_type=srs_review` → study entry gate (folder-scoped review). |
| Tap resume banner Resume | Tap | **Current (Prompt 45).** Navigate to the existing `study/session/{sessionId}`. No new session created. |
| Tap resume banner Discard | Tap | **Current (Prompt 47).** Show danger discard confirmation; on confirm cancel the paused session (shared `confirmAndDiscardResumeSession` → `CancelStudySessionUseCase`), refresh banner away. Cancel does nothing. Never creates a session. |
| Tap FAB | Tap | **Current.** Action depends on `content_mode`: open New folder dialog OR New deck sheet OR a 2-button picker (unlocked). |
| Tap overflow ⋮ | Tap | Menu: Rename folder / Move folder / Delete folder / Sort by. |

## Dialogs and bottom-sheets used

- Resume banner discard dialog — **Current (Prompt 47).** `MxConfirmationDialog` (danger) composed via the shared discard flow: `docs/wireframes/24-shared-dialogs.md` §discard-session.
- New folder dialog — `docs/wireframes/24-shared-dialogs.md` §folder-create.
- New deck bottom-sheet — `docs/wireframes/25-shared-bottom-sheets.md` §deck-create.
- Folder rename dialog — `docs/wireframes/24-shared-dialogs.md` §rename.
- Move-to-folder picker — `docs/wireframes/25-shared-bottom-sheets.md` §folder-picker.
- Delete folder dialog — `docs/wireframes/24-shared-dialogs.md` §delete-confirm.
- Item context sheet — `docs/wireframes/25-shared-bottom-sheets.md` §item-context.

## Navigation in

- Tap folder row from Library.
- Breadcrumb tap from descendant.
- Search result tap.

## Navigation out

- Subfolder row → child folder detail.
- Deck row → flashcard list.
- Study CTAs → **Future in V1.** Target: study entry gate / session.
- Back/breadcrumb → ancestor.

## Responsive

- ≥600dp: 2-col grid for rows. CTAs become inline buttons above grid.

## Performance

- Stream-based query for children based on `folder_id = :id`.
- Target/Future: recursive card count for folder-level study CTA cached for 30s; recalculated after content changes.

## Accessibility

- Breadcrumb is a single accessibility region; segments are buttons.
- Target/Future: "Study folder" disabled state announces reason ("No cards in this folder").

## Rules

- Folder shows EITHER subfolders OR decks based on `content_mode`. Never mixed.
- FAB action constrained by `content_mode`.
- Creating the first child in `unlocked` mode locks the folder to the corresponding mode.
- If a stale UI path or concurrent update attempts the incompatible action, the operation is rejected and the screen shows a localized snackbar, not a generic error:
  - folder already containing decks + create-subfolder attempt → "This folder already contains decks. Create a deck here or choose another folder for subfolders."
  - folder already containing subfolders + create-deck attempt → "This folder already contains subfolders. Create a subfolder here or choose another folder for decks."
- Deleting the last child can unlock back to `unlocked` (per `docs/business/folder/folder-management.md` state diagram).
- Empty folder in `unlocked` mode MUST show mode-choice empty state (not generic empty).
- Resume banner MUST appear above all other CTAs when present (Current, Prompt 45).

## Agent rule

- Do NOT show both "New subfolder" and "New deck" in a locked folder's FAB.
- Do NOT navigate user past mode-lock without explicit choice in unlocked mode.
- Breadcrumb MUST not become so long it overlaps title; truncate middle segments with ellipsis past ~3 levels.
- "Today (n)" CTA hidden when n = 0 (don't show "Today (0)") (Current, Prompt 45).
- Folder Detail MUST NOT bypass the Study Entry Gate; Today/Study folder route to the gate and Resume opens the existing session.

## Implementation refs

**Business specs:**

- `docs/business/folder/folder-management.md`
- `docs/business/deck/deck-management.md`
- `docs/business/resume/resume-session.md` (Current banner: Resume + Discard)

**Decision rows:**

- Folder management (mode lock, mode-choice empty state)
- Resume section (Current for this screen: Resume opens session; Discard cancels it)

**Schema / storage:**

- `folders.content_mode`, `folders.parent_id`
- Resume (Current for this screen): `study_sessions` filtered by entry_type=folder; Discard cancels via `CancelStudySessionUseCase` (no new session)

**Contracts:** `docs/contracts/usecase-contracts/folder.md`, `docs/contracts/usecase-contracts/deck.md`, `docs/contracts/repository-contracts/folder-repository.md`

**Code paths:**

- `lib/presentation/features/folders/screens/folder_detail_screen.dart`
- `lib/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart`
- `lib/presentation/features/folders/routes/folder_routes.dart`
- `lib/app/router/route_names.dart` → `RouteNames.folderDetail`

**Related wireframes:**

- `docs/wireframes/02-library.md` (parent)
- `docs/wireframes/06-flashcard-list.md` (deck child)
- `docs/wireframes/12-study-entry-gate.md` (folder-scoped study)
- `docs/wireframes/24-shared-dialogs.md` §folder-create, §rename, §delete-confirm, §discard-session
- `docs/wireframes/25-shared-bottom-sheets.md` §deck-create, §folder-picker, §item-context
