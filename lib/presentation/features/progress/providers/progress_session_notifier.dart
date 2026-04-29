import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content_providers.dart';
import '../../../../app/di/study_providers.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../../domain/value_objects/content_queries.dart';
import '../../study/providers/study_session_notifier.dart';

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

  int get readySessionCount {
    return sessions
        .where(
          (snapshot) =>
              snapshot.session.status == SessionStatus.readyToFinalize,
        )
        .length;
  }

  int get failedSessionCount {
    return sessions
        .where(
          (snapshot) =>
              snapshot.session.status == SessionStatus.failedToFinalize,
        )
        .length;
  }
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
  final cardCount = library.folders.fold<int>(
    0,
    (sum, folder) => sum + folder.itemCount,
  );
  final weightedMasteryTotal = library.folders.fold<int>(
    0,
    (sum, folder) => sum + folder.itemCount * folder.masteryPercent,
  );

  return ProgressOverviewState(
    sessions: sessions,
    overdueCount: library.overdueCount,
    dueTodayCount: library.dueTodayCount,
    newCardCount: library.newCardCount,
    cardCount: cardCount,
    masteryPercent: cardCount == 0
        ? 0
        : (weightedMasteryTotal / cardCount).round(),
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
