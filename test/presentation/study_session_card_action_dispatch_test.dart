import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/study/study_data_providers.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';

/// P0-2 fix: bury/suspend from the card-actions sheet must DROP the current
/// card (remove it from the session), never `skipCurrentItem` (which requeues).
void main() {
  test(
    'buryCurrentCard buries then drops, and never requeues (no skip)',
    () async {
      final repo = _RecordingStudyRepo();
      final container = ProviderContainer(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        studySessionActionControllerProvider('session-1').notifier,
      );

      final buriedId = await controller.buryCurrentCard();

      expect(buriedId, 'c1');
      expect(repo.buriedIds, <String>['c1']);
      expect(repo.dropCallCount, 1);
      expect(repo.skipCalled, isFalse);
      expect(repo.suspendedIds, isEmpty);
    },
  );

  test(
    'suspendCurrentCard suspends then drops, and never requeues (no skip)',
    () async {
      final repo = _RecordingStudyRepo();
      final container = ProviderContainer(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final controller = container.read(
        studySessionActionControllerProvider('session-1').notifier,
      );

      final suspendedId = await controller.suspendCurrentCard();

      expect(suspendedId, 'c1');
      expect(repo.suspendedIds, <String>['c1']);
      expect(repo.dropCallCount, 1);
      expect(repo.skipCalled, isFalse);
      expect(repo.buriedIds, isEmpty);
    },
  );
}

class _RecordingStudyRepo implements StudyRepo {
  final List<String> buriedIds = <String>[];
  final List<String> suspendedIds = <String>[];
  int dropCallCount = 0;
  bool skipCalled = false;

  StudySessionSnapshot get _snapshot => const StudySessionSnapshot(
    session: StudySession(
      id: 'session-1',
      entryType: StudyEntryType.deck,
      entryRefId: 'deck-1',
      studyType: StudyType.newStudy,
      studyFlow: StudyFlow.newFillOnly,
      settings: StudySettingsSnapshot(
        batchSize: 20,
        shuffleFlashcards: false,
        shuffleAnswers: false,
        prioritizeOverdue: false,
      ),
      status: SessionStatus.inProgress,
      startedAt: 0,
      endedAt: null,
      restartedFromSessionId: null,
    ),
    currentItem: StudySessionItem(
      id: 'item-1',
      sessionId: 'session-1',
      flashcard: StudyFlashcardRef(
        id: 'c1',
        deckId: 'deck-1',
        front: 'f',
        back: 'b',
        sourcePool: SessionItemSourcePool.due,
      ),
      studyMode: StudyMode.fill,
      modeOrder: 1,
      roundIndex: 1,
      queuePosition: 1,
      sourcePool: SessionItemSourcePool.due,
      status: SessionItemStatus.pending,
      completedAt: null,
    ),
    sessionFlashcards: <StudyFlashcardRef>[
      StudyFlashcardRef(
        id: 'c1',
        deckId: 'deck-1',
        front: 'f',
        back: 'b',
        sourcePool: SessionItemSourcePool.due,
      ),
    ],
    summary: StudySummary(
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

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) async => _snapshot;

  @override
  Future<void> setBuried({
    required String flashcardId,
    required bool buried,
  }) async {
    if (buried) buriedIds.add(flashcardId);
  }

  @override
  Future<void> setSuspended({
    required String flashcardId,
    required bool suspended,
  }) async {
    if (suspended) suspendedIds.add(flashcardId);
  }

  @override
  Future<StudySessionSnapshot> dropCurrentItemFromSession({
    required String sessionId,
    required List<StudyMode> modes,
  }) async {
    dropCallCount += 1;
    return _snapshot;
  }

  @override
  Future<StudySessionSnapshot> skipCurrentItem(String sessionId) async {
    skipCalled = true;
    return _snapshot;
  }

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
