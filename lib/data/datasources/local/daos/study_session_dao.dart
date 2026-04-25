import 'package:drift/drift.dart';

import '../app_database.dart';

final class StudySessionDao {
  const StudySessionDao(this._database);

  final AppDatabase _database;

  Future<StudySession?> findById(String sessionId) {
    return (_database.select(
      _database.studySessions,
    )..where((table) => table.id.equals(sessionId))).getSingleOrNull();
  }

  Future<StudySession?> findResumeCandidate({
    required String entryType,
    required String? entryRefId,
  }) {
    final statement = _database.select(_database.studySessions)
      ..where(
        (table) =>
            table.entryType.equals(entryType) &
            table.status.isIn(const <String>[
              'in_progress',
              'ready_to_finalize',
              'failed_to_finalize',
            ]),
      )
      ..orderBy([(table) => OrderingTerm.desc(table.startedAt)])
      ..limit(1);
    statement.where(
      (table) => entryRefId == null
          ? table.entryRefId.isNull()
          : table.entryRefId.equals(entryRefId),
    );
    return statement.getSingleOrNull();
  }

  Future<List<StudySession>> listActiveSessions() {
    return (_database.select(_database.studySessions)
          ..where(
            (table) => table.status.isIn(const <String>[
              'in_progress',
              'ready_to_finalize',
              'failed_to_finalize',
            ]),
          )
          ..orderBy([(table) => OrderingTerm.desc(table.startedAt)]))
        .get();
  }

  Future<void> insertSession(StudySessionsCompanion companion) {
    return _database.into(_database.studySessions).insert(companion);
  }

  Future<void> updateStatus({
    required String sessionId,
    required String status,
    required int? endedAt,
  }) {
    return (_database.update(
      _database.studySessions,
    )..where((table) => table.id.equals(sessionId))).write(
      StudySessionsCompanion(status: Value(status), endedAt: Value(endedAt)),
    );
  }
}
