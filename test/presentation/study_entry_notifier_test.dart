import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/core/errors/app_exception.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
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
