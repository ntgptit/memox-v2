import 'package:drift/drift.dart';

import '../app_database.dart';

final class StudySessionItemDao {
  const StudySessionItemDao(this._database);

  final AppDatabase _database;

  Future<void> insertItems(List<StudySessionItemsCompanion> items) async {
    await _database.batch((batch) {
      batch.insertAll(_database.studySessionItems, items);
    });
  }

  Future<StudySessionItem?> findCurrentPending(String sessionId) =>
      (_database.select(_database.studySessionItems)
            ..where(
              (table) =>
                  table.sessionId.equals(sessionId) &
                  table.status.equals('pending'),
            )
            ..orderBy([
              (table) => OrderingTerm.asc(table.modeOrder),
              (table) => OrderingTerm.asc(table.roundIndex),
              (table) => OrderingTerm.asc(table.queuePosition),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<List<StudySessionItem>> listItems(String sessionId) =>
      (_database.select(_database.studySessionItems)
            ..where((table) => table.sessionId.equals(sessionId))
            ..orderBy([
              (table) => OrderingTerm.asc(table.modeOrder),
              (table) => OrderingTerm.asc(table.roundIndex),
              (table) => OrderingTerm.asc(table.queuePosition),
            ]))
          .get();

  Future<List<StudySessionItem>> listModeRoundItems({
    required String sessionId,
    required int modeOrder,
    required int roundIndex,
  }) =>
      (_database.select(_database.studySessionItems)
            ..where(
              (table) =>
                  table.sessionId.equals(sessionId) &
                  table.modeOrder.equals(modeOrder) &
                  table.roundIndex.equals(roundIndex),
            )
            ..orderBy([(table) => OrderingTerm.asc(table.queuePosition)]))
          .get();

  Future<List<StudySessionItem>> listOriginalBatchItems(String sessionId) =>
      (_database.select(_database.studySessionItems)
            ..where(
              (table) =>
                  table.sessionId.equals(sessionId) &
                  table.modeOrder.equals(1) &
                  table.roundIndex.equals(1),
            )
            ..orderBy([(table) => OrderingTerm.asc(table.queuePosition)]))
          .get();

  Future<void> completeItem({
    required String itemId,
    required int completedAt,
  }) =>
      (_database.update(
        _database.studySessionItems,
      )..where((table) => table.id.equals(itemId))).write(
        StudySessionItemsCompanion(
          status: const Value('completed'),
          completedAt: Value(completedAt),
        ),
      );

  Future<void> requeuePendingItem({
    required String itemId,
    required int queuePosition,
  }) =>
      (_database.update(
        _database.studySessionItems,
      )..where((table) => table.id.equals(itemId))).write(
        StudySessionItemsCompanion(queuePosition: Value(queuePosition)),
      );

  Future<int> maxQueuePosition({
    required String sessionId,
    required int modeOrder,
    required int roundIndex,
  }) async {
    final row =
        await (_database.selectOnly(_database.studySessionItems)
              ..addColumns([_database.studySessionItems.queuePosition.max()])
              ..where(
                _database.studySessionItems.sessionId.equals(sessionId) &
                    _database.studySessionItems.modeOrder.equals(modeOrder) &
                    _database.studySessionItems.roundIndex.equals(roundIndex),
              ))
            .getSingle();
    return row.read(_database.studySessionItems.queuePosition.max()) ?? 0;
  }

  Future<bool> hasPendingInModeRound({
    required String sessionId,
    required int modeOrder,
    required int roundIndex,
  }) async {
    final row =
        await (_database.selectOnly(_database.studySessionItems)
              ..addColumns([_database.studySessionItems.id.count()])
              ..where(
                _database.studySessionItems.sessionId.equals(sessionId) &
                    _database.studySessionItems.modeOrder.equals(modeOrder) &
                    _database.studySessionItems.roundIndex.equals(roundIndex) &
                    _database.studySessionItems.status.equals('pending'),
              ))
            .getSingle();
    return (row.read(_database.studySessionItems.id.count()) ?? 0) > 0;
  }

  Future<void> abandonPending(String sessionId) =>
      (_database.update(_database.studySessionItems)..where(
            (table) =>
                table.sessionId.equals(sessionId) &
                table.status.equals('pending'),
          ))
          .write(const StudySessionItemsCompanion(status: Value('abandoned')));

  /// Abandons every still-pending item for [flashcardId] in [sessionId].
  /// Used by bury/suspend to remove the card from the active session queue
  /// without recording an attempt.
  Future<void> abandonFlashcardPendingItems({
    required String sessionId,
    required String flashcardId,
  }) =>
      (_database.update(_database.studySessionItems)..where(
            (table) =>
                table.sessionId.equals(sessionId) &
                table.flashcardId.equals(flashcardId) &
                table.status.equals('pending'),
          ))
          .write(const StudySessionItemsCompanion(status: Value('abandoned')));

  /// Distinct flashcard ids that have at least one abandoned item in
  /// [sessionId]. Buried/suspended cards are dropped this way and must be
  /// excluded from later modes and SRS commit.
  Future<Set<String>> listAbandonedFlashcardIds(String sessionId) async {
    final query =
        _database.selectOnly(_database.studySessionItems, distinct: true)
          ..addColumns([_database.studySessionItems.flashcardId])
          ..where(
            _database.studySessionItems.sessionId.equals(sessionId) &
                _database.studySessionItems.status.equals('abandoned'),
          );
    final rows = await query.get();
    return rows
        .map((row) => row.read(_database.studySessionItems.flashcardId))
        .whereType<String>()
        .toSet();
  }
}
