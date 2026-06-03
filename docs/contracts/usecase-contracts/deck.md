---
last_updated: 2026-06-02
status: contract
---

# Deck Use Cases Contract

> **Current implementation note (Prompt 43A, 2026-06-03):** nullable
> `parentFolderId` / root-deck signatures are Rejected / Out of Scope. Current
> production use cases require concrete folder ids and the Drift
> `decks.folder_id` column is non-null. Keep every deck folder-owned.
>
> **Prompt 42B design note (2026-06-02):**
> `docs/database/migrations/nullable-deck-parent-migration.md` is retained only
> as a rejected historical design note. Do not implement it.

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

## CreateDeckUseCase

```dart
Future<Either<Failure, Deck>> call({
  required String name,
  required TargetLanguage targetLanguage,
  required FolderId parentFolderId,
});
```

**Preconditions:**

- Parent folder exists.
- Parent `content_mode` ∈ (`unlocked`, `decks`).

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
  required FolderId newParentId,
});
```

**Preconditions:**

- New parent's `content_mode` ∈ (`unlocked`, `decks`).

**Rules:**

- Atomic deck-parent + both folder modes; recompute `sort_order`. See `docs/contracts/repository-contracts/deck-repository.md`.

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
Future<Either<Failure, Unit>> call({required FolderId parentId, required List<DeckId> orderedIds});
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
**Rejected migration design:** `docs/database/migrations/nullable-deck-parent-migration.md`
**Wireframes:** `docs/wireframes/02-library.md`, `docs/wireframes/05-folder-detail.md`, `docs/wireframes/06-flashcard-list.md`
**TTS gate:** `docs/business/tts/tts-settings.md`
**Decision table:** rows D1-D8
**Code paths:** `lib/domain/usecases/deck/**`
