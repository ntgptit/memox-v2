---
last_updated: 2026-06-02
status: contract
---

# Deck Use Cases Contract

> **Current implementation note (Prompt 42, 2026-06-02):** nullable
> `parentFolderId` / root-deck signatures in this contract are target shape only.
> Current production use cases require concrete folder ids and the Drift
> `decks.folder_id` column is non-null. Root-level deck create/move/reorder must
> wait for a dedicated nullable-`folder_id` schema/API migration batch.
>
> **Prompt 42B design note (2026-06-02):** nullable parent migration design is
> ready in `docs/database/migrations/nullable-deck-parent-migration.md`, but no
> production/schema/generated/test implementation was made in Prompt 42B.

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

## CreateDeckUseCase

```dart
Future<Either<Failure, Deck>> call({
  required String name,
  required TargetLanguage targetLanguage,
  required FolderId? parentFolderId,  // null = root
});
```

**Preconditions:**

- Parent folder (if any) exists.
- Parent `content_mode` ∈ (`unlocked`, `decks`).
- Root parent (`parentFolderId == null`) skips folder existence and folder mode
  updates; root is treated as an implicit unlocked container after migration.

**Rules:**

- Trim name. Reject empty.
- Reject duplicate within same parent (case-insensitive).
- Atomic insert + parent mode update. See `docs/contracts/repository-contracts/deck-repository.md`.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure` (parent locked to subfolders), `ValidationFailure`, `StorageFailure`.

**Test refs:** D1-D3.

## UpdateDeckUseCase

```dart
Future<Either<Failure, Deck>> call({
  required DeckId id,
  String? newName,
  TargetLanguage? newTargetLanguage,
});
```

**Rules:**

- At least one of `newName`/`newTargetLanguage` provided; else `ValidationFailure`.
- Trim name. Reject empty.
- Reject duplicate name in same parent.

**Errors:** `NotFoundFailure`, `ValidationFailure`, `StorageFailure`.

**Test refs:** D4-D5.

## MoveDeckUseCase

```dart
Future<Either<Failure, Deck>> call({
  required DeckId id,
  required FolderId? newParentId,  // null = root
});
```

**Preconditions:**

- New parent's `content_mode` ∈ (`unlocked`, `decks`).

**Rules:**

- Atomic deck-parent + both folder modes; recompute `sort_order`. See `docs/contracts/repository-contracts/deck-repository.md`.
- Moving from root to folder updates only the new folder mode; moving from
  folder to root updates only the old folder mode.

**Errors:** `NotFoundFailure`, `UnsupportedActionFailure`, `StorageFailure`.

**Test refs:** D6.

## DeleteDeckUseCase

```dart
Future<Either<Failure, Unit>> call({required DeckId id});
```

**Rules:**

- Atomic cascade across progress, tags, attempts, flashcards, sessions, deck row + old parent mode update. Full cascade list in `docs/contracts/repository-contracts/deck-repository.md`.

**Errors:** `NotFoundFailure`, `StorageFailure`.

**Caution:** Highly destructive. Caller MUST confirm via §delete-confirm dialog.

**Test refs:** D7.

## ReorderDecksUseCase

```dart
Future<Either<Failure, Unit>> call({required FolderId? parentId, required List<DeckId> orderedIds});
```

Same shape as ReorderFoldersUseCase.

**Test refs:** D8.

## GetDeckDetailUseCase

```dart
Future<Either<Failure, DeckDetail>> call({required DeckId id});
```

`DeckDetail` = deck + folder path + card count + due count.

## WatchDeckCountsUseCase

```dart
Stream<Either<Failure, DeckCounts>> call({required DeckId id});
```

`DeckCounts` = `{ totalCards, dueNow, suspendedCount, buriedTodayCount }`.

Used by deck-level study CTA enable/disable and Today CTA subtitle.

## Forbidden patterns

- ❌ Change `target_language` without consideration of TTS impact (UI must reflect on next study session).
- ❌ Delete deck without cascading session deletion.
- ❌ Allow create in `subfolders`-mode parent.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business spec:** `docs/business/deck/deck-management.md`
**Repository:** `docs/contracts/repository-contracts/deck-repository.md`
**Migration design:** `docs/database/migrations/nullable-deck-parent-migration.md`
**Wireframes:** `docs/wireframes/02-library.md`, `docs/wireframes/05-folder-detail.md`, `docs/wireframes/06-flashcard-list.md`
**TTS gate:** `docs/business/tts/tts-settings.md`
**Decision table:** rows D1-D8
**Code paths:** `lib/domain/usecases/deck/**`
