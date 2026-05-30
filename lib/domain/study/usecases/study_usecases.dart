import '../../../core/errors/app_exception.dart';
import '../../enums/study_enums.dart';
import '../entities/empty_scope_reason.dart';
import '../entities/study_models.dart';
import '../ports/study_repo.dart';
import '../strategy/study_mode_strategy.dart';
import '../strategy/study_strategy.dart';
import '../strategy/study_strategy_factory.dart';

final class StartStudySessionUseCase {
  const StartStudySessionUseCase({
    required StudyRepo repository,
    required StudyFlowStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyFlowStrategyFactory _strategyFactory;

  Future<StudySessionSnapshot> execute(
    StudyContext context, {
    List<StudyMode>? modes,
  }) async {
    final strategy = _strategyFactory.of(context.studyType);
    if (!strategy.supportsEntry(context.entryType)) {
      throw ValidationException(
        message:
            '${context.studyType.name} does not support ${context.entryType.name}.',
      );
    }
    final effectiveModes = modes ?? strategy.modes;
    final flow = _flowForModes(context.studyType, effectiveModes);

    await _rejectEmptyScope(context);

    final batch = await strategy.loadBatch(context, _repository);
    if (batch.isEmpty) {
      throw const ValidationException(
        message: 'No eligible flashcards are available for this study session.',
      );
    }

    final snapshot = await _repository.startSession(
      context: context,
      flow: flow,
      modes: effectiveModes,
      batch: batch,
    );
    return _withFlowPlan(snapshot, _flowPlan(context.studyType, flow));
  }

  /// Pre-check scope and throw a typed [EmptyScopeException] so the
  /// presentation layer can render a dedicated empty state with an actionable
  /// CTA instead of a generic error.
  ///
  /// Precedence (after confirming the scope has cards):
  /// 1. `allSuspended` — every card suspended (Tier 3).
  /// 2. `allBuried` — every remaining card buried for today (Tier 3).
  /// 3. `*_noDueCards` / `today_allDone` — eligible cards exist but none due
  ///    (srs_review only, Tier 1).
  ///
  /// Tier 2 (`tag`) remains blocked on `StudyEntryType.tag`.
  /// Spec: `docs/business/study/study-flow.md` §Empty scope matrix.
  Future<void> _rejectEmptyScope(StudyContext context) async {
    if (context.entryType != StudyEntryType.today &&
        context.entryRefId == null) {
      return;
    }

    final total = await _totalCardsInScope(context);
    if (total == 0) {
      throw EmptyScopeException(_noContentReason(context.entryType));
    }

    final suspended = await _repository.countSuspendedInScope(context);
    if (suspended >= total) {
      throw const EmptyScopeException(EmptyScopeReason.allSuspended);
    }

    final activeBuried = await _repository.countActiveBuriedInScope(context);
    if (suspended + activeBuried >= total) {
      throw const EmptyScopeException(EmptyScopeReason.allBuried);
    }

    if (context.studyType == StudyType.srsReview) {
      await _rejectNoDueCards(context, _noDueReason(context.entryType));
    }
  }

  Future<int> _totalCardsInScope(StudyContext context) {
    if (context.entryType == StudyEntryType.deck) {
      return _repository.countFlashcardsInDeck(context.entryRefId!);
    }
    return _repository.countFlashcardsInScope(context);
  }

  EmptyScopeReason _noContentReason(StudyEntryType entryType) =>
      switch (entryType) {
        StudyEntryType.deck => EmptyScopeReason.deckNoCards,
        StudyEntryType.folder => EmptyScopeReason.folderNoCards,
        StudyEntryType.today => EmptyScopeReason.todayNoContent,
      };

  EmptyScopeReason _noDueReason(StudyEntryType entryType) =>
      switch (entryType) {
        StudyEntryType.deck => EmptyScopeReason.deckNoDueCards,
        StudyEntryType.folder => EmptyScopeReason.folderNoDueCards,
        StudyEntryType.today => EmptyScopeReason.todayAllDone,
      };

  Future<void> _rejectNoDueCards(
    StudyContext context,
    EmptyScopeReason reason,
  ) async {
    final due = await _repository.countDueCardsInScope(context);
    if (due > 0) {
      return;
    }
    final nextDueAt = await _repository.nextDueAt(context);
    throw EmptyScopeException(reason, nextDueAt: nextDueAt);
  }
}

final class ResumeStudySessionUseCase {
  const ResumeStudySessionUseCase({
    required StudyRepo repository,
    required StudyFlowStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyFlowStrategyFactory _strategyFactory;

  Future<List<StudySessionSnapshot>> listActiveSessions() async {
    final sessions = await _repository.listActiveSessions();
    return sessions.map(_withRegisteredFlowPlan).toList(growable: false);
  }

  Future<StudySessionSnapshot?> findCandidate(StudyContext context) async {
    _strategyFactory.of(context.studyType);
    final snapshot = await _repository.findResumeCandidate(context);
    return snapshot == null ? null : _withRegisteredFlowPlan(snapshot);
  }

  Future<StudySessionSnapshot> execute(String sessionId) async =>
      _withRegisteredFlowPlan(await _repository.loadSession(sessionId));

  StudySessionSnapshot _withRegisteredFlowPlan(StudySessionSnapshot snapshot) =>
      _withFlowPlan(
        snapshot,
        _flowPlan(snapshot.session.studyType, snapshot.session.studyFlow),
      );
}

final class RestartStudySessionUseCase {
  const RestartStudySessionUseCase({
    required StudyRepo repository,
    required StudyFlowStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyFlowStrategyFactory _strategyFactory;

  /// Restarts [sessionId] for [context]. [modes] preserves the entry's selected
  /// mode flow (e.g. a single-mode entry) when provided; it defaults to the
  /// strategy's full flow so existing full-cycle / SRS callers are unchanged.
  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyContext context,
    List<StudyMode>? modes,
  }) async {
    final previous = await _repository.loadSession(sessionId);
    _requireSameEntry(previous.session, context);
    _requireRestartable(previous.session);

    final strategy = _strategyFactory.of(context.studyType);
    if (!strategy.supportsEntry(context.entryType)) {
      throw ValidationException(
        message:
            '${context.studyType.name} does not support ${context.entryType.name}.',
      );
    }
    final effectiveModes = modes ?? strategy.modes;
    final flow = _flowForModes(context.studyType, effectiveModes);
    final batch = await strategy.loadBatch(context, _repository);
    if (batch.isEmpty) {
      throw const ValidationException(
        message: 'No eligible flashcards are available for this study session.',
      );
    }

    final snapshot = await _repository.startSession(
      context: StudyContext(
        entryType: context.entryType,
        entryRefId: context.entryRefId,
        studyType: context.studyType,
        settings: context.settings,
        restartedFromSessionId: sessionId,
      ),
      flow: flow,
      modes: effectiveModes,
      batch: batch,
    );
    return _withFlowPlan(snapshot, _flowPlan(context.studyType, flow));
  }

  void _requireSameEntry(StudySession session, StudyContext context) {
    if (session.entryType == context.entryType &&
        session.entryRefId == context.entryRefId) {
      return;
    }
    throw const ValidationException(
      message: 'Restart target does not match the study entry.',
    );
  }

  void _requireRestartable(StudySession session) {
    if (session.status == SessionStatus.inProgress ||
        session.status == SessionStatus.readyToFinalize ||
        session.status == SessionStatus.failedToFinalize) {
      return;
    }
    throw const ValidationException(
      message: 'Only active study sessions can be restarted.',
    );
  }
}

final class AnswerFlashcardUseCase {
  const AnswerFlashcardUseCase({
    required StudyRepo repository,
    required StudyFlowStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyFlowStrategyFactory _strategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyType studyType,
    required AttemptGrade grade,
  }) async {
    _strategyFactory.of(studyType);
    final currentSnapshot = await _repository.loadSession(sessionId);
    final modes = studyModesForFlow(currentSnapshot.session.studyFlow);
    final snapshot = await _repository.answerCurrentItem(
      sessionId: sessionId,
      grade: grade,
      modes: modes,
    );
    return _withFlowPlan(
      snapshot,
      _flowPlan(snapshot.session.studyType, snapshot.session.studyFlow),
    );
  }
}

final class AnswerCurrentModeBatchUseCase {
  const AnswerCurrentModeBatchUseCase({
    required StudyRepo repository,
    required StudyFlowStrategyFactory flowStrategyFactory,
    required StudyModeStrategyFactory modeStrategyFactory,
  }) : _repository = repository,
       _flowStrategyFactory = flowStrategyFactory,
       _modeStrategyFactory = modeStrategyFactory;

  final StudyRepo _repository;
  final StudyFlowStrategyFactory _flowStrategyFactory;
  final StudyModeStrategyFactory _modeStrategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyType studyType,
    StudyModeUiResult uiResult = StudyModeUiResult.viewed,
  }) async {
    _flowStrategyFactory.of(studyType);
    final currentSnapshot = await _repository.loadSession(sessionId);
    final modes = studyModesForFlow(currentSnapshot.session.studyFlow);
    final modeStrategy = _modeStrategy(currentSnapshot);
    if (modeStrategy.handleType != StudyMode.review) {
      throw const ValidationException(
        message: 'Review batch answer is only available for Review mode.',
      );
    }
    final pendingItemIds = _pendingItemIds(currentSnapshot);
    final grade = modeStrategy.normalizeUiResult(uiResult);
    final submission = modeStrategy.buildSubmission(
      pendingItemIds: pendingItemIds,
      itemGrades: <String, AttemptGrade>{
        for (final itemId in pendingItemIds) itemId: grade,
      },
    );
    final result = await _repository.answerCurrentModeItemGradesBatch(
      sessionId: sessionId,
      itemGrades: submission.itemGrades,
      modes: modes,
    );
    return _withFlowPlan(
      result,
      _flowPlan(result.session.studyType, result.session.studyFlow),
    );
  }

  StudyModeStrategy _modeStrategy(StudySessionSnapshot snapshot) {
    final mode = snapshot.currentItem?.studyMode;
    if (mode == null) {
      throw const ValidationException(message: 'No pending study item.');
    }
    return _modeStrategyFactory.of(mode);
  }
}

final class AnswerCurrentModeItemGradesBatchUseCase {
  const AnswerCurrentModeItemGradesBatchUseCase({
    required StudyRepo repository,
    required StudyFlowStrategyFactory flowStrategyFactory,
    required StudyModeStrategyFactory modeStrategyFactory,
  }) : _repository = repository,
       _flowStrategyFactory = flowStrategyFactory,
       _modeStrategyFactory = modeStrategyFactory;

  final StudyRepo _repository;
  final StudyFlowStrategyFactory _flowStrategyFactory;
  final StudyModeStrategyFactory _modeStrategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyType studyType,
    required Map<String, AttemptGrade> itemGrades,
  }) async {
    _flowStrategyFactory.of(studyType);
    final currentSnapshot = await _repository.loadSession(sessionId);
    final modes = studyModesForFlow(currentSnapshot.session.studyFlow);
    final mode = currentSnapshot.currentItem?.studyMode;
    if (mode == null) {
      throw const ValidationException(message: 'No pending study item.');
    }
    final modeStrategy = _modeStrategyFactory.of(mode);
    final submission = modeStrategy.buildSubmission(
      pendingItemIds: _pendingItemIds(currentSnapshot),
      itemGrades: itemGrades,
    );
    final result = await _repository.answerCurrentModeItemGradesBatch(
      sessionId: sessionId,
      itemGrades: submission.itemGrades,
      modes: modes,
    );
    return _withFlowPlan(
      result,
      _flowPlan(result.session.studyType, result.session.studyFlow),
    );
  }
}

final class AnswerCurrentMatchModeBatchUseCase {
  const AnswerCurrentMatchModeBatchUseCase({
    required StudyRepo repository,
    required StudyFlowStrategyFactory flowStrategyFactory,
    required StudyModeStrategyFactory modeStrategyFactory,
  }) : _repository = repository,
       _flowStrategyFactory = flowStrategyFactory,
       _modeStrategyFactory = modeStrategyFactory;

  final StudyRepo _repository;
  final StudyFlowStrategyFactory _flowStrategyFactory;
  final StudyModeStrategyFactory _modeStrategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyType studyType,
    required Map<String, AttemptGrade> itemGrades,
  }) async {
    _flowStrategyFactory.of(studyType);
    final modeStrategy = _modeStrategyFactory.of(StudyMode.match);
    final currentSnapshot = await _repository.loadSession(sessionId);
    final modes = studyModesForFlow(currentSnapshot.session.studyFlow);
    if (currentSnapshot.currentItem?.studyMode != StudyMode.match) {
      throw const ValidationException(
        message: 'Match batch answer is only available for Match mode.',
      );
    }
    final submission = modeStrategy.buildSubmission(
      pendingItemIds: _pendingItemIds(currentSnapshot),
      itemGrades: itemGrades,
    );
    final result = await _repository.answerCurrentModeItemGradesBatch(
      sessionId: sessionId,
      itemGrades: submission.itemGrades,
      modes: modes,
    );
    return _withFlowPlan(
      result,
      _flowPlan(result.session.studyType, result.session.studyFlow),
    );
  }
}

final class SkipFlashcardUseCase {
  const SkipFlashcardUseCase(this._repository);

  final StudyRepo _repository;

  Future<StudySessionSnapshot> execute(String sessionId) =>
      _repository.skipCurrentItem(sessionId);
}

/// Removes the current card from the active session after a bury/suspend.
/// Unlike [SkipFlashcardUseCase] (which requeues), the card is abandoned and
/// never reappears in this session. No attempt is recorded; the session
/// advances or becomes ready to finalize. Spec:
/// `docs/business/study-actions/bury-suspend.md` §Bury.
final class DropCurrentStudyItemUseCase {
  const DropCurrentStudyItemUseCase(this._repository);

  final StudyRepo _repository;

  Future<StudySessionSnapshot> execute(String sessionId) async {
    final snapshot = await _repository.loadSession(sessionId);
    final modes = studyModesForFlow(snapshot.session.studyFlow);
    final result = await _repository.dropCurrentItemFromSession(
      sessionId: sessionId,
      modes: modes,
    );
    return _withFlowPlan(
      result,
      _flowPlan(result.session.studyType, result.session.studyFlow),
    );
  }
}

final class CancelStudySessionUseCase {
  const CancelStudySessionUseCase(this._repository);

  final StudyRepo _repository;

  Future<StudySessionSnapshot> execute(String sessionId) =>
      _repository.cancelSession(sessionId);
}

/// Buries a flashcard until the next local midnight. SRS state is unchanged.
/// Spec: `docs/business/study-actions/bury-suspend.md`,
/// `docs/contracts/usecase-contracts/study.md` §BuryCardUseCase.
final class BuryFlashcardUseCase {
  const BuryFlashcardUseCase(this._repository);

  final StudyRepo _repository;

  Future<void> execute(String flashcardId) =>
      _repository.setBuried(flashcardId: flashcardId, buried: true);
}

/// Clears a flashcard's buried state (used by the undo toast).
final class UnburyFlashcardUseCase {
  const UnburyFlashcardUseCase(this._repository);

  final StudyRepo _repository;

  Future<void> execute(String flashcardId) =>
      _repository.setBuried(flashcardId: flashcardId, buried: false);
}

/// Suspends a flashcard indefinitely. SRS state is preserved for unsuspend.
/// Spec: `docs/contracts/usecase-contracts/study.md` §SuspendCardUseCase.
final class SuspendFlashcardUseCase {
  const SuspendFlashcardUseCase(this._repository);

  final StudyRepo _repository;

  Future<void> execute(String flashcardId) =>
      _repository.setSuspended(flashcardId: flashcardId, suspended: true);
}

/// Resumes a suspended flashcard. It re-enters the due flow from its existing
/// `due_at`. Spec: `docs/contracts/usecase-contracts/study.md`
/// §UnsuspendCardUseCase.
final class UnsuspendFlashcardUseCase {
  const UnsuspendFlashcardUseCase(this._repository);

  final StudyRepo _repository;

  Future<void> execute(String flashcardId) =>
      _repository.setSuspended(flashcardId: flashcardId, suspended: false);
}

final class FinalizeStudySessionUseCase {
  const FinalizeStudySessionUseCase({
    required StudyRepo repository,
    required StudyFlowStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyFlowStrategyFactory _strategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyType studyType,
  }) async {
    final strategy = _strategyFactory.of(studyType);
    final snapshot = await _repository.finalizeSession(
      sessionId: sessionId,
      studyType: studyType,
      finalizePolicy: strategy.finalizePolicy,
    );
    return _withFlowPlan(snapshot, strategy.flowPlan);
  }
}

final class RetryFinalizeUseCase {
  const RetryFinalizeUseCase({
    required StudyRepo repository,
    required StudyFlowStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyFlowStrategyFactory _strategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyType studyType,
  }) async {
    final strategy = _strategyFactory.of(studyType);
    final snapshot = await _repository.retryFinalize(
      sessionId: sessionId,
      studyType: studyType,
      finalizePolicy: strategy.finalizePolicy,
    );
    return _withFlowPlan(snapshot, strategy.flowPlan);
  }
}

StudySessionSnapshot _withFlowPlan(
  StudySessionSnapshot snapshot,
  StudyFlowPlan flowPlan,
) => snapshot.copyWith(
  summary: snapshot.summary.copyWith(totalModeCount: flowPlan.totalModeCount),
);

StudyFlow _flowForModes(StudyType studyType, List<StudyMode> modes) {
  try {
    return studyFlowForModes(studyType, modes);
  } on FormatException catch (error) {
    throw ValidationException(message: error.message);
  }
}

StudyFlowPlan _flowPlan(StudyType studyType, StudyFlow flow) => StudyFlowPlan(
  studyType: studyType,
  flow: flow,
  modes: studyModesForFlow(flow),
);

List<String> _pendingItemIds(StudySessionSnapshot snapshot) {
  final currentItem = snapshot.currentItem;
  final pendingRoundIds = snapshot.currentRoundItems
      .where((item) => item.status == SessionItemStatus.pending)
      .map((item) => item.id)
      .toList(growable: false);
  if (pendingRoundIds.isNotEmpty) {
    return pendingRoundIds;
  }
  if (currentItem == null) {
    throw const ValidationException(message: 'No pending study item.');
  }
  return <String>[currentItem.id];
}
