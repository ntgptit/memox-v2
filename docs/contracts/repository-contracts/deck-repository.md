---
last_updated: 2026-06-02
status: contract
---

# Deck Repository Contract

> **Current implementation note (Prompt 42, 2026-06-02):** the signatures below
> are target contracts for nullable parent/root deck support. Current production
> code still requires a non-null folder id (`decks.folder_id` is non-null,
> `DeckEntity.folderId` is `String`, and `createDeck`/`moveDeck`/`reorderDecks`
> require concrete folder ids). Do not implement root-level deck UI against this
> contract until a dedicated schema/API migration updates code, generated Drift
> output, docs, and tests together.
>
> **Prompt 42B design note (2026-06-02):** implementation guidance for that
> migration now lives in
> `docs/database/migrations/nullable-deck-parent-migration.md`. Prompt 42B did
> not change production code, schema, generated files, or tests.

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

`abstract class DeckRepository`. Implementation in `lib/data/repositories/deck_repository_impl.dart`.

## Methods

```dart
Stream<List<Deck>> watchByFolder(FolderId? folderId);  // null = root decks
Stream<DeckDetail?> watchDeckDetail(DeckId id);
Stream<DeckCounts> watchDeckCounts(DeckId id);
Future<Either<Failure, Deck>> findById(DeckId id);
Future<Either<Failure, List<Deck>>> recentlyUpdated({int limit});
Future<Either<Failure, List<Deck>>> allInScope(FolderId? folderId, {bool recursive = false});

Future<Either<Failure, Deck>> create({
  required String name,
  required TargetLanguage targetLanguage,
  required FolderId? parentId,
});
Future<Either<Failure, Deck>> update(DeckId id, {String? name, TargetLanguage? targetLanguage});
Future<Either<Failure, Deck>> move(DeckId id, FolderId? newParentId);
Future<Either<Failure, Unit>> delete(DeckId id);
Future<Either<Failure, Unit>> reorder(FolderId? parentId, List<DeckId> orderedIds);
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
- Target: `folder_id` nullable (root deck) or references existing folder allowing decks.
- Current: `folder_id` is non-null; root-level decks are blocked pending migration.
- Root sibling uniqueness must not rely only on a plain `(folder_id, name)`
  unique constraint because SQLite treats `NULL` values as distinct. Use
  root-safe repository validation and/or partial unique indexes in the migration.

## Forbidden

- ❌ Return Drift row.
- ❌ Allow deck creation in `subfolders`-mode parent.
- ❌ Delete deck without cascading session deletion.

## Test contract

- Create root deck, deck in folder.
- Update name and target_language independently.
- Move deck + verify old/new parent mode.
- Delete cascade (verify no orphan attempts).
- Sibling uniqueness rejection.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`

**Business spec:** `docs/business/deck/deck-management.md`
**Use cases:** `docs/contracts/usecase-contracts/deck.md`
**Schema:** `docs/database/schema-contract.md` `decks` table
**Migration design:** `docs/database/migrations/nullable-deck-parent-migration.md`
**Code paths:** `lib/domain/repositories/deck_repository.dart`, `lib/data/repositories/deck_repository_impl.dart`, `lib/data/datasources/local/daos/deck_dao.dart`
