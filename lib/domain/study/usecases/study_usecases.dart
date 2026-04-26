import '../../../core/errors/app_exception.dart';
import '../../enums/study_enums.dart';
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

  Future<StudySessionSnapshot> execute(StudyContext context) async {
    final strategy = _strategyFactory.of(context.studyType);
    if (!strategy.supportsEntry(context.entryType)) {
      throw ValidationException(
        message:
            '${context.studyType.name} does not support ${context.entryType.name}.',
      );
    }

    final batch = await strategy.loadBatch(context, _repository);
    if (batch.isEmpty) {
      throw const ValidationException(
        message: 'No eligible flashcards are available for this study session.',
      );
    }

    final snapshot = await _repository.startSession(
      context: context,
      flow: strategy.flow,
      modes: strategy.modes,
      batch: batch,
    );
    return _withFlowPlan(snapshot, strategy.flowPlan);
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
    final snapshot = await _repository.findResumeCandidate(context);
    return snapshot == null ? null : _withRegisteredFlowPlan(snapshot);
  }

  Future<StudySessionSnapshot> execute(String sessionId) async {
    return _withRegisteredFlowPlan(await _repository.loadSession(sessionId));
  }

  StudySessionSnapshot _withRegisteredFlowPlan(StudySessionSnapshot snapshot) {
    final strategy = _strategyFactory.of(snapshot.session.studyType);
    return _withFlowPlan(snapshot, strategy.flowPlan);
  }
}

final class RestartStudySessionUseCase {
  const RestartStudySessionUseCase({
    required StudyRepo repository,
    required StudyFlowStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyFlowStrategyFactory _strategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyContext context,
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
    final batch = await strategy.loadBatch(context, _repository);
    if (batch.isEmpty) {
      throw const ValidationException(
        message: 'No eligible flashcards are available for this study session.',
      );
    }

    await _repository.cancelSession(sessionId);
    final snapshot = await _repository.startSession(
      context: StudyContext(
        entryType: context.entryType,
        entryRefId: context.entryRefId,
        studyType: context.studyType,
        settings: context.settings,
        restartedFromSessionId: sessionId,
      ),
      flow: strategy.flow,
      modes: strategy.modes,
      batch: batch,
    );
    return _withFlowPlan(snapshot, strategy.flowPlan);
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
    final strategy = _strategyFactory.of(studyType);
    final snapshot = await _repository.answerCurrentItem(
      sessionId: sessionId,
      grade: grade,
      modes: strategy.modes,
    );
    return _withFlowPlan(snapshot, strategy.flowPlan);
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
    final strategy = _flowStrategyFactory.of(studyType);
    final currentSnapshot = await _repository.loadSession(sessionId);
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
      modes: strategy.modes,
    );
    return _withFlowPlan(result, strategy.flowPlan);
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
    final strategy = _flowStrategyFactory.of(studyType);
    final currentSnapshot = await _repository.loadSession(sessionId);
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
      modes: strategy.modes,
    );
    return _withFlowPlan(result, strategy.flowPlan);
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
    final strategy = _flowStrategyFactory.of(studyType);
    final modeStrategy = _modeStrategyFactory.of(StudyMode.match);
    final currentSnapshot = await _repository.loadSession(sessionId);
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
      modes: strategy.modes,
    );
    return _withFlowPlan(result, strategy.flowPlan);
  }
}

final class SkipFlashcardUseCase {
  const SkipFlashcardUseCase(this._repository);

  final StudyRepo _repository;

  Future<StudySessionSnapshot> execute(String sessionId) {
    return _repository.skipCurrentItem(sessionId);
  }
}

final class CancelStudySessionUseCase {
  const CancelStudySessionUseCase(this._repository);

  final StudyRepo _repository;

  Future<StudySessionSnapshot> execute(String sessionId) {
    return _repository.cancelSession(sessionId);
  }
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
) {
  return snapshot.copyWith(
    summary: snapshot.summary.copyWith(totalModeCount: flowPlan.totalModeCount),
  );
}

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
