import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/app.dart';
import 'package:memox/app/config/app_config.dart';
import 'package:memox/app/config/env.dart';
import 'package:memox/app/di/content/content_core_providers.dart';
import 'package:memox/app/di/providers.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/app/logging/app_talker.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/core/config/google_oauth_config.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/core/services/clock.dart';
import 'package:memox/core/services/id_generator.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/domain/enums/folder_content_mode.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/presentation/features/settings/providers/locale_notifier.dart';
import 'package:memox/presentation/features/settings/providers/theme_mode_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Size integrationTestCompactSurfaceSize = Size(412, 915);
const String _windowsE2EWindowSizeEnv = 'MEMOX_E2E_WINDOW_SIZE';

Future<IntegrationTestAppHandle> pumpTestApp(
  WidgetTester tester, {
  String initialLocation = RoutePaths.library,
  Size? surfaceSize,
  Map<String, Object> sharedPreferencesOverrides = const <String, Object>{},
  File? databaseFile,
  FixedTestClock? clock,
  SequenceTestIdGenerator? idGenerator,
  Future<void> Function(IntegrationTestAppHandle app)? seedData,
}) async {
  if (surfaceSize != null) {
    if (Platform.isWindows) {
      _expectWindowsNativeWindowSizeEnv(surfaceSize);
    } else {
      await tester.binding.setSurfaceSize(surfaceSize);
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }
  }

  SharedPreferences.setMockInitialValues(<String, Object>{
    AppConstants.sharedPrefsShuffleFlashcardsKey: false,
    AppConstants.sharedPrefsShuffleAnswersKey: false,
    AppConstants.sharedPrefsPrioritizeOverdueKey: false,
    AppConstants.sharedPrefsTtsAutoPlayKey: false,
    ...sharedPreferencesOverrides,
  });
  final sharedPreferences = await SharedPreferences.getInstance();

  final database = AppDatabase(
    executor: _openIntegrationDatabase(databaseFile),
  );
  await database.ensureOpen();

  final config = integrationTestConfig(initialLocation: initialLocation);
  final fakeTts = NoopTtsService();
  final handle = IntegrationTestAppHandle._(
    database: database,
    databaseFile: databaseFile,
    clock: clock ?? FixedTestClock(DateTime.utc(2026, 4, 28, 9)),
    idGenerator: idGenerator ?? SequenceTestIdGenerator(),
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
        sharedPreferencesProvider.overrideWith((_) async => sharedPreferences),
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

Future<File> createIntegrationTestDatabaseFile() async {
  final directory = await Directory.systemTemp.createTemp('memox_e2e_db_');
  addTearDown(() async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  });
  return File(
    '${directory.path}${Platform.pathSeparator}memox-integration.sqlite',
  );
}

Future<IntegrationTestAppHandle> restartTestApp(
  WidgetTester tester,
  IntegrationTestAppHandle app, {
  String initialLocation = RoutePaths.library,
  Size? surfaceSize,
  Map<String, Object> sharedPreferencesOverrides = const <String, Object>{},
}) async {
  final databaseFile = app.databaseFile;
  if (databaseFile == null) {
    fail('restartTestApp requires pumpTestApp(databaseFile: ...).');
  }

  final clock = app.clock;
  final idGenerator = app.idGenerator;
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await app.dispose();

  return pumpTestApp(
    tester,
    initialLocation: initialLocation,
    surfaceSize: surfaceSize,
    sharedPreferencesOverrides: sharedPreferencesOverrides,
    databaseFile: databaseFile,
    clock: clock,
    idGenerator: idGenerator,
  );
}

QueryExecutor _openIntegrationDatabase(File? databaseFile) {
  if (databaseFile == null) {
    return NativeDatabase.memory();
  }
  return NativeDatabase(databaseFile);
}

void _expectWindowsNativeWindowSizeEnv(Size expectedSize) {
  final expectedValue = _formatWindowSize(expectedSize);
  final rawValue = Platform.environment[_windowsE2EWindowSizeEnv]?.trim();
  if (rawValue == null || rawValue.isEmpty) {
    fail(
      'Windows E2E compact tests must resize the native app window before '
      'Flutter renders. Set $_windowsE2EWindowSizeEnv=$expectedValue.',
    );
  }

  final actualSize = _parseWindowSize(rawValue);
  if (actualSize == expectedSize) {
    return;
  }

  fail(
    'Windows E2E compact tests expected $_windowsE2EWindowSizeEnv='
    '$expectedValue, but got "$rawValue".',
  );
}

Size? _parseWindowSize(String value) {
  final parts = value.toLowerCase().split('x');
  if (parts.length != 2) {
    return null;
  }

  final width = int.tryParse(parts[0]);
  final height = int.tryParse(parts[1]);
  if (width == null || height == null || width <= 0 || height <= 0) {
    return null;
  }

  return Size(width.toDouble(), height.toDouble());
}

String _formatWindowSize(Size size) => '${size.width.toInt()}x${size.height.toInt()}';

AppConfig integrationTestConfig({required String initialLocation}) => AppConfig(
    env: AppEnv.local,
    initialLocation: initialLocation,
    showDebugBanner: false,
    enableRouterDiagnostics: false,
    enableTalkerConsoleLogs: false,
    enableTalkerRouteLogging: false,
    enableRiverpodDiagnostics: false,
    exposeInternalErrorDetails: true,
    googleOAuthConfig: GoogleOAuthConfig.fromValues(),
  );

final class IntegrationTestAppHandle {
  IntegrationTestAppHandle._({
    required this.database,
    required this.databaseFile,
    required this.clock,
    required this.idGenerator,
    required this.ttsService,
  });

  final AppDatabase database;
  final File? databaseFile;
  final FixedTestClock clock;
  final SequenceTestIdGenerator idGenerator;
  final NoopTtsService ttsService;

  var _disposed = false;

  Future<Folder> seedRootFolder({
    required String folderId,
    required String folderName,
    FolderContentMode contentMode = FolderContentMode.unlocked,
    int sortOrder = 0,
  }) async {
    final now = clock.nowEpochMillis() + sortOrder;
    await database
        .into(database.folders)
        .insert(
          FoldersCompanion.insert(
            id: folderId,
            name: folderName,
            contentMode: contentMode.storageValue,
            sortOrder: sortOrder,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return findFolderByName(folderName);
  }

  Future<Folder> seedSubfolder({
    required String parentFolderId,
    required String folderId,
    required String folderName,
    FolderContentMode contentMode = FolderContentMode.unlocked,
    int sortOrder = 0,
    bool lockParentToSubfolders = true,
  }) async {
    final now = clock.nowEpochMillis() + sortOrder;
    await database.transaction(() async {
      if (lockParentToSubfolders) {
        await (database.update(
          database.folders,
        )..where((table) => table.id.equals(parentFolderId))).write(
          FoldersCompanion(
            contentMode: Value(FolderContentMode.subfolders.storageValue),
            updatedAt: Value(now),
          ),
        );
      }
      await database
          .into(database.folders)
          .insert(
            FoldersCompanion.insert(
              id: folderId,
              parentId: Value(parentFolderId),
              name: folderName,
              contentMode: contentMode.storageValue,
              sortOrder: sortOrder,
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
    return findFolderByName(folderName);
  }

  Future<Deck> seedDeckInFolder({
    required String folderId,
    required String deckId,
    required String deckName,
    int sortOrder = 0,
    bool lockFolderToDecks = true,
  }) async {
    final now = clock.nowEpochMillis() + sortOrder;
    await database.transaction(() async {
      if (lockFolderToDecks) {
        await (database.update(
          database.folders,
        )..where((table) => table.id.equals(folderId))).write(
          FoldersCompanion(
            contentMode: Value(FolderContentMode.decks.storageValue),
            updatedAt: Value(now),
          ),
        );
      }
      await database
          .into(database.decks)
          .insert(
            DecksCompanion.insert(
              id: deckId,
              folderId: folderId,
              name: deckName,
              sortOrder: sortOrder,
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
    return findDeckByName(deckName);
  }

  Future<void> seedDeckWithFlashcard({
    required String folderId,
    required String deckId,
    required String flashcardId,
    required String folderName,
    required String deckName,
    required String front,
    required String back,
    String? note,
    int currentBox = 1,
    int reviewCount = 0,
    int lapseCount = 0,
    int? lastStudiedAt,
    int? dueAt,
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
            note: note == null ? const Value.absent() : Value(note),
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await _seedFlashcardProgress(
      flashcardId: flashcardId,
      now: now,
      currentBox: currentBox,
      reviewCount: reviewCount,
      lapseCount: lapseCount,
      lastStudiedAt: lastStudiedAt,
      dueAt: dueAt,
    );
  }

  Future<void> seedDeckWithFlashcardInFolder({
    required String folderId,
    required String deckId,
    required String deckName,
    required String flashcardId,
    required String front,
    required String back,
    String? note,
    int deckSortOrder = 0,
    int flashcardSortOrder = 0,
    bool lockFolderToDecks = true,
    int currentBox = 1,
    int reviewCount = 0,
    int lapseCount = 0,
    int? lastStudiedAt,
    int? dueAt,
  }) async {
    await seedDeckInFolder(
      folderId: folderId,
      deckId: deckId,
      deckName: deckName,
      sortOrder: deckSortOrder,
      lockFolderToDecks: lockFolderToDecks,
    );
    await seedFlashcardInDeck(
      deckId: deckId,
      flashcardId: flashcardId,
      front: front,
      back: back,
      note: note,
      sortOrder: flashcardSortOrder,
      currentBox: currentBox,
      reviewCount: reviewCount,
      lapseCount: lapseCount,
      lastStudiedAt: lastStudiedAt,
      dueAt: dueAt,
    );
  }

  Future<void> seedFlashcardInDeck({
    required String deckId,
    required String flashcardId,
    required String front,
    required String back,
    String? note,
    int sortOrder = 0,
    int currentBox = 1,
    int reviewCount = 0,
    int lapseCount = 0,
    int? lastStudiedAt,
    int? dueAt,
  }) async {
    final now = clock.nowEpochMillis() + sortOrder;
    await database.transaction(() async {
      await database
          .into(database.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: flashcardId,
              deckId: deckId,
              front: front,
              back: back,
              note: note == null ? const Value.absent() : Value(note),
              sortOrder: sortOrder,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _seedFlashcardProgress(
        flashcardId: flashcardId,
        now: now,
        currentBox: currentBox,
        reviewCount: reviewCount,
        lapseCount: lapseCount,
        lastStudiedAt: lastStudiedAt,
        dueAt: dueAt,
      );
    });
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

  Future<Folder> findFolderByName(String name) => (database.select(
      database.folders,
    )..where((table) => table.name.equals(name))).getSingle();

  Future<Folder?> findFolderByNameOrNull(String name) => (database.select(
      database.folders,
    )..where((table) => table.name.equals(name))).getSingleOrNull();

  Future<Deck> findDeckByName(String name) => (database.select(
      database.decks,
    )..where((table) => table.name.equals(name))).getSingle();

  Future<Deck?> findDeckByNameOrNull(String name) => (database.select(
      database.decks,
    )..where((table) => table.name.equals(name))).getSingleOrNull();

  Future<List<Deck>> listDecksInFolder(String folderId) => (database.select(database.decks)
          ..where((table) => table.folderId.equals(folderId))
          ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
        .get();

  Future<List<Flashcard>> listFlashcardsInDeck(String deckId) => (database.select(database.flashcards)
          ..where((table) => table.deckId.equals(deckId))
          ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
        .get();

  Future<FlashcardProgressData> findProgressByFlashcardId(String flashcardId) => (database.select(
      database.flashcardProgress,
    )..where((table) => table.flashcardId.equals(flashcardId))).getSingle();

  Future<FlashcardProgressData?> findProgressByFlashcardIdOrNull(
    String flashcardId,
  ) => (database.select(database.flashcardProgress)
          ..where((table) => table.flashcardId.equals(flashcardId)))
        .getSingleOrNull();

  Future<List<String>> latestOriginalStudySessionFlashcardIds() async {
    final session =
        await (database.select(database.studySessions)
              ..orderBy([(table) => OrderingTerm.desc(table.startedAt)])
              ..limit(1))
            .getSingle();
    final items =
        await (database.select(database.studySessionItems)
              ..where(
                (table) =>
                    table.sessionId.equals(session.id) &
                    table.modeOrder.equals(1) &
                    table.roundIndex.equals(1),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.queuePosition)]))
            .get();
    return items.map((item) => item.flashcardId).toList(growable: false);
  }

  Future<void> _seedFlashcardProgress({
    required String flashcardId,
    required int now,
    int currentBox = 1,
    int reviewCount = 0,
    int lapseCount = 0,
    int? lastStudiedAt,
    int? dueAt,
  }) => database
        .into(database.flashcardProgress)
        .insert(
          FlashcardProgressCompanion.insert(
            flashcardId: flashcardId,
            currentBox: currentBox,
            reviewCount: reviewCount,
            lapseCount: lapseCount,
            createdAt: now,
            updatedAt: now,
            lastStudiedAt: Value(lastStudiedAt),
            dueAt: Value(dueAt),
          ),
        );

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
  Future<List<TtsVoice>> availableVoices(TtsLanguage language) async => const <TtsVoice>[];

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
