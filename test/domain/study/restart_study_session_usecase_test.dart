import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/errors/app_exception.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/strategy/study_strategy.dart';
import 'package:memox/domain/study/strategy/study_strategy_factory.dart';
import 'package:memox/domain/study/usecases/study_usecases.dart';

void main() {
  group('RestartStudySessionUseCase', () {
    test(
      'R6 restartSession: passes restartedFromSessionId without direct cancel',
      () async {
        final repo = _RestartStudyRepo();
        final useCase = _useCase(repo);

        final snapshot = await useCase.execute(
          sessionId: 'old-session',
          context: _context(),
        );

        expect(snapshot.session.id, 'new-session');
        expect(repo.cancelCount, 0);
        expect(repo.startCount, 1);
        expect(repo.startedContext?.restartedFromSessionId, 'old-session');
      },
    );

    test('R6 restartSession: creates session with requested modes', () async {
      final repo = _RestartStudyRepo();
      final useCase = _useCase(repo);

      final snapshot = await useCase.execute(
        sessionId: 'old-session',
        context: _context(),
        modes: const <StudyMode>[StudyMode.match],
      );

      expect(snapshot.session.studyFlow, StudyFlow.newMatchOnly);
      expect(repo.startedFlow, StudyFlow.newMatchOnly);
      expect(repo.startedModes, const <StudyMode>[StudyMode.match]);
      expect(repo.startedContext?.restartedFromSessionId, 'old-session');
    });

    test('R10 restartSession: rejects restart for a different entry', () async {
      final repo = _RestartStudyRepo(
        previous: _snapshot(entryRefId: 'other-deck'),
      );
      final useCase = _useCase(repo);

      expect(
        () => useCase.execute(sessionId: 'old-session', context: _context()),
        throwsA(isA<ValidationException>()),
      );
      expect(repo.startCount, 0);
      expect(repo.cancelCount, 0);
    });

    test(
      'R11 restartSession: rejects non-restartable completed session',
      () async {
        final repo = _RestartStudyRepo(
          previous: _snapshot(status: SessionStatus.completed),
        );
        final useCase = _useCase(repo);

        expect(
          () => useCase.execute(sessionId: 'old-session', context: _context()),
          throwsA(isA<ValidationException>()),
        );
        expect(repo.startCount, 0);
        expect(repo.cancelCount, 0);
      },
    );

    test('R12 restartSession: rejects empty eligible batch', () async {
      final repo = _RestartStudyRepo(batch: const <StudyFlashcardRef>[]);
      final useCase = _useCase(repo);

      expect(
        () => useCase.execute(sessionId: 'old-session', context: _context()),
        throwsA(isA<ValidationException>()),
      );
      expect(repo.startCount, 0);
      expect(repo.cancelCount, 0);
    });
  });
}

RestartStudySessionUseCase _useCase(_RestartStudyRepo repo) =>
    RestartStudySessionUseCase(
      repository: repo,
      strategyFactory: StudyFlowStrategyFactory(const <StudyFlowStrategy>[
        NewStudyStrategy(),
        SrsReviewStrategy(),
      ]),
    );

StudyContext _context({
  StudyEntryType entryType = StudyEntryType.deck,
  String? entryRefId = 'deck-1',
  StudyType studyType = StudyType.newStudy,
}) => StudyContext(
  entryType: entryType,
  entryRefId: entryRefId,
  studyType: studyType,
  settings: _settings,
);

const _settings = StudySettingsSnapshot(
  batchSize: 20,
  shuffleFlashcards: false,
  shuffleAnswers: false,
  prioritizeOverdue: true,
);

final class _RestartStudyRepo implements StudyRepo {
  _RestartStudyRepo({
    StudySessionSnapshot? previous,
    List<StudyFlashcardRef>? batch,
  }) : previous = previous ?? _snapshot(),
       batch = batch ?? const <StudyFlashcardRef>[_card];

  final StudySessionSnapshot previous;
  final List<StudyFlashcardRef> batch;
  int startCount = 0;
  int cancelCount = 0;
  StudyContext? startedContext;
  StudyFlow? startedFlow;
  List<StudyMode>? startedModes;

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) async => previous;

  @override
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) async =>
      batch;

  @override
  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context) async =>
      batch;

  @override
  Future<StudySessionSnapshot> startSession({
    required StudyContext context,
    required StudyFlow flow,
    required List<StudyMode> modes,
    required List<StudyFlashcardRef> batch,
  }) async {
    startCount += 1;
    startedContext = context;
    startedFlow = flow;
    startedModes = modes;
    return _snapshot(
      id: 'new-session',
      studyType: context.studyType,
      studyFlow: flow,
      restartedFromSessionId: context.restartedFromSessionId,
    );
  }

  @override
  Future<StudySessionSnapshot> cancelSession(String sessionId) async {
    cancelCount += 1;
    return previous;
  }

  @override
  Future<int> countActiveBuriedInScope(StudyContext context) =>
      throw UnimplementedError();

  @override
  Future<int> countDueCardsInScope(StudyContext context) =>
      throw UnimplementedError();

  @override
  Future<int> countFlashcardsInDeck(String deckId) =>
      throw UnimplementedError();

  @override
  Future<int> countFlashcardsInScope(StudyContext context) =>
      throw UnimplementedError();

  @override
  Future<int> countSuspendedInScope(StudyContext context) =>
      throw UnimplementedError();

  @override
  Future<StudySessionSnapshot> answerCurrentItem({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) => throw UnimplementedError();

  @override
  Future<StudySessionSnapshot> answerCurrentModeItemGradesBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
    required List<StudyMode> modes,
  }) => throw UnimplementedError();

  @override
  Future<StudySessionSnapshot> dropCurrentItemFromSession({
    required String sessionId,
    required List<StudyMode> modes,
  }) => throw UnimplementedError();

  @override
  Future<StudySessionSnapshot> finalizeSession({
    required String sessionId,
    required StudyType studyType,
    required StudyFinalizePolicy finalizePolicy,
  }) => throw UnimplementedError();

  @override
  Future<StudySessionSnapshot?> findResumeCandidate(StudyContext context) =>
      throw UnimplementedError();

  @override
  Future<List<StudySessionSnapshot>> listActiveSessions() =>
      throw UnimplementedError();

  @override
  Future<DateTime?> nextDueAt(StudyContext context) =>
      throw UnimplementedError();

  @override
  Future<StudySessionSnapshot> retryFinalize({
    required String sessionId,
    required StudyType studyType,
    required StudyFinalizePolicy finalizePolicy,
  }) => throw UnimplementedError();

  @override
  Future<void> setBuried({required String flashcardId, required bool buried}) =>
      throw UnimplementedError();

  @override
  Future<void> setSuspended({
    required String flashcardId,
    required bool suspended,
  }) => throw UnimplementedError();

  @override
  Future<StudySessionSnapshot> skipCurrentItem(String sessionId) =>
      throw UnimplementedError();
}

StudySessionSnapshot _snapshot({
  String id = 'old-session',
  StudyEntryType entryType = StudyEntryType.deck,
  String? entryRefId = 'deck-1',
  StudyType studyType = StudyType.newStudy,
  StudyFlow studyFlow = StudyFlow.newFullCycle,
  SessionStatus status = SessionStatus.inProgress,
  String? restartedFromSessionId,
}) => StudySessionSnapshot(
  session: StudySession(
    id: id,
    entryType: entryType,
    entryRefId: entryRefId,
    studyType: studyType,
    studyFlow: studyFlow,
    settings: _settings,
    status: status,
    startedAt: 0,
    endedAt: null,
    restartedFromSessionId: restartedFromSessionId,
  ),
  currentItem: null,
  sessionFlashcards: const <StudyFlashcardRef>[_card],
  summary: const StudySummary(
    totalCards: 1,
    completedAttempts: 0,
    correctAttempts: 0,
    incorrectAttempts: 0,
    increasedBoxCount: 0,
    decreasedBoxCount: 0,
    remainingCount: 1,
  ),
  canFinalize: false,
);

const _card = StudyFlashcardRef(
  id: 'card-1',
  deckId: 'deck-1',
  front: 'Front',
  back: 'Back',
  sourcePool: SessionItemSourcePool.newCards,
);
