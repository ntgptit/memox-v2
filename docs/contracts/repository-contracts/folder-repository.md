---
last_updated: 2026-05-26
status: contract
---

# Folder Repository Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

`abstract class FolderRepository` in `lib/domain/repositories/folder_repository.dart`.
Implementation `FolderRepositoryImpl` in `lib/data/repositories/folder_repository_impl.dart`.

## Methods

### Queries (return Future or Stream)

```dart
Stream<List<Folder>> watchRootFolders();
Stream<List<Folder>> watchSubfolders(FolderId parentId);
Stream<FolderDetail?> watchFolderDetail(FolderId id);
Future<Either<Failure, Folder>> findById(FolderId id);
Future<Either<Failure, List<Folder>>> resolveBreadcrumb(FolderId id);
Future<Either<Failure, int>> countDescendantFlashcards(FolderId id);
Future<Either<Failure, int>> countDescendantDueFlashcards(FolderId id);
```

### Mutations

```dart
Future<Either<Failure, Folder>> create({
  required String name,
  required FolderId? parentId,
});

Future<Either<Failure, Folder>> rename(FolderId id, String newName);
Future<Either<Failure, Folder>> move(FolderId id, FolderId? newParentId);
Future<Either<Failure, Unit>> delete(FolderId id);
Future<Either<Failure, Unit>> reorder(FolderId? parentId, List<FolderId> orderedIds);
Future<Either<Failure, Unit>> updateContentMode(FolderId id, ContentMode newMode);
```

## Transaction requirements

| Operation | Tables touched in single transaction |
| --- | --- |
| `create` (subfolder) | `folders` INSERT + parent `content_mode` UPDATE if unlocked |
| `move` | `folders` UPDATE + new parent mode + old parent mode (if children=0 → unlocked) |
| `delete` | `folders` recursive cascade: subfolders, decks under them, flashcards, flashcard_progress, flashcard_tags, study_attempts referencing those flashcards, study_sessions referencing this folder |
| `reorder` | `folders` batch UPDATE of `sort_order` |

## Constraints enforced at repo layer

- `parent_id` MUST reference existing folder OR be NULL.
- Folder cannot reference itself as parent.
- `content_mode` ∈ {`unlocked`, `subfolders`, `decks`}.
- Sibling name uniqueness (case-insensitive) enforced at INSERT/UPDATE.
- Move that would create cycle MUST fail. Cycle check via descendant traversal BEFORE update.

## Forbidden patterns

- ❌ Return Drift row type. Always map to `Folder` entity.
- ❌ Mix presentation models (e.g., `FolderCard`) into return types.
- ❌ Return deleted orphan records.
- ❌ Allow `content_mode` corruption (e.g., subfolders mode with deck children).
- ❌ Recurse outside transaction.

## Required mappers

`FolderMapper` in `lib/data/mappers/folder_mapper.dart`:

- `Folder fromRow(FolderRow row)`
- `FolderRow toRow(Folder entity)`
- `ContentMode fromString(String value)` / `String toStorage(ContentMode mode)`

## Test contract

- Repository test (real in-memory Drift):
  - Create root folder.
  - Create subfolder + verify parent mode update.
  - Create deck in folder + verify parent mode update.
  - Move folder + cycle detection.
  - Delete cascade.
  - Reorder.
  - Sibling uniqueness rejection.
- Domain test (mock repo):
  - Use case orchestration tested with mocktail.

## Related

**Base contracts:** `docs/contracts/error-contract.md`, `docs/contracts/types-catalog.md`, `docs/contracts/code-style.md`

**Business spec:** `docs/business/folder/folder-management.md`
**Use cases:** `docs/contracts/usecase-contracts/folder.md`
**Schema:** `docs/database/schema-contract.md` `folders` table
**Code paths:**

- `lib/domain/repositories/folder_repository.dart` (interface)
- `lib/data/repositories/folder_repository_impl.dart`
- `lib/data/datasources/local/daos/folder_dao.dart`
- `lib/data/mappers/folder_mapper.dart`
