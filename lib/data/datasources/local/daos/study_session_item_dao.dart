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

  Future<StudySessionItem?> findCurrentPending(String sessionId) {
    return (_database.select(_database.studySessionItems)
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
  }

  Future<List<StudySessionItem>> listItems(String sessionId) {
    return (_database.select(_database.studySessionItems)
          ..where((table) => table.sessionId.equals(sessionId))
          ..orderBy([
            (table) => OrderingTerm.asc(table.modeOrder),
            (table) => OrderingTerm.asc(table.roundIndex),
            (table) => OrderingTerm.asc(table.queuePosition),
          ]))
        .get();
  }

  Future<List<StudySessionItem>> listModeRoundItems({
    required String sessionId,
    required int modeOrder,
    required int roundIndex,
  }) {
    return (_database.select(_database.studySessionItems)
          ..where(
            (table) =>
                table.sessionId.equals(sessionId) &
                table.modeOrder.equals(modeOrder) &
                table.roundIndex.equals(roundIndex),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.queuePosition)]))
        .get();
  }

  Future<List<StudySessionItem>> listOriginalBatchItems(String sessionId) {
    return (_database.select(_database.studySessionItems)
          ..where(
            (table) =>
                table.sessionId.equals(sessionId) &
                table.modeOrder.equals(1) &
                table.roundIndex.equals(1),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.queuePosition)]))
        .get();
  }

  Future<void> completeItem({
    required String itemId,
    required int completedAt,
  }) {
    return (_database.update(
      _database.studySessionItems,
    )..where((table) => table.id.equals(itemId))).write(
      StudySessionItemsCompanion(
        status: const Value('completed'),
        completedAt: Value(completedAt),
      ),
    );
  }

  Future<void> requeuePendingItem({
    required String itemId,
    required int queuePosition,
  }) {
    return (_database.update(_database.studySessionItems)
          ..where((table) => table.id.equals(itemId)))
        .write(StudySessionItemsCompanion(queuePosition: Value(queuePosition)));
  }

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

  Future<void> abandonPending(String sessionId) {
    return (_database.update(_database.studySessionItems)..where(
          (table) =>
              table.sessionId.equals(sessionId) &
              table.status.equals('pending'),
        ))
        .write(const StudySessionItemsCompanion(status: Value('abandoned')));
  }
}
