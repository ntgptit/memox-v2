part of 'settings_screen_test.dart';

Future<_SettingsHarness> _pumpSettings(
  WidgetTester tester, {
  Widget child = const SettingsScreen(),
  MediaQueryData? mediaQueryData,
  Future<StudySettingsStore>? studySettingsStoreFuture,
  Future<TtsSettingsRepository>? ttsSettingsRepositoryFuture,
  Future<String>? appVersionLabelFuture,
  GoogleOAuthConfig? googleConfig,
  GoogleAccountAuthService? googleAuth,
  DriveSyncRepository? driveSyncRepository,
  bool settle = true,
}) async {
  final fakeTts = _FakeTtsService();
  final database = AppDatabase(executor: NativeDatabase.memory());
  final effectiveGoogleAuth = googleAuth ?? _FakeGoogleAccountAuthService();
  final effectiveDriveSyncRepository =
      driveSyncRepository ??
      _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus.signedOut(),
      );
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      appVersionLabelProvider.overrideWith(
        (ref) =>
            appVersionLabelFuture ?? Future<String>.value('1.4.2 (build 248)'),
      ),
      ttsServiceProvider.overrideWithValue(fakeTts),
      driveSyncRepositoryProvider.overrideWith(
        (ref) async => effectiveDriveSyncRepository,
      ),
      driveSyncRuntimeEffectsProvider.overrideWithValue(
        _FakeDriveSyncRuntimeEffects(),
      ),
      if (googleConfig != null)
        googleOAuthConfigProvider.overrideWithValue(googleConfig),
      googleAccountAuthServiceProvider.overrideWithValue(effectiveGoogleAuth),
      if (studySettingsStoreFuture != null)
        studySettingsStoreProvider.overrideWith(
          (ref) => studySettingsStoreFuture,
        ),
      if (ttsSettingsRepositoryFuture != null)
        ttsSettingsRepositoryProvider.overrideWith(
          (ref) => ttsSettingsRepositoryFuture,
        ),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(database.close);
  addTearDown(fakeTts.dispose);
  if (effectiveGoogleAuth is _FakeGoogleAccountAuthService) {
    addTearDown(effectiveGoogleAuth.dispose);
  }

  final effectiveChild = mediaQueryData == null
      ? child
      : MediaQuery(data: mediaQueryData, child: child);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _TestApp(child: effectiveChild),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }

  return _SettingsHarness(container: container, tts: fakeTts);
}

Future<_SettingsHarness> _pumpSettingsRouter(
  WidgetTester tester, {
  GoogleOAuthConfig? googleConfig,
  GoogleAccountAuthService? googleAuth,
  DriveSyncRepository? driveSyncRepository,
  Future<String>? appVersionLabelFuture,
}) async {
  final fakeTts = _FakeTtsService();
  final database = AppDatabase(executor: NativeDatabase.memory());
  final effectiveGoogleAuth = googleAuth ?? _FakeGoogleAccountAuthService();
  final effectiveDriveSyncRepository =
      driveSyncRepository ??
      _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus.signedOut(),
      );
  final container = ProviderContainer(
    overrides: [
      appDatabaseProvider.overrideWithValue(database),
      appVersionLabelProvider.overrideWith(
        (ref) =>
            appVersionLabelFuture ?? Future<String>.value('1.4.2 (build 248)'),
      ),
      ttsServiceProvider.overrideWithValue(fakeTts),
      driveSyncRepositoryProvider.overrideWith(
        (ref) async => effectiveDriveSyncRepository,
      ),
      driveSyncRuntimeEffectsProvider.overrideWithValue(
        _FakeDriveSyncRuntimeEffects(),
      ),
      if (googleConfig != null)
        googleOAuthConfigProvider.overrideWithValue(googleConfig),
      googleAccountAuthServiceProvider.overrideWithValue(effectiveGoogleAuth),
      // Tag management screen watches a live Drift stream. Override with an
      // immediately-completing stream so pumpAndSettle can settle and no timer
      // leaks into subsequent tests.
      tagListProvider.overrideWith(
        (_) => Stream<List<TagWithCount>>.value(const <TagWithCount>[]),
      ),
    ],
  );
  final router = GoRouter(
    initialLocation: RoutePaths.settings,
    routes: [
      GoRoute(
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(
            path: RoutePaths.settingsAccountSegment,
            name: RouteNames.settingsAccount,
            builder: (context, state) => const AccountSettingsScreen(),
          ),
          GoRoute(
            path: RoutePaths.settingsLearningSegment,
            name: RouteNames.settingsLearning,
            builder: (context, state) => const LearningSettingsScreen(),
          ),
          GoRoute(
            path: RoutePaths.settingsLearningTagsSegment,
            name: RouteNames.settingsLearningTags,
            builder: (context, state) => const SettingsTagManagementScreen(),
          ),
          GoRoute(
            path: RoutePaths.settingsAudioSpeechSegment,
            name: RouteNames.settingsAudioSpeech,
            builder: (context, state) => const AudioSpeechSettingsScreen(),
          ),
        ],
      ),
    ],
  );

  addTearDown(container.dispose);
  addTearDown(database.close);
  addTearDown(router.dispose);
  addTearDown(fakeTts.dispose);
  if (effectiveGoogleAuth is _FakeGoogleAccountAuthService) {
    addTearDown(effectiveGoogleAuth.dispose);
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _RouterTestApp(router: router),
    ),
  );
  await tester.pumpAndSettle();

  return _SettingsHarness(container: container, tts: fakeTts);
}

final class _SettingsHarness {
  const _SettingsHarness({required this.container, required this.tts});

  final ProviderContainer container;
  final _FakeTtsService tts;
}

final class _FakeTtsSettingsRepository implements TtsSettingsRepository {
  _FakeTtsSettingsRepository({TtsSettings? settings})
    : settings = settings ?? TtsSettings.defaults;

  TtsSettings settings;

  @override
  Future<TtsSettings> load() async => settings;

  @override
  Future<void> save(TtsSettings settings) async {
    this.settings = settings;
  }
}

MxCard _overviewCardForKey(WidgetTester tester, String key) =>
    tester.widget<MxCard>(_overviewCardFinderForKey(key).first);

Finder _overviewCardFinderForKey(String key) => find.ancestor(
  of: find.byKey(ValueKey<String>(key)),
  matching: find.byType(MxCard),
);

final class _FakeDriveSyncRepository implements DriveSyncRepository {
  _FakeDriveSyncRepository({
    DriveSyncStatus? loadStatusResult,
    List<DriveSyncStatus>? loadStatusResults,
    DriveSyncRunResult? uploadResult,
    DriveSyncRunResult? restoreResult,
    this.loadStatusError,
  }) : loadStatusResult = loadStatusResult ?? const DriveSyncStatus.signedOut(),
       _loadStatusResults = loadStatusResults?.toList() ?? <DriveSyncStatus>[],
       uploadResult =
           uploadResult ??
           const DriveSyncRunResult.noChanges(DriveSyncStatus.signedOut()),
       restoreResult =
           restoreResult ??
           const DriveSyncRunResult.noChanges(DriveSyncStatus.signedOut());

  DriveSyncStatus loadStatusResult;
  final List<DriveSyncStatus> _loadStatusResults;
  final DriveSyncRunResult uploadResult;
  final DriveSyncRunResult restoreResult;
  final Object? loadStatusError;
  int uploadLocalCount = 0;
  int restoreDriveCount = 0;

  @override
  Future<DriveSyncStatus> loadStatus() async {
    final error = loadStatusError;
    if (error != null) {
      throw error;
    }
    if (_loadStatusResults.isNotEmpty) {
      return _loadStatusResults.removeAt(0);
    }
    return loadStatusResult;
  }

  @override
  Future<DriveSyncRunResult> uploadLocalSnapshot() async {
    uploadLocalCount += 1;
    return uploadResult;
  }

  @override
  Future<DriveSyncRunResult> restoreDriveSnapshot() async {
    restoreDriveCount += 1;
    return restoreResult;
  }
}

final class _FakeDriveSyncRuntimeEffects implements DriveSyncRuntimeEffects {
  @override
  Future<void> apply(DriveSyncRestoreEffect effect) async {}
}

final _configuredGoogle = GoogleOAuthConfig.fromValues(
  webClientId: 'web-client-id.apps.googleusercontent.com',
  serverClientId: 'server-client-id.apps.googleusercontent.com',
);

const _driveReadyLink = CloudAccountLink(
  provider: CloudProvider.google,
  subjectId: 'google-user-001',
  email: 'alex@memox.app',
  displayName: 'MemoX User',
  photoUrl: null,
  grantedScopes: <String>{googleDriveAppDataScope},
  driveAuthorizationState: DriveAuthorizationState.authorized,
  linkedAt: 1,
  lastSignedInAt: 1,
);

DriveSyncRemoteSnapshot _remoteSnapshot() => const DriveSyncRemoteSnapshot(
  manifest: DriveSyncManifest(
    manifestVersion: DriveSyncManifest.currentManifestVersion,
    snapshotFormatVersion: DriveSyncManifest.currentSnapshotFormatVersion,
    appId: DriveSyncManifest.currentAppId,
    appDatabaseSchemaVersion: 6,
    createdAt: 1,
    deviceId: 'remote-device',
    deviceLabel: 'Remote device',
    databaseSha256: 'db',
    settingsSha256: 'settings',
    snapshotSizeBytes: 2,
  ),
  manifestFileId: 'manifest-file',
  manifestFileVersion: 'manifest-version',
  snapshotFileId: 'snapshot-file',
  snapshotFileVersion: 'snapshot-version',
  modifiedAt: 1,
);

const _driveMissingLink = CloudAccountLink(
  provider: CloudProvider.google,
  subjectId: 'google-user-001',
  email: 'alex@memox.app',
  displayName: 'MemoX User',
  photoUrl: null,
  grantedScopes: <String>{},
  driveAuthorizationState: DriveAuthorizationState.authorizationRequired,
  linkedAt: 1,
  lastSignedInAt: 1,
);

GoogleAccountAuthSession _session({
  required Set<String> grantedScopes,
  required DriveAuthorizationState driveAuthorizationState,
}) => GoogleAccountAuthSession(
  profile: const GoogleAccountProfile(
    subjectId: 'google-user-001',
    email: 'alex@memox.app',
    displayName: 'MemoX User',
    photoUrl: null,
  ),
  grantedScopes: grantedScopes,
  driveAuthorizationState: driveAuthorizationState,
);

final class _FakeGoogleAccountAuthService implements GoogleAccountAuthService {
  _FakeGoogleAccountAuthService({
    this.restoreResult = const GoogleAccountAuthResult.signedOut(),
    this.restoreFuture,
    this.signInResult = const GoogleAccountAuthResult.signedOut(),
    this.signInFuture,
    this.requiresPlatformSignInButton = false,
  });

  final StreamController<GoogleAccountAuthResult> _events =
      StreamController<GoogleAccountAuthResult>.broadcast();

  GoogleAccountAuthResult restoreResult;
  Future<GoogleAccountAuthResult>? restoreFuture;
  GoogleAccountAuthResult signInResult;
  Future<GoogleAccountAuthResult>? signInFuture;
  @override
  final bool requiresPlatformSignInButton;
  int signOutCount = 0;

  @override
  Stream<GoogleAccountAuthResult> get authenticationEvents => _events.stream;

  @override
  bool get supportsInteractiveSignIn => true;

  @override
  Future<void> initialize(GoogleOAuthConfig config) async {}

  @override
  Future<GoogleAccountAuthResult> restoreLightweightSession(
    GoogleOAuthConfig config,
  ) async => restoreFuture ?? restoreResult;

  @override
  Future<GoogleAccountAuthResult> signInAndAuthorizeDriveAppData(
    GoogleOAuthConfig config,
  ) async => signInFuture ?? signInResult;

  @override
  Future<GoogleAccountAuthResult> authorizeDriveAppData(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  ) async => signInFuture ?? signInResult;

  @override
  Future<DriveAccessTokenResult> getDriveAppDataAccessToken(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  ) async => const DriveAccessTokenResult.reauthorizationRequired();

  @override
  Future<void> signOutLocal() async {
    signOutCount += 1;
  }

  @override
  Future<void> disconnect() async {
    signOutCount += 1;
  }

  void emit(GoogleAccountAuthResult result) {
    _events.add(result);
  }

  Future<void> dispose() => _events.close();
}

final class _SpeakCall {
  const _SpeakCall({
    required this.text,
    required this.language,
    required this.rate,
    required this.pitch,
    required this.volume,
    this.voiceName,
  });

  final String text;
  final TtsLanguage language;
  final double rate;
  final double pitch;
  final double volume;
  final String? voiceName;
}

final class _FakeTtsService implements TtsService {
  final StreamController<TtsState> _states =
      StreamController<TtsState>.broadcast();

  final List<TtsLanguage> availableVoiceRequests = <TtsLanguage>[];
  final List<_SpeakCall> speakCalls = <_SpeakCall>[];
  int stopCount = 0;

  @override
  Stream<TtsState> get state => _states.stream;

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguage language) async {
    availableVoiceRequests.add(language);
    return [
      TtsVoice(
        name: '${language.localeTag.toLowerCase()}-x-ism-local',
        language: language,
        gender: 'male',
      ),
      TtsVoice(
        name: '${language.localeTag.toLowerCase()}-x-ism-network',
        language: language,
      ),
    ];
  }

  @override
  Future<void> speak(
    String text, {
    required TtsLanguage language,
    required double rate,
    required double pitch,
    required double volume,
    String? voiceName,
  }) async {
    speakCalls.add(
      _SpeakCall(
        text: text,
        language: language,
        rate: rate,
        pitch: pitch,
        volume: volume,
        voiceName: voiceName,
      ),
    );
    if (!_states.isClosed) {
      _states.add(TtsState.speaking);
    }
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
    if (!_states.isClosed) {
      _states.add(TtsState.idle);
    }
  }

  @override
  Future<void> dispose() async {
    await _states.close();
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

class _RouterTestApp extends StatelessWidget {
  const _RouterTestApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: ThemeMode.dark,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}
