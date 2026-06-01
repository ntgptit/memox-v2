---
last_updated: 2026-05-26
applies_to: flashcard tags — creation, filtering, study-by-tag, management
---

# Tag System

## Purpose

Today tags exist on `flashcard_tags` table but only serve as visual labels. This doc upgrades tags to first-class organizational primitives that complement folders/decks without replacing them.

Use cases:

- Tag cards as `#weak` while studying; later study only `#weak` cards.
- Filter flashcard list by `#chapter-3` to revise specific content.
- Bulk operations on tagged cards (delete, move, suspend).

## Data model

Existing tables (see `docs/business/flashcard/flashcard-management.md`):

- `flashcard_tags` (flashcard_id, tag).

No schema change required. Tag is already a TEXT row keyed by flashcard.

Normalization (existing):

- Tag is trimmed.
- Tag is non-empty after trim (validation).
- Tags are deduplicated case-insensitively per flashcard.
- Tag MUST NOT contain a comma (`,`). Commas are reserved as the separator inside `entry_ref_id` when `entry_type=tag` (see "Study by tag" below).
- Tag max length: 50 chars after trim.

This doc adds rules and surfaces, not new tables.

## Tag identity

- Tag identity is case-insensitive across the app (`#Verb` and `#verb` are the same tag).
- Storage and display form (V1): tags are stored **lowercased**. The `flashcard_tags` table has only a `tag` column (no separate display-name column), so V1 does not preserve original casing — input is lowercased on write (validator + DAO) and rendered lowercased. Schema v11 backfills existing rows to lowercase (see `docs/database/migration-contract.md`).
- Cross-deck tags: tags are global by name. `#weak` in deck A and `#weak` in deck B refer to the same tag conceptually for filter/study purposes.

## Tag filter in flashcard list

Flashcard list (`/library/deck/:deckId/flashcards`) supports tag filtering:

| Filter UI | Behavior |
| --- | --- |
| Tag chip row above list | Shows tags present in current deck, sorted by usage count desc |
| Multi-select | User taps multiple chips to filter |
| Logic | Multi-select uses AND (cards must have ALL selected tags) |
| Clear | "Clear filters" button when any chip is active |
| Empty result | Show empty state "No cards match selected tags" with Clear CTA |

Combination with other filters (see `docs/business/study-actions/bury-suspend.md`):

- Tag filter AND status filter (Active / Suspended / Buried / Due) are independent.
- Both compose: e.g., "Active + #weak" shows non-suspended cards tagged `#weak`.

## Study by tag

**Status:** Blocked / Future for Current V1. The rules below define the target contract, but the current app must not expose tag-scoped study until `StudyEntryType.tag`, tag-scope resolution, and tests are implemented.

A new tag-scoped study entry exists alongside deck/folder/today entries.

### Entry shape

| Entry type | Meaning | `entry_ref_id` format |
| --- | --- | --- |
| `tag` | Study cards across all decks matching one or more tag names | Comma-joined list of tag names, lowercased. Example: `"weak,grammar"`. Order does not matter for resolution but should be sorted alphabetically for cache stability. |

Format rules:

- Tag names are lowercased in `entry_ref_id`.
- Separator is a single comma, no whitespace around it.
- Tag names CANNOT contain commas (enforced by tag validation, see above).
- Empty list is invalid (no session is created).
- Max number of tags per study-by-tag session: 10 (UI hint; server-side this is enforced when constructing the session).

### Resolution

```sql
SELECT f.* FROM flashcards f
INNER JOIN flashcard_tags ft ON ft.flashcard_id = f.id
WHERE LOWER(ft.tag) IN (<lowercased selected tags>)
  AND <existing active/buried/suspended filters>
GROUP BY f.id
HAVING COUNT(DISTINCT LOWER(ft.tag)) = <number of selected tags>;
```

The HAVING clause enforces AND semantics across multiple tags.

### Where to trigger

| Surface | Trigger |
| --- | --- |
| Flashcard list with tag filter active | "Study filtered cards" CTA below list |
| Tag management screen | "Study cards with this tag" action on each tag row |
| Dashboard | Optional shortcut for frequently-used tags (deferred) |

### Study type allowed

- `new` flows: allowed.
- `srs_review`: allowed when at least one matching card is due.
- Same empty-scope rules apply (see `docs/business/study/study-flow.md` empty scope matrix).

## Tag management screen

Settings → Learning → "Manage tags" (new sub-screen, or inline within Learning Settings depending on layout).

Route: `/settings/learning/tags`. Learning Settings owns only the navigation entry; Tag Management owns tag list/search/sort plus rename/merge/delete actions.

### Functionality

| Action | Behavior |
| --- | --- |
| List all tags | Shows every distinct tag across all decks, with usage count (number of cards using it) |
| Search | Filter visible tags by typed substring |
| Rename | Inline edit; updates all `flashcard_tags` rows in a transaction |
| Merge | Select 2+ tags → "Merge into..." → pick target; all cards re-tagged to target, source tags removed |
| Delete | Removes the tag from all cards. Confirmation required. |
| Study | Blocked/Future: requires `StudyEntryType.tag`; not exposed in Current V1 |
| View cards | Future: belongs to global tag-filtered list / Global Search ownership; not exposed in Current V1 |

### Rename rules

- New name must pass tag validation (non-empty after trim).
- New name conflicting with existing tag (case-insensitive) → behaves as merge: confirm before proceeding.
- Rename is a transaction: all rows updated atomically.

### Merge rules

- Cannot merge a tag into itself.
- After merge, all cards previously tagged with any source tag are now tagged with the target tag.
- Duplicate tag rows (same card had both source and target) are de-duped during merge.

### Delete rules

- Confirmation: "Delete tag '#{name}'? This removes the tag from {n} cards. Cards are not deleted."
- Transaction-wrapped.

## Bulk tag operations on cards

From flashcard list multi-select (see `docs/business/bulk/bulk-operations.md`):

| Action | Behavior |
| --- | --- |
| Add tag(s) to selected | User types or picks existing tags; appended to each selected card (deduped) |
| Remove tag(s) from selected | User picks from tags present on selection; removed from each |
| Replace tags on selected | User picks final tag set; replaces each card's tag set (use with caution; confirm) |

All bulk operations are transactional.

## Rules

- Tag identity is case-insensitive for matching. Current V1 stores and renders lowercased tags because `flashcard_tags` has no separate display-name column.
- Tags are global by name (cross-deck). There are no scoped/namespaced tags.
- A tag with zero cards no longer exists (rows in `flashcard_tags` are the only source of tag list; no separate tag entity table).
- Tag input must trim, validate non-empty, dedupe case-insensitively within the same card.
- Tag filter in flashcard list uses AND across multi-select.
- Study-by-tag is a new `entry_type=tag` that joins all decks.
- Renaming / merging / deleting tags are transactional. Failure must not leave inconsistent state.

## Edge cases

| Case | Behavior |
| --- | --- |
| User filters by tag in deck A, tag exists in other decks | Filter scoped to current deck. Tag count chip reflects only this deck's usage. |
| Study-by-tag with tags spanning decks of different content types | All matching cards combined. Folder hierarchy ignored. |
| Tag rename collides with existing tag (case-insensitive) | Prompt: "This will merge with existing tag '#{existing}'. Continue?" |
| Tag deleted while cards are in active session | Session continues with cards in-memory; tag removal doesn't affect ongoing session. |
| Bulk add tag to 1000 cards | Single transaction; OK for current scale. Profile if slower than ~2s. |
| Tag with very long name (e.g., 200 chars) | Validate max length (suggest 50). Reject longer. |
| User enters tag with leading `#` (e.g., `#weak`) | Strip leading `#` before storing. Display can re-add `#` cosmetically. |

## UI display

- Tag chip in flashcard card: small rounded label, theme color.
- Long tag truncated with ellipsis after ~16 chars; tap to view full.
- Tag count overflow: if a card has > 5 tags, show 4 + "+{n}" overflow chip.

## Required UI states

- Tag filter row: hidden when deck has zero tags; visible otherwise.
- Empty filter result: shared empty state.
- Tag management: loading, empty (no tags), local-search no-results, error, normal.
- Rename/merge/delete: confirmation dialogs.

## Performance

- Tag list per deck: stream from `flashcard_tags` with COUNT GROUP BY.
- Global tag list (management screen): stream same query without deck filter.
- Tag filter query: add compound index on `flashcard_tags(tag, flashcard_id)` if not present.
- Study-by-tag resolution: single SQL query, return flashcard IDs. Future/Blocked until the tag study entry type is promoted.

## Agent rule

- Do NOT create a separate `tags` table. Tag entity is implicit in `flashcard_tags` rows.
- Do NOT make tags case-sensitive for matching; only display preserves case.
- Do NOT scope tags per-deck. Tags are global by name.
- Multi-select tag filter MUST use AND, not OR. Document intentionally chooses AND for precision.
- Study-by-tag is `entry_type=tag`. Do not piggyback on `entry_type=deck` with a tag param.
- Tag rename collision MUST prompt user (do not silently merge).
- Tag input MUST reject commas at validation time. Show inline error: "Tags cannot contain commas." Do not strip silently — user might be trying something the app cannot represent.
- Tag max length 50 chars after trim. Reject longer at validation time.

## Related

**Wireframes:**

- `docs/wireframes/07-flashcard-create.md` — tag input with comma rejection
- `docs/wireframes/08-flashcard-edit.md` — tag list edit
- `docs/wireframes/22-settings-tag-management.md` — global tag management (rename / merge / delete)
- `docs/wireframes/25-shared-bottom-sheets.md` §tag-picker (multi-select, AND filter, create-new)

**Schema:**

- `docs/database/schema-contract.md` → `flashcard_tags` (`flashcard_id`, `tag`)
- Recommended index: `flashcard_tags(LOWER(tag), flashcard_id)` for case-insensitive lookup
- Reserved use in `study_sessions.entry_ref_id` when `entry_type=tag`: sorted, lowercased, comma-joined tag names

**Decision table:**

- `docs/decision-tables/memox-core-decision-table.md` rows TG1-TG11 (incl. TG9 comma rejection, TG10 max 50, TG11 entry_ref_id construction)

**Glossary terms:**

- `docs/business/glossary.md` → `tag`, "case-insensitive uniqueness", "study by tag", `entry_ref_id`

**Related business specs:**

- `docs/business/flashcard/flashcard-management.md` — tag input on create/edit
- `docs/business/study/study-flow.md` — `entry_type=tag` study entry
- `docs/business/bulk/bulk-operations.md` — bulk add/remove tag
- `docs/business/search/global-search.md` — tag is one of the 4 result types
- `docs/business/navigation/navigation-flow.md` — `/library/study/tag/<tags>` route + `/settings/learning/tags` route

**Source files to inspect:**

- `lib/data/datasources/local/tables/flashcard_tags_table.dart`
- `lib/domain/usecases/tag_usecases.dart` (watch/add/remove/rename/merge/delete)
- `lib/presentation/features/settings/screens/tag_management_screen.dart`
- `lib/presentation/features/settings/providers/tag_management_notifier.dart`
