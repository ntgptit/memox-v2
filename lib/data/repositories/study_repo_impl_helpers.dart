part of 'study_repo_impl.dart';

extension _StudyRepoImplQueryHelpers on StudyRepoImpl {
  Future<List<QueryRow>> _eligibleFlashcards({
    required StudyContext context,
    required String whereProgress,
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
      INNER JOIN flashcard_progress p ON p.flashcard_id = f.id
      WHERE ${scope.whereClause}
        AND $whereProgress
      $orderBy
      ''',
          variables: <Variable>[...scope.variables, ...extraVariables],
          readsFrom: {
            _database.flashcards,
            _database.decks,
            _database.flashcardProgress,
          },
        )
        .get();
    return rows;
  }

  Future<_SqlScope> _scopeSql(StudyContext context) async =>
      switch (context.entryType) {
        StudyEntryType.deck => _SqlScope(
          whereClause: 'f.deck_id = ?',
          variables: [Variable<String>(_requireEntryRef(context))],
        ),
        StudyEntryType.folder => await _folderScopeSql(
          _requireEntryRef(context),
        ),
        StudyEntryType.today => const _SqlScope(
          whereClause: '1 = 1',
          variables: <Variable>[],
        ),
      };

  Future<_SqlScope> _folderScopeSql(String folderId) async {
    final subtreeIds = await _folderDao.getSubtreeIds(folderId);
    if (subtreeIds.isEmpty) {
      return const _SqlScope(whereClause: '0 = 1', variables: <Variable>[]);
    }
    return _SqlScope(
      whereClause:
          'd.folder_id IN (${_studyRepoPlaceholders(subtreeIds.length)})',
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
    required StudyFinalizePolicy finalizePolicy,
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
      final outcome = switch (finalizePolicy) {
        // New Study means the card passed every required learning mode.
        // Retry history remains in study_attempts; initial SRS placement is deterministic.
        StudyFinalizePolicy.newStudy => _SrsOutcome(
          result: ReviewResult.initialPassed,
          oldBox: oldBox,
          newBox: 2,
          nextDueAt: now + const Duration(days: 1).inMilliseconds,
          lapseDelta: 0,
        ),
        StudyFinalizePolicy.srsReview => _reviewOutcome(
          oldBox: oldBox,
          attempts: cardAttempts,
          now: now,
        ),
      };
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

  Future<local.FlashcardProgressData?> _findProgress(String flashcardId) =>
      (_database.select(_database.flashcardProgress)
            ..where((table) => table.flashcardId.equals(flashcardId)))
          .getSingleOrNull();

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
}
