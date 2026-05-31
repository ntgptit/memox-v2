part of 'study_repo_impl.dart';

extension _StudyRepoImplMappingHelpers on StudyRepoImpl {
  Future<StudySessionSnapshot> _loadSnapshot(String sessionId) async {
    final session = await _requireSession(sessionId);
    final currentItem = await _studySessionItemDao.findCurrentPending(
      sessionId,
    );
    final currentRoundItems = currentItem == null
        ? const <local.StudySessionItem>[]
        : await _studySessionItemDao.listModeRoundItems(
            sessionId: sessionId,
            modeOrder: currentItem.modeOrder,
            roundIndex: currentItem.roundIndex,
          );
    final attempts = await _studyAttemptDao.listAttempts(sessionId);
    final items = await _studySessionItemDao.listItems(sessionId);
    final flashcards = await _originalBatchFlashcards(sessionId);
    final domainAttempts = attempts.map(_mapAttempt).toList(growable: false);
    return StudySessionSnapshot(
      session: _mapSession(session),
      currentItem: currentItem == null ? null : await _mapItem(currentItem),
      currentRoundItems: await _mapItems(currentRoundItems),
      sessionFlashcards: flashcards,
      summary: _summary(session: session, items: items, attempts: attempts),
      canFinalize:
          session.status == SessionStatus.readyToFinalize.storageValue ||
          session.status == SessionStatus.failedToFinalize.storageValue,
      resultBreakdown: computeStudyResultBreakdown(
        domainAttempts,
        studyType: DatabaseEnumCodecs.studyTypeFromStorage(session.studyType),
      ),
      boxChangeBreakdown: computeBoxChangeBreakdown(domainAttempts),
      resultCardReviewItems: computeStudyResultCardReviewItems(
        attempts: domainAttempts,
        flashcards: flashcards,
        studyType: DatabaseEnumCodecs.studyTypeFromStorage(session.studyType),
      ),
    );
  }

  StudyAttempt _mapAttempt(local.StudyAttempt row) => StudyAttempt(
    id: row.id,
    sessionId: row.sessionId,
    sessionItemId: row.sessionItemId,
    flashcardId: row.flashcardId,
    attemptNumber: row.attemptNumber,
    grade: DatabaseEnumCodecs.attemptGradeFromStorage(row.result),
    answeredAt: row.answeredAt,
    oldBox: row.oldBox,
    newBox: row.newBox,
    nextDueAt: row.nextDueAt,
  );

  StudySummary _summary({
    required local.StudySession session,
    required List<local.StudySessionItem> items,
    required List<local.StudyAttempt> attempts,
  }) {
    final originalCards = items
        .where((item) => item.modeOrder == 1 && item.roundIndex == 1)
        .map((item) => item.flashcardId)
        .toSet();
    final pending = items.where((item) => item.status == 'pending').length;
    final failedAttemptCardIds = <String>{};
    var correct = 0;
    for (final attempt in attempts) {
      final grade = DatabaseEnumCodecs.attemptGradeFromStorage(attempt.result);
      if (grade.isPassing) {
        correct += 1;
        continue;
      }
      failedAttemptCardIds.add(attempt.flashcardId);
    }
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
      masteredCardCount: _masteredCardCount(
        originalCards: originalCards,
        items: items,
        requiredModeCount: _requiredModeCount(session),
      ),
      retryCardCount: failedAttemptCardIds.length,
      completedAttempts: attempts.length,
      correctAttempts: correct,
      incorrectAttempts: attempts.length - correct,
      increasedBoxCount: boxDeltas.values.where((delta) => delta > 0).length,
      decreasedBoxCount: boxDeltas.values.where((delta) => delta < 0).length,
      remainingCount: pending,
    );
  }

  int _masteredCardCount({
    required Set<String> originalCards,
    required List<local.StudySessionItem> items,
    required int requiredModeCount,
  }) {
    final completedModesByCard = <String, Set<int>>{};
    final unfinishedCards = <String>{};
    for (final item in items) {
      if (!originalCards.contains(item.flashcardId)) {
        continue;
      }
      if (item.status == SessionItemStatus.completed.storageValue) {
        completedModesByCard
            .putIfAbsent(item.flashcardId, () => <int>{})
            .add(item.modeOrder);
        continue;
      }
      unfinishedCards.add(item.flashcardId);
    }

    return originalCards.where((cardId) {
      if (unfinishedCards.contains(cardId)) {
        return false;
      }
      return (completedModesByCard[cardId]?.length ?? 0) >= requiredModeCount;
    }).length;
  }

  int _requiredModeCount(local.StudySession session) =>
      switch (DatabaseEnumCodecs.studyFlowFromStorage(session.studyFlow)) {
        StudyFlow.newFullCycle => 5,
        StudyFlow.newReviewOnly ||
        StudyFlow.newMatchOnly ||
        StudyFlow.newGuessOnly ||
        StudyFlow.newRecallOnly ||
        StudyFlow.newFillOnly => 1,
        StudyFlow.srsFillReview => 1,
      };

  StudySession _mapSession(local.StudySession row) => StudySession(
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

  Future<StudySessionItem> _mapItem(local.StudySessionItem row) async =>
      StudySessionItem(
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

  Future<List<StudySessionItem>> _mapItems(
    List<local.StudySessionItem> rows,
  ) async {
    final items = <StudySessionItem>[];
    for (final row in rows) {
      items.add(await _mapItem(row));
    }
    return items;
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
  }) => StudyFlashcardRef(
    id: row.read<String>('id'),
    deckId: row.read<String>('deck_id'),
    front: row.read<String>('front'),
    back: row.read<String>('back'),
    sourcePool: sourcePool,
  );

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
      throw const ValidationException(
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
    if (!preserveOverduePriority || !context.settings.prioritizeOverdue) {
      cards.shuffle(_shuffleRandom);
      return;
    }
    final overdue =
        cards
            .where((card) => card.sourcePool == SessionItemSourcePool.overdue)
            .toList(growable: true)
          ..shuffle(_shuffleRandom);
    final due =
        cards
            .where((card) => card.sourcePool != SessionItemSourcePool.overdue)
            .toList(growable: true)
          ..shuffle(_shuffleRandom);
    cards
      ..clear()
      ..addAll(overdue)
      ..addAll(due);
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

  Duration _intervalForBox(int box) => switch (box) {
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

  String _requireEntryRef(StudyContext context) {
    final refId = context.entryRefId;
    if (refId == null || refId.isEmpty) {
      throw const ValidationException(
        message: 'Study entry reference is required.',
      );
    }
    return refId;
  }
}

String _studyRepoPlaceholders(int count) =>
    List<String>.filled(count, '?').join(', ');

/// SQL fragment excluding suspended and currently-buried cards from study
/// eligibility. Missing progress rows are treated as new active cards so old
/// or repaired local databases do not block Study Entry forever; finalization
/// upserts the missing progress row. Binds one trailing positional `?` =
/// current epoch ms (now). Spec:
/// `docs/business/study-actions/bury-suspend.md` §Auto-unbury.
const String _eligibilityClause =
    'COALESCE(p.is_suspended, 0) = 0 '
    'AND (p.buried_until IS NULL OR p.buried_until <= ?)';
