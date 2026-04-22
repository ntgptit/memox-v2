import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/local/app_database.dart';
import '../config/app_config.dart';
import '../config/env.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AppEnv appEnv(Ref ref) {
  return AppEnv.fromEnvironment();
}

@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) {
  final env = ref.watch(appEnvProvider);
  return AppConfig.fromEnv(env);
}

@Riverpod(keepAlive: true)
ConnectivityService connectivityService(Ref ref) {
  final service = ConnectivityService(
    debounce: AppConstants.connectivityDebounce,
  );
  ref.onDispose(service.dispose);
  return service;
}

@Riverpod(keepAlive: true)
NetworkInfo networkInfo(Ref ref) {
  return ref.watch(connectivityServiceProvider);
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(() {
    unawaited(database.close());
  });
  return database;
}
