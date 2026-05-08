import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../data/datasources/local/daos/study_attempt_dao.dart';
import '../../../data/datasources/local/daos/study_session_dao.dart';
import '../../../data/datasources/local/daos/study_session_item_dao.dart';
import '../../../data/repositories/study_repo_impl.dart';
import '../../../domain/study/ports/study_repo.dart';
import '../../logging/app_talker.dart';
import '../content/content_core_providers.dart';
import '../content/content_data_providers.dart';
import '../providers.dart';

part 'study_data_providers.g.dart';

@riverpod
StudySessionDao studySessionDao(Ref ref) {
  return StudySessionDao(ref.watch(appDatabaseProvider));
}

@riverpod
StudySessionItemDao studySessionItemDao(Ref ref) {
  return StudySessionItemDao(ref.watch(appDatabaseProvider));
}

@riverpod
StudyAttemptDao studyAttemptDao(Ref ref) {
  return StudyAttemptDao(ref.watch(appDatabaseProvider));
}

@riverpod
Random studyShuffleRandom(Ref ref) {
  return Random();
}

@riverpod
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
    shuffleRandom: ref.watch(studyShuffleRandomProvider),
    logger: TalkerAppLogger(ref.watch(talkerProvider)),
  );
}
