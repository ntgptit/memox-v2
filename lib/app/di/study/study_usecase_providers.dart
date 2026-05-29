import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../domain/study/usecases/study_usecases.dart';
import 'study_data_providers.dart';
import 'study_strategy_providers.dart';

part 'study_usecase_providers.g.dart';

@riverpod
StartStudySessionUseCase startStudySessionUseCase(Ref ref) =>
    StartStudySessionUseCase(
      repository: ref.watch(studyRepoProvider),
      strategyFactory: ref.watch(studyStrategyFactoryProvider),
    );

@riverpod
ResumeStudySessionUseCase resumeStudySessionUseCase(Ref ref) =>
    ResumeStudySessionUseCase(
      repository: ref.watch(studyRepoProvider),
      strategyFactory: ref.watch(studyStrategyFactoryProvider),
    );

@riverpod
RestartStudySessionUseCase restartStudySessionUseCase(Ref ref) =>
    RestartStudySessionUseCase(
      repository: ref.watch(studyRepoProvider),
      strategyFactory: ref.watch(studyStrategyFactoryProvider),
    );

@riverpod
AnswerFlashcardUseCase answerFlashcardUseCase(Ref ref) =>
    AnswerFlashcardUseCase(
      repository: ref.watch(studyRepoProvider),
      strategyFactory: ref.watch(studyStrategyFactoryProvider),
    );

@riverpod
AnswerCurrentModeBatchUseCase answerCurrentModeBatchUseCase(Ref ref) =>
    AnswerCurrentModeBatchUseCase(
      repository: ref.watch(studyRepoProvider),
      flowStrategyFactory: ref.watch(studyStrategyFactoryProvider),
      modeStrategyFactory: ref.watch(studyModeStrategyFactoryProvider),
    );

@riverpod
AnswerCurrentModeItemGradesBatchUseCase answerCurrentModeItemGradesBatchUseCase(
  Ref ref,
) => AnswerCurrentModeItemGradesBatchUseCase(
  repository: ref.watch(studyRepoProvider),
  flowStrategyFactory: ref.watch(studyStrategyFactoryProvider),
  modeStrategyFactory: ref.watch(studyModeStrategyFactoryProvider),
);

@riverpod
AnswerCurrentMatchModeBatchUseCase answerCurrentMatchModeBatchUseCase(
  Ref ref,
) => AnswerCurrentMatchModeBatchUseCase(
  repository: ref.watch(studyRepoProvider),
  flowStrategyFactory: ref.watch(studyStrategyFactoryProvider),
  modeStrategyFactory: ref.watch(studyModeStrategyFactoryProvider),
);

@riverpod
SkipFlashcardUseCase skipFlashcardUseCase(Ref ref) =>
    SkipFlashcardUseCase(ref.watch(studyRepoProvider));

@riverpod
DropCurrentStudyItemUseCase dropCurrentStudyItemUseCase(Ref ref) =>
    DropCurrentStudyItemUseCase(ref.watch(studyRepoProvider));

@riverpod
CancelStudySessionUseCase cancelStudySessionUseCase(Ref ref) =>
    CancelStudySessionUseCase(ref.watch(studyRepoProvider));

@riverpod
FinalizeStudySessionUseCase finalizeStudySessionUseCase(Ref ref) =>
    FinalizeStudySessionUseCase(
      repository: ref.watch(studyRepoProvider),
      strategyFactory: ref.watch(studyStrategyFactoryProvider),
    );

@riverpod
RetryFinalizeUseCase retryFinalizeUseCase(Ref ref) => RetryFinalizeUseCase(
  repository: ref.watch(studyRepoProvider),
  strategyFactory: ref.watch(studyStrategyFactoryProvider),
);

@riverpod
BuryFlashcardUseCase buryFlashcardUseCase(Ref ref) =>
    BuryFlashcardUseCase(ref.watch(studyRepoProvider));

@riverpod
UnburyFlashcardUseCase unburyFlashcardUseCase(Ref ref) =>
    UnburyFlashcardUseCase(ref.watch(studyRepoProvider));

@riverpod
SuspendFlashcardUseCase suspendFlashcardUseCase(Ref ref) =>
    SuspendFlashcardUseCase(ref.watch(studyRepoProvider));

@riverpod
UnsuspendFlashcardUseCase unsuspendFlashcardUseCase(Ref ref) =>
    UnsuspendFlashcardUseCase(ref.watch(studyRepoProvider));
