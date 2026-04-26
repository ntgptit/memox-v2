import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/daos/study_attempt_dao.dart';
import '../../data/datasources/local/daos/study_session_dao.dart';
import '../../data/datasources/local/daos/study_session_item_dao.dart';
import '../../data/repositories/study_repo_impl.dart';
import '../../data/settings/study_settings_store.dart';
import '../../domain/study/ports/study_repo.dart';
import '../../domain/study/strategy/study_mode_strategy.dart';
import '../../domain/study/strategy/study_strategy.dart';
import '../../domain/study/strategy/study_strategy_factory.dart';
import '../../domain/study/usecases/study_usecases.dart';
import 'content_providers.dart';
import 'providers.dart';

part 'study_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
Future<StudySettingsStore> studySettingsStore(Ref ref) async {
  return StudySettingsStore(await ref.watch(sharedPreferencesProvider.future));
}

@Riverpod(keepAlive: true)
StudySessionDao studySessionDao(Ref ref) {
  return StudySessionDao(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
StudySessionItemDao studySessionItemDao(Ref ref) {
  return StudySessionItemDao(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
StudyAttemptDao studyAttemptDao(Ref ref) {
  return StudyAttemptDao(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
StudyFlowStrategyFactory studyStrategyFactory(Ref ref) {
  return StudyFlowStrategyFactory(const <StudyFlowStrategy>[
    NewStudyStrategy(),
    SrsReviewStrategy(),
  ]);
}

@Riverpod(keepAlive: true)
StudyModeStrategyFactory studyModeStrategyFactory(Ref ref) {
  return StudyModeStrategyFactory(const <StudyModeStrategy>[
    ReviewModeStrategy(),
    MatchModeStrategy(),
    GuessModeStrategy(),
    RecallModeStrategy(),
    FillModeStrategy(),
  ]);
}

@Riverpod(keepAlive: true)
StudyRepo studyRepo(Ref ref) {
  return StudyRepoImpl(
    database: ref.watch(appDatabaseProvider),
    studySessionDao: ref.watch(studySessionDaoProvider),
    studySessionItemDao: ref.watch(studySessionItemDaoProvider),
    studyAttemptDao: ref.watch(studyAttemptDaoProvider),
    folderDao: ref.watch(folderDaoProvider),
    transactionRunner: ref.watch(localTransactionRunnerProvider),
    clock: ref.watch(clockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
  );
}

@Riverpod(keepAlive: true)
StartStudySessionUseCase startStudySessionUseCase(Ref ref) {
  return StartStudySessionUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}

@Riverpod(keepAlive: true)
ResumeStudySessionUseCase resumeStudySessionUseCase(Ref ref) {
  return ResumeStudySessionUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}

@Riverpod(keepAlive: true)
RestartStudySessionUseCase restartStudySessionUseCase(Ref ref) {
  return RestartStudySessionUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}

@Riverpod(keepAlive: true)
AnswerFlashcardUseCase answerFlashcardUseCase(Ref ref) {
  return AnswerFlashcardUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}

@Riverpod(keepAlive: true)
AnswerCurrentModeBatchUseCase answerCurrentModeBatchUseCase(Ref ref) {
  return AnswerCurrentModeBatchUseCase(
    repository: ref.watch(studyRepoProvider),
    flowStrategyFactory: ref.watch(studyStrategyFactoryProvider),
    modeStrategyFactory: ref.watch(studyModeStrategyFactoryProvider),
  );
}

@Riverpod(keepAlive: true)
AnswerCurrentModeItemGradesBatchUseCase answerCurrentModeItemGradesBatchUseCase(
  Ref ref,
) {
  return AnswerCurrentModeItemGradesBatchUseCase(
    repository: ref.watch(studyRepoProvider),
    flowStrategyFactory: ref.watch(studyStrategyFactoryProvider),
    modeStrategyFactory: ref.watch(studyModeStrategyFactoryProvider),
  );
}

@Riverpod(keepAlive: true)
AnswerCurrentMatchModeBatchUseCase answerCurrentMatchModeBatchUseCase(Ref ref) {
  return AnswerCurrentMatchModeBatchUseCase(
    repository: ref.watch(studyRepoProvider),
    flowStrategyFactory: ref.watch(studyStrategyFactoryProvider),
    modeStrategyFactory: ref.watch(studyModeStrategyFactoryProvider),
  );
}

@Riverpod(keepAlive: true)
SkipFlashcardUseCase skipFlashcardUseCase(Ref ref) {
  return SkipFlashcardUseCase(ref.watch(studyRepoProvider));
}

@Riverpod(keepAlive: true)
CancelStudySessionUseCase cancelStudySessionUseCase(Ref ref) {
  return CancelStudySessionUseCase(ref.watch(studyRepoProvider));
}

@Riverpod(keepAlive: true)
FinalizeStudySessionUseCase finalizeStudySessionUseCase(Ref ref) {
  return FinalizeStudySessionUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}

@Riverpod(keepAlive: true)
RetryFinalizeUseCase retryFinalizeUseCase(Ref ref) {
  return RetryFinalizeUseCase(
    repository: ref.watch(studyRepoProvider),
    strategyFactory: ref.watch(studyStrategyFactoryProvider),
  );
}
