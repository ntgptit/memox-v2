import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/study/study_usecase_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../shared/providers/study_revision_providers.dart';
import '../../../shared/viewmodels/mx_action_errors.dart';
import '../../../shared/viewmodels/mx_async_action_runner.dart';

part 'study_session_notifier.g.dart';

@Riverpod(keepAlive: true)
Future<StudySessionSnapshot> studySessionState(Ref ref, String sessionId) =>
    ref.watch(resumeStudySessionUseCaseProvider).execute(sessionId);

@riverpod
class StudySessionActionController extends _$StudySessionActionController {
  @override
  FutureOr<void> build(String sessionId) {}

  Future<bool> answer(AttemptGrade grade) async => _executeWithCurrentSession(
    (snapshot) => ref
        .read(answerFlashcardUseCaseProvider)
        .execute(
          sessionId: sessionId,
          studyType: snapshot.session.studyType,
          grade: grade,
        ),
  );

  Future<bool> answerCurrentReviewModeAsCorrect() async =>
      _executeWithCurrentSession(
        (snapshot) => ref
            .read(answerCurrentModeBatchUseCaseProvider)
            .execute(
              sessionId: sessionId,
              studyType: snapshot.session.studyType,
            ),
      );

  Future<bool> answerCurrentModeItemGradesBatch(
    Map<String, AttemptGrade> itemGrades,
  ) async => _executeWithCurrentSession(
    (snapshot) => ref
        .read(answerCurrentModeItemGradesBatchUseCaseProvider)
        .execute(
          sessionId: sessionId,
          studyType: snapshot.session.studyType,
          itemGrades: itemGrades,
        ),
  );

  Future<bool> skip() async => _executeWithCurrentSession(
    (_) => ref.read(skipFlashcardUseCaseProvider).execute(sessionId),
  );

  Future<bool> cancel() async => _executeWithCurrentSession(
    (_) => ref.read(cancelStudySessionUseCaseProvider).execute(sessionId),
  );

  /// Buries the current card and removes it from the active session (it does
  /// not reappear this session). Returns the buried card id (for the undo
  /// toast) or null when there is no current card / on failure.
  Future<String?> buryCurrentCard() => _mutateCurrentCard((card) async {
    await ref.read(buryFlashcardUseCaseProvider).execute(card.id);
    await ref.read(dropCurrentStudyItemUseCaseProvider).execute(sessionId);
  });

  /// Suspends the current card and removes it from the active session (it does
  /// not reappear this session). Returns the suspended card id (for the undo
  /// toast) or null when unavailable / on failure.
  Future<String?> suspendCurrentCard() => _mutateCurrentCard((card) async {
    await ref.read(suspendFlashcardUseCaseProvider).execute(card.id);
    await ref.read(dropCurrentStudyItemUseCaseProvider).execute(sessionId);
  });

  Future<void> unburyCard(String flashcardId) => _executeMutation(
    () => ref.read(unburyFlashcardUseCaseProvider).execute(flashcardId),
  );

  Future<void> unsuspendCard(String flashcardId) => _executeMutation(
    () => ref.read(unsuspendFlashcardUseCaseProvider).execute(flashcardId),
  );

  Future<String?> _mutateCurrentCard(
    Future<void> Function(StudyFlashcardRef card) action,
  ) async {
    state = const AsyncLoading<void>();
    final snapshot = await ref.read(
      studySessionStateProvider(sessionId).future,
    );
    if (!ref.mounted) {
      return null;
    }
    final card = snapshot.currentItem?.flashcard;
    if (card == null) {
      state = const AsyncData<void>(null);
      return null;
    }
    final succeeded = await _executeMutation(() => action(card));
    return succeeded ? card.id : null;
  }

  Future<bool> finalizeSession() async => _executeWithCurrentSession(
    (snapshot) => ref
        .read(finalizeStudySessionUseCaseProvider)
        .execute(sessionId: sessionId, studyType: snapshot.session.studyType),
  );

  Future<bool> _executeWithCurrentSession(
    Future<void> Function(StudySessionSnapshot snapshot) action,
  ) async {
    state = const AsyncLoading<void>();
    final snapshot = await ref.read(
      studySessionStateProvider(sessionId).future,
    );
    if (!ref.mounted) {
      return false;
    }
    return _executeMutation(() => action(snapshot));
  }

  Future<bool> _executeMutation(Future<void> Function() action) async =>
      _actionRunner.run(action, onSuccess: _refreshStudySessionReadModels);

  MxAsyncActionRunner get _actionRunner => MxAsyncActionRunner(
    isMounted: () => ref.mounted,
    setState: (nextState) => state = nextState,
  );

  void _refreshStudySessionReadModels() {
    ref.invalidate(studySessionStateProvider(sessionId));
    ref.read(studySessionDataRevisionProvider.notifier).bump();
  }
}

AppFailure? studyActionError(AsyncValue<void> actionState) =>
    MxActionErrors.failureOf(actionState);

String studyErrorMessage(Object? error) {
  if (error is AppFailure) {
    return MxActionErrors.messageOf(error);
  }
  if (error is ValidationException) {
    return error.message;
  }
  return 'Study action failed.';
}
