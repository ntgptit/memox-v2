---
last_updated: 2026-05-26
route: /library
source_specs:
  - docs/business/folder/folder-management.md
  - docs/business/deck/deck-management.md
  - docs/business/search/global-search.md
---

# 02 — Library

## Purpose

Root content browser. Shows top-level folders and decks (those whose `folder_id` is the root). Entry point for content management and a launch point for study.

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

**Code paths:**
- `lib/presentation/features/library/screens/library_screen.dart`
- `lib/presentation/features/library/notifiers/library_notifier.dart`
- `lib/presentation/features/library/widgets/library_row.dart`
- `lib/domain/usecases/library/get_root_items_usecase.dart`
- `lib/app/router/route_names.dart` → `RouteNames.library`

**Related wireframes:**
- `docs/wireframes/05-folder-detail.md` — child folder detail
- `docs/wireframes/06-flashcard-list.md` — deck content
- `docs/wireframes/11-library-search.md` — search target
- `docs/wireframes/24-shared-dialogs.md` §folder-create, §delete-confirm
- `docs/wireframes/25-shared-bottom-sheets.md` §library-fab, §deck-create, §item-context, §folder-picker
