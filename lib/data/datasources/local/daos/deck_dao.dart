import 'package:drift/drift.dart';

import '../../../domain/value_objects/content_queries.dart';
import '../app_database.dart';

final class DeckDao {
  const DeckDao(this._database);

  final AppDatabase _database;

  Future<Deck?> findById(String deckId) {
    return (_database.select(
      _database.decks,
    )..where((table) => table.id.equals(deckId))).getSingleOrNull();
  }

  Future<List<Deck>> listAllDecks() {
    return (_database.select(
      _database.decks,
    )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get();
  }

  Future<List<Deck>> listDecksInFolder({
    required String folderId,
    required ContentQuery query,
  }) {
    final statement = _database.select(_database.decks)
      ..where((table) => table.folderId.equals(folderId));
    if (query.hasSearchTerm) {
      final pattern = '%${query.normalizedSearchTerm.toLowerCase()}%';
      statement.where((table) => table.name.lower().like(pattern));
    }
    switch (query.sortMode) {
      case ContentSortMode.manual:
      case ContentSortMode.lastStudied:
        statement.orderBy([(table) => OrderingTerm.asc(table.sortOrder)]);
      case ContentSortMode.name:
        statement.orderBy([(table) => OrderingTerm.asc(table.name.lower())]);
      case ContentSortMode.newest:
        statement.orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    }
    return statement.get();
  }

  Future<int> nextSortOrder(String folderId) async {
    final row = await (_database.selectOnly(_database.decks)
      ..addColumns([_database.decks.sortOrder.max()])
      ..where(_database.decks.folderId.equals(folderId))).getSingleOrNull();
    final currentMax = row?.read(_database.decks.sortOrder.max()) ?? -1;
    return currentMax + 1;
  }

  Future<void> insertDeck({
    required String id,
    required String folderId,
    required String name,
    required int sortOrder,
    required int createdAt,
    required int updatedAt,
  }) {
    return _database.into(_database.decks).insert(
      DecksCompanion.insert(
        id: id,
        folderId: folderId,
        name: name,
        sortOrder: sortOrder,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }

  Future<void> updateDeckName({
    required String deckId,
    required String name,
    required int updatedAt,
  }) {
    return (_database.update(_database.decks)
      ..where((table) => table.id.equals(deckId))).write(
      DecksCompanion(
        name: Value(name),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> updateDeckFolder({
    required String deckId,
    required String folderId,
    required int sortOrder,
    required int updatedAt,
  }) {
    return (_database.update(_database.decks)
      ..where((table) => table.id.equals(deckId))).write(
      DecksCompanion(
        folderId: Value(folderId),
        sortOrder: Value(sortOrder),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> deleteDeck(String deckId) {
    return (_database.delete(
      _database.decks,
    )..where((table) => table.id.equals(deckId))).go();
  }

  Future<void> reorderDecks({
    required String folderId,
    required List<String> orderedDeckIds,
    required int updatedAt,
  }) async {
    for (var index = 0; index < orderedDeckIds.length; index++) {
      await (_database.update(_database.decks)
        ..where(
          (table) =>
              table.folderId.equals(folderId) &
              table.id.equals(orderedDeckIds[index]),
        )).write(
        DecksCompanion(
          sortOrder: Value(index),
          updatedAt: Value(updatedAt),
        ),
      );
    }
  }

  Future<int> countFlashcardsInDeck(String deckId) async {
    final row = await (_database.selectOnly(_database.flashcards)
      ..addColumns([_database.flashcards.id.count()])
      ..where(_database.flashcards.deckId.equals(deckId))).getSingle();
    return row.read(_database.flashcards.id.count()) ?? 0;
  }

  Future<int> countDueTodayInDeck({
    required String deckId,
    required int endOfTodayEpochMillis,
  }) async {
    final row = await _database.customSelect(
      '''
      SELECT COUNT(f.id) AS due_today
      FROM flashcards f
      INNER JOIN flashcard_progress p ON p.flashcard_id = f.id
      WHERE f.deck_id = ?1 AND p.due_at IS NOT NULL AND p.due_at <= ?2
      ''',
      variables: [
        Variable<String>(deckId),
        Variable<int>(endOfTodayEpochMillis),
      ],
      readsFrom: {_database.flashcards, _database.flashcardProgress},
    ).getSingle();
    return row.read<int>('due_today');
  }

  Future<int?> getLastStudiedAtInDeck(String deckId) async {
    final row = await _database.customSelect(
      '''
      SELECT MAX(p.last_studied_at) AS last_studied_at
      FROM flashcard_progress p
      INNER JOIN flashcards f ON f.id = p.flashcard_id
      WHERE f.deck_id = ?1
      ''',
      variables: [Variable<String>(deckId)],
      readsFrom: {_database.flashcards, _database.flashcardProgress},
    ).getSingle();
    return row.read<int?>('last_studied_at');
  }

  Future<List<int>> getCurrentBoxesInDeck(String deckId) async {
    final rows = await _database.customSelect(
      '''
      SELECT p.current_box
      FROM flashcard_progress p
      INNER JOIN flashcards f ON f.id = p.flashcard_id
      WHERE f.deck_id = ?1
      ''',
      variables: [Variable<String>(deckId)],
      readsFrom: {_database.flashcards, _database.flashcardProgress},
    ).get();
    return rows.map((row) => row.read<int>('current_box')).toList(growable: false);
  }

  Future<List<Flashcard>> listDeckFlashcards(String deckId) {
    return (_database.select(_database.flashcards)
      ..where((table) => table.deckId.equals(deckId))
      ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)])).get();
  }
}
