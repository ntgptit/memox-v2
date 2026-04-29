import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/study_providers.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/study_models.dart';
import '../../../../domain/study/study_settings_policy.dart';

part 'study_settings_defaults_notifier.g.dart';

@immutable
final class StudyDefaultsSettingsState {
  const StudyDefaultsSettingsState({
    required this.newStudyDefaults,
    required this.reviewDefaults,
  });

  final StudySettingsSnapshot newStudyDefaults;
  final StudySettingsSnapshot reviewDefaults;

  bool get shuffleFlashcards => newStudyDefaults.shuffleFlashcards;
  bool get shuffleAnswers => newStudyDefaults.shuffleAnswers;
  bool get prioritizeOverdue => newStudyDefaults.prioritizeOverdue;
}

@Riverpod(keepAlive: true)
class StudySettingsDataRevision extends _$StudySettingsDataRevision {
  @override
  int build() => 0;

  void bump() {
    state += 1;
  }
}

@Riverpod(keepAlive: true)
class StudyDefaultsSettings extends _$StudyDefaultsSettings {
  @override
  Future<StudyDefaultsSettingsState> build() async {
    return _load();
  }

  // guard:retry-reviewed
  Future<void> setNewStudyBatchSize(int value) {
    return _update(
      (current) => StudyDefaultsSettingsState(
        newStudyDefaults: _copySettings(
          current.newStudyDefaults,
          batchSize: StudySettingsPolicy.clampBatchSize(
            value,
            StudyType.newStudy,
          ),
        ),
        reviewDefaults: current.reviewDefaults,
      ),
    );
  }

  // guard:retry-reviewed
  Future<void> setReviewBatchSize(int value) {
    return _update(
      (current) => StudyDefaultsSettingsState(
        newStudyDefaults: current.newStudyDefaults,
        reviewDefaults: _copySettings(
          current.reviewDefaults,
          batchSize: StudySettingsPolicy.clampBatchSize(
            value,
            StudyType.srsReview,
          ),
        ),
      ),
    );
  }

  // guard:retry-reviewed
  Future<void> setShuffleFlashcards(bool value) {
    return _updateShared(shuffleFlashcards: value);
  }

  // guard:retry-reviewed
  Future<void> setShuffleAnswers(bool value) {
    return _updateShared(shuffleAnswers: value);
  }

  // guard:retry-reviewed
  Future<void> setPrioritizeOverdue(bool value) {
    return _updateShared(prioritizeOverdue: value);
  }

  Future<StudyDefaultsSettingsState> _load() async {
    final store = await ref.watch(studySettingsStoreProvider.future);
    return StudyDefaultsSettingsState(
      newStudyDefaults: store.loadNewStudyDefaults(),
      reviewDefaults: store.loadReviewDefaults(),
    );
  }

  Future<void> _update(
    StudyDefaultsSettingsState Function(StudyDefaultsSettingsState current)
    buildNext,
  ) async {
    final current = state.value ?? await future;
    if (!ref.mounted) {
      return;
    }
    final next = buildNext(current);
    try {
      final store = await ref.read(studySettingsStoreProvider.future);
      if (!ref.mounted) {
        return;
      }
      await store.saveNewStudyDefaults(next.newStudyDefaults);
      if (!ref.mounted) {
        return;
      }
      await store.saveReviewDefaults(next.reviewDefaults);
      if (!ref.mounted) {
        return;
      }
      state = AsyncData(next);
      ref.read(studySettingsDataRevisionProvider.notifier).bump();
    } catch (error, stackTrace) {
      state = AsyncError<StudyDefaultsSettingsState>(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> _updateShared({
    bool? shuffleFlashcards,
    bool? shuffleAnswers,
    bool? prioritizeOverdue,
  }) {
    return _update((current) {
      final nextNewStudy = _copySettings(
        current.newStudyDefaults,
        shuffleFlashcards:
            shuffleFlashcards ?? current.newStudyDefaults.shuffleFlashcards,
        shuffleAnswers:
            shuffleAnswers ?? current.newStudyDefaults.shuffleAnswers,
        prioritizeOverdue:
            prioritizeOverdue ?? current.newStudyDefaults.prioritizeOverdue,
      );
      final nextReview = _copySettings(
        current.reviewDefaults,
        shuffleFlashcards:
            shuffleFlashcards ?? current.reviewDefaults.shuffleFlashcards,
        shuffleAnswers: shuffleAnswers ?? current.reviewDefaults.shuffleAnswers,
        prioritizeOverdue:
            prioritizeOverdue ?? current.reviewDefaults.prioritizeOverdue,
      );
      return StudyDefaultsSettingsState(
        newStudyDefaults: nextNewStudy,
        reviewDefaults: nextReview,
      );
    });
  }
}

StudySettingsSnapshot _copySettings(
  StudySettingsSnapshot settings, {
  int? batchSize,
  bool? shuffleFlashcards,
  bool? shuffleAnswers,
  bool? prioritizeOverdue,
}) {
  return StudySettingsSnapshot(
    batchSize: batchSize ?? settings.batchSize,
    shuffleFlashcards: shuffleFlashcards ?? settings.shuffleFlashcards,
    shuffleAnswers: shuffleAnswers ?? settings.shuffleAnswers,
    prioritizeOverdue: prioritizeOverdue ?? settings.prioritizeOverdue,
  );
}
