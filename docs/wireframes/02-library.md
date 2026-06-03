---
last_updated: 2026-06-02
route: /library
source_specs:
  - docs/business/folder/folder-management.md
  - docs/business/deck/deck-management.md
  - docs/business/search/global-search.md
---

# 02 — Library

## V1 verification status (2026-05-31, Prompt 18/18B; root-deck decision updated 2026-06-03, Prompt 43A; 6-state visual parity 2026-06-04, Prompt 49; loaded-state visual fix 2026-06-04, Prompt 49B)

This screen is **partially Current**. The recursive folder counts (verified Prompt 14) plus the aspects below are verified by code and tests; the remainder is **Future** and intentionally not exposed in V1. Do NOT mark the whole screen Current. The §Layout / §Components / §Actions / §Sort options blocks below describe the **target** design; where they conflict with this section, this section is the current truth.

**Prompt 49 scope (2026-06-04):** visual/layout parity for the **6 Library Overview states only** (loaded · loading · empty · error · search · overflow sheet) against `docs/system-design/MemoX Design System/ui_kits/mobile/index.html` §"03 · Library overview". No schema/SRS/domain/repository/use-case behavior change. Library search stays inline/scope-local; Global Search and a `/library/search` screen remain **Future**; root-level decks remain **Rejected / Out of Scope**; the overflow sheet exposes only current approved folder actions (Edit / Move / Import flashcards / Delete). Card padding/radius and bottom-nav density remain a separate Design Token / Density Foundation follow-up and were not changed here.

**Prompt 49B scope (2026-06-04):** fixes the **loaded-state visual drift** left by Prompt 49 against the same mock §"03 · Library overview". No schema/SRS/repository/use-case change. Changes are presentation-only:

- Header right control is now a sliders/filter affordance (`Icons.tune_rounded`), **not** a search-icon toggle. It is a **visual-only target** — rendered disabled because Library has no approved filter/sort sheet yet (no unsupported action is exposed).
- Search is **always-visible inline** scope-local search directly below the title (no toggle). It never navigates; Global Search and `/library/search` remain **Future**.
- The static `All` filter chip is **removed** from the loaded header.
- Loaded state renders a `{n} FOLDERS` overline section header (count only; **no sort control** — the mock sort pill remains Future).
- A **due summary card** (`{n} cards due today`) is rendered when `dueToday > 0` and hidden otherwise. It is **non-interactive**: Library state only knows the aggregate `dueToday`, so there is no subtitle (folder span / estimated minutes) and no study-launch navigation.
- The FAB is now a labelled **`New folder` pill** wired to the existing create-folder flow. **New deck / Import are not exposed** from Library root.

**Verified Current (behaviour + tests):**

- Route `/library` opens `LibraryOverviewView` (also `initialLocation`). Folder row → `pushFolderDetail` → `/library/folder/:id`. No `/library/search` route exists; the always-visible inline search field filters scope-locally, it does not navigate.
- Renders **top-level folders only**. Recursive subtree counts per folder (subfolders · decks · cards · due) are Current from Prompt 14 and isolated between sibling roots.
- States (all 6 verified by widget tests, Prompt 49):
  - **Loaded** — `LibraryFolderSliver` of `MxFolderTile` rows; no root-level deck card (`MxDeckCard` absent).
  - **Loading** — `MxRetainedAsyncState.skeletonBuilder` → `LibrarySkeleton` (skeleton folder rows, `ValueKey('library_skeleton')`), not a full-screen spinner; no folder row is tappable while data is absent.
  - **Error** — `MxRetainedAsyncState.errorBuilder` → `MxErrorState` with localized `libraryLoadFailedTitle` / `libraryLoadFailedMessage`, `Icons.cloud_off_outlined`, Retry → `ref.invalidate(libraryOverviewQueryProvider)`; no raw exception text surfaced.
  - **True empty library** — `totalFolderCount == 0`, regardless of search term → `LibraryEmptyStateSection` "Create folder" CTA.
  - **Search no-results** — `folders.isEmpty && searchTerm` active **&& `totalFolderCount > 0`** → `LibrarySearchNoResultsSection`, `ValueKey('library_search_no_results')`, "Clear" CTA. Distinct from true empty (Prompt 18; classification corrected Prompt 18B — counts driven by `LibraryOverviewState.totalFolderCount` from `LibraryOverviewReadModel.totalFolderCount`).
  - **Overflow sheet** — each folder row carries a visible kebab (`Icons.more_vert`, tooltip `libraryOverflowTooltip`) **and** long-press, both opening the folder action sheet.
- Inline search (Prompt 49B: always visible below the title, no toggle): scope-local within Library. When a term is active the query broadens to match **any folder by name across the tree** (`listAllFolders` + normalized contains); empty term restores top-level folders. Never routes to Global Search; does not mutate persisted `sort_order`.
- Loaded section header: `{n} FOLDERS` overline (`libraryFolderCountLabel`, count only — no sort UI control).
- Due summary card (Prompt 49B): rendered when `dueToday > 0` (`libraryDueSummaryTitle`), hidden otherwise. Non-interactive — no subtitle and no study-launch (state only carries the aggregate `dueToday`).
- Create folder: FAB is a labelled **`New folder` pill** (`MxFab` extended, `Icons.create_new_folder_outlined`, `libraryNewFolderLabel`); the empty-state CTA and the pill both open `MxNameDialog` → `createFolderUseCase.createRoot`. Blank name rejected by dialog; failures map to a localized error snackbar; success refreshes via `contentDataRevision`. No New deck / Import entry on Library root.
- Folder row overflow (kebab tap or long-press) → folder actions sheet (Edit / Move / Import flashcards / Delete); Import hidden for subfolder-mode folders. The mock's "Study due cards" / "Archive folder" actions are **not** exposed (out of current scope).
- Sort (`ContentSortMode`: manual/name/newest/lastStudied) is implemented and tested at the **repository + use-case** layer (`folder_repository_impl`, `content_repository_test`). The viewmodel exposes `setSortMode`. No sort **UI control** is rendered (the mock's sort pill remains Future).

**Future / not exposed in V1:**

- **Root-level decks are Rejected / Out of Scope.** `LibraryOverviewReadModel` carries `folders` only. The §Layout "Top-level deck" rows and the "Tap deck row → /library/deck/:deckId/flashcards" action are visual history only, not target scope.
- FAB action sheet (New folder / New deck / Import) — V1 FAB is a `New folder` pill that creates a folder directly; there is no New deck or Import entry on Library Overview. Deck creation/import remain owned by Folder Detail / Flashcard List / Deck Import.
- Filter chips (All / Folders / Decks) — removed in Prompt 49B (the previous static, non-functional "All" chip is gone). A real filter/sort control behind the header sliders icon remains Future.
- No sort **UI control** on Library Overview (no overflow sort menu / sort chip). Sort exists only in the data/use-case layer.
- Drag-to-reorder of root items, pull-to-refresh, and grid/multi-column responsive layout.
- Global Search screen / `/library/search` route (Global Search remains Future).

**Prompt 42/42B superseded (2026-06-03, Prompt 43A):** Product ownership rejected
root-level decks and nullable deck parent migration. Keep `decks.folder_id`
non-null, keep deck APIs folder-bound, and keep Library root folders-only.
`docs/database/migrations/nullable-deck-parent-migration.md` is retained as a
rejected historical design note only.

## Purpose

Root content browser. Current V1 shows top-level folders only. Root-level decks are Rejected / Out of Scope and are not rendered in the current app. Entry point for content management and a launch point for study.

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
| Top-level decks (`folder_id IS NULL`) | Rejected / Out of Scope | do not query; decks must belong to exactly one folder |
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
- `lib/presentation/features/folders/widgets/library_folder_list.dart` (folder rows + kebab overflow trigger), `library_app_bar.dart`, `library_empty_state_section.dart` (`LibraryEmptyStateSection`, `LibrarySearchNoResultsSection`), `library_skeleton.dart` (`LibrarySkeleton`, Prompt 49)
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
