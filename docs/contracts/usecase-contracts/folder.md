---
last_updated: 2026-05-26
status: contract
---

# Folder Use Cases Contract

> Target architecture note: `Either<Failure, T>` / `fpdart` references describe MemoX's intended error/result contract style. If the project has not yet adopted `fpdart`, do not add it during ordinary feature implementation. First run an approved dependency/API migration task, or use the existing repository error/result pattern until that migration is approved.

All folder-mutation logic lives in use cases. Widgets and notifiers MUST NOT call `FolderRepository` directly for mutations.

Each section below specifies: signature, preconditions, rules, side effects, errors, test refs.

## CreateRootFolderUseCase

```dart
Future<Either<Failure, Folder>> call({required String name});
```

**Preconditions:** none.

**Rules:**

- Trim `name`.
- Reject empty after trim → `ValidationFailure(field: 'name', code: empty)`.
- Reject duplicate name among root folders (case-insensitive) → `ValidationFailure(code: duplicate)`.
- Insert with `parent_id = NULL`, `content_mode = unlocked`, `sort_order = MAX(sort_order)+1` among root.

**Side effects:**

- INSERT into `folders`.

**Errors:** `ValidationFailure`, `StorageFailure`.

**Test refs:** F1-F3 in decision table; `test/domain/usecases/folder/create_root_folder_test.dart`.

## CreateSubfolderUseCase

```dart
Future<Either<Failure, Folder>> call({required FolderId parentId, required String name});
```

**Preconditions:**

- Parent folder exists.
- Parent `content_mode` ∈ (`unlocked`, `subfolders`).

**Rules:**

- Trim name. Reject empty.
- Reject duplicate name among siblings.
- INSERT child folder with `parent_id`, `content_mode=unlocked`, next `sort_order`.
- UPDATE parent `content_mode` to `subfolders` if currently `unlocked`.
- Atomic (single transaction). Detail in `docs/contracts/repository-contracts/folder-repository.md`.

**Errors:** `NotFoundFailure` (parent), `UnsupportedActionFailure` (parent locked to decks), `ValidationFailure`, `StorageFailure`.

**Test refs:** F4-F7.

## CreateDeckInFolderUseCase

See `docs/contracts/usecase-contracts/deck.md` §CreateDeckUseCase. The use case lives there but updates folder `content_mode` to `decks` if parent currently `unlocked`. Single transaction.

## RenameFolderUseCase

```dart
Future<Either<Failure, Folder>> call({required FolderId id, required String newName});
```

**Rules:**

- Trim name. Reject empty.
- Reject duplicate among siblings (same `parent_id`).
- No-op (return `Right(folder)`) if new name equals current after trim.

**Errors:** `NotFoundFailure`, `ValidationFailure`, `StorageFailure`.

**Test refs:** F8.

## MoveFolderUseCase

```dart
Future<Either<Failure, Folder>> call({required FolderId id, required FolderId? newParentId});
```

**Preconditions:**

- Folder exists.
- New parent exists (or null for root).
- New parent's `content_mode` allows subfolders.
- Move does NOT create a cycle (new parent is not the folder itself OR any of its descendants).

**Rules:**

- Atomic update of folder + parent modes; recompute `sort_order`. See `docs/contracts/repository-contracts/folder-repository.md` for table list.

**Errors:** `NotFoundFailure`, `ValidationFailure(code: cycleDetected)`, `UnsupportedActionFailure`, `StorageFailure`.

**Test refs:** F9-F11.

## DeleteFolderUseCase

```dart
Future<Either<Failure, Unit>> call({required FolderId id});
```

**Rules:**

- Atomic recursive cascade (descendants + their content + sessions targeting them). Full cascade list in `docs/contracts/repository-contracts/folder-repository.md`.
- UPDATE old parent's `content_mode` to `unlocked` if no more children remain.

**Errors:** `NotFoundFailure`, `StorageFailure`.

**Test refs:** F12.

**Caution:** Destructive. Caller MUST confirm via §delete-confirm dialog before invoking.

## ReorderFoldersUseCase

```dart
Future<Either<Failure, Unit>> call({required FolderId? parentId, required List<FolderId> orderedIds});
```

**Rules:**

- Atomic batch `sort_order` UPDATE. All ids MUST belong to the same parent (else `ValidationFailure`).

**Errors:** `ValidationFailure`, `StorageFailure`.

**Test refs:** F13.

## GetFolderDetailUseCase

```dart
Future<Either<Failure, FolderDetail>> call({required FolderId id});
```

`FolderDetail` = folder + breadcrumb path + child counts.

**Errors:** `NotFoundFailure`, `StorageFailure`.

## WatchRootChildrenUseCase

```dart
Stream<Either<Failure, RootChildren>> call();
```

`RootChildren` = `{ folders: List<FolderWithCount>, decks: List<DeckWithCount> }`.

Used by Library screen.

## WatchFolderChildrenUseCase

```dart
Stream<Either<Failure, FolderChildren>> call({required FolderId id});
```

Returns folder + appropriate children based on `content_mode`. Used by Folder detail screen.

## ListAllFoldersUseCase

```dart
Future<List<FolderScopeOption>> execute();
```

`FolderScopeOption` = `{ id: FolderId, name: String, breadcrumb: List<String> }` (breadcrumb is root→leaf including the folder itself; `parentBreadcrumb` drops the leaf for parent context).

Pure read path that lists **every** folder as a flat scope option. Unlike `GetFolderMoveTargetsUseCase`, it performs **no** move validation and **no** descendant exclusion. Backed by the existing `FolderDao.listAllFolders()` + `getBreadcrumbNames()` (no schema change). Used by the Dashboard "Start new learning" scope picker (Folder scope). Impl: `FolderRepositoryImpl.listAllFolders`; provider `listAllFoldersUseCaseProvider`.

## Forbidden patterns

- ❌ Update `content_mode` without a transaction that also touches children.
- ❌ Allow `content_mode` transition that violates the lock rule.
- ❌ Delete without confirming via dialog (caller responsibility).
- ❌ Move folder into a `decks`-mode parent.
- ❌ Skip `sort_order` recomputation on move/insert.

## Related

**Base contracts:** `docs/contracts/error-contract.md` (Failure types), `docs/contracts/types-catalog.md` (enums and value objects), `docs/contracts/code-style.md` (naming)

**Business spec:** `docs/business/folder/folder-management.md`
**Repository:** `docs/contracts/repository-contracts/folder-repository.md`
**Wireframes:** `docs/wireframes/02-library.md`, `docs/wireframes/05-folder-detail.md`
**Decision table:** rows F1-F13
**Code paths:** `lib/domain/usecases/folder/**`
