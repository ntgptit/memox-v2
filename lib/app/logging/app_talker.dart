import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import '../config/app_config.dart';

const int _maxTalkerHistoryItems = 500;
const String _unhandledErrorMessage = 'Unhandled MemoX app error';

Talker createAppTalker([AppConfig? config]) {
  return TalkerFlutter.init(settings: _talkerSettings(config));
}

void configureAppTalker(Talker talker, AppConfig config) {
  talker.configure(settings: _talkerSettings(config));
}

List<ProviderObserver> createAppProviderObservers({
  required Talker talker,
  required AppConfig config,
}) {
  if (!config.enableRiverpodDiagnostics) {
    return const <ProviderObserver>[];
  }

  return <ProviderObserver>[
    TalkerRiverpodObserver(
      talker: talker,
      settings: const TalkerRiverpodLoggerSettings(
        printProviderAdded: true,
        printProviderUpdated: true,
        printProviderDisposed: false,
        printProviderFailed: true,
        printStateFullData: false,
        printFailFullData: true,
        printMutationStart: true,
        printMutationSuccess: true,
        printMutationFailed: true,
        printMutationReset: false,
      ),
    ),
  ];
}

void reportAppErrorToTalker(
  Talker talker,
  Object error,
  StackTrace stackTrace,
) {
  talker.handle(error, stackTrace, _unhandledErrorMessage);
}

TalkerSettings _talkerSettings(AppConfig? config) {
  return TalkerSettings(
    useHistory: true,
    useConsoleLogs: config?.enableTalkerConsoleLogs ?? true,
    maxHistoryItems: _maxTalkerHistoryItems,
  );
}
