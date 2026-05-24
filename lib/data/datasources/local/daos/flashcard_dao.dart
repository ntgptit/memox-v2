import 'package:drift/drift.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../../domain/enums/content_sort_mode.dart';
import '../../../../domain/enums/flashcard_starting_status.dart';
import '../../../../domain/value_objects/content_actions.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../app_database.dart';

final class FlashcardDeckProgressSummary {
  const FlashcardDeckProgressSummary({
    required this.newCount,
    required this.learningCount,
    required this.masteredCount,
    required this.currentBoxes,
  });

  final int newCount;
  final int learningCount;
  final int masteredCount;
  final List<int> currentBoxes;
}

final class FlashcardDao {
  const FlashcardDao(this._database);

  final AppDatabase _database;
  static const int _initialSrsBox = 1;
  static const int _learningStartingSrsBox = 3;
  static const int _reviewingStartingSrsBox = 6;
  static const int _masteredSrsBox = 8;

  static int initialBoxFor(FlashcardStartingStatus status) {
    return switch (status) {
      FlashcardStartingStatus.newCard => _initialSrsBox,
      FlashcardStartingStatus.learning => _learningStartingSrsBox,
      FlashcardStartingStatus.reviewing => _reviewingStartingSrsBox,
    };
  }

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

  Future<FlashcardDeckProgressSummary> getDeckProgressSummary(
    String deckId,
  ) async {
    final rows = await _database
        .customSelect(
          '''
      SELECT p.current_box, p.due_at
      FROM flashcards f
      LEFT JOIN flashcard_progress p ON p.flashcard_id = f.id
      WHERE f.deck_id = ?1
      ''',
          variables: [Variable<String>(deckId)],
          readsFrom: {_database.flashcards, _database.flashcardProgress},
        )
        .get();

    var newCount = 0;
    var learningCount = 0;
    var masteredCount = 0;
    final currentBoxes = <int>[];

    for (final row in rows) {
      final currentBox = row.read<int?>('current_box');
      final dueAt = row.read<int?>('due_at');
      currentBoxes.add(currentBox ?? _initialSrsBox);
      if (currentBox == null || dueAt == null) {
        newCount += 1;
        continue;
      }
      if (currentBox >= _masteredSrsBox) {
        masteredCount += 1;
        continue;
      }
      learningCount += 1;
    }

    return FlashcardDeckProgressSummary(
      newCount: newCount,
      learningCount: learningCount,
      masteredCount: masteredCount,
      currentBoxes: currentBoxes,
    );
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
            example: Value(StringUtils.trimToNull(draft.example)),
            pronunciation: Value(StringUtils.trimToNull(draft.pronunciation)),
            hint: Value(StringUtils.trimToNull(draft.hint)),
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
        );
    await _replaceTagsForFlashcard(flashcardId: id, tags: draft.tags);
    await _database
        .into(_database.flashcardProgress)
        .insert(
          FlashcardProgressCompanion.insert(
            flashcardId: id,
            currentBox: initialBoxFor(draft.startingStatus),
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
  }) async {
    await (_database.update(
      _database.flashcards,
    )..where((table) => table.id.equals(flashcardId))).write(
      FlashcardsCompanion(
        front: Value(StringUtils.trimmed(draft.front)),
        back: Value(StringUtils.trimmed(draft.back)),
        note: Value(StringUtils.trimToNull(draft.note)),
        example: Value(StringUtils.trimToNull(draft.example)),
        pronunciation: Value(StringUtils.trimToNull(draft.pronunciation)),
        hint: Value(StringUtils.trimToNull(draft.hint)),
        updatedAt: Value(updatedAt),
      ),
    );
    await _replaceTagsForFlashcard(flashcardId: flashcardId, tags: draft.tags);
  }

  Future<List<String>> findTagsForFlashcard(String flashcardId) async {
    final rows = await (_database.select(_database.flashcardTags)
          ..where((table) => table.flashcardId.equals(flashcardId))
          ..orderBy([(table) => OrderingTerm.asc(table.tag)]))
        .get();
    return rows.map((row) => row.tag).toList(growable: false);
  }

  Future<Map<String, List<String>>> findTagsForFlashcards(
    List<String> flashcardIds,
  ) async {
    if (flashcardIds.isEmpty) {
      return const <String, List<String>>{};
    }
    final rows = await (_database.select(_database.flashcardTags)
          ..where((table) => table.flashcardId.isIn(flashcardIds))
          ..orderBy([(table) => OrderingTerm.asc(table.tag)]))
        .get();
    final result = <String, List<String>>{};
    for (final row in rows) {
      result.putIfAbsent(row.flashcardId, () => <String>[]).add(row.tag);
    }
    return result;
  }

  Future<void> _replaceTagsForFlashcard({
    required String flashcardId,
    required List<String> tags,
  }) async {
    await (_database.delete(
      _database.flashcardTags,
    )..where((table) => table.flashcardId.equals(flashcardId))).go();
    final cleaned = <String>{};
    for (final tag in tags) {
      final trimmed = StringUtils.trimmed(tag);
      if (trimmed.isNotEmpty) {
        cleaned.add(trimmed);
      }
    }
    if (cleaned.isEmpty) {
      return;
    }
    await _database.batch((batch) {
      batch.insertAll(
        _database.flashcardTags,
        [
          for (final tag in cleaned)
            FlashcardTagsCompanion.insert(flashcardId: flashcardId, tag: tag),
        ],
      );
    });
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
