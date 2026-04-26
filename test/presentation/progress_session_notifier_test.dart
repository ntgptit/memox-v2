import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/presentation/features/progress/providers/progress_session_notifier.dart';
import 'package:memox/presentation/features/study/providers/study_entry_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'DT1 onDisplay: provider returns active study sessions from repository',
    () async {
      final repo = _ProgressStudyRepo(activeSessions: [_snapshot()]);
      final container = ProviderContainer(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final sessions = await container.read(
        progressStudySessionsProvider.future,
      );

      expect(sessions.map((snapshot) => snapshot.session.id), ['session-1']);
    },
  );

  test('DT1 onUpdate: cancel action succeeds without provider error', () async {
    final repo = _ProgressStudyRepo(activeSessions: [_snapshot()]);
    final container = ProviderContainer(
      overrides: [studyRepoProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final success = await container
        .read(progressSessionActionControllerProvider.notifier)
        .cancel('session-1');

    expect(success, isTrue);
    expect(repo.cancelCount, 1);
    expect(
      container.read(progressSessionActionControllerProvider).hasError,
      isFalse,
    );
  });

  test(
    'DT2 onUpdate: finalize action succeeds without provider error',
    () async {
      final repo = _ProgressStudyRepo(activeSessions: [_snapshot()]);
      final container = ProviderContainer(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final success = await container
          .read(progressSessionActionControllerProvider.notifier)
          .finalize(_snapshot(status: SessionStatus.readyToFinalize));

      expect(success, isTrue);
      expect(repo.finalizeCount, 1);
      expect(repo.lastFinalizedStudyType, StudyType.srsReview);
      expect(
        container.read(progressSessionActionControllerProvider).hasError,
        isFalse,
      );
    },
  );

  test(
    'DT3 onUpdate: retry finalize action succeeds without provider error',
    () async {
      final repo = _ProgressStudyRepo(activeSessions: [_snapshot()]);
      final container = ProviderContainer(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final success = await container
          .read(progressSessionActionControllerProvider.notifier)
          .retryFinalize(_snapshot(status: SessionStatus.failedToFinalize));

      expect(success, isTrue);
      expect(repo.retryFinalizeCount, 1);
      expect(repo.lastRetriedStudyType, StudyType.srsReview);
      expect(
        container.read(progressSessionActionControllerProvider).hasError,
        isFalse,
      );
    },
  );

  test(
    'DT4 onUpdate: terminal Progress mutation invalidates cached Study Entry resume state',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final repo = _ProgressStudyRepo(activeSessions: [_snapshot()]);
      final container = ProviderContainer(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final initial = await container.read(
        studyEntryStateProvider('deck', 'deck-1').future,
      );
      expect(initial.resumeCandidate?.session.id, 'session-1');
      expect(repo.resumeCandidateLoadCount, 1);

      final success = await container
          .read(progressSessionActionControllerProvider.notifier)
          .finalize(_snapshot(status: SessionStatus.readyToFinalize));
      final refreshed = await container.read(
        studyEntryStateProvider('deck', 'deck-1').future,
      );

      expect(success, isTrue);
      expect(repo.resumeCandidateLoadCount, 2);
      expect(refreshed.resumeCandidate, isNull);
    },
  );
}

final class _ProgressStudyRepo implements StudyRepo {
  _ProgressStudyRepo({required this.activeSessions});

  final List<StudySessionSnapshot> activeSessions;
  int cancelCount = 0;
  int finalizeCount = 0;
  int retryFinalizeCount = 0;
  int resumeCandidateLoadCount = 0;
  bool hasResumeCandidate = true;
  StudyType? lastFinalizedStudyType;
  StudyType? lastRetriedStudyType;

  @override
  Future<List<StudySessionSnapshot>> listActiveSessions() async {
    return activeSessions;
  }

  @override
  Future<StudySessionSnapshot> cancelSession(String sessionId) async {
    cancelCount += 1;
    hasResumeCandidate = false;
    return _snapshot(status: SessionStatus.cancelled);
  }

  @override
  Future<StudySessionSnapshot> finalizeSession({
    required String sessionId,
    required StudyType studyType,
    required StudyFinalizePolicy finalizePolicy,
  }) async {
    finalizeCount += 1;
    hasResumeCandidate = false;
    lastFinalizedStudyType = studyType;
    return _snapshot(status: SessionStatus.completed);
  }

  @override
  Future<StudySessionSnapshot> retryFinalize({
    required String sessionId,
    required StudyType studyType,
    required StudyFinalizePolicy finalizePolicy,
  }) async {
    retryFinalizeCount += 1;
    hasResumeCandidate = false;
    lastRetriedStudyType = studyType;
    return _snapshot(status: SessionStatus.completed);
  }

  @override
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) {
    throw UnimplementedError();
  }

  @override
  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot?> findResumeCandidate(
    StudyContext context,
  ) async {
    resumeCandidateLoadCount += 1;
    if (!hasResumeCandidate) {
      return null;
    }
    return _snapshot();
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
  Future<StudySessionSnapshot> answerCurrentModeItemGradesBatch({
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
}

StudySessionSnapshot _snapshot({
  String id = 'session-1',
  SessionStatus status = SessionStatus.inProgress,
}) {
  final card = _card();
  return StudySessionSnapshot(
    session: StudySession(
      id: id,
      entryType: StudyEntryType.deck,
      entryRefId: 'deck-1',
      studyType: StudyType.srsReview,
      studyFlow: StudyFlow.srsFillReview,
      settings: const StudySettingsSnapshot(
        batchSize: 1,
        shuffleFlashcards: false,
        shuffleAnswers: false,
        prioritizeOverdue: true,
      ),
      status: status,
      startedAt: 0,
      endedAt: null,
      restartedFromSessionId: null,
    ),
    currentItem: status == SessionStatus.inProgress
        ? StudySessionItem(
            id: 'item-1',
            sessionId: id,
            flashcard: card,
            studyMode: StudyMode.fill,
            modeOrder: 1,
            roundIndex: 1,
            queuePosition: 1,
            sourcePool: SessionItemSourcePool.due,
            status: SessionItemStatus.pending,
            completedAt: null,
          )
        : null,
    sessionFlashcards: [card],
    summary: StudySummary(
      totalCards: 1,
      completedAttempts: status == SessionStatus.inProgress ? 0 : 1,
      correctAttempts: status == SessionStatus.inProgress ? 0 : 1,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: status == SessionStatus.inProgress ? 1 : 0,
    ),
    canFinalize:
        status == SessionStatus.readyToFinalize ||
        status == SessionStatus.failedToFinalize,
  );
}

StudyFlashcardRef _card() {
  return const StudyFlashcardRef(
    id: 'card-1',
    deckId: 'deck-1',
    front: 'front 1',
    back: 'back 1',
    sourcePool: SessionItemSourcePool.due,
  );
}
