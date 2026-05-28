---
last_updated: 2026-05-26
route: /library/search
source_specs:
  - docs/business/search/global-search.md
---

# 11 — Library Search

## Purpose

Search across folders, decks, flashcards, and tags. Default recursive scope across all user content (active account).

## Layout — initial (no query yet)

```
┌───────────────────────────────────────┐
│ ←  🔍  Search                  ✕      │  ← Search field full-width
├───────────────────────────────────────┤
│                                       │
│ RECENT                                │
│ ┌───────────────────────────────────┐ │
│ │ 🕐 korean grammar          ✕      │ │  ← Tap to re-run; ✕ to remove
│ ├───────────────────────────────────┤ │
│ │ 🕐 hello                   ✕      │ │
│ ├───────────────────────────────────┤ │
│ │ 🕐 #weak                   ✕      │ │
│ └───────────────────────────────────┘ │
│                                       │
│ POPULAR TAGS                          │
│ ┌───────────────────────────────────┐ │
│ │ #greet 42  #N5 60  #weak 12       │ │  ← Top tags by usage
│ │ #verb 80  #adj 30                 │ │
│ └───────────────────────────────────┘ │
│                                       │
└───────────────────────────────────────┘
```

## Layout — typing (query too short)

```
┌───────────────────────────────────────┐
│ ←  🔍  ko_                     ✕      │
├───────────────────────────────────────┤
│                                       │
│   Type at least 2 characters.         │
│                                       │
└───────────────────────────────────────┘
```

## Layout — results

```
┌───────────────────────────────────────┐
│ ←  🔍  korean                  ✕      │
├───────────────────────────────────────┤
│                                       │
│ FOLDERS (3)                           │
│ ┌───────────────────────────────────┐ │
│ │ 📁 Korean                         │ │
│ │    in Library                     │ │
│ ├───────────────────────────────────┤ │
│ │ 📁 Korean Honorifics              │ │
│ │    in Library                     │ │
│ ├───────────────────────────────────┤ │
│ │ 📁 Grammar                        │ │
│ │    in Library / Korean            │ │
│ └───────────────────────────────────┘ │
│                                       │
│ DECKS (8)  [Show all]                 │
│ ┌───────────────────────────────────┐ │
│ │ 📚 Korean N5                      │ │
│ │    42 cards · in Library / Korean │ │
│ ├───────────────────────────────────┤ │
│ │ 📚 Korean N4                      │ │
│ │    60 cards · in Library / Korean │ │
│ └───────────────────────────────────┘ │
│                                       │
│ FLASHCARDS (42)  [Show all]           │
│ ┌───────────────────────────────────┐ │
│ │ 안녕하세요                         │ │
│ │ Hello · in Korean N5              │ │
│ ├───────────────────────────────────┤ │
│ │ 감사합니다                         │ │
│ │ Thank you · in Korean N5          │ │
│ └───────────────────────────────────┘ │
│                                       │
│ TAGS (2)                              │
│ ┌───────────────────────────────────┐ │
│ │ #korean  38 cards                 │ │
│ ├───────────────────────────────────┤ │
│ │ #koreanslang  6 cards             │ │
│ └───────────────────────────────────┘ │
│                                       │
└───────────────────────────────────────┘
```

## Layout — no results

```
┌───────────────────────────────────────┐
│ ←  🔍  xyzqq                   ✕      │
├───────────────────────────────────────┤
│                                       │
│              🔍                        │
│                                       │
│      No results for "xyzqq".          │
│                                       │
│   Try fewer characters or check       │
│   for typos.                          │
│                                       │
└───────────────────────────────────────┘
```

## Inputs

| Param | Source | Notes |
| --- | --- | --- |
| `q` (optional query param) | URL | initial search text; for deep-link |
| `deckScope` (optional query param) | URL | when entered from flashcard list, pre-filter to deck |

## Data to load

| Data | Source | Refresh trigger |
| --- | --- | --- |
| Recent searches (top 5) | SharedPreferences `search.recent` | watch |
| Popular tags (top 5 by usage) | `flashcard_tags` aggregate GROUP BY tag ORDER BY count DESC LIMIT 5 | watch, cached 5 min |
| Folder results (LIKE on name) | `folders WHERE LOWER(name) LIKE ?` | debounced 300ms after >= 2 chars |
| Deck results | `decks WHERE LOWER(name) LIKE ?` | same |
| Flashcard results | `flashcards WHERE LOWER(front) LIKE ? OR LOWER(back) LIKE ?` | same |
| Tag results | `flashcard_tags WHERE LOWER(tag) LIKE ?` aggregated | same |

Each section fires independently; UI populates progressively.

## Forbidden

- ❌ Add flat/recursive toggle. Search is recursive by default.
- ❌ Cache result lists across queries. Each query is fresh.
- ❌ Allow special LIKE chars `%` `_` raw in query. Escape before passing.
- ❌ Use ranked search (FTS) without explicit ADR. Keep LIKE for now.
- ❌ Persist > 5 recent searches. Cap and rotate.
- ❌ Fire query at < 2 chars. Show "Type at least 2 characters" hint.
- ❌ Cancel a query without stopping its underlying stream subscription (memory leak).

## Components

| Component | Spec |
| --- | --- |
| Search bar | Full-width text field in app bar. Auto-focus on screen open. ✕ clears query. |
| Recent searches | Up to 5 chips/rows. Stored in SharedPreferences. ✕ removes single entry. |
| Popular tags | Top tags by usage count across all decks. Tap → run search with `#{tag}`. |
| Results section | Per-type: Folders / Decks / Flashcards / Tags. Each capped at 5 visible with "Show all". |
| Result row | Icon + main label + breadcrumb subtitle. |
| No-results state | Friendly empty state with suggestion. |

## Result row content

| Type | Icon | Main | Subtitle |
| --- | --- | --- | --- |
| Folder | 📁 | folder name | `in {parent path}` |
| Deck | 📚 | deck name | `{n} cards · in {folder path}` |
| Flashcard | 🃏 | front (truncated 60 chars) | `{back truncated} · in {deck name}` |
| Tag | 🏷 | `#{tag}` | `{n} cards` |

## States

| State | Trigger | Behavior |
| --- | --- | --- |
| Empty query | Field cleared | Show recent + popular tags. |
| Too short | Query length 1 | Hint "Type at least 2 characters". |
| Loading | Query fired after debounce 300ms | Skeleton rows in each section that loads. Sections fill in independently. |
| Results | Query >= 2 chars and matches | Grouped results. |
| No results | Query >= 2 chars, zero matches | Empty state. |
| Error | Query failure (rare) | Inline error per section. |

## Actions

| Action | Trigger | Result |
| --- | --- | --- |
| Type in search bar | Type | Debounce 300ms → fire query. |
| Tap ✕ | Tap | Clear field; revert to initial layout. |
| Tap recent search row | Tap | Re-populate field; run query. |
| Tap ✕ on recent row | Tap | Remove from recent list. |
| Tap popular tag | Tap | Run search with tag name (no `#` in query — match by tag type). |
| Tap folder result | Tap | Navigate to `/library/folder/:id`. |
| Tap deck result | Tap | Navigate to `/library/deck/:deckId/flashcards`. |
| Tap flashcard result | Tap | Navigate to flashcard list of that card's deck; scroll to row; enter edit-ready state. |
| Tap tag result | Tap | Navigate to flashcard list filtered to that tag globally (cross-deck view). |
| Tap "Show all" | Tap | Expand section in place (paginated). |
| Tap back | Back | Pop to caller (usually Library or Dashboard). |

## Dialogs and bottom-sheets used

None native to this screen.

## Query rules

- Min 2 chars before query fires.
- Debounce 300ms.
- Case- and diacritic-insensitive.
- Multi-token AND (each token must match somewhere in row).
- Special chars (`%`, `_`) escaped before LIKE.
- Tag chip popular section shows top 5 by `flashcard_tags` usage count.

## Navigation in

- App bar search icon from Dashboard or Library.
- Search icon from Flashcard list (pre-scoped to deck — same screen, with a deck-filter chip shown).
- Deep link.

## Navigation out

- Result tap → respective destination.
- Back → caller.

## Responsive

- ≥600dp: results in two columns. Folders+Decks left, Flashcards+Tags right.

## Performance

- Query uses Drift `LIKE` with escaped special chars.
- Each section fires independently; UI populates progressively.
- Stop in-flight query on new keystroke (debounce naturally handles via cancellation).
- Recent + popular tags cached in memory for the screen lifecycle.

## Accessibility

- Search field labeled "Search MemoX".
- Hint announced when < 2 chars typed.
- Section headers as headings.
- "Show all" labeled with count for context.

## Rules

- Recursive by default everywhere (no flat/recursive toggle).
- Empty input MUST show recent + popular tag shortcuts.
- Special chars in user query MUST be escaped before LIKE.
- Result actions MUST use route constants.
- Tag search via popular chip: query targets tag matching, not text search containing `#`.

## Agent rule

- Do NOT show a flat/recursive toggle. Recursive is the only behavior.
- Do NOT cache result lists across queries; each query is fresh.
- Result row order within a section: exact name > starts-with > substring > recency tie-break.
- Recent searches MUST persist across app restarts (SharedPreferences). Cap at 5.

## Implementation refs

**Business specs:**
- `docs/business/search/global-search.md`
- `docs/business/tags/tag-system.md` (tag result rows)

**Decision rows:**
- SR1-SR10 (recursive default, breadcrumb, debounce, 2-char min)

**Schema / storage:**
- LIKE queries against `folders.name`, `decks.name`, `flashcards.front/back`, `flashcard_tags.tag`
- SharedPreferences: `search.recent` (cap 5)

**Contracts:** `docs/contracts/usecase-contracts/search.md`

**Code paths:**
- `lib/presentation/features/search/screens/library_search_screen.dart`
- `lib/presentation/features/search/notifiers/library_search_notifier.dart`
- `lib/presentation/features/search/widgets/result_group.dart`
- `lib/domain/usecases/search/global_search_usecase.dart`
- `lib/data/repositories/search_repository.dart`
- `lib/app/router/route_names.dart` → `RouteNames.librarySearch`

**Related wireframes:**
- `docs/wireframes/01-dashboard.md` (search icon source), `docs/wireframes/02-library.md` (search icon source), `docs/wireframes/06-flashcard-list.md` (in-deck search variant)
