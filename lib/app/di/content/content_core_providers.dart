import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/services/clock.dart';
import '../../../core/services/id_generator.dart';
import '../../../data/datasources/local/local_transaction_runner.dart';
import '../providers.dart';

part 'content_core_providers.g.dart';

@riverpod
Clock clock(Ref ref) => const SystemClock();

@riverpod
IdGenerator idGenerator(Ref ref) => RandomIdGenerator();

@Riverpod(keepAlive: true)
LocalTransactionRunner localTransactionRunner(Ref ref) =>
    LocalTransactionRunner(ref.watch(appDatabaseProvider));
