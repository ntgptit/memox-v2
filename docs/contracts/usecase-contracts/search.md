---
last_updated: 2026-05-29
status: V1 inline search guidance; GlobalSearchUseCase is Future Proposal
---

# Search Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

V1 uses inline/scope-local search. The dedicated recursive global search use cases below are **Future Proposal** and must not be implemented in V1 unless promoted by `docs/checklist/v1-implementation-scope-2026-05-29.md`.

## V1 inline search

V1 search improvements should reuse existing screen-level providers/widgets and keep search inside the current screen scope. Do not add recent-search persistence or a dedicated global route.

## Future Proposal: GlobalSearchUseCase

```dart
Future<Either<Failure, SearchResults>> call({
  required String query,
  DeckId? deckScope,  // optional pre-filter for in-deck search
});
```

**Rules:**

- Trim query. Reject if length < 2 → `ValidationFailure(code: tooShort)`.
- Escape special LIKE chars (`%`, `_`) before passing to DB.
- Run 4 parallel queries (folders, decks, flashcards, tags), each section LIKE-based.
- Apply `deckScope` filter to flashcards section when provided.
- Sort within each section: exact match → starts-with → substring → recency tiebreak.
- Cap each section at 5 visible (`SearchResults` includes total counts for "Show all" link).

**Returns:** `SearchResults { folders, decks, flashcards, tags, queryDuration }`.

**Errors:** `ValidationFailure`, `StorageFailure`.

**Test refs:** SR1-SR10.

## Future Proposal: GetRecentSearchesUseCase

```dart
Future<List<String>> call();
```

Read SharedPreferences `search.recent` (capped 5).

## Future Proposal: SaveRecentSearchUseCase

```dart
Future<void> call(String query);
```

**Rules:**

- Trim. Skip if < 2 chars.
- Insert at top. Dedup case-insensitive. Trim list to 5.
- Persist to SharedPreferences.

## Future Proposal: RemoveRecentSearchUseCase

```dart
Future<void> call(String query);
```

## Future Proposal: GetPopularTagsUseCase

```dart
Future<Either<Failure, List<TagWithCount>>> call({int limit = 5});
```

Top tags by usage. Cached in screen state.

## V1 forbidden patterns

- ❌ Do not implement `GlobalSearchUseCase` in V1.
- ❌ Do not add `/library/search` in V1.
- ❌ Do not persist `search.recent` in V1.
- ❌ Do not add grouped cross-scope result UI in V1.

## Forbidden patterns

- ❌ Add flat/recursive toggle. Search is always recursive.
- ❌ Pass raw user query to LIKE without escaping.
- ❌ Cache search results across queries.
- ❌ Implement FTS (full-text search) without explicit ADR — keep LIKE for Phase 1.
- ❌ Fire query at < 2 chars.
- ❌ Store > 5 recent searches.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business spec:** `docs/business/search/global-search.md`
**Repository:** `docs/contracts/repository-contracts/folder-repository.md`, `docs/contracts/repository-contracts/deck-repository.md`, `docs/contracts/repository-contracts/flashcard-repository.md`, `docs/contracts/repository-contracts/tag-repository.md`
**Wireframes:** `docs/wireframes/11-library-search.md`
**Decision table:** SR1-SR10
**Code paths:** `lib/domain/usecases/search/**`
