import 'package:drift/drift.dart';

import '../app_database.dart';

final class StudyAttemptDao {
  const StudyAttemptDao(this._database);

  final AppDatabase _database;

  Future<void> insertAttempt(StudyAttemptsCompanion companion) {
    return _database.into(_database.studyAttempts).insert(companion);
  }

  Future<List<StudyAttempt>> listAttempts(String sessionId) {
    return (_database.select(_database.studyAttempts)
          ..where((table) => table.sessionId.equals(sessionId))
          ..orderBy([(table) => OrderingTerm.asc(table.answeredAt)]))
        .get();
  }

  Future<List<StudyAttempt>> listAttemptsForItems(List<String> itemIds) {
    if (itemIds.isEmpty) {
      return Future.value(const <StudyAttempt>[]);
    }
    return (_database.select(_database.studyAttempts)
          ..where((table) => table.sessionItemId.isIn(itemIds))
          ..orderBy([(table) => OrderingTerm.asc(table.answeredAt)]))
        .get();
  }

  Future<int> nextAttemptNumber({
    required String sessionId,
    required String flashcardId,
  }) async {
    final row =
        await (_database.selectOnly(_database.studyAttempts)
              ..addColumns([_database.studyAttempts.attemptNumber.max()])
              ..where(
                _database.studyAttempts.sessionId.equals(sessionId) &
                    _database.studyAttempts.flashcardId.equals(flashcardId),
              ))
            .getSingle();
    return (row.read(_database.studyAttempts.attemptNumber.max()) ?? 0) + 1;
  }

  Future<void> updateAttemptSrsSummary({
    required String attemptId,
    required int oldBox,
    required int newBox,
    required int nextDueAt,
  }) {
    return (_database.update(
      _database.studyAttempts,
    )..where((table) => table.id.equals(attemptId))).write(
      StudyAttemptsCompanion(
        oldBox: Value(oldBox),
        newBox: Value(newBox),
        nextDueAt: Value(nextDueAt),
      ),
    );
  }
}
