---
last_updated: 2026-05-26
applies_to: global search across folders, decks, flashcards, tags
---

# Search

## Purpose

As the user accumulates content, finding a specific deck or card requires browsing through folder hierarchy. Global search provides a single entry point to locate content by name or content.

## Surfaces

| Surface | Scope | Trigger |
| --- | --- | --- |
| Library top bar search | Folders, decks, flashcards, tags across all data | Tap search icon on Library screen |
| Flashcard list search | Flashcards in current deck | Tap search icon on flashcard list |
| Folder detail search | Subfolders and decks in current folder | Tap search icon on folder detail |
| Tag search (within management) | Tags by name | Inline filter on tag management screen |

This doc focuses primarily on global Library-level search. Scoped searches reuse the same query infrastructure with added filter clauses.

## Query input

| Aspect | Behavior |
| --- | --- |
| Min characters | 2 chars; below 2 → show "Type at least 2 characters" hint, no query fired |
| Debounce | 300ms (matches UI/UX contract performance rules) |
| Case sensitivity | Case-insensitive |
| Diacritics | Insensitive (compare normalized form). Implementation: rely on SQLite `LIKE` with normalized columns or `LOWER` + diacritic stripping helper |
| Partial match | Substring match (`LIKE '%term%'`) |
| Whitespace | Trim around query; collapse internal whitespace to single space |

Multi-token queries (e.g., "korean grammar"):

- Tokenize by whitespace.
- Require ALL tokens to match (AND), each token can match any of the searched fields.

## Searched fields

| Result type | Fields searched | Display |
| --- | --- | --- |
| Folder | `name` | Folder icon + breadcrumb path (parent chain) |
| Deck | `name`, parent folder name (for context match) | Deck icon + folder breadcrumb |
| Flashcard | `front`, `back`, `note`, `pronunciation`, `example`, `hint` | Truncated front, deck name |
| Tag | tag name (across `flashcard_tags`) | Tag chip + usage count |

Fields like `tags` (on a card) are NOT directly searched as field values; tags appear as their own result type.

## Result presentation

Results grouped by type with section headers. Each section shows top N (e.g., 5) by relevance, with "Show all" link.

```text
SECTION: Folders (3 matches)
  📁 Korean → top-level
  📁 Korean / Grammar

SECTION: Decks (8 matches)
  📚 Korean N5 — in Korean
  📚 Korean N4 — in Korean

SECTION: Flashcards (42 matches)
  안녕하세요 — in Korean N5
  감사합니다 — in Korean N5
  [Show all]

SECTION: Tags (2 matches)
  #grammar (38 cards)
  #weak (12 cards)
```

Empty state when no match: "No results for '{query}'."

## Result actions

| Tap on | Behavior |
| --- | --- |
| Folder result | Navigate to `/library/folder/:id` |
| Deck result | Navigate to `/library/deck/:deckId/flashcards` |
| Flashcard result | Navigate to deck's flashcard list, scrolled to card, edit ready |
| Tag result | Open flashcard list filtered to that tag globally (multi-deck) |

## Ranking

Simple ranking for now (no full-text index yet):

1. Exact name match (folder/deck) wins.
2. Name starts-with match wins over substring match.
3. Within flashcards: matches in `front` rank higher than matches in `back`, which rank higher than matches in `note`/`example`/`pronunciation`/`hint`.
4. Recently studied/edited cards break ties.

If ranking complexity grows, consider SQLite FTS5 — out of scope for current spec.

## Recursive vs flat

All search surfaces are **recursive by default**. There is no flat/recursive toggle.

- Library-level global search descends into all folders and all decks.
- Folder-detail search descends into all subfolders and decks under the current folder.
- Flashcard list search is naturally limited to that deck (no descendants exist below a deck).

Rationale: a flat folder search is confusing ("why doesn't search find my Korean/Grammar card from inside Korean?"). Recursive default matches user intuition. Result rows include breadcrumb so the user understands where each match lives.

## Performance

- Use Drift `LIKE` with leading wildcard for now (full table scan acceptable at personal-use scale, typically < 10k cards).
- Add compound indexes on `(LOWER(front))`, `(LOWER(back))` if scan exceeds 200ms typical.
- Stream results: emit folder/deck results first (fast), then flashcard results, then tag results, so UI populates progressively.
- Cap result rows per section at 200 hard limit to avoid memory blow-up; "Show all" pages via more queries.

## Account scope

Search runs against the **active account database** only (per `docs/business/account-sync/account-sync.md`). It does not span accounts or include the guest DB when signed in (or vice versa).

## Edge cases

| Case | Behavior |
| --- | --- |
| Query of 1 character | Below min length; show hint, no query |
| Query is pure whitespace | Treat as empty; show search-empty state |
| Query with special chars (`%`, `_`) used in LIKE | Escape via `\` per Drift's `like` API; do not let user inject LIKE patterns |
| User changes query mid-search | Cancel in-flight query (debounce already covers this) |
| User opens search but doesn't type | Show recent searches (last 5) and tag shortcuts |
| Result tap on a deleted entity (race) | Show error toast "This item no longer exists." and refresh search |
| Suspended/buried cards | Included in flashcard results (badge indicates state) |

## Rules

- Search MUST debounce 300ms before firing query.
- Minimum 2 characters before query fires.
- Search is case- and diacritic-insensitive.
- Multi-token AND semantics.
- Results grouped by type, capped per section, "Show all" for deep dive.
- Tap on a result deep-links to the right screen with context.
- Recent searches stored in SharedPreferences (not Drift); cap at 5 entries.
- Search MUST NOT mutate any data.

## Required UI states

- Empty input → recent searches + tag shortcuts.
- Loading (query in flight) → skeleton in each section.
- No results → friendly empty state.
- Results → grouped sections.
- Error (rare) → shared error state.

## Agent rule

- Do NOT use FTS without explicit decision (current scale doesn't need it).
- Do NOT search across multiple account databases.
- Special chars in user query MUST be escaped before LIKE.
- Result actions MUST use route constants (no hardcoded paths).
- "Show all" expansion MUST paginate; do not load 10k results at once.

## Related

**Wireframes:**
- `docs/wireframes/11-library-search.md` — full search screen (initial / typing / results / no results) with grouped results: folders, decks, flashcards, tags

**Schema:**
- `docs/database/schema-contract.md` → searches against `folders.name`, `decks.name`, `flashcards.front/back`, `flashcard_tags.tag`
- Recent searches: SharedPreferences (NOT in database) — see `docs/database/storage-boundaries.md`

**Decision table:**
- `docs/decision-tables/memox-core-decision-table.md` rows SR1-SR10 (recursive default SR9, breadcrumb display SR10)

**Glossary terms:**
- `docs/business/glossary.md` → "global search", "recursive search"

**Related business specs:**
- `docs/business/folder/folder-management.md` — folder result rows
- `docs/business/deck/deck-management.md` — deck result rows
- `docs/business/flashcard/flashcard-management.md` — flashcard result rows
- `docs/business/tags/tag-system.md` — tag result rows
- `docs/business/navigation/navigation-flow.md` — `/library/search` route

**Source files to inspect:**
- `lib/domain/usecases/search/global_search_usecase.dart`
- `lib/data/repositories/search_repository.dart`
- `lib/presentation/features/search/**`
