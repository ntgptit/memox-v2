import 'package:drift/drift.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../app_database.dart';

final class FlashcardDao {
  const FlashcardDao(this._database);

  final AppDatabase _database;

  Future<Flashcard?> findById(String flashcardId) {
    return (_database.select(
      _database.flashcards,
    )..where((table) => table.id.equals(flashcardId))).getSingleOrNull();
  }

  Future<List<Flashcard>> listFlashcardsInDeck({
    required String deckId,
    required ContentQuery query,
  }) {
    final statement = _database.select(_database.flashcards)
      ..where((table) => table.deckId.equals(deckId));
    if (query.hasSearchTerm) {
      final pattern = '%${query.normalizedSearchTerm}%';
      statement.where(
        (table) =>
            table.front.lower().like(pattern) |
            table.back.lower().like(pattern),
      );
    }
    switch (query.sortMode) {
      case ContentSortMode.manual:
      case ContentSortMode.lastStudied:
        statement.orderBy([(table) => OrderingTerm.asc(table.sortOrder)]);
      case ContentSortMode.name:
        statement.orderBy([(table) => OrderingTerm.asc(table.sortOrder)]);
      case ContentSortMode.newest:
        statement.orderBy([(table) => OrderingTerm.desc(table.createdAt)]);
    }
    return statement.get();
  }

  Future<Map<String, int?>> getLastStudiedMap(List<String> flashcardIds) async {
    if (flashcardIds.isEmpty) {
      return const <String, int?>{};
    }

    final rows = await (_database.select(
      _database.flashcardProgress,
    )..where((table) => table.flashcardId.isIn(flashcardIds))).get();
    return <String, int?>{
      for (final row in rows) row.flashcardId: row.lastStudiedAt,
    };
  }

  Future<FlashcardProgressData?> findProgressByFlashcardId(String flashcardId) {
    return (_database.select(_database.flashcardProgress)
          ..where((table) => table.flashcardId.equals(flashcardId)))
        .getSingleOrNull();
  }

  Future<int> nextSortOrder(String deckId) async {
    final row =
        await (_database.selectOnly(_database.flashcards)
              ..addColumns([_database.flashcards.sortOrder.max()])
              ..where(_database.flashcards.deckId.equals(deckId)))
            .getSingleOrNull();
    final currentMax = row?.read(_database.flashcards.sortOrder.max()) ?? -1;
    return currentMax + 1;
  }

  Future<void> insertFlashcard({
    required String id,
    required String deckId,
    required FlashcardDraft draft,
    required int sortOrder,
    required int createdAt,
    required int updatedAt,
  }) async {
    await _database
        .into(_database.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: id,
            deckId: deckId,
            front: StringUtils.trimmed(draft.front),
            back: StringUtils.trimmed(draft.back),
            note: Value(StringUtils.trimToNull(draft.note)),
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        );
    await _database
        .into(_database.flashcardProgress)
        .insert(
          FlashcardProgressCompanion.insert(
            flashcardId: id,
            currentBox: 1,
            reviewCount: 0,
            lapseCount: 0,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        );
  }

  Future<void> updateFlashcard({
    required String flashcardId,
    required FlashcardDraft draft,
    required int updatedAt,
  }) {
    return (_database.update(
      _database.flashcards,
    )..where((table) => table.id.equals(flashcardId))).write(
      FlashcardsCompanion(
        front: Value(StringUtils.trimmed(draft.front)),
        back: Value(StringUtils.trimmed(draft.back)),
        note: Value(StringUtils.trimToNull(draft.note)),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> resetFlashcardProgress({
    required String flashcardId,
    required int updatedAt,
  }) {
    return (_database.update(
      _database.flashcardProgress,
    )..where((table) => table.flashcardId.equals(flashcardId))).write(
      FlashcardProgressCompanion(
        currentBox: const Value(1),
        reviewCount: const Value(0),
        lapseCount: const Value(0),
        lastResult: const Value<String?>(null),
        lastStudiedAt: const Value<int?>(null),
        dueAt: const Value<int?>(null),
        updatedAt: Value(updatedAt),
      ),
    );
  }

  Future<void> deleteFlashcards(List<String> flashcardIds) {
    return (_database.delete(
      _database.flashcards,
    )..where((table) => table.id.isIn(flashcardIds))).go();
  }

  Future<void> moveFlashcards({
    required List<String> flashcardIds,
    required String targetDeckId,
    required int startingSortOrder,
    required int updatedAt,
  }) async {
    for (var index = 0; index < flashcardIds.length; index++) {
      await (_database.update(
        _database.flashcards,
      )..where((table) => table.id.equals(flashcardIds[index]))).write(
        FlashcardsCompanion(
          deckId: Value(targetDeckId),
          sortOrder: Value(startingSortOrder + index),
          updatedAt: Value(updatedAt),
        ),
      );
    }
  }

  Future<void> reorderFlashcards({
    required String deckId,
    required List<String> orderedFlashcardIds,
    required int updatedAt,
  }) async {
    for (var index = 0; index < orderedFlashcardIds.length; index++) {
      await (_database.update(_database.flashcards)..where(
            (table) =>
                table.deckId.equals(deckId) &
                table.id.equals(orderedFlashcardIds[index]),
          ))
          .write(
            FlashcardsCompanion(
              sortOrder: Value(index),
              updatedAt: Value(updatedAt),
            ),
          );
    }
  }

  Future<List<Flashcard>> listFlashcardsByIds(List<String> flashcardIds) {
    return (_database.select(_database.flashcards)
          ..where((table) => table.id.isIn(flashcardIds))
          ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
        .get();
  }
}
