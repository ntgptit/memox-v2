---
last_updated: 2026-05-28
route: /library/folder/:id
source_specs:
  - docs/business/folder/folder-management.md
  - docs/business/deck/deck-management.md
  - docs/business/resume/resume-session.md
  - docs/business/study/study-flow.md
---

# 05 — Folder Detail

## Purpose

Browse a folder's children: either subfolders or decks (never both, per `content_mode` rule). Surface folder-level study CTAs and resume banner.

## Layout — folder in `subfolders` mode

```
┌───────────────────────────────────────┐
│ ← Korean                       🔍  ⋮  │  ← App bar; back to parent
├───────────────────────────────────────┤
│ Library / Korean                      │  ← Breadcrumb
├───────────────────────────────────────┤
│                                       │
│ ⚠ You have a paused study session     │  ← RESUME BANNER (when applicable)
│   for this folder.                    │
│   [Resume]  [Discard]                 │
├───────────────────────────────────────┤
│                                       │
│ ┌─────────────────┐  ┌─────────────┐ │
│ │ Study folder    │  │ Today (12)  │ │  ← Folder-level CTAs
│ │ ▸               │  │ ▸           │ │     "Today" shown if due > 0
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
│ │ Study folder    │  │ Today (8)   │ │
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
| Recursive card count (for Study CTA enable state) | aggregate from descendants | cached 30s, invalidated on content change |
| Recursive due count (for Today CTA subtitle) | aggregate filtered by SRS | cached 30s |
| Resumable session for this scope | `study_sessions` matched on `entry_type=folder` and `entry_ref_id=:folderId` | watch |

## Forbidden

- ❌ Show both "New subfolder" and "New deck" in FAB for a locked folder.
- ❌ Allow tapping past mode-lock without explicit user choice in unlocked mode.
- ❌ Display "Today (0)" — hide the chip when 0 due.
- ❌ Truncate breadcrumb so user loses location. Past 3 levels, use middle ellipsis but keep first and last.
- ❌ Auto-unlock a locked-but-empty folder. Wait for explicit user action.
- ❌ Cache recursive counts longer than 30s; content can change frequently.

## Components

| Component | Spec |
| --- | --- |
| App bar back | Returns to parent folder or Library. |
| Breadcrumb | Full path from Library to current. Tap any segment to jump. |
| Resume banner | Visible iff resumable session with `entry_type=folder, entry_ref_id=this.id`. |
| Study folder CTA | Tap → study entry gate `/library/study/folder/:folderId`. Disabled if folder has zero recursive cards. |
| Today CTA | Tap → study entry gate `/library/study/folder/:folderId` with `study_type = srs_review` (folder-scoped review of due cards). Subtitle shows recursive due count. Note: this is `entry_type=folder` filtered to due, NOT `entry_type=today` (which is global). |
| Subfolder row (subfolders mode) | Icon + name + "{n} subfolders" or "{n} decks" subtitle + chevron. |
| Deck row (decks mode) | Icon + name + "{n} cards" + optional "{m} due" badge + chevron. |
| FAB | Plus button. Action depends on mode: New subfolder (subfolders mode), New deck (decks mode), choice both (unlocked mode). |
| Empty state | When `unlocked` and zero children: show choice layout. |
| Search + sort toolbar | Renders via shared `MxSearchSortToolbar<ContentSortMode>` (`lib/presentation/shared/widgets/mx_search_sort_toolbar.dart`). Combines inline search field + sort menu chip into a single sticky row above the children list. Same widget instance is also used by other browsing surfaces; do NOT fork it. Sort options come from `ContentSortMode` enum (`lib/domain/enums/content_sort_mode.dart`). |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Initial fetch | Skeleton rows. |
| Populated | Has children | List shown. |
| Empty (unlocked) | Zero children | Empty state with mode-choice buttons. |
| Empty (locked) | Locked but empty (shouldn't happen normally; can occur if all children deleted) | Show "This folder is empty" with FAB action only. Don't auto-unlock. |
| Resume present | Folder has resumable session | Show banner above CTAs. |
| Folder not found | `:id` invalid or deleted | Show error "Folder not found" with back button. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap back | Back | Pop to parent. |
| Tap breadcrumb segment | Tap | Go to that segment's folder; deep stack if needed. |
| Tap subfolder row | Tap | `push` to `/library/folder/:childId`. |
| Tap deck row | Tap | `push` to `/library/deck/:deckId/flashcards`. |
| Long-press row | Long-press | Open item context sheet (Rename / Move / Delete). |
| Tap "Study folder" | Tap | Navigate to `/library/study/folder/:folderId` → study entry gate. |
| Tap "Today (n)" | Tap | Navigate to `/library/study/folder/:folderId?study_type=srs_review` → study entry gate (folder-scoped review). |
| Tap resume banner Resume | Tap | Navigate to `/library/study/session/{sessionId}`. |
| Tap resume banner Discard | Tap | Show discard dialog. |
| Tap FAB | Tap | Action depends on `content_mode`: open New folder dialog OR New deck sheet OR a 2-button picker (unlocked). |
| Tap overflow ⋮ | Tap | Menu: Rename folder / Move folder / Delete folder / Sort by. |

## Dialogs and bottom-sheets used

- Resume banner discard dialog — `docs/wireframes/24-shared-dialogs.md` §discard-session.
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
- Study CTAs → study entry gate / session.
- Back/breadcrumb → ancestor.

## Responsive

- ≥600dp: 2-col grid for rows. CTAs become inline buttons above grid.

## Performance

- Stream-based query for children based on `folder_id = :id`.
- Recursive card count for folder-level study CTA cached for 30s; recalculated after content changes.

## Accessibility

- Breadcrumb is a single accessibility region; segments are buttons.
- "Study folder" disabled state announces reason ("No cards in this folder").

## Rules

- Folder shows EITHER subfolders OR decks based on `content_mode`. Never mixed.
- FAB action constrained by `content_mode`.
- Creating the first child in `unlocked` mode locks the folder to the corresponding mode.
- If a stale UI path or concurrent update attempts the incompatible action, the operation is rejected and the screen shows a localized snackbar, not a generic error:
  - folder already containing decks + create-subfolder attempt → "This folder already contains decks. Create a deck here or choose another folder for subfolders."
  - folder already containing subfolders + create-deck attempt → "This folder already contains subfolders. Create a subfolder here or choose another folder for decks."
- Deleting the last child can unlock back to `unlocked` (per `docs/business/folder/folder-management.md` state diagram).
- Empty folder in `unlocked` mode MUST show mode-choice empty state (not generic empty).
- Resume banner MUST appear above all other CTAs when present.

## Agent rule

- Do NOT show both "New subfolder" and "New deck" in a locked folder's FAB.
- Do NOT navigate user past mode-lock without explicit choice in unlocked mode.
- Breadcrumb MUST not become so long it overlaps title; truncate middle segments with ellipsis past ~3 levels.
- "Today (n)" CTA hidden when n = 0 (don't show "Today (0)").

## Implementation refs

**Business specs:**

- `docs/business/folder/folder-management.md`
- `docs/business/deck/deck-management.md`
- `docs/business/resume/resume-session.md` (banner)

**Decision rows:**

- Folder management (mode lock, mode-choice empty state)
- Resume section

**Schema / storage:**

- `folders.content_mode`, `folders.parent_id`
- Resume: `study_sessions` filtered by entry_type=folder

**Contracts:** `docs/contracts/usecase-contracts/folder.md`, `docs/contracts/usecase-contracts/deck.md`, `docs/contracts/repository-contracts/folder-repository.md`

**Code paths:**

- `lib/presentation/features/folders/screens/folder_detail_screen.dart`
- `lib/presentation/features/folders/viewmodels/folder_detail_viewmodel.dart`
- `lib/presentation/features/folders/routes/folder_routes.dart`
- `lib/app/router/route_names.dart` → `RouteNames.folderDetail`

## V1 verification status (Prompt 19, 2026-05-31)

Honest split between what is implemented + tested (`Current`) and what this
wireframe specs but the screen does **not** yet expose (`Future`):

| Section | Status | Notes |
| --- | --- | --- |
| Route `/library/folder/:id` + invalid-id safety | Current | `folder_routes.dart`; missing folder → `NotFoundException` → `MxErrorState` with Retry (no crash, no raw exception). Tested. |
| Breadcrumb (Library → … → current) + segment tap | Current | `FolderHeaderSection` + `MxBreadcrumbBar`; ancestor tap navigates. Tested. |
| Content-mode rendering (subfolders / decks / unlocked) | Current | `effectiveContentMode` drives a single body; never mixed. Tested. |
| Inline scope-local search (`MxSearchSortToolbar`) | Current | Filters only the visible child type; never navigates to Global Search; does not mutate persisted order. Tested. |
| True-empty vs search no-results | Current | Gated by `FolderDetailState.hasUnfilteredChildren` (from `FolderDetailReadModel`). Genuinely empty folder stays true-empty for any search term; no-results ("Clear" CTA) only when children exist but are filtered out. Tested (Prompt 19). |
| Sort (`ContentSortMode`: manual/name/newest/lastStudied) | Current | Applied at repository/use-case layer; selected sort shown in `MxSortMenuChip`; manual = persisted order. Repo-tested. |
| Create subfolder / deck + lock-mode typed snackbar | Current | Shared `MxNameDialog`; unlocked FAB shows 2-choice sheet; stale invalid action → typed localized snackbar (`folder_contains_decks` / `folder_contains_subfolders`, Prompt 14). Tested. |
| Row actions (subfolder/deck Edit / Move / Delete / Import / Duplicate / Export) | Current | Long-press + overflow open `showFolderActions` / `showDeckActions`; deck import routes to Deck Import. Tested. |
| Manual reorder (drag) | Current | Enter via overflow when `sortMode.allowsManualReorder`; Save/Cancel. Tested at repo/use-case layer. |
| **Study folder CTA / Today (n) CTA** | **Future** | The screen exposes **no** folder-level study CTA. `AppNavigation` has folder-scope study helpers, but Folder Detail does not call them. Belongs to study-entry-gate work (§12), not Folder Detail V1. |
| **Resume banner** | **Future** | Not rendered on this screen. Tracked under `docs/business/resume/resume-session.md`. |

Out of Folder Detail V1 scope (remain Future, not exposed here): Global Search
screen/route, Flashcard History, Drive sync, Progress/Settings, tag-scoped
study, root-level deck rendering in Library Overview, Library FAB action sheet.

**Related wireframes:**

- `docs/wireframes/02-library.md` (parent)
- `docs/wireframes/06-flashcard-list.md` (deck child)
- `docs/wireframes/12-study-entry-gate.md` (folder-scoped study)
- `docs/wireframes/24-shared-dialogs.md` §folder-create, §rename, §delete-confirm, §discard-session
- `docs/wireframes/25-shared-bottom-sheets.md` §deck-create, §folder-picker, §item-context
