import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/app.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/config/env.dart';
import 'package:memox/app/di/content_providers.dart';
import 'package:memox/app/di/providers.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/app/logging/app_talker.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/core/services/clock.dart';
import 'package:memox/core/services/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/enums/folder_content_mode.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/presentation/features/settings/providers/locale_notifier.dart';
import 'package:memox/presentation/features/settings/providers/theme_mode_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Size integrationTestCompactSurfaceSize = Size(390, 844);

Future<IntegrationTestAppHandle> pumpTestApp(
  WidgetTester tester, {
  String initialLocation = RoutePaths.library,
  Size? surfaceSize,
  Map<String, Object> sharedPreferencesOverrides = const <String, Object>{},
  Future<void> Function(IntegrationTestAppHandle app)? seedData,
}) async {
  if (surfaceSize != null) {
    await tester.binding.setSurfaceSize(surfaceSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  SharedPreferences.setMockInitialValues(<String, Object>{
    AppConstants.sharedPrefsShuffleFlashcardsKey: false,
    AppConstants.sharedPrefsShuffleAnswersKey: false,
    AppConstants.sharedPrefsPrioritizeOverdueKey: false,
    AppConstants.sharedPrefsTtsAutoPlayKey: false,
    ...sharedPreferencesOverrides,
  });

  final database = AppDatabase(executor: NativeDatabase.memory());
  await database.ensureOpen();

  final config = integrationTestConfig(initialLocation: initialLocation);
  final fakeTts = NoopTtsService();
  final handle = IntegrationTestAppHandle._(
    database: database,
    clock: FixedTestClock(DateTime.utc(2026, 4, 28, 9)),
    idGenerator: SequenceTestIdGenerator(),
    ttsService: fakeTts,
  );
  addTearDown(handle.dispose);

  if (seedData != null) {
    await seedData(handle);
  }

  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 10));
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(AppEnv.local),
        appConfigProvider.overrideWithValue(config),
        talkerProvider.overrideWithValue(createAppTalker(config)),
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(handle.clock),
        idGeneratorProvider.overrideWithValue(handle.idGenerator),
        ttsServiceProvider.overrideWithValue(fakeTts),
        localeProvider.overrideWithValue(const Locale('en')),
        themeModeProvider.overrideWithValue(ThemeMode.light),
      ],
      child: const MemoxApp(),
    ),
  );
  await tester.pump();

  return handle;
}

AppConfig integrationTestConfig({required String initialLocation}) {
  return AppConfig(
    env: AppEnv.local,
    initialLocation: initialLocation,
    showDebugBanner: false,
    enableRouterDiagnostics: false,
    enableTalkerConsoleLogs: false,
    enableTalkerRouteLogging: false,
    enableRiverpodDiagnostics: false,
    exposeInternalErrorDetails: true,
  );
}

final class IntegrationTestAppHandle {
  IntegrationTestAppHandle._({
    required this.database,
    required this.clock,
    required this.idGenerator,
    required this.ttsService,
  });

  final AppDatabase database;
  final FixedTestClock clock;
  final SequenceTestIdGenerator idGenerator;
  final NoopTtsService ttsService;

  var _disposed = false;

  Future<void> seedDeckWithFlashcard({
    required String folderId,
    required String deckId,
    required String flashcardId,
    required String folderName,
    required String deckName,
    required String front,
    required String back,
  }) async {
    final now = clock.nowEpochMillis();
    await database
        .into(database.folders)
        .insert(
          FoldersCompanion.insert(
            id: folderId,
            name: folderName,
            contentMode: FolderContentMode.decks.storageValue,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.decks)
        .insert(
          DecksCompanion.insert(
            id: deckId,
            folderId: folderId,
            name: deckName,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.flashcards)
        .insert(
          FlashcardsCompanion.insert(
            id: flashcardId,
            deckId: deckId,
            front: front,
            back: back,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> seedDeckWithoutFlashcards({
    required String folderId,
    required String deckId,
    required String folderName,
    required String deckName,
  }) async {
    final now = clock.nowEpochMillis();
    await database
        .into(database.folders)
        .insert(
          FoldersCompanion.insert(
            id: folderId,
            name: folderName,
            contentMode: FolderContentMode.decks.storageValue,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.decks)
        .insert(
          DecksCompanion.insert(
            id: deckId,
            folderId: folderId,
            name: deckName,
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await database.close();
    await ttsService.dispose();
  }
}

final class FixedTestClock implements Clock {
  FixedTestClock(this._current);

  DateTime _current;

  @override
  DateTime nowUtc() => _current;

  @override
  int nowEpochMillis() => _current.millisecondsSinceEpoch;

  void advance(Duration duration) {
    _current = _current.add(duration);
  }
}

final class SequenceTestIdGenerator implements IdGenerator {
  var _counter = 0;

  @override
  String nextId() {
    final value = _counter.toString().padLeft(4, '0');
    _counter += 1;
    return 'e2e-id-$value';
  }
}

final class NoopTtsService implements TtsService {
  final StreamController<TtsState> _stateController =
      StreamController<TtsState>.broadcast();

  @override
  Stream<TtsState> get state => _stateController.stream;

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguage language) async {
    return const <TtsVoice>[];
  }

  @override
  Future<void> speak(
    String text, {
    required TtsLanguage language,
    required double rate,
    String? voiceName,
  }) async {
    _stateController.add(TtsState.speaking);
    _stateController.add(TtsState.idle);
  }

  @override
  Future<void> stop() async {
    _stateController.add(TtsState.idle);
  }

  @override
  Future<void> dispose() async {
    await _stateController.close();
  }
}
