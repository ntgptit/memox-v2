import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/datasources/local/app_database.dart';
import '../../config/app_config.dart';
import '../providers.dart';

part 'study_entry_diagnostic_providers.g.dart';

@Riverpod(keepAlive: true)
StudyEntryDiagnosticService studyEntryDiagnosticService(Ref ref) =>
    StudyEntryDiagnosticService(ref.watch(appDatabaseProvider));

class StudyEntryDiagnosticService {
  const StudyEntryDiagnosticService(this._database);

  final AppDatabase? _database;

  Future<String> buildFailureBlock({
    required AppConfig config,
    required String entryType,
    required String? entryRefId,
    required String? studyMode,
  }) async {
    if (!config.exposeInternalErrorDetails) {
      return '';
    }

    final schemaVersion = await _readInt('PRAGMA user_version', 'user_version');
    final flashcardCount = await _countFlashcards(entryType, entryRefId);
    final progressCount = await _countProgressRows(entryType, entryRefId);
    final missingProgressCount = await _countMissingProgressRows(
      entryType,
      entryRefId,
    );
    final activeSessionCount = await _countActiveSessions(
      entryType,
      entryRefId,
    );
    final lastActiveSession = await _lastActiveSession(entryType, entryRefId);
    final pendingItemCount = lastActiveSession == null
        ? 0
        : await _countPendingItems(lastActiveSession.id);
    final missingItemReferences = lastActiveSession == null
        ? 0
        : await _countMissingItemReferences(lastActiveSession.id);

    return [
      'Study Entry diagnostics',
      'schemaVersion=$schemaVersion',
      'entryType=$entryType',
      'entryRefId=${entryRefId ?? '<null>'}',
      'studyMode=${studyMode ?? '<default>'}',
      'flashcardsInScope=$flashcardCount',
      'progressRowsInScope=$progressCount',
      'missingProgressRowsInScope=$missingProgressCount',
      'activeSessionsForScope=$activeSessionCount',
      'lastActiveSessionId=${lastActiveSession?.id ?? '<none>'}',
      'lastActiveSessionStatus=${lastActiveSession?.status ?? '<none>'}',
      'pendingSessionItems=$pendingItemCount',
      'missingFlashcardReferences=$missingItemReferences',
    ].join('\n');
  }

  Future<int> _readInt(String sql, String columnName) async {
    final row = await _database!.customSelect(sql).getSingle();
    return row.read<int>(columnName);
  }

  Future<int> _countFlashcards(String entryType, String? entryRefId) async {
    final scope = await _scope(entryType, entryRefId);
    final database = _database!;
    final row = await database
        .customSelect(
          '''
      SELECT COUNT(f.id) AS count
      FROM flashcards f
      INNER JOIN decks d ON d.id = f.deck_id
      WHERE ${scope.whereClause}
      ''',
          variables: scope.variables,
          readsFrom: {database.flashcards, database.decks},
        )
        .getSingle();
    return row.read<int>('count');
  }

  Future<int> _countProgressRows(String entryType, String? entryRefId) async {
    final scope = await _scope(entryType, entryRefId);
    final database = _database!;
    final row = await database
        .customSelect(
          '''
      SELECT COUNT(p.flashcard_id) AS count
      FROM flashcards f
      INNER JOIN decks d ON d.id = f.deck_id
      INNER JOIN flashcard_progress p ON p.flashcard_id = f.id
      WHERE ${scope.whereClause}
      ''',
          variables: scope.variables,
          readsFrom: {
            database.flashcards,
            database.decks,
            database.flashcardProgress,
          },
        )
        .getSingle();
    return row.read<int>('count');
  }

  Future<int> _countMissingProgressRows(
    String entryType,
    String? entryRefId,
  ) async {
    final scope = await _scope(entryType, entryRefId);
    final database = _database!;
    final row = await database
        .customSelect(
          '''
      SELECT COUNT(f.id) AS count
      FROM flashcards f
      INNER JOIN decks d ON d.id = f.deck_id
      LEFT JOIN flashcard_progress p ON p.flashcard_id = f.id
      WHERE ${scope.whereClause}
        AND p.flashcard_id IS NULL
      ''',
          variables: scope.variables,
          readsFrom: {
            database.flashcards,
            database.decks,
            database.flashcardProgress,
          },
        )
        .getSingle();
    return row.read<int>('count');
  }

  Future<int> _countActiveSessions(String entryType, String? entryRefId) async {
    final database = _database!;
    final row = await database
        .customSelect(
          '''
      SELECT COUNT(id) AS count
      FROM study_sessions
      WHERE entry_type = ?
        AND ${_entryRefPredicate(entryRefId)}
        AND status IN ('draft', 'in_progress')
      ''',
          variables: _sessionScopeVariables(entryType, entryRefId),
          readsFrom: {database.studySessions},
        )
        .getSingle();
    return row.read<int>('count');
  }

  Future<_SessionDiagnostic?> _lastActiveSession(
    String entryType,
    String? entryRefId,
  ) async {
    final database = _database!;
    final row = await database
        .customSelect(
          '''
      SELECT id, status
      FROM study_sessions
      WHERE entry_type = ?
        AND ${_entryRefPredicate(entryRefId)}
        AND status IN ('draft', 'in_progress')
      ORDER BY started_at DESC
      LIMIT 1
      ''',
          variables: _sessionScopeVariables(entryType, entryRefId),
          readsFrom: {database.studySessions},
        )
        .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _SessionDiagnostic(
      id: row.read<String>('id'),
      status: row.read<String>('status'),
    );
  }

  Future<int> _countPendingItems(String sessionId) async {
    final database = _database!;
    final row = await database
        .customSelect(
          '''
      SELECT COUNT(id) AS count
      FROM study_session_items
      WHERE session_id = ?
        AND status = 'pending'
      ''',
          variables: [Variable<String>(sessionId)],
          readsFrom: {database.studySessionItems},
        )
        .getSingle();
    return row.read<int>('count');
  }

  Future<int> _countMissingItemReferences(String sessionId) async {
    final database = _database!;
    final row = await database
        .customSelect(
          '''
      SELECT COUNT(i.id) AS count
      FROM study_session_items i
      LEFT JOIN flashcards f ON f.id = i.flashcard_id
      WHERE i.session_id = ?
        AND f.id IS NULL
      ''',
          variables: [Variable<String>(sessionId)],
          readsFrom: {database.studySessionItems, database.flashcards},
        )
        .getSingle();
    return row.read<int>('count');
  }

  Future<_ScopeDiagnostic> _scope(String entryType, String? entryRefId) async {
    if (entryType == 'deck') {
      return _ScopeDiagnostic(
        whereClause: 'f.deck_id = ?',
        variables: [Variable<String>(entryRefId ?? '')],
      );
    }
    if (entryType == 'folder') {
      final ids = await _folderSubtreeIds(entryRefId);
      if (ids.isEmpty) {
        return const _ScopeDiagnostic(
          whereClause: '0 = 1',
          variables: <Variable>[],
        );
      }
      return _ScopeDiagnostic(
        whereClause: 'd.folder_id IN (${_placeholders(ids.length)})',
        variables: ids.map(Variable<String>.new).toList(growable: false),
      );
    }
    return const _ScopeDiagnostic(
      whereClause: '1 = 1',
      variables: <Variable>[],
    );
  }

  Future<List<String>> _folderSubtreeIds(String? rootId) async {
    if (rootId == null || rootId.isEmpty) {
      return const <String>[];
    }
    final database = _database!;
    final rows = await database
        .customSelect(
          '''
      WITH RECURSIVE subtree(id) AS (
        SELECT id FROM folders WHERE id = ?
        UNION ALL
        SELECT folders.id
        FROM folders
        INNER JOIN subtree ON folders.parent_id = subtree.id
      )
      SELECT id FROM subtree
      ''',
          variables: [Variable<String>(rootId)],
          readsFrom: {database.folders},
        )
        .get();
    return rows.map((row) => row.read<String>('id')).toList(growable: false);
  }

  List<Variable> _sessionScopeVariables(String entryType, String? entryRefId) =>
      entryRefId == null
      ? <Variable>[Variable<String>(entryType)]
      : <Variable>[Variable<String>(entryType), Variable<String>(entryRefId)];

  String _entryRefPredicate(String? entryRefId) =>
      entryRefId == null ? 'entry_ref_id IS NULL' : 'entry_ref_id = ?';
}

final class _ScopeDiagnostic {
  const _ScopeDiagnostic({required this.whereClause, required this.variables});

  final String whereClause;
  final List<Variable> variables;
}

final class _SessionDiagnostic {
  const _SessionDiagnostic({required this.id, required this.status});

  final String id;
  final String status;
}

String _placeholders(int count) => List<String>.filled(count, '?').join(', ');
