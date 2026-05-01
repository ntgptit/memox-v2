import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/content_providers.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/errors/result.dart';
import 'package:memox/domain/entities/folder_entity.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/enums/folder_content_mode.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/usecases/content_query_usecases.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/domain/value_objects/content_queries.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
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

  test(
    'DT2 onDisplay: overview provider combines library analytics and session recovery counts',
    () async {
      final repo = _ProgressStudyRepo(
        activeSessions: [
          _snapshot(id: 'session-1'),
          _snapshot(id: 'session-2', status: SessionStatus.readyToFinalize),
          _snapshot(id: 'session-3', status: SessionStatus.failedToFinalize),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          contentDataRevisionProvider.overrideWith(
            (ref) => Stream<int>.value(0),
          ),
          studyRepoProvider.overrideWithValue(repo),
          watchLibraryOverviewUseCaseProvider.overrideWithValue(
            WatchLibraryOverviewUseCase(_ProgressFolderRepo()),
          ),
        ],
      );
      addTearDown(container.dispose);

      final overview = await container.read(progressOverviewProvider.future);

      expect(overview.reviewCount, 5);
      expect(overview.newCardCount, 4);
      expect(overview.cardCount, 10);
      expect(overview.masteryPercent, 50);
      expect(overview.activeSessionCount, 3);
      expect(overview.readySessionCount, 1);
      expect(overview.failedSessionCount, 1);
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

final class _ProgressFolderRepo implements FolderRepository {
  @override
  Future<LibraryOverviewReadModel> getLibraryOverview(
    ContentQuery query,
  ) async {
    return LibraryOverviewReadModel(
      overdueCount: 2,
      dueTodayCount: 3,
      newCardCount: 4,
      totalFolderCount: 2,
      folders: [
        _folderReadModel(id: 'folder-1', itemCount: 4, masteryPercent: 25),
        _folderReadModel(id: 'folder-2', itemCount: 6, masteryPercent: 67),
      ],
    );
  }

  @override
  Future<Result<FolderEntity>> createRootFolder(String name) {
    throw UnimplementedError();
  }

  @override
  Future<Result<FolderEntity>> createSubfolder({
    required String parentFolderId,
    required String name,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> deleteFolder(String folderId) {
    throw UnimplementedError();
  }

  @override
  Future<FolderDetailReadModel> getFolderDetail(
    String folderId,
    ContentQuery query,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<FolderMoveTarget>> getFolderMoveTargets(String folderId) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> moveFolder({
    required String folderId,
    required String? targetParentId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> reorderFolders({
    required String? parentFolderId,
    required List<String> orderedFolderIds,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<FolderEntity>> updateFolder({
    required String folderId,
    required String name,
  }) {
    throw UnimplementedError();
  }
}

LibraryFolderReadModel _folderReadModel({
  required String id,
  required int itemCount,
  required int masteryPercent,
}) {
  return LibraryFolderReadModel(
    folder: FolderEntity(
      id: id,
      parentId: null,
      name: id,
      contentMode: FolderContentMode.decks,
      sortOrder: 0,
      createdAt: 0,
      updatedAt: 0,
    ),
    breadcrumb: const [],
    subfolderCount: 0,
    deckCount: 1,
    itemCount: itemCount,
    dueCardCount: 0,
    newCardCount: 0,
    masteryPercent: masteryPercent,
    lastStudiedAt: null,
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
