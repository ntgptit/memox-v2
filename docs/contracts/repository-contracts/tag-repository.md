---
last_updated: 2026-05-26
status: contract
---

# Tag Repository Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

`flashcard_tags` operations. Tag storage = lowercased trimmed string keyed by `(flashcard_id, LOWER(tag))`.

## Methods

```dart
Stream<List<TagWithCount>> watchAllWithCount();
Stream<List<TagName>> watchTagsForDeck(DeckId deckId);
Stream<List<TagName>> watchTagsForCard(FlashcardId cardId);
Future<Either<Failure, List<TagWithCount>>> popularTags({int limit});
Future<Either<Failure, bool>> existsCaseInsensitive(String name);

Future<Either<Failure, Unit>> addToCard(FlashcardId cardId, String tag);
Future<Either<Failure, Unit>> removeFromCard(FlashcardId cardId, String tag);
Future<Either<Failure, Unit>> rename(String oldName, String newName);
Future<Either<Failure, MergeResult>> merge(String source, String destination);
Future<Either<Failure, int>> delete(String name);  // returns affected card count
```

## Transaction requirements

| Operation | Tables touched |
| --- | --- |
| `addToCard` | `flashcard_tags` INSERT (idempotent dedupe by LOWER) |
| `removeFromCard` | `flashcard_tags` DELETE |
| `rename` | `flashcard_tags` UPDATE batch |
| `merge` | `flashcard_tags`: INSERT dest if missing per card + DELETE source rows. Atomic. |
| `delete` | `flashcard_tags` DELETE WHERE LOWER(tag) = LOWER(:tag) |

## Constraints

- Tag stored lowercased.
- Validation (no comma, max 50) MUST happen in domain layer (TagValidator). Repo assumes pre-validated input.
- `(flashcard_id, LOWER(tag))` pair uniqueness via DB index.

## Forbidden

- ❌ Persist with original casing.
- ❌ Bypass `existsCaseInsensitive` check before rename.
- ❌ Auto-merge on rename collision (caller decides).
- ❌ Delete cards when deleting a tag.

## Test contract

- Add tag idempotent.
- Rename → no collision: update all rows.
- Rename → collision detected: caller-driven merge.
- Merge → dedupe per card.
- Delete → cards unaffected, only tag rows gone.
- Watch + count correctness.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`

**Business spec:** `docs/business/tags/tag-system.md`
**Use cases:** `docs/contracts/usecase-contracts/tag.md`
**Schema:** `docs/database/schema-contract.md` `flashcard_tags`
**Code paths:**

- `lib/domain/repositories/tag_repository.dart`
- `lib/data/repositories/tag_repository_impl.dart`
- `lib/data/datasources/local/daos/flashcard_tag_dao.dart`
