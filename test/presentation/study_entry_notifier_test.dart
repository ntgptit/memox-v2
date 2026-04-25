import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/errors/app_exception.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/presentation/features/progress/providers/progress_session_notifier.dart';
import 'package:memox/presentation/features/study/providers/study_entry_notifier.dart';

void main() {
  test(
    'DT1 onExternalChange: empty eligible batch returns validation without provider failure',
    () async {
      final container = ProviderContainer(
        overrides: [
          studyRepoProvider.overrideWithValue(const _EmptyStudyRepo()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(studyEntryActionControllerProvider('deck', 'deck-1').notifier)
          .start(
            studyType: StudyType.newStudy,
            settings: const StudySettingsSnapshot(
              batchSize: 20,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          );

      final actionState = container.read(
        studyEntryActionControllerProvider('deck', 'deck-1'),
      );

      expect(result?.sessionId, isNull);
      expect(result?.error, isA<ValidationException>());
      expect(actionState.hasError, isFalse);
      expect(actionState.hasValue, isTrue);
    },
  );

  test(
    'DT2 onExternalChange: successful start invalidates cached Progress sessions',
    () async {
      final repo = _SuccessfulStudyRepo();
      final container = ProviderContainer(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(progressStudySessionsProvider.future);
      expect(repo.activeSessionLoadCount, 1);

      final result = await container
          .read(studyEntryActionControllerProvider('deck', 'deck-1').notifier)
          .start(
            studyType: StudyType.newStudy,
            settings: const StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          );
      await container.read(progressStudySessionsProvider.future);

      expect(result?.sessionId, 'session-1');
      expect(repo.activeSessionLoadCount, 2);
    },
  );
}

final class _SuccessfulStudyRepo implements StudyRepo {
  int activeSessionLoadCount = 0;

  @override
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) async {
    return [_card()];
  }

  @override
  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context) async {
    return const <StudyFlashcardRef>[];
  }

  @override
  Future<List<StudySessionSnapshot>> listActiveSessions() async {
    activeSessionLoadCount += 1;
    return [_snapshot()];
  }

  @override
  Future<StudySessionSnapshot> startSession({
    required StudyContext context,
    required StudyFlow flow,
    required List<StudyMode> modes,
    required List<StudyFlashcardRef> batch,
  }) async {
    return _snapshot(
      entryType: context.entryType,
      entryRefId: context.entryRefId,
      studyType: context.studyType,
      studyFlow: flow,
      settings: context.settings,
      mode: modes.first,
    );
  }

  @override
  Future<StudySessionSnapshot?> findResumeCandidate(StudyContext context) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentItem({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentModeBatch({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentMatchModeBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> skipCurrentItem(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> cancelSession(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> finalizeSession({
    required String sessionId,
    required StudyType studyType,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> retryFinalize({
    required String sessionId,
    required StudyType studyType,
  }) {
    throw UnimplementedError();
  }
}

final class _EmptyStudyRepo implements StudyRepo {
  const _EmptyStudyRepo();

  @override
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) async {
    return const <StudyFlashcardRef>[];
  }

  @override
  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context) async {
    return const <StudyFlashcardRef>[];
  }

  @override
  Future<StudySessionSnapshot?> findResumeCandidate(StudyContext context) {
    throw UnimplementedError();
  }

  @override
  Future<List<StudySessionSnapshot>> listActiveSessions() {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> startSession({
    required StudyContext context,
    required StudyFlow flow,
    required List<StudyMode> modes,
    required List<StudyFlashcardRef> batch,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentItem({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentModeBatch({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentMatchModeBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> skipCurrentItem(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> cancelSession(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> finalizeSession({
    required String sessionId,
    required StudyType studyType,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> retryFinalize({
    required String sessionId,
    required StudyType studyType,
  }) {
    throw UnimplementedError();
  }
}

StudySessionSnapshot _snapshot({
  StudyEntryType entryType = StudyEntryType.deck,
  String? entryRefId = 'deck-1',
  StudyType studyType = StudyType.newStudy,
  StudyFlow studyFlow = StudyFlow.newFullCycle,
  StudySettingsSnapshot settings = const StudySettingsSnapshot(
    batchSize: 1,
    shuffleFlashcards: false,
    shuffleAnswers: false,
    prioritizeOverdue: true,
  ),
  StudyMode mode = StudyMode.review,
}) {
  final card = _card();
  return StudySessionSnapshot(
    session: StudySession(
      id: 'session-1',
      entryType: entryType,
      entryRefId: entryRefId,
      studyType: studyType,
      studyFlow: studyFlow,
      settings: settings,
      status: SessionStatus.inProgress,
      startedAt: 0,
      endedAt: null,
      restartedFromSessionId: null,
    ),
    currentItem: StudySessionItem(
      id: 'item-1',
      sessionId: 'session-1',
      flashcard: card,
      studyMode: mode,
      modeOrder: 1,
      roundIndex: 1,
      queuePosition: 1,
      sourcePool: SessionItemSourcePool.newCards,
      status: SessionItemStatus.pending,
      completedAt: null,
    ),
    sessionFlashcards: [card],
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
}

StudyFlashcardRef _card() {
  return const StudyFlashcardRef(
    id: 'card-1',
    deckId: 'deck-1',
    front: 'front 1',
    back: 'back 1',
    sourcePool: SessionItemSourcePool.newCards,
  );
}
