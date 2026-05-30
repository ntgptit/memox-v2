import 'dart:math';

import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/logging/app_logger.dart';
import '../../core/services/clock.dart';
import '../../core/services/id_generator.dart';
import '../../domain/enums/study_enums.dart';
import '../../domain/study/entities/study_models.dart';
import '../../domain/study/ports/study_repo.dart';
import '../../domain/study/result_breakdown.dart';
import '../datasources/local/app_database.dart' as local;
import '../datasources/local/daos/folder_dao.dart';
import '../datasources/local/daos/study_attempt_dao.dart';
import '../datasources/local/daos/study_session_dao.dart';
import '../datasources/local/daos/study_session_item_dao.dart';
import '../datasources/local/local_transaction_runner.dart';
import '../mappers/database_enum_codecs.dart';

part 'study_repo_impl_helpers.dart';
part 'study_repo_impl_mapping_helpers.dart';
part 'study_repo_impl_models.dart';
part 'study_repo_impl_session_helpers.dart';

final class StudyRepoImpl implements StudyRepo {
  const StudyRepoImpl({
    required local.AppDatabase database,
    required StudySessionDao studySessionDao,
    required StudySessionItemDao studySessionItemDao,
    required StudyAttemptDao studyAttemptDao,
    required FolderDao folderDao,
    required LocalTransactionRunner transactionRunner,
    required Clock clock,
    required IdGenerator idGenerator,
    required Random shuffleRandom,
    required AppLogger logger,
  }) : _database = database,
       _studySessionDao = studySessionDao,
       _studySessionItemDao = studySessionItemDao,
       _studyAttemptDao = studyAttemptDao,
       _folderDao = folderDao,
       _transactionRunner = transactionRunner,
       _clock = clock,
       _idGenerator = idGenerator,
       _shuffleRandom = shuffleRandom,
       _logger = logger;

  final local.AppDatabase _database;
  final StudySessionDao _studySessionDao;
  final StudySessionItemDao _studySessionItemDao;
  final StudyAttemptDao _studyAttemptDao;
  final FolderDao _folderDao;
  final LocalTransactionRunner _transactionRunner;
  final Clock _clock;
  final IdGenerator _idGenerator;
  final Random _shuffleRandom;
  final AppLogger _logger;

  @override
  Future<int> countFlashcardsInDeck(String deckId) async {
    final countExpr = _database.flashcards.id.count();
    final query = _database.selectOnly(_database.flashcards)
      ..addColumns([countExpr])
      ..where(_database.flashcards.deckId.equals(deckId));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  @override
  Future<int> countFlashcardsInScope(StudyContext context) =>
      _countFlashcardsInScope(context);

  @override
  Future<int> countDueCardsInScope(StudyContext context) =>
      _countDueCardsInScope(
        context,
        endOfTodayEpochMillis: _endOfTodayEpochMillis(),
      );

  @override
  Future<DateTime?> nextDueAt(StudyContext context) =>
      _nextDueAt(context, endOfTodayEpochMillis: _endOfTodayEpochMillis());

  @override
  Future<void> setBuried({
    required String flashcardId,
    required bool buried,
  }) async {
    final now = _clock.nowEpochMillis();
    await (_database.update(
      _database.flashcardProgress,
    )..where((table) => table.flashcardId.equals(flashcardId))).write(
      local.FlashcardProgressCompanion(
        buriedUntil: Value(buried ? _nextLocalMidnightEpochMillis() : null),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<void> setSuspended({
    required String flashcardId,
    required bool suspended,
  }) async {
    final now = _clock.nowEpochMillis();
    await (_database.update(
      _database.flashcardProgress,
    )..where((table) => table.flashcardId.equals(flashcardId))).write(
      local.FlashcardProgressCompanion(
        isSuspended: Value(suspended),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<int> countSuspendedInScope(StudyContext context) =>
      _countSuspendedInScope(context);

  @override
  Future<int> countActiveBuriedInScope(StudyContext context) =>
      _countActiveBuriedInScope(
        context,
        nowEpochMillis: _clock.nowEpochMillis(),
      );

  @override
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) async {
    final rows = await _eligibleFlashcards(
      context: context,
      whereProgress: 'p.due_at IS NULL',
      dueOnly: false,
    );
    final cards = rows
        .map(
          (row) => _flashcardRefFromRow(
            row,
            sourcePool: SessionItemSourcePool.newCards,
          ),
        )
        .toList(growable: true);
    _applyShuffle(cards, context);
    return cards.take(context.settings.batchSize).toList(growable: false);
  }

  @override
  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context) async {
    final startOfToday = _startOfTodayEpochMillis();
    final endOfToday = _endOfTodayEpochMillis();
    final rows = await _eligibleFlashcards(
      context: context,
      whereProgress: 'p.due_at IS NOT NULL AND p.due_at <= ?',
      dueOnly: true,
      extraVariables: [Variable<int>(endOfToday)],
    );
    final cards = rows
        .map((row) {
          final dueAt = row.read<int>('due_at');
          return _flashcardRefFromRow(
            row,
            sourcePool: dueAt < startOfToday
                ? SessionItemSourcePool.overdue
                : SessionItemSourcePool.due,
          );
        })
        .toList(growable: true);
    if (context.settings.prioritizeOverdue) {
      cards.sort((left, right) {
        final leftRank = left.sourcePool == SessionItemSourcePool.overdue
            ? 0
            : 1;
        final rightRank = right.sourcePool == SessionItemSourcePool.overdue
            ? 0
            : 1;
        return leftRank.compareTo(rightRank);
      });
    }
    _applyShuffle(cards, context, preserveOverduePriority: true);
    return cards.take(context.settings.batchSize).toList(growable: false);
  }

  @override
  Future<StudySessionSnapshot?> findResumeCandidate(
    StudyContext context,
  ) async {
    final row = await _studySessionDao.findResumeCandidate(
      entryType: context.entryType.storageValue,
      entryRefId: context.entryRefId,
    );
    if (row == null) {
      return null;
    }
    return _loadSnapshot(row.id);
  }

  @override
  Future<List<StudySessionSnapshot>> listActiveSessions() async {
    final sessions = await _studySessionDao.listActiveSessions();
    final snapshots = <StudySessionSnapshot>[];
    for (final session in sessions) {
      snapshots.add(await _loadSnapshot(session.id));
    }
    return snapshots;
  }

  @override
  Future<StudySessionSnapshot> startSession({
    required StudyContext context,
    required StudyFlow flow,
    required List<StudyMode> modes,
    required List<StudyFlashcardRef> batch,
  }) async {
    final sessionId = _idGenerator.nextId();
    final now = _clock.nowEpochMillis();
    await _transactionRunner.write((_) async {
      final restartedFrom = context.restartedFromSessionId;
      if (restartedFrom != null) {
        await _studySessionItemDao.abandonPending(restartedFrom);
        await _studySessionDao.updateStatus(
          sessionId: restartedFrom,
          status: SessionStatus.cancelled.storageValue,
          endedAt: now,
        );
      }

      await _studySessionDao.insertSession(
        local.StudySessionsCompanion.insert(
          id: sessionId,
          entryType: context.entryType.storageValue,
          entryRefId: Value(context.entryRefId),
          studyType: context.studyType.storageValue,
          studyFlow: flow.storageValue,
          batchSize: context.settings.batchSize,
          shuffleFlashcards: context.settings.shuffleFlashcards ? 1 : 0,
          shuffleAnswers: context.settings.shuffleAnswers ? 1 : 0,
          prioritizeOverdue: context.settings.prioritizeOverdue ? 1 : 0,
          status: SessionStatus.inProgress.storageValue,
          startedAt: now,
          restartedFromSessionId: Value(restartedFrom),
        ),
      );
      await _insertQueue(
        sessionId: sessionId,
        cards: batch,
        mode: modes.first,
        modeOrder: 1,
        roundIndex: 1,
        sourcePoolOverride: null,
      );
    });
    return _loadSnapshot(sessionId);
  }

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) =>
      _loadSnapshot(sessionId);

  @override
  Future<StudySessionSnapshot> answerCurrentItem({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) async {
    await _transactionRunner.write((_) async {
      final session = await _requireSession(sessionId);
      _requireStatus(session, const <SessionStatus>[SessionStatus.inProgress]);
      final item = await _requireCurrentItem(sessionId);
      final now = _clock.nowEpochMillis();
      final attemptNumber = await _studyAttemptDao.nextAttemptNumber(
        sessionId: sessionId,
        flashcardId: item.flashcardId,
      );
      await _studyAttemptDao.insertAttempt(
        local.StudyAttemptsCompanion.insert(
          id: _idGenerator.nextId(),
          sessionId: sessionId,
          sessionItemId: item.id,
          flashcardId: item.flashcardId,
          attemptNumber: attemptNumber,
          result: grade.storageValue,
          answeredAt: now,
        ),
      );
      await _studySessionItemDao.completeItem(
        itemId: item.id,
        completedAt: now,
      );

      final hasPendingInRound = await _studySessionItemDao
          .hasPendingInModeRound(
            sessionId: sessionId,
            modeOrder: item.modeOrder,
            roundIndex: item.roundIndex,
          );
      if (hasPendingInRound) {
        return;
      }

      final failedCards = await _failedCardsInRound(
        sessionId: sessionId,
        modeOrder: item.modeOrder,
        roundIndex: item.roundIndex,
      );
      if (failedCards.isNotEmpty) {
        await _insertQueue(
          sessionId: sessionId,
          cards: failedCards,
          mode: DatabaseEnumCodecs.studyModeFromStorage(item.studyMode),
          modeOrder: item.modeOrder,
          roundIndex: item.roundIndex + 1,
          sourcePoolOverride: SessionItemSourcePool.retry,
        );
        return;
      }

      if (item.modeOrder < modes.length) {
        final nextModeOrder = item.modeOrder + 1;
        final batch = await _originalBatchFlashcards(sessionId);
        await _insertQueue(
          sessionId: sessionId,
          cards: batch,
          mode: modes[nextModeOrder - 1],
          modeOrder: nextModeOrder,
          roundIndex: 1,
          sourcePoolOverride: null,
        );
        return;
      }

      await _studySessionDao.updateStatus(
        sessionId: sessionId,
        status: SessionStatus.readyToFinalize.storageValue,
        endedAt: now,
      );
    });
    return _loadSnapshot(sessionId);
  }

  @override
  Future<StudySessionSnapshot> answerCurrentModeItemGradesBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
    required List<StudyMode> modes,
  }) async {
    await _transactionRunner.write((_) async {
      final session = await _requireSession(sessionId);
      _requireStatus(session, const <SessionStatus>[SessionStatus.inProgress]);
      final currentItem = await _requireCurrentItem(sessionId);
      final currentMode = DatabaseEnumCodecs.studyModeFromStorage(
        currentItem.studyMode,
      );
      final items = await _studySessionItemDao.listModeRoundItems(
        sessionId: sessionId,
        modeOrder: currentItem.modeOrder,
        roundIndex: currentItem.roundIndex,
      );
      final pendingItems = items
          .where(
            (item) => item.status == SessionItemStatus.pending.storageValue,
          )
          .toList(growable: false);
      if (pendingItems.isEmpty) {
        throw const ValidationException(message: 'No pending study item.');
      }

      final pendingItemIds = pendingItems.map((item) => item.id).toSet();
      final submittedItemIds = itemGrades.keys.toSet();
      if (pendingItemIds.length != submittedItemIds.length ||
          !pendingItemIds.containsAll(submittedItemIds)) {
        throw const ValidationException(
          message: 'Mode batch must include every pending item exactly once.',
        );
      }

      const acceptedGrades = <AttemptGrade>{
        AttemptGrade.correct,
        AttemptGrade.recovered,
        AttemptGrade.incorrect,
      };
      if (itemGrades.values.any((grade) => !acceptedGrades.contains(grade))) {
        throw ValidationException(
          message:
              'Mode batch only accepts ${_acceptedBatchGradeLabel(acceptedGrades)} grades.',
        );
      }

      final now = _clock.nowEpochMillis();
      final failedCards = <StudyFlashcardRef>[];
      for (final item in pendingItems) {
        final grade = itemGrades[item.id]!;
        final attemptNumber = await _studyAttemptDao.nextAttemptNumber(
          sessionId: sessionId,
          flashcardId: item.flashcardId,
        );
        await _studyAttemptDao.insertAttempt(
          local.StudyAttemptsCompanion.insert(
            id: _idGenerator.nextId(),
            sessionId: sessionId,
            sessionItemId: item.id,
            flashcardId: item.flashcardId,
            attemptNumber: attemptNumber,
            result: grade.storageValue,
            answeredAt: now,
          ),
        );
        await _studySessionItemDao.completeItem(
          itemId: item.id,
          completedAt: now,
        );
        if (grade.isFailing) {
          failedCards.add(await _flashcardRefForItem(item));
        }
      }

      if (failedCards.isNotEmpty) {
        await _insertQueue(
          sessionId: sessionId,
          cards: failedCards,
          mode: currentMode,
          modeOrder: currentItem.modeOrder,
          roundIndex: currentItem.roundIndex + 1,
          sourcePoolOverride: SessionItemSourcePool.retry,
        );
        return;
      }

      if (currentItem.modeOrder < modes.length) {
        final nextModeOrder = currentItem.modeOrder + 1;
        final batch = await _originalBatchFlashcards(sessionId);
        await _insertQueue(
          sessionId: sessionId,
          cards: batch,
          mode: modes[nextModeOrder - 1],
          modeOrder: nextModeOrder,
          roundIndex: 1,
          sourcePoolOverride: null,
        );
        return;
      }

      await _studySessionDao.updateStatus(
        sessionId: sessionId,
        status: SessionStatus.readyToFinalize.storageValue,
        endedAt: now,
      );
    });
    return _loadSnapshot(sessionId);
  }

  String _acceptedBatchGradeLabel(Set<AttemptGrade> grades) =>
      grades.map((grade) => grade.storageValue).join(' or ');

  @override
  Future<StudySessionSnapshot> skipCurrentItem(String sessionId) async {
    await _transactionRunner.write((_) async {
      final item = await _requireCurrentItem(sessionId);
      final nextPosition = await _studySessionItemDao.maxQueuePosition(
        sessionId: sessionId,
        modeOrder: item.modeOrder,
        roundIndex: item.roundIndex,
      );
      await _studySessionItemDao.requeuePendingItem(
        itemId: item.id,
        queuePosition: nextPosition + 1,
      );
    });
    return _loadSnapshot(sessionId);
  }

  @override
  Future<StudySessionSnapshot> dropCurrentItemFromSession({
    required String sessionId,
    required List<StudyMode> modes,
  }) => _dropCurrentItemFromSession(sessionId: sessionId, modes: modes);

  @override
  Future<StudySessionSnapshot> cancelSession(String sessionId) async {
    final session = await _requireSession(sessionId);
    _requireCancellable(session);
    final now = _clock.nowEpochMillis();
    await _transactionRunner.write((_) async {
      final currentSession = await _requireSession(sessionId);
      _requireCancellable(currentSession);
      await _studySessionItemDao.abandonPending(sessionId);
      await _studySessionDao.updateStatus(
        sessionId: sessionId,
        status: SessionStatus.cancelled.storageValue,
        endedAt: now,
      );
    });
    return _loadSnapshot(sessionId);
  }

  @override
  Future<StudySessionSnapshot> finalizeSession({
    required String sessionId,
    required StudyType studyType,
    required StudyFinalizePolicy finalizePolicy,
  }) async {
    final session = await _requireSession(sessionId);
    _requireReadyToFinalize(session);
    _requireMatchingStudyType(session, studyType);

    try {
      await _transactionRunner.write((_) async {
        final currentSession = await _requireSession(sessionId);
        _requireReadyToFinalize(currentSession);
        _requireMatchingStudyType(currentSession, studyType);
        await _commitSrs(sessionId: sessionId, finalizePolicy: finalizePolicy);
        await _studySessionDao.updateStatus(
          sessionId: sessionId,
          status: SessionStatus.completed.storageValue,
          endedAt: _clock.nowEpochMillis(),
        );
      });
    } on ValidationException {
      rethrow;
    } on NotFoundException {
      rethrow;
    } catch (error, stackTrace) {
      _logger.error('Failed to finalize study session.', error, stackTrace);
      await _markFailedToFinalize(sessionId);
    }
    return _loadSnapshot(sessionId);
  }

  @override
  Future<StudySessionSnapshot> retryFinalize({
    required String sessionId,
    required StudyType studyType,
    required StudyFinalizePolicy finalizePolicy,
  }) => finalizeSession(
    sessionId: sessionId,
    studyType: studyType,
    finalizePolicy: finalizePolicy,
  );
}
