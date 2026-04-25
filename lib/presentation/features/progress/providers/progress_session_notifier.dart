import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/study_providers.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../study/providers/study_session_notifier.dart';

part 'progress_session_notifier.g.dart';

@Riverpod(keepAlive: true)
Future<List<StudySessionSnapshot>> progressStudySessions(Ref ref) {
  ref.watch(studySessionDataRevisionProvider);
  return ref.watch(resumeStudySessionUseCaseProvider).listActiveSessions();
}

@riverpod
class ProgressSessionActionController
    extends _$ProgressSessionActionController {
  @override
  FutureOr<void> build() {}

  Future<bool> cancel(String sessionId) async {
    state = const AsyncLoading<void>();
    try {
      await ref.read(cancelStudySessionUseCaseProvider).execute(sessionId);
      if (!ref.mounted) {
        return false;
      }
      _refresh();
      state = const AsyncData<void>(null);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) {
        return false;
      }
      state = AsyncError<void>(error, stackTrace);
      return false;
    }
  }

  Future<bool> finalize(StudySessionSnapshot snapshot) async {
    state = const AsyncLoading<void>();
    try {
      await ref
          .read(finalizeStudySessionUseCaseProvider)
          .execute(
            sessionId: snapshot.session.id,
            studyType: snapshot.session.studyType,
          );
      if (!ref.mounted) {
        return false;
      }
      _refresh();
      state = const AsyncData<void>(null);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) {
        return false;
      }
      state = AsyncError<void>(error, stackTrace);
      return false;
    }
  }

  Future<bool> retryFinalize(StudySessionSnapshot snapshot) async {
    state = const AsyncLoading<void>();
    try {
      await ref
          .read(retryFinalizeUseCaseProvider)
          .execute(
            sessionId: snapshot.session.id,
            studyType: snapshot.session.studyType,
          );
      if (!ref.mounted) {
        return false;
      }
      _refresh();
      state = const AsyncData<void>(null);
      return true;
    } catch (error, stackTrace) {
      if (!ref.mounted) {
        return false;
      }
      state = AsyncError<void>(error, stackTrace);
      return false;
    }
  }

  void _refresh() {
    ref.read(studySessionDataRevisionProvider.notifier).bump();
  }
}
