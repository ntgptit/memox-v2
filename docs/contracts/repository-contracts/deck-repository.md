---
last_updated: 2026-06-02
status: contract
---

# Deck Repository Contract

> **Current implementation note (Prompt 43A, 2026-06-03):** root-level decks and
> nullable deck parents are Rejected / Out of Scope. Current production requires
> a non-null folder id (`decks.folder_id` is non-null, `DeckEntity.folderId` is
> `String`, and `createDeck`/`moveDeck`/`reorderDecks` require concrete folder
> ids). Keep this folder-owned deck invariant.
>
> **Prompt 42B design note (2026-06-02):**
> `docs/database/migrations/nullable-deck-parent-migration.md` is retained only
> as a rejected historical design note. Do not use it as implementation
> guidance.

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

`abstract class DeckRepository`. Implementation in `lib/data/repositories/deck_repository_impl.dart`.

## Methods

```dart
Stream<List<Deck>> watchByFolder(FolderId folderId);
Stream<DeckDetail?> watchDeckDetail(DeckId id);
Stream<DeckCounts> watchDeckCounts(DeckId id);
Future<Either<Failure, Deck>> findById(DeckId id);
Future<Either<Failure, List<Deck>>> recentlyUpdated({int limit});
Future<Either<Failure, List<Deck>>> allInScope(FolderId folderId, {bool recursive = false});

Future<Either<Failure, Deck>> create({
  required String name,
  required TargetLanguage targetLanguage,
  required FolderId parentId,
});
Future<Either<Failure, Deck>> update(DeckId id, {String? name, TargetLanguage? targetLanguage});
Future<Either<Failure, Deck>> move(DeckId id, FolderId newParentId);
Future<Either<Failure, Unit>> delete(DeckId id);
Future<Either<Failure, Unit>> reorder(FolderId parentId, List<DeckId> orderedIds);
```

## Transaction requirements

| Operation | Tables touched |
| --- | --- |
| `create` | `decks` INSERT + parent folder `content_mode` UPDATE if unlocked |
| `move` | `decks` UPDATE + both old/new parent folder mode |
| `delete` | cascade: `flashcard_progress`, `flashcard_tags`, `study_attempts`, `flashcards`, `study_session_items` for sessions targeting this deck, `study_sessions` with entry_type=deck and entry_ref_id=id, `decks` |

## Constraints

- Sibling name unique (case-insensitive) within same `folder_id`.
- `target_language` ∈ TargetLanguage enum.
- `folder_id` is non-null and references an existing folder allowing decks.
- Root-level decks are Rejected / Out of Scope.
- Nullable deck parent migration is Not Applicable while the folder-owned deck
  invariant holds.

## Forbidden

- ❌ Return Drift row.
- ❌ Allow deck creation in `subfolders`-mode parent.
- ❌ Delete deck without cascading session deletion.

## Test contract

- Create deck in folder.
- Update name and target_language independently.
- Move deck + verify old/new parent mode.
- Delete cascade (verify no orphan attempts).
- Sibling uniqueness rejection.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`

**Business spec:** `docs/business/deck/deck-management.md`
**Use cases:** `docs/contracts/usecase-contracts/deck.md`
**Schema:** `docs/database/schema-contract.md` `decks` table
**Rejected migration design:** `docs/database/migrations/nullable-deck-parent-migration.md`
**Code paths:** `lib/domain/repositories/deck_repository.dart`, `lib/data/repositories/deck_repository_impl.dart`, `lib/data/datasources/local/daos/deck_dao.dart`
