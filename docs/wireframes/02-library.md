---
last_updated: 2026-05-31
route: /library
source_specs:
  - docs/business/folder/folder-management.md
  - docs/business/deck/deck-management.md
  - docs/business/search/global-search.md
---

# 02 — Library

## V1 verification status (2026-05-31, Prompt 18/18B)

This screen is **partially Current**. The recursive folder counts (verified Prompt 14) plus the aspects below are verified by code and tests; the remainder is **Future** and intentionally not exposed in V1. Do NOT mark the whole screen Current. The §Layout / §Components / §Actions / §Sort options blocks below describe the **target** design; where they conflict with this section, this section is the current truth.

**Verified Current (behaviour + tests):**

- Route `/library` opens `LibraryOverviewView` (also `initialLocation`). Folder row → `pushFolderDetail` → `/library/folder/:id`. No `/library/search` route exists; the search icon opens an inline field, it does not navigate.
- Renders **top-level folders only**. Recursive subtree counts per folder (subfolders · decks · cards · due) are Current from Prompt 14 and isolated between sibling roots.
- States: Loading (`MxRetainedAsyncState` → `MxLoadingState`), error (retained-async error surface, no raw exception text), **true empty library** (`totalFolderCount == 0`, regardless of search term → `LibraryEmptyStateSection` "Create folder" CTA), and **search no-results** (`folders.isEmpty && searchTerm` active **&& `totalFolderCount > 0`** → `LibrarySearchNoResultsSection`, `ValueKey('library_search_no_results')`, "Clear" CTA). Distinct (Prompt 18; classification corrected Prompt 18B — counts driven by `LibraryOverviewState.totalFolderCount` from `LibraryOverviewReadModel.totalFolderCount`).
- Inline search: scope-local within Library. When a term is active the query broadens to match **any folder by name across the tree** (`listAllFolders` + normalized contains); empty term restores top-level folders. Never routes to Global Search; does not mutate persisted `sort_order`.
- Create folder: FAB (single `Icons.add`) and empty-state CTA both open `MxNameDialog` → `createFolderUseCase.createRoot`. Blank name rejected by dialog; failures map to a localized error snackbar; success refreshes via `contentDataRevision`.
- Folder row long-press → folder actions sheet (Edit / Move / Import flashcards / Delete); Import hidden for subfolder-mode folders.
- Sort (`ContentSortMode`: manual/name/newest/lastStudied) is implemented and tested at the **repository + use-case** layer (`folder_repository_impl`, `content_repository_test`). The viewmodel exposes `setSortMode`.

**Future / not exposed in V1:**

- **Root-level decks are NOT rendered.** `LibraryOverviewReadModel` carries `folders` only; decks whose `folder_id` is null are not surfaced here. The §Layout "Top-level deck" rows and the "Tap deck row → /library/deck/:deckId/flashcards" action are target, not current.
- FAB action sheet (New folder / New deck / Import) — V1 FAB creates a folder directly; there is no New deck or Import entry on Library Overview. Deck creation/import remain owned by Folder Detail / Flashcard List / Deck Import.
- Filter chips (All / Folders / Decks) — only a static "All" chip is rendered; it is non-functional.
- No sort **UI control** on Library Overview (no overflow sort menu / sort chip). Sort exists only in the data/use-case layer.
- Drag-to-reorder of root items, pull-to-refresh, and grid/multi-column responsive layout.
- Global Search screen / `/library/search` route (Global Search remains Future).

## Purpose

Root content browser. Current V1 shows top-level folders only. Top-level deck rows (decks whose `folder_id` is the root) remain Future/Target and are not rendered in the current app. Entry point for content management and a launch point for study.

## Layout

```
┌───────────────────────────────────────┐
│ Library                  🔍   ⋮       │  ← App bar; search → /library/search
├───────────────────────────────────────┤
│                                       │     ⋮ overflow → menu (sort, new)
│ ┌─[ All ]─[ Folders ]─[ Decks ]─────┐ │  ← Optional filter chips (top-level)
│ └───────────────────────────────────┘ │
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ 📁 Korean              5 decks ▸ │ │  ← Folder row
│ ├───────────────────────────────────┤ │
│ │ 📁 English             3 decks ▸ │ │
│ ├───────────────────────────────────┤ │
│ │ 📁 Misc                1 deck  ▸ │ │
│ ├───────────────────────────────────┤ │
│ │ 📚 Quick vocab        42 cards ▸ │ │  ← Top-level deck
│ ├───────────────────────────────────┤ │
│ │ 📚 IELTS words       180 cards ▸ │ │
│ └───────────────────────────────────┘ │
│                                       │
│                            ┌───┐      │
│                            │ + │      │  ← FAB
│                            └───┘      │
├───────────────────────────────────────┤
│ 🏠 Home  📚 Library  📈 Progress  ⚙️  │
└───────────────────────────────────────┘
```

## Layout — empty state

```
┌───────────────────────────────────────┐
│ Library                  🔍   ⋮       │
├───────────────────────────────────────┤
│                                       │
│              📁                        │
│                                       │
│      Nothing here yet                 │
│                                       │
│   Create a folder to organize, or a   │
│   deck to start adding cards.         │
│                                       │
│   ┌──────────────┐  ┌──────────────┐  │
│   │ + New folder │  │ + New deck   │  │
│   └──────────────┘  └──────────────┘  │
│                                       │
│            or                          │
│                                       │
│   [Import from file]                  │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `filter` (optional query param) | URL | `all` / `folders` / `decks`; default `all` |
| `sort` (optional query param) | URL or SharedPreferences | persisted |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Top-level folders (`parent_id IS NULL`) | `folders` table | stream from DB |
| Top-level decks (`folder_id IS NULL`) | `decks` table | stream from DB |
| Per-row card count (decks) | `flashcards` aggregate cached | invalidated on flashcard change |
| Per-row subfolder/deck count (folders) | aggregates cached | invalidated on folder/deck change |
| Sort preference | SharedPreferences key `library.sort` | watch |

## Forbidden

- ❌ Query DAO from widget. Use `LibraryNotifier`.
- ❌ Mix folder and deck rows alphabetically when sort is manual. Folders MUST appear above decks in manual sort.
- ❌ Recompute aggregate counts on every render. Cache 60s.
- ❌ Lose drag-reorder on app restart. Persist to `sort_order` column.
- ❌ Show FAB action sheet's "New deck" when current root would require choosing a folder first — not applicable at root (root acts as unlocked), but if extended, follow folder-detail rules.

## Components

| Component | Spec |
| --- | --- |
| App bar | Title "Library". Right side: search icon, overflow menu (⋮). |
| Filter chips | Optional. Three chips: All / Folders / Decks. Default: All. |
| Item row | Icon (folder 📁 or deck 📚) + name + subtitle (count) + chevron. |
| Folder subtitle | "{n} decks" or "{n} subfolders" depending on `content_mode`. |
| Deck subtitle | "{n} cards" (total) and optional "{m} due" badge in theme color. |
| FAB | Plus button (bottom-right). Tap → action sheet: New folder / New deck / Import. |

### Count semantics

- Folder-row counts are recursive over the folder subtree: descendant subfolders, decks in any descendant folder, and flashcards inside those decks are included.
- Root-level sibling folder trees are isolated; counts from one root folder do not leak into another.
- Empty nested folders contribute `0` deck/card/due/new-card counts.
- Deck/card counts are derived from deck and flashcard rows in the subtree and are not recomputed in presentation.

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Loading | Initial query | Shimmer rows. |
| Populated | Normal | List shown. |
| Empty | No folders AND no top-level decks | Empty state layout. |
| Error | Query failure | Inline error card with retry. |
| Sort active | User picked a sort | Items reordered; chip in app bar showing current sort. |

## Sort options (from overflow)

| Sort | Stored as |
| --- | --- |
| Manual (default) | `sort_order` |
| Name A→Z | `name` ascending |
| Name Z→A | `name` descending |
| Recently updated | `updated_at` descending |
| Most cards | computed |

Sort preference persists per user via SharedPreferences (key `library.sort`).

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Tap folder row | Tap | Navigate to `/library/folder/:id`. |
| Tap deck row | Tap | Navigate to `/library/deck/:deckId/flashcards`. |
| Long-press folder/deck | Long-press | Enter selection mode (multi-select) OR open context bottom-sheet (Rename / Move / Delete). Decide via UI/UX contract; recommend context sheet here since multi-select on folders is rare. |
| Tap search icon | Tap | Navigate to `/library/search`. |
| Tap overflow ⋮ | Tap | Menu: Sort by ▸ / New folder / New deck / Import. |
| Tap FAB | Tap | Action sheet (`docs/wireframes/25-shared-bottom-sheets.md` §library-fab). |
| Pull to refresh | Pull | Re-run queries. |
| Reorder (drag) in Manual sort | Long-press handle + drag | Update `sort_order` of dragged item; persist on drop. |

## Dialogs and bottom-sheets used

- Library FAB action sheet — see `docs/wireframes/25-shared-bottom-sheets.md` §library-fab.
- New folder dialog — see `docs/wireframes/24-shared-dialogs.md` §folder-create.
- New deck bottom-sheet (with target_language field) — see `docs/wireframes/25-shared-bottom-sheets.md` §deck-create.
- Item context sheet (Rename / Move / Delete) — see `docs/wireframes/25-shared-bottom-sheets.md` §item-context.
- Delete confirm dialog — see `docs/wireframes/24-shared-dialogs.md` §delete-confirm.
- Move-to-folder picker — see `docs/wireframes/25-shared-bottom-sheets.md` §folder-picker.

## Navigation in

- Bottom nav tap "Library".
- App launch when user has explicit deep-link.
- From Settings → Manage data → back to Library.

## Navigation out

- Folder row → `/library/folder/:id`.
- Deck row → `/library/deck/:deckId/flashcards`.
- Search icon → `/library/search`.
- Tabs → other top-level destinations.

## Responsive

- ≥600dp: grid layout, 2 columns of cards instead of single-column list.
- ≥1024dp: 3 columns; FAB stays bottom-right.

## Performance

- Stream-based query via Drift `watchTopLevelFoldersAndDecks`. Re-renders on data change.
- Reorder writes batched; one transaction per drop.
- Card-count subtitle uses cached counts (avoid count per row on every render).

## Accessibility

- Item rows: announce "{Folder|Deck} {name}, {subtitle}".
- FAB labeled "Add content".
- Filter chips selectable via keyboard nav on tablet.

## Rules

- Top-level items are folders + decks whose `folder_id` is null.
- Decks at root are allowed (Library is treated as an implicit unlocked root container; "decks can be in folders that are unlocked or `decks` mode" — root is conceptually unlocked).
- FAB action sheet MUST include Import even though Import is technically per-deck (it routes via "pick a deck" flow when invoked from Library FAB).
- Sort default is Manual (user-controlled order via `sort_order`).

## Agent rule

- Do NOT create a separate route for "folder/0" or root folder. Library IS the root.
- Do NOT mix folder and deck rows visually in confusing ways; keep folders above decks when sorting by manual order.
- Reorder MUST persist; do not lose order on app restart.
- Empty state CTAs MUST be clearly distinct visually from FAB to avoid duplicate paths confusion.

## Implementation refs

**Business specs:**

- `docs/business/folder/folder-management.md`
- `docs/business/deck/deck-management.md`
- `docs/business/search/global-search.md` (search icon entry)

**Decision rows:**

- Folder management, Deck management (top-level rules)

**Schema / storage:**

- `folders` (parent_id = null = root), `decks` (folder_id = null = root)
- SharedPreferences: `library.sort`

**Contracts:** `docs/contracts/usecase-contracts/folder.md`, `docs/contracts/usecase-contracts/deck.md`, `docs/contracts/repository-contracts/folder-repository.md`, `docs/contracts/repository-contracts/deck-repository.md`

**Code paths (verified Prompt 18):**

- `lib/presentation/features/folders/screens/library_overview_screen.dart`
- `lib/presentation/features/folders/viewmodels/library_overview_viewmodel.dart` (`libraryOverviewQuery`, `LibraryToolbarState`, `LibraryOverviewActionController`)
- `lib/presentation/features/folders/widgets/library_folder_list.dart`, `library_app_bar.dart`, `library_empty_state_section.dart` (`LibraryEmptyStateSection`, `LibrarySearchNoResultsSection`)
- `lib/presentation/features/folders/routes/folder_routes.dart` (`libraryBranchRoutes`)
- `lib/domain/usecases/content_query_usecases.dart` → `WatchLibraryOverviewUseCase`
- `lib/data/repositories/folder_repository_impl.dart` → `getLibraryOverview`
- `lib/app/router/route_names.dart` → `RouteNames.library`

**Related wireframes:**

- `docs/wireframes/05-folder-detail.md` — child folder detail
- `docs/wireframes/06-flashcard-list.md` — deck content
- `docs/wireframes/11-library-search.md` — search target
- `docs/wireframes/24-shared-dialogs.md` §folder-create, §delete-confirm
- `docs/wireframes/25-shared-bottom-sheets.md` §library-fab, §deck-create, §item-context, §folder-picker
