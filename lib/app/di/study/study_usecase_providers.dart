import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/study/usecases/study_usecases.dart';
import 'study_data_providers.dart';
import 'study_strategy_providers.dart';

part 'study_usecase_providers.g.dart';

@riverpod
StartStudySessionUseCase startStudySessionUseCase(Ref ref) {
  return StartStudySessionUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}

@riverpod
ResumeStudySessionUseCase resumeStudySessionUseCase(Ref ref) {
  return ResumeStudySessionUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}

@riverpod
RestartStudySessionUseCase restartStudySessionUseCase(Ref ref) {
  return RestartStudySessionUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}

@riverpod
AnswerFlashcardUseCase answerFlashcardUseCase(Ref ref) {
  return AnswerFlashcardUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}

@riverpod
AnswerCurrentModeBatchUseCase answerCurrentModeBatchUseCase(Ref ref) {
  return AnswerCurrentModeBatchUseCase(
    repository: ref.watch(studyRepoProvider),
    flowStrategyFactory: ref.watch(studyStrategyFactoryProvider),
    modeStrategyFactory: ref.watch(studyModeStrategyFactoryProvider),
  );
}

@riverpod
AnswerCurrentModeItemGradesBatchUseCase answerCurrentModeItemGradesBatchUseCase(
  Ref ref,
) {
  return AnswerCurrentModeItemGradesBatchUseCase(
    repository: ref.watch(studyRepoProvider),
    flowStrategyFactory: ref.watch(studyStrategyFactoryProvider),
    modeStrategyFactory: ref.watch(studyModeStrategyFactoryProvider),
  );
}

@riverpod
AnswerCurrentMatchModeBatchUseCase answerCurrentMatchModeBatchUseCase(Ref ref) {
  return AnswerCurrentMatchModeBatchUseCase(
    repository: ref.watch(studyRepoProvider),
    flowStrategyFactory: ref.watch(studyStrategyFactoryProvider),
    modeStrategyFactory: ref.watch(studyModeStrategyFactoryProvider),
  );
}

@riverpod
SkipFlashcardUseCase skipFlashcardUseCase(Ref ref) {
  return SkipFlashcardUseCase(ref.watch(studyRepoProvider));
}

@riverpod
CancelStudySessionUseCase cancelStudySessionUseCase(Ref ref) {
  return CancelStudySessionUseCase(ref.watch(studyRepoProvider));
}

@riverpod
FinalizeStudySessionUseCase finalizeStudySessionUseCase(Ref ref) {
  return FinalizeStudySessionUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}

@riverpod
RetryFinalizeUseCase retryFinalizeUseCase(Ref ref) {
  return RetryFinalizeUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}
