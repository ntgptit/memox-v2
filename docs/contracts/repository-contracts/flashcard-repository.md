---
last_updated: 2026-05-26
status: contract
---

# Flashcard Repository Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Handles flashcards + their `flashcard_progress` rows (1:1) + `flashcard_tags` (1:N).

## Methods

```dart
// Queries
Stream<List<FlashcardWithState>> watchByDeck(DeckId deckId, {
  CardStatusFilter status = CardStatusFilter.all,
  List<TagName> tags = const [],
});
Stream<FlashcardDetail?> watchDetail(FlashcardId id);
Future<Either<Failure, Flashcard>> findById(FlashcardId id);
Future<Either<Failure, int>> countByDeck(DeckId deckId);
Future<Either<Failure, int>> countDueByDeck(DeckId deckId);
Future<Either<Failure, int>> countDueGlobal();
Future<Either<Failure, List<Flashcard>>> findByIds(List<FlashcardId> ids);
Future<Either<Failure, List<Flashcard>>> findInScope(StudyScope scope);
Future<Either<Failure, List<Flashcard>>> existingByFrontBackPairs(
  DeckId deckId,
  List<({String front, String back})> pairs,
);

// Mutations
Future<Either<Failure, Flashcard>> create(FlashcardCreationData data);
Future<Either<Failure, Flashcard>> update(FlashcardId id, FlashcardUpdateData data);
Future<Either<Failure, Flashcard>> move(FlashcardId id, DeckId newDeckId);
Future<Either<Failure, Unit>> delete(FlashcardId id);
Future<Either<Failure, int>> deleteMany(List<FlashcardId> ids);
Future<Either<Failure, int>> moveMany(List<FlashcardId> ids, DeckId targetDeckId);
Future<Either<Failure, int>> bulkAddTags(List<FlashcardId> ids, List<String> tags);
Future<Either<Failure, int>> bulkRemoveTags(List<FlashcardId> ids, List<String> tags);
Future<Either<Failure, int>> bulkSuspend(List<FlashcardId> ids);
Future<Either<Failure, int>> bulkUnsuspend(List<FlashcardId> ids);
Future<Either<Failure, int>> bulkResetProgress(List<FlashcardId> ids);
Future<Either<Failure, ImportCommitResult>> importChunked(
  DeckId deckId, 
  List<FlashcardCreationData> items,
);
```

## Transaction requirements

| Operation | Single transaction across |
| --- | --- |
| `create` | `flashcards` INSERT + `flashcard_progress` initial row + `flashcard_tags` INSERTs |
| `update` (with tags) | `flashcards` UPDATE + replace `flashcard_tags` rows |
| `move` | `flashcards.deck_id` UPDATE + `sort_order` recompute |
| `delete` | `study_attempts`, `flashcard_tags`, `flashcard_progress`, `flashcards` |
| `bulk*` | Single transaction for ALL ids in batch |
| `importChunked` | Each chunk = own transaction (SQLite param limit ~500). Caller treats overall result as committed/aborted as whole. |

## CardState computation

When returning `FlashcardWithState`, compute priority: Suspended > Buried > Due > Active. Logic in `CardStateComputer` (shared, NOT duplicated per repo method).

## Constraints

- `front` and `back` non-empty after trim.
- Tags via `flashcard_tags` rows, lowercased, max 50 chars.
- Initial progress row MUST be created with `current_box=1`, `due_at=now`.

## Forbidden

- ❌ Skip initial `flashcard_progress` row on create.
- ❌ Update `current_box` from this repo (only `docs/contracts/repository-contracts/progress-repository.md` does that).
- ❌ Return Drift row.
- ❌ Apply tag normalization without going through `TagValidator`.
- ❌ Bulk operation outside transaction.
- ❌ Per-row loop in `deleteMany` / `moveMany` (use batch operation).

## Test contract

- Create flashcard with tags → verify progress + tags rows created.
- Update flashcard tags → verify replace semantics.
- Move flashcard → verify progress + tags preserved.
- Bulk operations → verify atomicity (rollback on one failure).
- Import chunked → verify chunked transactions, verify duplicate detection.
- Filter by status + tags → verify SQL correctness.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`

**Business spec:** `docs/business/flashcard/flashcard-management.md`
**Use cases:** `docs/contracts/usecase-contracts/flashcard.md`, `docs/contracts/usecase-contracts/bulk.md`
**Schema:** `docs/database/schema-contract.md` `flashcards`, `flashcard_progress`, `flashcard_tags`
**Code paths:**

- `lib/domain/repositories/flashcard_repository.dart`
- `lib/data/repositories/flashcard_repository_impl.dart`
- `lib/data/datasources/local/daos/flashcard_dao.dart`
- `lib/data/datasources/local/daos/flashcard_progress_dao.dart`
- `lib/data/datasources/local/daos/flashcard_tag_dao.dart`
- `lib/domain/flashcard/card_state_computer.dart`
