part of 'study_repo_impl.dart';

extension _StudyRepoImplSessionHelpers on StudyRepoImpl {
  /// Abandons the current card's pending items (bury/suspend) without an
  /// attempt, then advances the session: next pending → retry round → next
  /// mode (excluding dropped cards) → ready to finalize.
  Future<StudySessionSnapshot> _dropCurrentItemFromSession({
    required String sessionId,
    required List<StudyMode> modes,
  }) async {
    await _transactionRunner.write((_) async {
      final session = await _requireSession(sessionId);
      _requireStatus(session, const <SessionStatus>[SessionStatus.inProgress]);
      final item = await _requireCurrentItem(sessionId);
      final now = _clock.nowEpochMillis();

      await _studySessionItemDao.abandonFlashcardPendingItems(
        sessionId: sessionId,
        flashcardId: item.flashcardId,
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
        if (batch.isNotEmpty) {
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
      }

      await _studySessionDao.updateStatus(
        sessionId: sessionId,
        status: SessionStatus.readyToFinalize.storageValue,
        endedAt: now,
      );
    });
    return _loadSnapshot(sessionId);
  }
}
