import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/network/connectivity_service.dart';
import '../../core/network/network_info.dart';
import '../../core/services/app_info_service.dart';
import '../../data/datasources/local/app_database.dart';
import '../config/app_config.dart';
import '../config/env.dart';
import '../logging/app_talker.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) =>
    SharedPreferences.getInstance();

@Riverpod(keepAlive: true)
AppEnv appEnv(Ref ref) => AppEnv.fromEnvironment();

@Riverpod(keepAlive: true)
AppConfig appConfig(Ref ref) {
  final env = ref.watch(appEnvProvider);
  return AppConfig.fromEnv(env);
}

@Riverpod(keepAlive: true)
Talker talker(Ref ref) {
  final config = ref.watch(appConfigProvider);
  return createAppTalker(config);
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
NetworkInfo networkInfo(Ref ref) => ref.watch(connectivityServiceProvider);

@Riverpod(keepAlive: true)
AppInfoService appInfoService(Ref ref) => const PackageInfoAppInfoService();

/// Cached app version label such as `1.0.0+1`. Resolved once at startup via
/// `PackageInfo.fromPlatform()` and reused for every Drive backup manifest.
@Riverpod(keepAlive: true)
Future<String> appVersionLabel(Ref ref) async {
  final service = ref.watch(appInfoServiceProvider);
  final info = await service.load();
  return info.fullLabel;
}

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final database = AppDatabase();
  ref.onDispose(() {
    unawaited(database.close());
  });
  return database;
}
