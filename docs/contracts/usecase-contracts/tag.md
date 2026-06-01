---
last_updated: 2026-05-26
status: contract
---

# Tag Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

Tags are global (cross-deck), case-insensitive by name, with strict input validation (no comma, max 50 chars).

## TagValidator (pure)

```dart
class TagValidator {
  Either<ValidationFailure, String> validate(String input);  // returns normalized form
}
```

**Rules:**

- Trim input.
- Reject empty → `ValidationFailure(field: 'tag', code: empty)`.
- Reject if contains comma `,` → `code: invalidCharacter`.
- Reject if `length > 50` after trim → `code: tooLong`.
- Return lowercased trimmed string on success.

**Source:** `lib/domain/tag/tag_validator.dart`.

## AddTagToCardUseCase

```dart
Future<Either<Failure, Unit>> call({required FlashcardId cardId, required String tag});
```

**Rules:**

- Validate via `TagValidator`.
- INSERT into `flashcard_tags` UNLESS already present (dedupe by `LOWER(tag)`).
- Atomic. See `docs/contracts/repository-contracts/tag-repository.md`.

**Errors:** `ValidationFailure`, `NotFoundFailure`, `StorageFailure`.

## RemoveTagFromCardUseCase

```dart
Future<Either<Failure, Unit>> call({required FlashcardId cardId, required String tag});
```

**Rules:**

- DELETE matching row by `LOWER(tag)`.
- Idempotent (no error if not present).

**Errors:** `NotFoundFailure` (card), `StorageFailure`.

## RenameTagUseCase

```dart
Future<Either<Failure, Unit>> call({required String oldName, required String newName});
```

**Rules:**

- Validate `newName` via `TagValidator`.
- If `LOWER(newName) == LOWER(oldName)` → no-op.
- If new name exists as another tag → return `ConflictFailure` so UI shows merge confirmation. Do NOT auto-merge.
- Atomic UPDATE: `UPDATE flashcard_tags SET tag = newName WHERE LOWER(tag) = LOWER(oldName)`. See `docs/contracts/repository-contracts/tag-repository.md`.

**Errors:** `ValidationFailure`, `ConflictFailure`, `StorageFailure`.

## MergeTagUseCase

```dart
Future<Either<Failure, MergeResult>> call({required String sourceName, required String destinationName});
```

**Rules:**

- Validate destinationName.
- Atomic: for each card tagged with source, ensure destination exists (insert if missing); DELETE source rows. Per-card dedup. See `docs/contracts/repository-contracts/tag-repository.md`.

**Errors:** `ValidationFailure`, `StorageFailure`.

**Test refs:** TG section.

## DeleteTagUseCase

```dart
Future<Either<Failure, int>> call({required String tag});  // returns affected card count
```

**Rules:**

- DELETE all `flashcard_tags WHERE LOWER(tag) = LOWER(:tag)`.
- Cards themselves NOT deleted.

**Caution:** Confirm via §delete-confirm.

**Errors:** `StorageFailure`.

**Test refs:** TG7.

## BuildStudyByTagRefIdUseCase

**Status:** Target / Blocked for Current V1. Do not expose tag-scoped study until `StudyEntryType.tag`, tag-scope resolution, and executable tests are implemented.

```dart
String call(List<String> selectedTags);
```

Pure function. Returns canonical `entry_ref_id` for `entry_type=tag`:

1. Validate each via `TagValidator`.
2. Lowercase each.
3. Sort alphabetically.
4. Join by `,`.

Example: `["Weak", "grammar"]` → `"grammar,weak"`.

**Errors:** throws `AssertionError` if any tag invalid (programmer error — caller should validate first).

**Test refs:** TG11.

**Source:** Target only; no Current V1 source file.

## WatchAllTagsWithCountUseCase

```dart
Stream<Either<Failure, List<TagWithCount>>> call();
```

Returns all tags + card counts, used by tag management screen.

## WatchTagsForDeckUseCase

```dart
Stream<Either<Failure, List<TagName>>> call({required DeckId deckId});
```

Returns distinct tags within a deck, used by flashcard list tag filter.

## Forbidden patterns

- ❌ Allow comma in tag name to pass through ANY layer. Reject at validator boundary.
- ❌ Persist tag with original casing. Always normalize to lowercase at storage.
- ❌ Auto-merge on rename collision. Surface `ConflictFailure` so user decides.
- ❌ Build `entry_ref_id` for tag scope outside `BuildStudyByTagRefIdUseCase`.
- ❌ DELETE the cards when deleting a tag.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business spec:** `docs/business/tags/tag-system.md`
**Repository:** `docs/contracts/repository-contracts/tag-repository.md`
**Wireframes:** `docs/wireframes/22-settings-tag-management.md`, `docs/wireframes/07-flashcard-create.md`, `docs/wireframes/25-shared-bottom-sheets.md` §tag-picker
**Decision table:** rows TG1-TG11
**Code paths:** `lib/domain/usecases/tag/**`, `lib/domain/tag/**`
