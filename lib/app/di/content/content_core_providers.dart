import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/clock.dart';
import '../../../core/services/id_generator.dart';
import '../../../data/datasources/local/local_transaction_runner.dart';
import '../providers.dart';

part 'content_core_providers.g.dart';

@riverpod
Clock clock(Ref ref) {
  return const SystemClock();
}

@riverpod
IdGenerator idGenerator(Ref ref) {
  return RandomIdGenerator();
}

@riverpod
LocalTransactionRunner localTransactionRunner(Ref ref) {
  return LocalTransactionRunner(ref.watch(appDatabaseProvider));
}
