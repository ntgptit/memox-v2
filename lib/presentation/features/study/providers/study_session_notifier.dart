import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/study_providers.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/study_models.dart';

part 'study_session_notifier.g.dart';

const _defaultAnswerDistractorLimit = 3;
const _guessAnswerDistractorLimit = 4;

@Riverpod(keepAlive: true)
class StudySessionDataRevision extends _$StudySessionDataRevision {
  @override
  int build() => 0;

  void bump() {
    state += 1;
  }
}

@Riverpod(keepAlive: true)
Future<StudySessionSnapshot> studySessionState(Ref ref, String sessionId) {
  return ref.watch(resumeStudySessionUseCaseProvider).execute(sessionId);
}

@riverpod
class StudySessionActionController extends _$StudySessionActionController {
  @override
  FutureOr<void> build(String sessionId) {}

  Future<bool> answer(AttemptGrade grade) async {
    state = const AsyncLoading<void>();
    final snapshot = await ref.read(
      studySessionStateProvider(sessionId).future,
    );
    if (!ref.mounted) {
      return false;
    }
    try {
      await ref
          .read(answerFlashcardUseCaseProvider)
          .execute(
            sessionId: sessionId,
            studyType: snapshot.session.studyType,
            grade: grade,
          );
      if (!ref.mounted) {
        return false;
      }
      _refreshStudySessionReadModels();
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

  Future<bool> answerCurrentReviewModeAsCorrect() async {
    state = const AsyncLoading<void>();
    final snapshot = await ref.read(
      studySessionStateProvider(sessionId).future,
    );
    if (!ref.mounted) {
      return false;
    }
    try {
      await ref
          .read(answerCurrentModeBatchUseCaseProvider)
          .execute(
            sessionId: sessionId,
            studyType: snapshot.session.studyType,
          );
      if (!ref.mounted) {
        return false;
      }
      _refreshStudySessionReadModels();
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

  Future<bool> answerCurrentModeItemGradesBatch(
    Map<String, AttemptGrade> itemGrades,
  ) async {
    state = const AsyncLoading<void>();
    final snapshot = await ref.read(
      studySessionStateProvider(sessionId).future,
    );
    if (!ref.mounted) {
      return false;
    }
    try {
      await ref
          .read(answerCurrentModeItemGradesBatchUseCaseProvider)
          .execute(
            sessionId: sessionId,
            studyType: snapshot.session.studyType,
            itemGrades: itemGrades,
          );
      if (!ref.mounted) {
        return false;
      }
      _refreshStudySessionReadModels();
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

  Future<bool> skip() async {
    state = const AsyncLoading<void>();
    await ref.read(studySessionStateProvider(sessionId).future);
    if (!ref.mounted) {
      return false;
    }
    try {
      await ref.read(skipFlashcardUseCaseProvider).execute(sessionId);
      if (!ref.mounted) {
        return false;
      }
      _refreshStudySessionReadModels();
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

  Future<bool> cancel() async {
    state = const AsyncLoading<void>();
    await ref.read(studySessionStateProvider(sessionId).future);
    if (!ref.mounted) {
      return false;
    }
    try {
      await ref.read(cancelStudySessionUseCaseProvider).execute(sessionId);
      if (!ref.mounted) {
        return false;
      }
      _refreshStudySessionReadModels();
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

  Future<bool> finalizeSession() async {
    state = const AsyncLoading<void>();
    final snapshot = await ref.read(
      studySessionStateProvider(sessionId).future,
    );
    if (!ref.mounted) {
      return false;
    }
    try {
      await ref
          .read(finalizeStudySessionUseCaseProvider)
          .execute(sessionId: sessionId, studyType: snapshot.session.studyType);
      if (!ref.mounted) {
        return false;
      }
      _refreshStudySessionReadModels();
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

  void _refreshStudySessionReadModels() {
    ref.invalidate(studySessionStateProvider(sessionId));
    ref.read(studySessionDataRevisionProvider.notifier).bump();
  }
}

List<StudyFlashcardRef> studyAnswerOptions(StudySessionSnapshot snapshot) {
  return _studyAnswerOptions(
    snapshot,
    distractorLimit: _defaultAnswerDistractorLimit,
  );
}

List<StudyFlashcardRef> studyGuessAnswerOptions(StudySessionSnapshot snapshot) {
  return _studyAnswerOptions(
    snapshot,
    distractorLimit: _guessAnswerDistractorLimit,
  );
}

List<StudyFlashcardRef> _studyAnswerOptions(
  StudySessionSnapshot snapshot, {
  required int distractorLimit,
}) {
  final item = snapshot.currentItem;
  if (item == null) {
    return const <StudyFlashcardRef>[];
  }
  final distractors = snapshot.sessionFlashcards
      .where((flashcard) => flashcard.id != item.flashcard.id)
      .toList(growable: true);
  distractors.shuffle(
    Random(
      _stableSeed(
        '${snapshot.session.id}:${item.id}:${item.studyMode.storageValue}:${item.flashcard.id}',
      ),
    ),
  );
  final optionIds = <String>{
    item.flashcard.id,
    for (final distractor in distractors.take(distractorLimit)) distractor.id,
  };
  final options = snapshot.sessionFlashcards
      .where((flashcard) => optionIds.contains(flashcard.id))
      .toList(growable: true);
  if (!snapshot.session.settings.shuffleAnswers) {
    return options;
  }
  options.shuffle(
    Random(
      _stableSeed(
        '${item.id}:${item.flashcard.id}:${snapshot.session.settings.shuffleAnswers}',
      ),
    ),
  );
  return options;
}

AppFailure? studyActionError(AsyncValue<void> actionState) {
  return actionState.whenOrNull(
    error: (error, _) => error is AppFailure ? error : null,
  );
}

String studyErrorMessage(Object? error) {
  if (error is AppFailure) {
    if (error.cause case final ValidationException cause) {
      return cause.message;
    }
    return error.message;
  }
  if (error is ValidationException) {
    return error.message;
  }
  return 'Study action failed.';
}

int _stableSeed(String raw) {
  var hash = 0;
  for (final codeUnit in raw.codeUnits) {
    hash = 0x1fffffff & (hash + codeUnit);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash ^= hash >> 6;
  }
  return hash;
}
