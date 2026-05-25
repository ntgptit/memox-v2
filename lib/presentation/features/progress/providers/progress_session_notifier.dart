import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content/content_revision_providers.dart';
import '../../../../app/di/content/folder_providers.dart';
import '../../../../app/di/study/study_usecase_providers.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../../../shared/providers/study_revision_providers.dart';
import '../../../shared/viewmodels/mx_async_action_runner.dart';

part 'progress_session_notifier.g.dart';

@immutable
final class ProgressOverviewState {
  const ProgressOverviewState({
    required this.sessions,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.newCardCount,
    required this.cardCount,
    required this.masteryPercent,
  });

  final List<StudySessionSnapshot> sessions;
  final int overdueCount;
  final int dueTodayCount;
  final int newCardCount;
  final int cardCount;
  final int masteryPercent;

  int get reviewCount => overdueCount + dueTodayCount;
  int get activeSessionCount => sessions.length;

  int get readySessionCount => sessions
      .where(
        (snapshot) => snapshot.session.status == SessionStatus.readyToFinalize,
      )
      .length;

  int get failedSessionCount => sessions
      .where(
        (snapshot) => snapshot.session.status == SessionStatus.failedToFinalize,
      )
      .length;
}

@Riverpod(keepAlive: true)
Future<ProgressOverviewState> progressOverview(Ref ref) async {
  ref.watch(contentDataRevisionProvider);
  ref.watch(studySessionDataRevisionProvider);

  final library = await ref
      .watch(watchLibraryOverviewUseCaseProvider)
      .execute(const ContentQuery());
  final sessions = await ref
      .watch(resumeStudySessionUseCaseProvider)
      .listActiveSessions();
  return ProgressOverviewState(
    sessions: sessions,
    overdueCount: library.overdueCount,
    dueTodayCount: library.dueTodayCount,
    newCardCount: library.newCardCount,
    cardCount: library.cardCount,
    masteryPercent: library.masteryPercent,
  );
}

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

  Future<bool> cancel(String sessionId) async => _executeMutation(
    () => ref.read(cancelStudySessionUseCaseProvider).execute(sessionId),
  );

  Future<bool> finalize(StudySessionSnapshot snapshot) async =>
      _executeMutation(
        () => ref
            .read(finalizeStudySessionUseCaseProvider)
            .execute(
              sessionId: snapshot.session.id,
              studyType: snapshot.session.studyType,
            ),
      );

  Future<bool> retryFinalize(StudySessionSnapshot snapshot) async =>
      _executeMutation(
        () => ref
            .read(retryFinalizeUseCaseProvider)
            .execute(
              sessionId: snapshot.session.id,
              studyType: snapshot.session.studyType,
            ),
      );

  Future<bool> _executeMutation(Future<void> Function() action) async =>
      _actionRunner.run(action, onSuccess: _refresh);

  MxAsyncActionRunner get _actionRunner => MxAsyncActionRunner(
    isMounted: () => ref.mounted,
    setState: (nextState) => state = nextState,
  );

  void _refresh() {
    ref.read(studySessionDataRevisionProvider.notifier).bump();
  }
}
