import '../../../core/errors/app_exception.dart';
import '../../enums/study_enums.dart';
import '../entities/study_models.dart';
import '../ports/study_repo.dart';
import '../strategy/study_strategy_factory.dart';

final class StartStudySessionUseCase {
  const StartStudySessionUseCase({
    required StudyRepo repository,
    required StudyStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyStrategyFactory _strategyFactory;

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

    return _repository.startSession(
      context: context,
      flow: strategy.flow,
      modes: strategy.modes,
      batch: batch,
    );
  }
}

final class ResumeStudySessionUseCase {
  const ResumeStudySessionUseCase(this._repository);

  final StudyRepo _repository;

  Future<List<StudySessionSnapshot>> listActiveSessions() {
    return _repository.listActiveSessions();
  }

  Future<StudySessionSnapshot?> findCandidate(StudyContext context) {
    return _repository.findResumeCandidate(context);
  }

  Future<StudySessionSnapshot> execute(String sessionId) {
    return _repository.loadSession(sessionId);
  }
}

final class RestartStudySessionUseCase {
  const RestartStudySessionUseCase({
    required StudyRepo repository,
    required StudyStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyStrategyFactory _strategyFactory;

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
    return _repository.startSession(
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
    required StudyStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyStrategyFactory _strategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyType studyType,
    required AttemptGrade grade,
  }) {
    final strategy = _strategyFactory.of(studyType);
    return _repository.answerCurrentItem(
      sessionId: sessionId,
      grade: grade,
      modes: strategy.modes,
    );
  }
}

final class AnswerCurrentModeBatchUseCase {
  const AnswerCurrentModeBatchUseCase({
    required StudyRepo repository,
    required StudyStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyStrategyFactory _strategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyType studyType,
    required AttemptGrade grade,
  }) {
    final strategy = _strategyFactory.of(studyType);
    return _repository.answerCurrentModeBatch(
      sessionId: sessionId,
      grade: grade,
      modes: strategy.modes,
    );
  }
}

final class AnswerCurrentMatchModeBatchUseCase {
  const AnswerCurrentMatchModeBatchUseCase({
    required StudyRepo repository,
    required StudyStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyStrategyFactory _strategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyType studyType,
    required Map<String, AttemptGrade> itemGrades,
  }) {
    final strategy = _strategyFactory.of(studyType);
    return _repository.answerCurrentMatchModeBatch(
      sessionId: sessionId,
      itemGrades: itemGrades,
      modes: strategy.modes,
    );
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
    required StudyStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyStrategyFactory _strategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyType studyType,
  }) {
    _strategyFactory.of(studyType);
    return _repository.finalizeSession(
      sessionId: sessionId,
      studyType: studyType,
    );
  }
}

final class RetryFinalizeUseCase {
  const RetryFinalizeUseCase({
    required StudyRepo repository,
    required StudyStrategyFactory strategyFactory,
  }) : _repository = repository,
       _strategyFactory = strategyFactory;

  final StudyRepo _repository;
  final StudyStrategyFactory _strategyFactory;

  Future<StudySessionSnapshot> execute({
    required String sessionId,
    required StudyType studyType,
  }) {
    _strategyFactory.of(studyType);
    return _repository.retryFinalize(
      sessionId: sessionId,
      studyType: studyType,
    );
  }
}
