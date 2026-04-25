import 'dart:math';

import 'package:drift/drift.dart';

import '../../core/errors/app_exception.dart';
import '../../core/services/clock.dart';
import '../../core/services/id_generator.dart';
import '../../domain/enums/study_enums.dart';
import '../../domain/study/entities/study_models.dart';
import '../../domain/study/ports/study_repo.dart';
import '../datasources/local/app_database.dart' as local;
import '../datasources/local/daos/folder_dao.dart';
import '../datasources/local/daos/study_attempt_dao.dart';
import '../datasources/local/daos/study_session_dao.dart';
import '../datasources/local/daos/study_session_item_dao.dart';
import '../datasources/local/local_transaction_runner.dart';
import '../mappers/database_enum_codecs.dart';

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
  }) : _database = database,
       _studySessionDao = studySessionDao,
       _studySessionItemDao = studySessionItemDao,
       _studyAttemptDao = studyAttemptDao,
       _folderDao = folderDao,
       _transactionRunner = transactionRunner,
       _clock = clock,
       _idGenerator = idGenerator;

  final local.AppDatabase _database;
  final StudySessionDao _studySessionDao;
  final StudySessionItemDao _studySessionItemDao;
  final StudyAttemptDao _studyAttemptDao;
  final FolderDao _folderDao;
  final LocalTransactionRunner _transactionRunner;
  final Clock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) async {
    final rows = await _eligibleFlashcards(
      context: context,
      whereProgress: '(p.flashcard_id IS NULL OR p.due_at IS NULL)',
      readsProgress: true,
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
      readsProgress: true,
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
  Future<StudySessionSnapshot> loadSession(String sessionId) {
    return _loadSnapshot(sessionId);
  }

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
  Future<StudySessionSnapshot> answerCurrentModeBatch({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) async {
    await _transactionRunner.write((_) async {
      final session = await _requireSession(sessionId);
      _requireStatus(session, const <SessionStatus>[SessionStatus.inProgress]);
      final currentItem = await _requireCurrentItem(sessionId);
      final currentMode = DatabaseEnumCodecs.studyModeFromStorage(
        currentItem.studyMode,
      );
      if (currentMode != StudyMode.review) {
        throw const ValidationException(
          message: 'Batch mode answer is only available for Review mode.',
        );
      }

      final now = _clock.nowEpochMillis();
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

      for (final item in pendingItems) {
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
  }) async {
    final session = await _requireSession(sessionId);
    _requireReadyToFinalize(session);
    _requireMatchingStudyType(session, studyType);

    try {
      await _transactionRunner.write((_) async {
        final currentSession = await _requireSession(sessionId);
        _requireReadyToFinalize(currentSession);
        _requireMatchingStudyType(currentSession, studyType);
        await _commitSrs(sessionId: sessionId, studyType: studyType);
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
      Object.hash(error, stackTrace);
      await _markFailedToFinalize(sessionId);
    }
    return _loadSnapshot(sessionId);
  }

  @override
  Future<StudySessionSnapshot> retryFinalize({
    required String sessionId,
    required StudyType studyType,
  }) {
    return finalizeSession(sessionId: sessionId, studyType: studyType);
  }

  Future<List<QueryRow>> _eligibleFlashcards({
    required StudyContext context,
    required String whereProgress,
    required bool readsProgress,
    required bool dueOnly,
    List<Variable> extraVariables = const <Variable>[],
  }) async {
    final scope = await _scopeSql(context);
    final orderBy = dueOnly
        ? 'ORDER BY p.due_at ASC, f.sort_order ASC'
        : 'ORDER BY f.sort_order ASC';
    final rows = await _database
        .customSelect(
          '''
      SELECT f.id, f.deck_id, f.front, f.back, p.due_at
      FROM flashcards f
      INNER JOIN decks d ON d.id = f.deck_id
      LEFT JOIN flashcard_progress p ON p.flashcard_id = f.id
      WHERE ${scope.whereClause}
        AND $whereProgress
      $orderBy
      ''',
          variables: <Variable>[...scope.variables, ...extraVariables],
          readsFrom: {
            _database.flashcards,
            _database.decks,
            if (readsProgress) _database.flashcardProgress,
          },
        )
        .get();
    return rows;
  }

  Future<_SqlScope> _scopeSql(StudyContext context) async {
    return switch (context.entryType) {
      StudyEntryType.deck => _SqlScope(
        whereClause: 'f.deck_id = ?',
        variables: [Variable<String>(_requireEntryRef(context))],
      ),
      StudyEntryType.folder => await _folderScopeSql(_requireEntryRef(context)),
      StudyEntryType.today => const _SqlScope(
        whereClause: '1 = 1',
        variables: <Variable>[],
      ),
    };
  }

  Future<_SqlScope> _folderScopeSql(String folderId) async {
    final subtreeIds = await _folderDao.getSubtreeIds(folderId);
    if (subtreeIds.isEmpty) {
      return const _SqlScope(whereClause: '0 = 1', variables: <Variable>[]);
    }
    return _SqlScope(
      whereClause: 'd.folder_id IN (${_placeholders(subtreeIds.length)})',
      variables: subtreeIds.map(Variable<String>.new).toList(growable: false),
    );
  }

  Future<void> _insertQueue({
    required String sessionId,
    required List<StudyFlashcardRef> cards,
    required StudyMode mode,
    required int modeOrder,
    required int roundIndex,
    required SessionItemSourcePool? sourcePoolOverride,
  }) async {
    final items = <local.StudySessionItemsCompanion>[];
    for (var index = 0; index < cards.length; index++) {
      final card = cards[index];
      items.add(
        local.StudySessionItemsCompanion.insert(
          id: _idGenerator.nextId(),
          sessionId: sessionId,
          flashcardId: card.id,
          studyMode: mode.storageValue,
          modeOrder: modeOrder,
          roundIndex: roundIndex,
          queuePosition: index + 1,
          sourcePool: (sourcePoolOverride ?? card.sourcePool).storageValue,
          status: SessionItemStatus.pending.storageValue,
        ),
      );
    }
    await _studySessionItemDao.insertItems(items);
  }

  Future<List<StudyFlashcardRef>> _failedCardsInRound({
    required String sessionId,
    required int modeOrder,
    required int roundIndex,
  }) async {
    final items = await _studySessionItemDao.listModeRoundItems(
      sessionId: sessionId,
      modeOrder: modeOrder,
      roundIndex: roundIndex,
    );
    final attempts = await _studyAttemptDao.listAttemptsForItems(
      items.map((item) => item.id).toList(growable: false),
    );
    final attemptsByItem = <String, local.StudyAttempt>{
      for (final attempt in attempts) attempt.sessionItemId: attempt,
    };
    final failed = <StudyFlashcardRef>[];
    for (final item in items) {
      final attempt = attemptsByItem[item.id];
      if (attempt == null) {
        continue;
      }
      final grade = DatabaseEnumCodecs.attemptGradeFromStorage(attempt.result);
      if (grade.isFailing) {
        failed.add(await _flashcardRefForItem(item));
      }
    }
    return failed;
  }

  Future<List<StudyFlashcardRef>> _originalBatchFlashcards(
    String sessionId,
  ) async {
    final items = await _studySessionItemDao.listOriginalBatchItems(sessionId);
    final cards = <StudyFlashcardRef>[];
    for (final item in items) {
      cards.add(await _flashcardRefForItem(item));
    }
    return cards;
  }

  Future<void> _commitSrs({
    required String sessionId,
    required StudyType studyType,
  }) async {
    final batch = await _originalBatchFlashcards(sessionId);
    final attempts = await _studyAttemptDao.listAttempts(sessionId);
    final attemptsByCard = <String, List<local.StudyAttempt>>{};
    for (final attempt in attempts) {
      attemptsByCard
          .putIfAbsent(attempt.flashcardId, () => <local.StudyAttempt>[])
          .add(attempt);
    }
    final now = _clock.nowEpochMillis();
    for (final card in batch) {
      final progress = await _findProgress(card.id);
      final oldBox = progress?.currentBox ?? 1;
      final cardAttempts =
          attemptsByCard[card.id] ?? const <local.StudyAttempt>[];
      final outcome = studyType == StudyType.newStudy
          ? _SrsOutcome(
              result: ReviewResult.perfect,
              oldBox: oldBox,
              newBox: 2,
              nextDueAt: now + const Duration(days: 1).inMilliseconds,
              lapseDelta: 0,
            )
          : _reviewOutcome(oldBox: oldBox, attempts: cardAttempts, now: now);
      await _upsertProgress(
        flashcardId: card.id,
        outcome: outcome,
        now: now,
        existing: progress,
      );
      for (final attempt in cardAttempts) {
        await _studyAttemptDao.updateAttemptSrsSummary(
          attemptId: attempt.id,
          oldBox: outcome.oldBox,
          newBox: outcome.newBox,
          nextDueAt: outcome.nextDueAt,
        );
      }
    }
  }

  _SrsOutcome _reviewOutcome({
    required int oldBox,
    required List<local.StudyAttempt> attempts,
    required int now,
  }) {
    final grades = attempts
        .map(
          (attempt) =>
              DatabaseEnumCodecs.attemptGradeFromStorage(attempt.result),
        )
        .toList(growable: false);
    if (grades.contains(AttemptGrade.forgot)) {
      return _SrsOutcome(
        result: ReviewResult.forgot,
        oldBox: oldBox,
        newBox: 1,
        nextDueAt: now + _intervalForBox(1).inMilliseconds,
        lapseDelta: 1,
      );
    }
    if (grades.any((grade) => grade.isFailing)) {
      final newBox = max(1, oldBox - 1);
      return _SrsOutcome(
        result: ReviewResult.recovered,
        oldBox: oldBox,
        newBox: newBox,
        nextDueAt: now + _intervalForBox(newBox).inMilliseconds,
        lapseDelta: 1,
      );
    }
    final newBox = min(8, oldBox + 1);
    return _SrsOutcome(
      result: ReviewResult.perfect,
      oldBox: oldBox,
      newBox: newBox,
      nextDueAt: now + _intervalForBox(newBox).inMilliseconds,
      lapseDelta: 0,
    );
  }

  Future<local.FlashcardProgressData?> _findProgress(String flashcardId) {
    return (_database.select(_database.flashcardProgress)
          ..where((table) => table.flashcardId.equals(flashcardId)))
        .getSingleOrNull();
  }

  Future<void> _upsertProgress({
    required String flashcardId,
    required _SrsOutcome outcome,
    required int now,
    required local.FlashcardProgressData? existing,
  }) async {
    if (existing == null) {
      await _database
          .into(_database.flashcardProgress)
          .insert(
            local.FlashcardProgressCompanion.insert(
              flashcardId: flashcardId,
              currentBox: outcome.newBox,
              reviewCount: 1,
              lapseCount: outcome.lapseDelta,
              lastResult: Value(outcome.result.storageValue),
              lastStudiedAt: Value(now),
              dueAt: Value(outcome.nextDueAt),
              createdAt: now,
              updatedAt: now,
            ),
          );
      return;
    }

    await (_database.update(
      _database.flashcardProgress,
    )..where((table) => table.flashcardId.equals(flashcardId))).write(
      local.FlashcardProgressCompanion(
        currentBox: Value(outcome.newBox),
        reviewCount: Value(existing.reviewCount + 1),
        lapseCount: Value(existing.lapseCount + outcome.lapseDelta),
        lastResult: Value(outcome.result.storageValue),
        lastStudiedAt: Value(now),
        dueAt: Value(outcome.nextDueAt),
        updatedAt: Value(now),
      ),
    );
  }

  Future<StudySessionSnapshot> _loadSnapshot(String sessionId) async {
    final session = await _requireSession(sessionId);
    final currentItem = await _studySessionItemDao.findCurrentPending(
      sessionId,
    );
    final attempts = await _studyAttemptDao.listAttempts(sessionId);
    final items = await _studySessionItemDao.listItems(sessionId);
    final flashcards = await _originalBatchFlashcards(sessionId);
    return StudySessionSnapshot(
      session: _mapSession(session),
      currentItem: currentItem == null ? null : await _mapItem(currentItem),
      sessionFlashcards: flashcards,
      summary: _summary(items: items, attempts: attempts),
      canFinalize:
          session.status == SessionStatus.readyToFinalize.storageValue ||
          session.status == SessionStatus.failedToFinalize.storageValue,
    );
  }

  StudySummary _summary({
    required List<local.StudySessionItem> items,
    required List<local.StudyAttempt> attempts,
  }) {
    final originalCards = items
        .where((item) => item.modeOrder == 1 && item.roundIndex == 1)
        .map((item) => item.flashcardId)
        .toSet();
    final pending = items.where((item) => item.status == 'pending').length;
    final correct = attempts
        .where(
          (attempt) => DatabaseEnumCodecs.attemptGradeFromStorage(
            attempt.result,
          ).isPassing,
        )
        .length;
    final boxDeltas = <String, int>{};
    for (final attempt in attempts) {
      final oldBox = attempt.oldBox;
      final newBox = attempt.newBox;
      if (oldBox == null || newBox == null) {
        continue;
      }
      boxDeltas[attempt.flashcardId] = newBox.compareTo(oldBox);
    }
    return StudySummary(
      totalCards: originalCards.length,
      completedAttempts: attempts.length,
      correctAttempts: correct,
      incorrectAttempts: attempts.length - correct,
      increasedBoxCount: boxDeltas.values.where((delta) => delta > 0).length,
      decreasedBoxCount: boxDeltas.values.where((delta) => delta < 0).length,
      remainingCount: pending,
    );
  }

  StudySession _mapSession(local.StudySession row) {
    return StudySession(
      id: row.id,
      entryType: DatabaseEnumCodecs.studyEntryTypeFromStorage(row.entryType),
      entryRefId: row.entryRefId,
      studyType: DatabaseEnumCodecs.studyTypeFromStorage(row.studyType),
      studyFlow: DatabaseEnumCodecs.studyFlowFromStorage(row.studyFlow),
      settings: StudySettingsSnapshot(
        batchSize: row.batchSize,
        shuffleFlashcards: row.shuffleFlashcards == 1,
        shuffleAnswers: row.shuffleAnswers == 1,
        prioritizeOverdue: row.prioritizeOverdue == 1,
      ),
      status: DatabaseEnumCodecs.sessionStatusFromStorage(row.status),
      startedAt: row.startedAt,
      endedAt: row.endedAt,
      restartedFromSessionId: row.restartedFromSessionId,
    );
  }

  Future<StudySessionItem> _mapItem(local.StudySessionItem row) async {
    return StudySessionItem(
      id: row.id,
      sessionId: row.sessionId,
      flashcard: await _flashcardRefForItem(row),
      studyMode: DatabaseEnumCodecs.studyModeFromStorage(row.studyMode),
      modeOrder: row.modeOrder,
      roundIndex: row.roundIndex,
      queuePosition: row.queuePosition,
      sourcePool: DatabaseEnumCodecs.sessionItemSourcePoolFromStorage(
        row.sourcePool,
      ),
      status: DatabaseEnumCodecs.sessionItemStatusFromStorage(row.status),
      completedAt: row.completedAt,
    );
  }

  Future<StudyFlashcardRef> _flashcardRefForItem(
    local.StudySessionItem item,
  ) async {
    final flashcard = await (_database.select(
      _database.flashcards,
    )..where((table) => table.id.equals(item.flashcardId))).getSingle();
    return StudyFlashcardRef(
      id: flashcard.id,
      deckId: flashcard.deckId,
      front: flashcard.front,
      back: flashcard.back,
      sourcePool: DatabaseEnumCodecs.sessionItemSourcePoolFromStorage(
        item.sourcePool,
      ),
    );
  }

  StudyFlashcardRef _flashcardRefFromRow(
    QueryRow row, {
    required SessionItemSourcePool sourcePool,
  }) {
    return StudyFlashcardRef(
      id: row.read<String>('id'),
      deckId: row.read<String>('deck_id'),
      front: row.read<String>('front'),
      back: row.read<String>('back'),
      sourcePool: sourcePool,
    );
  }

  Future<local.StudySession> _requireSession(String sessionId) async {
    final session = await _studySessionDao.findById(sessionId);
    if (session == null) {
      throw const NotFoundException(message: 'Study session not found.');
    }
    return session;
  }

  Future<local.StudySessionItem> _requireCurrentItem(String sessionId) async {
    final item = await _studySessionItemDao.findCurrentPending(sessionId);
    if (item == null) {
      throw const ValidationException(message: 'No pending study item.');
    }
    return item;
  }

  void _requireStatus(
    local.StudySession session,
    List<SessionStatus> allowedStatuses,
  ) {
    final status = DatabaseEnumCodecs.sessionStatusFromStorage(session.status);
    if (!allowedStatuses.contains(status)) {
      throw ValidationException(
        message: 'Session status ${status.name} is not allowed here.',
      );
    }
  }

  void _requireReadyToFinalize(local.StudySession session) {
    _requireStatus(session, const <SessionStatus>[
      SessionStatus.readyToFinalize,
      SessionStatus.failedToFinalize,
    ]);
  }

  void _requireCancellable(local.StudySession session) {
    final status = DatabaseEnumCodecs.sessionStatusFromStorage(session.status);
    if (status == SessionStatus.completed ||
        status == SessionStatus.cancelled) {
      throw ValidationException(
        message: 'Cannot cancel a terminal study session.',
      );
    }
  }

  void _requireMatchingStudyType(
    local.StudySession session,
    StudyType studyType,
  ) {
    if (session.studyType == studyType.storageValue) {
      return;
    }
    throw const ValidationException(
      message: 'Study type does not match the session.',
    );
  }

  Future<void> _markFailedToFinalize(String sessionId) async {
    final session = await _studySessionDao.findById(sessionId);
    if (session == null) {
      return;
    }
    final status = DatabaseEnumCodecs.sessionStatusFromStorage(session.status);
    if (status != SessionStatus.readyToFinalize &&
        status != SessionStatus.failedToFinalize) {
      return;
    }
    await _studySessionDao.updateStatus(
      sessionId: sessionId,
      status: SessionStatus.failedToFinalize.storageValue,
      endedAt: _clock.nowEpochMillis(),
    );
  }

  void _applyShuffle(
    List<StudyFlashcardRef> cards,
    StudyContext context, {
    bool preserveOverduePriority = false,
  }) {
    if (!context.settings.shuffleFlashcards || cards.length < 2) {
      return;
    }
    final random = Random(
      _stableSeed(
        '${context.entryType.storageValue}:${context.entryRefId}:${context.studyType.storageValue}',
      ),
    );
    if (!preserveOverduePriority || !context.settings.prioritizeOverdue) {
      cards.shuffle(random);
      return;
    }
    final overdue =
        cards
            .where((card) => card.sourcePool == SessionItemSourcePool.overdue)
            .toList(growable: true)
          ..shuffle(random);
    final due =
        cards
            .where((card) => card.sourcePool != SessionItemSourcePool.overdue)
            .toList(growable: true)
          ..shuffle(random);
    cards
      ..clear()
      ..addAll(overdue)
      ..addAll(due);
  }

  int _stableSeed(String raw) {
    var hash = 0;
    for (final codeUnit in raw.codeUnits) {
      hash = 0x1fffffff & (hash + codeUnit);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    return hash;
  }

  int _startOfTodayEpochMillis() {
    final localNow = _clock.nowUtc().toLocal();
    return DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
    ).toUtc().millisecondsSinceEpoch;
  }

  int _endOfTodayEpochMillis() {
    final localNow = _clock.nowUtc().toLocal();
    return DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
      23,
      59,
      59,
      999,
    ).toUtc().millisecondsSinceEpoch;
  }

  Duration _intervalForBox(int box) {
    return switch (box) {
      1 => Duration.zero,
      2 => const Duration(days: 1),
      3 => const Duration(days: 3),
      4 => const Duration(days: 7),
      5 => const Duration(days: 14),
      6 => const Duration(days: 30),
      7 => const Duration(days: 60),
      8 => const Duration(days: 120),
      _ => throw ValidationException(message: 'Unsupported SRS box: $box.'),
    };
  }

  String _requireEntryRef(StudyContext context) {
    final refId = context.entryRefId;
    if (refId == null || refId.isEmpty) {
      throw const ValidationException(
        message: 'Study entry reference is required.',
      );
    }
    return refId;
  }

  static String _placeholders(int count) {
    return List<String>.filled(count, '?').join(', ');
  }
}

final class _SqlScope {
  const _SqlScope({required this.whereClause, required this.variables});

  final String whereClause;
  final List<Variable> variables;
}

final class _SrsOutcome {
  const _SrsOutcome({
    required this.result,
    required this.oldBox,
    required this.newBox,
    required this.nextDueAt,
    required this.lapseDelta,
  });

  final ReviewResult result;
  final int oldBox;
  final int newBox;
  final int nextDueAt;
  final int lapseDelta;
}
