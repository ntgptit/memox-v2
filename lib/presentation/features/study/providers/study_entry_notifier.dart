import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/study_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/study_models.dart';
import 'study_session_notifier.dart';

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
  const StudyEntryStartResult._({this.sessionId, this.error});

  const StudyEntryStartResult.started(String sessionId)
    : this._(sessionId: sessionId);

  const StudyEntryStartResult.rejected(Object error) : this._(error: error);

  final String? sessionId;
  final Object? error;
}

@Riverpod(keepAlive: true)
Future<StudyEntryState> studyEntryState(
  Ref ref,
  String entryType,
  String? entryRefId,
) async {
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

@riverpod
class StudyEntryActionController extends _$StudyEntryActionController {
  @override
  FutureOr<void> build(String entryType, String? entryRefId) {}

  Future<StudyEntryStartResult?> start({
    required StudyType studyType,
    required StudySettingsSnapshot settings,
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
          ? await ref.read(startStudySessionUseCaseProvider).execute(context)
          : await ref
                .read(restartStudySessionUseCaseProvider)
                .execute(sessionId: restartedFromSessionId, context: context);
      if (!ref.mounted) {
        return null;
      }
      ref.invalidate(studyEntryStateProvider(entryType, entryRefId));
      ref.read(studySessionDataRevisionProvider.notifier).bump();
      state = const AsyncData<void>(null);
      return StudyEntryStartResult.started(snapshot.session.id);
    } on ValidationException catch (error) {
      if (!ref.mounted) {
        return null;
      }
      state = const AsyncData<void>(null);
      return StudyEntryStartResult.rejected(error);
    } catch (error, stackTrace) {
      if (!ref.mounted) {
        return null;
      }
      state = AsyncError<void>(error, stackTrace);
      return null;
    }
  }
}

StudyEntryType _parseEntryType(String raw) {
  return StudyEntryType.values.firstWhere(
    (value) => value.storageValue == raw,
    orElse: () => throw ArgumentError.value(raw, 'entryType'),
  );
}
