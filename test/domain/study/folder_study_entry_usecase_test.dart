import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/usecases/folder_study_entry_usecase.dart';

void main() {
  group('GetFolderStudyEntryUseCase', () {
    test('composes recursive counts and resumable session for a folder', () async {
      final repo = _FakeStudyRepo(
        totalCardCount: 12,
        dueCount: 4,
        resumeSessionId: 'session-007',
      );
      final useCase = GetFolderStudyEntryUseCase(repository: repo);

      final entry = await useCase.execute('folder-001');

      expect(entry.totalCardCount, 12);
      expect(entry.dueCount, 4);
      expect(entry.resumeSessionId, 'session-007');
      expect(entry.hasCards, isTrue);
      expect(entry.hasDue, isTrue);
      expect(entry.hasResume, isTrue);
      // Scope probes must use a folder context for this folder id.
      expect(repo.capturedEntryType, StudyEntryType.folder);
      expect(repo.capturedEntryRefId, 'folder-001');
    });

    test('reports an empty study surface when folder has no cards or session', () async {
      final repo = _FakeStudyRepo(
        totalCardCount: 0,
        dueCount: 0,
        resumeSessionId: null,
      );
      final useCase = GetFolderStudyEntryUseCase(repository: repo);

      final entry = await useCase.execute('folder-empty');

      expect(entry.hasCards, isFalse);
      expect(entry.hasDue, isFalse);
      expect(entry.hasResume, isFalse);
      expect(entry.resumeSessionId, isNull);
    });

    test('cards present but none due hides Today but keeps Study folder', () async {
      final repo = _FakeStudyRepo(
        totalCardCount: 30,
        dueCount: 0,
        resumeSessionId: null,
      );
      final useCase = GetFolderStudyEntryUseCase(repository: repo);

      final entry = await useCase.execute('folder-002');

      expect(entry.hasCards, isTrue);
      expect(entry.hasDue, isFalse);
      expect(entry.hasResume, isFalse);
    });
  });
}

class _FakeStudyRepo implements StudyRepo {
  _FakeStudyRepo({
    required this.totalCardCount,
    required this.dueCount,
    required this.resumeSessionId,
  });

  final int totalCardCount;
  final int dueCount;
  final String? resumeSessionId;

  StudyEntryType? capturedEntryType;
  String? capturedEntryRefId;

  @override
  Future<int> countFlashcardsInScope(StudyContext context) async {
    capturedEntryType = context.entryType;
    capturedEntryRefId = context.entryRefId;
    return totalCardCount;
  }

  @override
  Future<int> countDueCardsInScope(StudyContext context) async => dueCount;

  @override
  Future<StudySessionSnapshot?> findResumeCandidate(StudyContext context) async {
    final id = resumeSessionId;
    if (id == null) {
      return null;
    }
    return _snapshot(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

StudySessionSnapshot _snapshot(String sessionId) => StudySessionSnapshot(
  session: StudySession(
    id: sessionId,
    entryType: StudyEntryType.folder,
    entryRefId: 'folder-001',
    studyType: StudyType.srsReview,
    studyFlow: StudyFlow.srsFillReview,
    settings: const StudySettingsSnapshot(
      batchSize: 12,
      shuffleFlashcards: false,
      shuffleAnswers: false,
      prioritizeOverdue: true,
    ),
    status: SessionStatus.inProgress,
    startedAt: 0,
    endedAt: null,
    restartedFromSessionId: null,
  ),
  currentItem: null,
  sessionFlashcards: const <StudyFlashcardRef>[],
  summary: const StudySummary(
    totalCards: 0,
    completedAttempts: 0,
    correctAttempts: 0,
    incorrectAttempts: 0,
    increasedBoxCount: 0,
    decreasedBoxCount: 0,
    remainingCount: 0,
  ),
  canFinalize: false,
);
