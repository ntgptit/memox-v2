import 'package:drift/drift.dart';

import '../../../domain/enums/folder_content_mode.dart';
import '../../../domain/value_objects/content_queries.dart';
import '../app_database.dart';

final class FolderDao {
  const FolderDao(this._database);

  final AppDatabase _database;

  Future<Folder?> findById(String folderId) {
    return (_database.select(
      _database.folders,
    )..where((table) => table.id.equals(folderId))).getSingleOrNull();
  }

  Future<List<Folder>> listAllFolders() {
    return (_database.select(
      _database.folders,
    )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get();
  }

  Future<List<Folder>> listRootFolders(ContentQuery query) {
    final statement = _database.select(_database.folders)
      ..where((table) => table.parentId.isNull());
    _applyFolderFilter(statement, query);
    _applyFolderSort(statement, query);
    return statement.get();
  }

  Future<List<Folder>> listSubfolders({
    required String parentFolderId,
    required ContentQuery query,
  }) {
    final statement = _database.select(_database.folders)
      ..where((table) => table.parentId.equals(parentFolderId));
    _applyFolderFilter(statement, query);
    _applyFolderSort(statement, query);
    return statement.get();
  }

  Future<int> nextSortOrder(String? parentFolderId) async {
    final query = _database.selectOnly(_database.folders)
      ..addColumns([_database.folders.sortOrder.max()]);
    if (parentFolderId == null) {
      query.where(_database.folders.parentId.isNull());
    } else {
      query.where(_database.folders.parentId.equals(parentFolderId));
    }
    final row = await query.getSingleOrNull();
    final currentMax = row?.read(_database.folders.sortOrder.max()) ?? -1;
    return currentMax + 1;
  }

  Future<void> insertFolder({
    required String id,
    required String? parentId,
    required String name,
    required FolderContentMode contentMode,
    required int sortOrder,
    required int createdAt,
    required int updatedAt,
  }) {
    return _database.into(_database.folders).insert(
      FoldersCompanion.insert(
        id: id,
        parentId: Value(parentId),
        name: name,
        contentMode: contentMode.storageValue,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  Future<void> updateFolderName({
    required String folderId,
    required String name,
    required int updatedAt,
  }) {
    return (_database.update(_database.folders)
      ..where((table) => table.id.equals(folderId))).write(
      FoldersCompanion(
        name: Value(name),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> updateFolderParent({
    required String folderId,
    required String? parentId,
    required int sortOrder,
    required int updatedAt,
  }) {
    return (_database.update(_database.folders)
      ..where((table) => table.id.equals(folderId))).write(
      FoldersCompanion(
        parentId: Value(parentId),
        sortOrder: Value(sortOrder),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> updateFolderMode({
    required String folderId,
    required FolderContentMode contentMode,
    required int updatedAt,
  }) {
    return (_database.update(_database.folders)
      ..where((table) => table.id.equals(folderId))).write(
      FoldersCompanion(
        contentMode: Value(contentMode.storageValue),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> deleteFolder(String folderId) {
    return (_database.delete(
      _database.folders,
    )..where((table) => table.id.equals(folderId))).go();
  }

  Future<void> reorderFolders({
    required String? parentFolderId,
    required List<String> orderedFolderIds,
    required int updatedAt,
  }) async {
    for (var index = 0; index < orderedFolderIds.length; index++) {
      await (_database.update(_database.folders)
        ..where((table) {
          final matchesParent = parentFolderId == null
              ? table.parentId.isNull()
              : table.parentId.equals(parentFolderId);
          return matchesParent & table.id.equals(orderedFolderIds[index]);
        })).write(
        FoldersCompanion(
          sortOrder: Value(index),
          updatedAt: Value(updatedAt),
        ),
      );
    }
  }

  Future<bool> hasSubfolders(String folderId) async {
    final row = await (_database.selectOnly(_database.folders)
      ..addColumns([_database.folders.id.count()])
      ..where(_database.folders.parentId.equals(folderId))).getSingle();
    return (row.read(_database.folders.id.count()) ?? 0) > 0;
  }

  Future<bool> hasDecks(String folderId) async {
    final row = await (_database.selectOnly(_database.decks)
      ..addColumns([_database.decks.id.count()])
      ..where(_database.decks.folderId.equals(folderId))).getSingle();
    return (row.read(_database.decks.id.count()) ?? 0) > 0;
  }

  Future<List<String>> getSubtreeIds(String folderId) async {
    final result = await _database.customSelect(
      '''
      WITH RECURSIVE subtree(id) AS (
        SELECT id FROM folders WHERE id = ?1
        UNION ALL
        SELECT child.id
        FROM folders child
        INNER JOIN subtree parent ON child.parent_id = parent.id
      )
      SELECT id FROM subtree
      ''',
      variables: [Variable<String>(folderId)],
      readsFrom: {_database.folders},
    ).get();
    return result.map((row) => row.read<String>('id')).toList(growable: false);
  }

  Future<Set<String>> getDescendantIds(String folderId) async {
    final subtree = await getSubtreeIds(folderId);
    return subtree.where((id) => id != folderId).toSet();
  }

  Future<List<String>> getBreadcrumbNames(String folderId) async {
    final result = await _database.customSelect(
      '''
      WITH RECURSIVE breadcrumb(id, parent_id, name, depth) AS (
        SELECT id, parent_id, name, 0 FROM folders WHERE id = ?1
        UNION ALL
        SELECT parent.id, parent.parent_id, parent.name, child.depth + 1
        FROM folders parent
        INNER JOIN breadcrumb child ON child.parent_id = parent.id
      )
      SELECT name FROM breadcrumb ORDER BY depth DESC
      ''',
      variables: [Variable<String>(folderId)],
      readsFrom: {_database.folders},
    ).get();
    return result.map((row) => row.read<String>('name')).toList(growable: false);
  }

  Future<int> countDecksInSubtree(String folderId) async {
    final subtreeIds = await getSubtreeIds(folderId);
    if (subtreeIds.isEmpty) {
      return 0;
    }
    final row = await (_database.selectOnly(_database.decks)
      ..addColumns([_database.decks.id.count()])
      ..where(_database.decks.folderId.isIn(subtreeIds))).getSingle();
    return row.read(_database.decks.id.count()) ?? 0;
  }

  Future<int> countFlashcardsInSubtree(String folderId) async {
    final subtreeIds = await getSubtreeIds(folderId);
    if (subtreeIds.isEmpty) {
      return 0;
    }
    final row = await _database.customSelect(
      '''
      SELECT COUNT(f.id) AS item_count
      FROM flashcards f
      INNER JOIN decks d ON d.id = f.deck_id
      WHERE d.folder_id IN (${_placeholders(subtreeIds.length)})
      ''',
      variables: subtreeIds.map(Variable<String>.new).toList(),
      readsFrom: {_database.decks, _database.flashcards},
    ).getSingle();
    return row.read<int>('item_count');
  }

  Future<int?> getLastStudiedAtInSubtree(String folderId) async {
    final subtreeIds = await getSubtreeIds(folderId);
    if (subtreeIds.isEmpty) {
      return null;
    }
    final row = await _database.customSelect(
      '''
      SELECT MAX(p.last_studied_at) AS last_studied_at
      FROM flashcard_progress p
      INNER JOIN flashcards f ON f.id = p.flashcard_id
      INNER JOIN decks d ON d.id = f.deck_id
      WHERE d.folder_id IN (${_placeholders(subtreeIds.length)})
      ''',
      variables: subtreeIds.map(Variable<String>.new).toList(),
      readsFrom: {_database.decks, _database.flashcards, _database.flashcardProgress},
    ).getSingle();
    return row.read<int?>('last_studied_at');
  }

  Future<List<int>> getCurrentBoxesInSubtree(String folderId) async {
    final subtreeIds = await getSubtreeIds(folderId);
    if (subtreeIds.isEmpty) {
      return const <int>[];
    }
    final rows = await _database.customSelect(
      '''
      SELECT p.current_box
      FROM flashcard_progress p
      INNER JOIN flashcards f ON f.id = p.flashcard_id
      INNER JOIN decks d ON d.id = f.deck_id
      WHERE d.folder_id IN (${_placeholders(subtreeIds.length)})
      ''',
      variables: subtreeIds.map(Variable<String>.new).toList(),
      readsFrom: {_database.decks, _database.flashcards, _database.flashcardProgress},
    ).get();
    return rows.map((row) => row.read<int>('current_box')).toList(growable: false);
  }

  Future<int> countDueToday(int endOfTodayEpochMillis) async {
    final row = await (_database.selectOnly(_database.flashcardProgress)
      ..addColumns([_database.flashcardProgress.flashcardId.count()])
      ..where(
        _database.flashcardProgress.dueAt.isSmallerOrEqualValue(
          endOfTodayEpochMillis,
        ),
      )).getSingle();
    return row.read(_database.flashcardProgress.flashcardId.count()) ?? 0;
  }

  void _applyFolderFilter(
    SimpleSelectStatement<$FoldersTable, Folder> statement,
    ContentQuery query,
  ) {
    if (!query.hasSearchTerm) {
      return;
    }

    final pattern = '%${query.normalizedSearchTerm.toLowerCase()}%';
    statement.where((table) => table.name.lower().like(pattern));
  }

  void _applyFolderSort(
    SimpleSelectStatement<$FoldersTable, Folder> statement,
    ContentQuery query,
  ) {
    switch (query.sortMode) {
      case ContentQuery().sortMode:
      case ContentSortMode.manual:
        statement.orderBy([(table) => OrderingTerm.asc(table.sortOrder)]);
      case ContentSortMode.name:
        statement.orderBy([(table) => OrderingTerm.asc(table.name.lower())]);
      case ContentSortMode.newest:
        statement.orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
      case ContentSortMode.lastStudied:
        statement.orderBy([(table) => OrderingTerm.asc(table.sortOrder)]);
    }
  }

  static String _placeholders(int count) {
    return List<String>.generate(count, (index) => '?${index + 1}').join(', ');
  }
}
