import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/providers.dart';
import '../../../../app/di/study/study_settings_providers.dart';
import '../../../../app/di/study/study_usecase_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/empty_scope_reason.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../shared/providers/study_revision_providers.dart';

part 'study_entry_notifier.g.dart';

final class StudyEntryState {
  const StudyEntryState({
    required this.entryType,
    required this.entryRefId,
    required this.newStudyDefaults,
    required this.reviewDefaults,
    required this.resumeCandidate,
  });

  final StudyEntryType entryType;
  final String? entryRefId;
  final StudySettingsSnapshot newStudyDefaults;
  final StudySettingsSnapshot reviewDefaults;
  final StudySessionSnapshot? resumeCandidate;
}

final class StudyEntryStartResult {
  const StudyEntryStartResult._({this.sessionId, this.error, this.stackTrace});

  const StudyEntryStartResult.started(String sessionId)
    : this._(sessionId: sessionId);

  const StudyEntryStartResult.rejected(Object error, StackTrace stackTrace)
    : this._(error: error, stackTrace: stackTrace);

  final String? sessionId;
  final Object? error;
  final StackTrace? stackTrace;
}

@Riverpod(keepAlive: true)
Future<StudyEntryState> studyEntryState(
  Ref ref,
  String entryType,
  String? entryRefId,
) async {
  ref.watch(studySettingsDataRevisionProvider);
  ref.watch(studySessionDataRevisionProvider);
  final parsedEntryType = _parseEntryType(entryType);
  final store = await ref.watch(studySettingsStoreProvider.future);
  final newDefaults = store.loadNewStudyDefaults();
  final reviewDefaults = store.loadReviewDefaults();
  final resumeCandidate = await ref
      .watch(resumeStudySessionUseCaseProvider)
      .findCandidate(
        StudyContext(
          entryType: parsedEntryType,
          entryRefId: entryRefId,
          studyType: StudyType.srsReview,
          settings: reviewDefaults,
        ),
      );
  return StudyEntryState(
    entryType: parsedEntryType,
    entryRefId: entryRefId,
    newStudyDefaults: newDefaults,
    reviewDefaults: reviewDefaults,
    resumeCandidate: resumeCandidate,
  );
}

@Riverpod(keepAlive: true)
class StudyEntryActionController extends _$StudyEntryActionController {
  @override
  FutureOr<void> build(String entryType, String? entryRefId) {}

  /// Starts (or restarts) a study session for this entry. Always resolves to a
  /// [StudyEntryStartResult]: [StudyEntryStartResult.started] on success or
  /// [StudyEntryStartResult.rejected] (carrying the original error and stack
  /// trace) on any failure. It never returns null, so the presentation layer
  /// can surface the real root cause instead of synthesizing a placeholder
  /// "session was not started" error. The controller is `keepAlive` so an
  /// in-flight start is not disposed mid-await.
  Future<StudyEntryStartResult> start({
    required StudyType studyType,
    required StudySettingsSnapshot settings,
    List<StudyMode>? modes,
    String? restartedFromSessionId,
  }) async {
    state = const AsyncLoading<void>();
    try {
      final context = StudyContext(
        entryType: _parseEntryType(entryType),
        entryRefId: entryRefId,
        studyType: studyType,
        settings: settings,
      );
      final snapshot = restartedFromSessionId == null
          ? await ref
                .read(startStudySessionUseCaseProvider)
                .execute(context, modes: modes)
          : await ref
                .read(restartStudySessionUseCaseProvider)
                .execute(
                  sessionId: restartedFromSessionId,
                  context: context,
                  modes: modes,
                );
      final sessionId = snapshot.session.id;
      if (!ref.mounted) {
        return StudyEntryStartResult.started(sessionId);
      }
      ref.invalidate(studyEntryStateProvider(entryType, entryRefId));
      ref.read(studySessionDataRevisionProvider.notifier).bump();
      state = const AsyncData<void>(null);
      return StudyEntryStartResult.started(sessionId);
    } on EmptyScopeException catch (error, stackTrace) {
      if (ref.mounted) {
        state = const AsyncData<void>(null);
      }
      return StudyEntryStartResult.rejected(error, stackTrace);
    } on ValidationException catch (error, stackTrace) {
      if (ref.mounted) {
        state = const AsyncData<void>(null);
      }
      return StudyEntryStartResult.rejected(error, stackTrace);
    } catch (error, stackTrace) {
      if (ref.mounted) {
        ref
            .read(appLoggerProvider)
            .error(
              'Study entry start action failed. '
              'entryType=$entryType '
              'entryRefId=${entryRefId ?? '<null>'} '
              'studyType=${studyType.storageValue} '
              'modes=${modes?.map((mode) => mode.storageValue).join(',') ?? '<default>'} '
              'restartedFromSessionId=${restartedFromSessionId ?? '<null>'}',
              error,
              stackTrace,
            );
        state = AsyncError<void>(error, stackTrace);
      }
      return StudyEntryStartResult.rejected(error, stackTrace);
    }
  }
}

StudyEntryType _parseEntryType(String raw) => StudyEntryType.values.firstWhere(
  (value) => value.storageValue == raw,
  orElse: () => throw ArgumentError.value(raw, 'entryType'),
);
