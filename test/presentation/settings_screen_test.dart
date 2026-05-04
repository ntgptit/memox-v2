import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/account_providers.dart';
import 'package:memox/app/di/sync_providers.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/services/drive_sync_runtime_effects.dart';
import 'package:memox/core/config/google_oauth_config.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/data/settings/cloud_account_store.dart';
import 'package:memox/data/settings/study_settings_store.dart';
import 'package:memox/data/settings/tts_settings_store.dart';
import 'package:memox/domain/entities/cloud_account_link.dart';
import 'package:memox/domain/entities/drive_sync_models.dart';
import 'package:memox/domain/repositories/drive_sync_repository.dart';
import 'package:memox/domain/services/google_account_auth_service.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/providers/locale_notifier.dart';
import 'package:memox/presentation/features/settings/providers/theme_mode_notifier.dart';
import 'package:memox/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox/presentation/features/study/providers/study_settings_defaults_notifier.dart';
import 'package:memox/presentation/features/tts/providers/tts_settings_notifier.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/mx_segmented_control.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _speechPreviewButtonKey = ValueKey<String>(
  'settings-speech-preview-button',
);
const _speechVoiceOptionsButtonKey = ValueKey<String>(
  'settings-speech-voice-options-button',
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DT1 onOpen: renders settings page with default controls', (
    tester,
  ) async {
    final harness = await _pumpSettings(tester);

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('No Google account is linked.'), findsOneWidget);
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('System'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('English'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('English'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Study defaults'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Study defaults'), findsOneWidget);
    expect(harness.tts.availableVoiceRequests, isEmpty);
  });

  testWidgets(
    'DT2 onOpen: renders study defaults through shared loading state',
    (tester) async {
      final completer = Completer<StudySettingsStore>();
      addTearDown(() async {
        if (!completer.isCompleted) {
          completer.complete(
            StudySettingsStore(await SharedPreferences.getInstance()),
          );
        }
      });

      await _pumpSettings(
        tester,
        settle: false,
        studySettingsStoreFuture: completer.future,
      );
      await tester.scrollUntilVisible(
        find.text('Study defaults'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Study defaults'), findsOneWidget);
      expect(find.text('Loading study defaults'), findsOneWidget);
      expect(find.byType(MxLoadingState), findsOneWidget);
    },
  );

  testWidgets(
    'DT3 onOpen: renders speech settings through shared loading state',
    (tester) async {
      final completer = Completer<TtsSettingsStore>();
      addTearDown(() async {
        if (!completer.isCompleted) {
          completer.complete(
            TtsSettingsStore(await SharedPreferences.getInstance()),
          );
        }
      });

      await _pumpSettings(
        tester,
        settle: false,
        ttsSettingsStoreFuture: completer.future,
      );
      await tester.scrollUntilVisible(
        find.text('Loading speech settings'),
        300,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Speech'), findsOneWidget);
      expect(find.text('Loading speech settings'), findsOneWidget);
      expect(find.byType(MxLoadingState), findsOneWidget);
    },
  );

  testWidgets('DT1 onDisplay: shows theme and language sections', (
    tester,
  ) async {
    await _pumpSettings(tester);

    expect(find.text('Appearance'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Language'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
  });

  testWidgets(
    'DT5 onDisplay: disables Google sign-in when OAuth config is missing',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await _pumpSettings(tester);

        final signInButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Sign in with Google'),
        );

        expect(
          find.text('Add Google OAuth client IDs to enable account linking.'),
          findsOneWidget,
        );
        expect(signInButton.onPressed, isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    },
  );

  testWidgets('DT6 onDisplay: shows linked Google account with Drive ready', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final store = CloudAccountStore(preferences);
    await store.save(_driveReadyLink);

    await _pumpSettings(
      tester,
      googleConfig: _configuredGoogle,
      googleAuth: _FakeGoogleAccountAuthService(
        restoreResult: GoogleAccountAuthResult.success(
          _session(
            grantedScopes: const <String>{googleDriveAppDataScope},
            driveAuthorizationState: DriveAuthorizationState.authorized,
          ),
        ),
      ),
    );

    expect(find.text('MemoX User'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('Google Drive ready'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets(
    'DT7 onDisplay: shows reconnect state when Drive scope is missing',
    (tester) async {
      final preferences = await SharedPreferences.getInstance();
      final store = CloudAccountStore(preferences);
      await store.save(_driveMissingLink);

      await _pumpSettings(
        tester,
        googleConfig: _configuredGoogle,
        googleAuth: _FakeGoogleAccountAuthService(
          restoreResult: GoogleAccountAuthResult.driveAuthorizationRequired(
            _session(
              grantedScopes: const <String>{},
              driveAuthorizationState:
                  DriveAuthorizationState.authorizationRequired,
            ),
          ),
        ),
      );

      expect(find.text('MemoX User'), findsOneWidget);
      expect(find.text('Google Drive reconnect required'), findsOneWidget);
      expect(find.text('Reconnect Google Drive'), findsOneWidget);
    },
  );

  testWidgets(
    'DT8 onDisplay: renders platform Google button for web reconnect state',
    (tester) async {
      final preferences = await SharedPreferences.getInstance();
      final store = CloudAccountStore(preferences);
      await store.save(_driveMissingLink);

      await _pumpSettings(
        tester,
        googleConfig: _configuredGoogle,
        googleAuth: _FakeGoogleAccountAuthService(
          requiresPlatformSignInButton: true,
          restoreResult: GoogleAccountAuthResult.driveAuthorizationRequired(
            _session(
              grantedScopes: const <String>{},
              driveAuthorizationState:
                  DriveAuthorizationState.authorizationRequired,
            ),
          ),
        ),
      );

      expect(find.text('Google Drive reconnect required'), findsOneWidget);
      expect(find.text('Reconnect Google Drive'), findsNothing);
      expect(find.text('Sign out'), findsOneWidget);
    },
  );

  testWidgets(
    'DT9 onDisplay: shows Drive sync group disabled while signed out',
    (tester) async {
      await _pumpSettings(tester);

      expect(find.text('Drive sync'), findsOneWidget);
      expect(
        find.text('Sign in with Google to sync the local database with Drive.'),
        findsNothing,
      );
      final syncButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sync now'),
      );
      expect(syncButton.onPressed, isNull);
    },
  );

  testWidgets(
    'DT10 onDisplay: shows Drive sync action when Google Drive is ready',
    (tester) async {
      final repository = _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
      );

      await _pumpSettings(tester, driveSyncRepository: repository);

      expect(find.text('Drive sync'), findsOneWidget);
      expect(
        find.text('Create the first Drive backup from this device.'),
        findsNothing,
      );
      final syncButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Sync now'),
      );
      expect(syncButton.onPressed, isNotNull);
    },
  );

  testWidgets(
    'DT11 onDisplay: compact top settings groups fit first phone viewport',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final preferences = await SharedPreferences.getInstance();
      final store = CloudAccountStore(preferences);
      await store.save(_driveReadyLink);
      final repository = _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
      );

      await _pumpSettings(
        tester,
        googleConfig: _configuredGoogle,
        googleAuth: _FakeGoogleAccountAuthService(
          restoreResult: GoogleAccountAuthResult.success(
            _session(
              grantedScopes: const <String>{googleDriveAppDataScope},
              driveAuthorizationState: DriveAuthorizationState.authorized,
            ),
          ),
        ),
        driveSyncRepository: repository,
      );

      final viewportHeight =
          tester.view.physicalSize.height / tester.view.devicePixelRatio;

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Drive sync'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(
        tester.getRect(find.text('Language')).bottom,
        lessThanOrEqualTo(viewportHeight),
      );
    },
  );

  testWidgets(
    'DT2 onDisplay: renders speech settings with Korean and English only',
    (tester) async {
      await _pumpSettings(tester);

      await tester.scrollUntilVisible(
        find.text('Speech'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(find.text('Speech'), findsOneWidget);
      expect(find.text('Auto-play in study'), findsOneWidget);
      expect(find.text('Front language'), findsOneWidget);
      expect(find.text('Back language'), findsNothing);
      expect(find.text('Voice options'), findsOneWidget);
      expect(find.text('Front voice'), findsNothing);
      expect(find.text('Back voice'), findsNothing);

      final speechLanguageControls = tester
          .widgetList<MxSegmentedControl<TtsLanguage>>(
            find.byType(MxSegmentedControl<TtsLanguage>),
          )
          .toList();
      expect(speechLanguageControls, hasLength(1));
      for (final control in speechLanguageControls) {
        expect(
          control.segments.map((segment) => segment.value),
          orderedEquals(TtsLanguage.values),
        );
      }
    },
  );

  testWidgets('DT3 onDisplay: renders study defaults before speech settings', (
    tester,
  ) async {
    await _pumpSettings(tester);

    await tester.scrollUntilVisible(
      find.text('Study defaults'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Study defaults'), findsOneWidget);
    expect(find.text('New Study batch size'), findsOneWidget);
    expect(find.text('Review batch size'), findsOneWidget);
    expect(find.text('5-20 cards'), findsOneWidget);
    expect(find.text('5-50 cards'), findsOneWidget);
    expect(find.text('Shuffle flashcards'), findsOneWidget);
    expect(find.text('Shuffle answers'), findsOneWidget);
    expect(find.text('Prioritize overdue cards'), findsOneWidget);
  });

  testWidgets(
    'DT4 onDisplay: clamps persisted study defaults before rendering',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        AppConstants.sharedPrefsDefaultNewBatchSizeKey: 100,
        AppConstants.sharedPrefsDefaultReviewBatchSizeKey: 1,
      });

      final harness = await _pumpSettings(tester);
      final settings = await harness.container.read(
        studyDefaultsSettingsProvider.future,
      );
      final store = await harness.container.read(
        studySettingsStoreProvider.future,
      );

      expect(settings.newStudyDefaults.batchSize, 20);
      expect(settings.reviewDefaults.batchSize, 5);
      expect(store.loadNewStudyDefaults().batchSize, 20);
      expect(store.loadReviewDefaults().batchSize, 5);
      await tester.scrollUntilVisible(
        find.text('Study defaults'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('20'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    },
  );

  testWidgets(
    'DT1 onUpdate: updates theme and locale providers from segmented controls',
    (tester) async {
      final harness = await _pumpSettings(tester);

      await tester.ensureVisible(find.text('Dark'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(harness.container.read(themeModeProvider), ThemeMode.dark);
      expect(find.text('Settings updated.'), findsOneWidget);

      await tester.ensureVisible(find.text('Vietnamese'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vietnamese'));
      await tester.pumpAndSettle();

      expect(harness.container.read(localeProvider), const Locale('vi'));
    },
  );

  testWidgets(
    'DT2 onUpdate: compact text-scale fallback still updates providers',
    (tester) async {
      final harness = await _pumpSettings(
        tester,
        mediaQueryData: const MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(1.4),
        ),
      );

      await tester.scrollUntilVisible(
        find.text('Appearance'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.byType(RadioListTile<ThemeMode>), findsNWidgets(3));

      await tester.ensureVisible(find.text('Dark'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(harness.container.read(themeModeProvider), ThemeMode.dark);

      await tester.ensureVisible(find.text('Vietnamese'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vietnamese'));
      await tester.pumpAndSettle();

      expect(harness.container.read(localeProvider), const Locale('vi'));
    },
  );

  testWidgets(
    'DT3 onUpdate: speech controls persist settings and preview selected language',
    (tester) async {
      final harness = await _pumpSettings(tester);

      await tester.scrollUntilVisible(
        find.text('Auto-play in study'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).last);
      await tester.pumpAndSettle();

      final languageControls = tester
          .widgetList<MxSegmentedControl<TtsLanguage>>(
            find.byType(MxSegmentedControl<TtsLanguage>),
          )
          .toList();
      languageControls.first.onChanged({TtsLanguage.english});
      await tester.pumpAndSettle();

      tester.widget<Slider>(find.byType(Slider)).onChanged?.call(0.7);
      await tester.pumpAndSettle();

      final settings = await harness.container.read(ttsSettingsProvider.future);
      expect(settings.autoPlay, isTrue);
      expect(settings.frontLanguage, TtsLanguage.english);
      expect(settings.rate, 0.7);

      await tester.scrollUntilVisible(
        find.byKey(_speechPreviewButtonKey),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_speechPreviewButtonKey));
      await tester.pumpAndSettle();

      expect(harness.tts.speakCalls, hasLength(1));
      expect(harness.tts.speakCalls.single.language, TtsLanguage.english);
      expect(harness.tts.speakCalls.single.rate, 0.7);
    },
  );

  testWidgets(
    'DT4 onUpdate: speech voice options stay collapsed until requested',
    (tester) async {
      final harness = await _pumpSettings(tester);

      expect(find.text('Front voice'), findsNothing);
      expect(find.text('Back voice'), findsNothing);
      expect(harness.tts.availableVoiceRequests, isEmpty);

      await tester.scrollUntilVisible(
        find.byKey(_speechVoiceOptionsButtonKey),
        300,
        scrollable: find
            .descendant(
              of: find.byKey(const ValueKey<String>('settings_content')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_speechVoiceOptionsButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Hide voice options'), findsOneWidget);
      expect(find.text('Front voice'), findsOneWidget);
      expect(find.text('Back voice'), findsNothing);
      expect(harness.tts.availableVoiceRequests, [TtsLanguage.korean]);
    },
  );

  testWidgets(
    'DT5 onUpdate: study default controls persist batch sizes and shared toggles',
    (tester) async {
      final harness = await _pumpSettings(tester);

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('settings-study-new-batch-increase')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('settings-study-new-batch-increase')),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>('settings-study-review-batch-decrease'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey<String>('settings-study-review-batch-decrease'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(SwitchListTile, 'Shuffle flashcards'),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Shuffle flashcards'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SwitchListTile, 'Shuffle answers'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Prioritize overdue cards'),
      );
      await tester.pumpAndSettle();

      final settings = await harness.container.read(
        studyDefaultsSettingsProvider.future,
      );
      final store = await harness.container.read(
        studySettingsStoreProvider.future,
      );

      expect(settings.newStudyDefaults.batchSize, 11);
      expect(settings.reviewDefaults.batchSize, 19);
      expect(settings.shuffleFlashcards, isFalse);
      expect(settings.shuffleAnswers, isFalse);
      expect(settings.prioritizeOverdue, isFalse);
      expect(store.loadNewStudyDefaults().batchSize, 11);
      expect(store.loadReviewDefaults().batchSize, 19);
      expect(store.loadNewStudyDefaults().shuffleFlashcards, isFalse);
    },
  );

  testWidgets(
    'DT6 onUpdate: Google sign-in persists account and Drive appdata scope',
    (tester) async {
      final googleAuth = _FakeGoogleAccountAuthService(
        signInResult: GoogleAccountAuthResult.success(
          _session(
            grantedScopes: const <String>{googleDriveAppDataScope},
            driveAuthorizationState: DriveAuthorizationState.authorized,
          ),
        ),
      );
      final harness = await _pumpSettings(
        tester,
        googleConfig: _configuredGoogle,
        googleAuth: googleAuth,
      );

      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      final repository = await harness.container.read(
        cloudAccountRepositoryProvider.future,
      );
      final link = await repository.load();

      expect(link?.email, 'user@example.com');
      expect(link?.driveAppDataAuthorized, isTrue);
      expect(find.text('Google Drive ready'), findsOneWidget);
    },
  );

  testWidgets(
    'DT7 onUpdate: canceled Google sign-in keeps account signed out',
    (tester) async {
      final harness = await _pumpSettings(
        tester,
        googleConfig: _configuredGoogle,
        googleAuth: _FakeGoogleAccountAuthService(
          signInResult: const GoogleAccountAuthResult.canceled(),
        ),
      );

      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      final repository = await harness.container.read(
        cloudAccountRepositoryProvider.future,
      );

      expect(await repository.load(), isNull);
      expect(find.text('Google sign-in was canceled.'), findsOneWidget);
    },
  );

  testWidgets(
    'DT8 onUpdate: denied Drive scope stores account and asks reconnect',
    (tester) async {
      final harness = await _pumpSettings(
        tester,
        googleConfig: _configuredGoogle,
        googleAuth: _FakeGoogleAccountAuthService(
          signInResult: GoogleAccountAuthResult.driveAuthorizationRequired(
            _session(
              grantedScopes: const <String>{},
              driveAuthorizationState: DriveAuthorizationState.denied,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      final repository = await harness.container.read(
        cloudAccountRepositoryProvider.future,
      );
      final link = await repository.load();
      final preferences = await SharedPreferences.getInstance();
      final rawAccount = preferences.getString(
        AppConstants.sharedPrefsCloudAccountLinkKey,
      );

      expect(link?.email, 'user@example.com');
      expect(link?.driveAppDataAuthorized, isFalse);
      expect(rawAccount, isNot(contains('accessToken')));
      expect(find.text('Google Drive reconnect required'), findsOneWidget);
    },
  );

  testWidgets(
    'DT9 onUpdate: local sign out clears account and preserves study defaults',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        AppConstants.sharedPrefsDefaultNewBatchSizeKey: 12,
      });
      final preferences = await SharedPreferences.getInstance();
      final store = CloudAccountStore(preferences);
      await store.save(_driveReadyLink);
      final googleAuth = _FakeGoogleAccountAuthService(
        restoreResult: GoogleAccountAuthResult.success(
          _session(
            grantedScopes: const <String>{googleDriveAppDataScope},
            driveAuthorizationState: DriveAuthorizationState.authorized,
          ),
        ),
      );
      final harness = await _pumpSettings(
        tester,
        googleConfig: _configuredGoogle,
        googleAuth: googleAuth,
      );

      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      final repository = await harness.container.read(
        cloudAccountRepositoryProvider.future,
      );
      final studyStore = await harness.container.read(
        studySettingsStoreProvider.future,
      );

      expect(await repository.load(), isNull);
      expect(googleAuth.signOutCount, 1);
      expect(studyStore.loadNewStudyDefaults().batchSize, 12);
      expect(
        find.text('Signed out. Local flashcards stay on this device.'),
        findsOneWidget,
      );
    },
  );
}

Future<_SettingsHarness> _pumpSettings(
  WidgetTester tester, {
  MediaQueryData? mediaQueryData,
  Future<StudySettingsStore>? studySettingsStoreFuture,
  Future<TtsSettingsStore>? ttsSettingsStoreFuture,
  GoogleOAuthConfig? googleConfig,
  GoogleAccountAuthService? googleAuth,
  DriveSyncRepository? driveSyncRepository,
  bool settle = true,
}) async {
  final fakeTts = _FakeTtsService();
  final effectiveGoogleAuth = googleAuth ?? _FakeGoogleAccountAuthService();
  final effectiveDriveSyncRepository =
      driveSyncRepository ??
      _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus.signedOut(),
      );
  final container = ProviderContainer(
    overrides: [
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
      if (ttsSettingsStoreFuture != null)
        ttsSettingsStoreProvider.overrideWith((ref) => ttsSettingsStoreFuture),
    ],
  );
  addTearDown(container.dispose);
  addTearDown(fakeTts.dispose);
  if (effectiveGoogleAuth is _FakeGoogleAccountAuthService) {
    addTearDown(effectiveGoogleAuth.dispose);
  }

  final child = mediaQueryData == null
      ? const SettingsScreen()
      : MediaQuery(data: mediaQueryData, child: const SettingsScreen());

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: _TestApp(child: child),
    ),
  );
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
  }

  return _SettingsHarness(container: container, tts: fakeTts);
}

final class _SettingsHarness {
  const _SettingsHarness({required this.container, required this.tts});

  final ProviderContainer container;
  final _FakeTtsService tts;
}

final class _FakeDriveSyncRepository implements DriveSyncRepository {
  _FakeDriveSyncRepository({
    DriveSyncStatus? loadStatusResult,
    DriveSyncRunResult? syncResult,
    DriveSyncRunResult? resolveResult,
  }) : loadStatusResult = loadStatusResult ?? const DriveSyncStatus.signedOut(),
       syncResult =
           syncResult ??
           DriveSyncRunResult.noChanges(const DriveSyncStatus.signedOut()),
       resolveResult =
           resolveResult ??
           DriveSyncRunResult.canceled(const DriveSyncStatus.ready());

  final DriveSyncStatus loadStatusResult;
  final DriveSyncRunResult syncResult;
  final DriveSyncRunResult resolveResult;
  int syncNowCount = 0;

  @override
  Future<DriveSyncStatus> loadStatus() async {
    return loadStatusResult;
  }

  @override
  Future<DriveSyncRunResult> syncNow() async {
    syncNowCount += 1;
    return syncResult;
  }

  @override
  Future<DriveSyncRunResult> resolveConflict(
    DriveSyncConflict conflict,
    DriveSyncConflictChoice choice,
  ) async {
    return resolveResult;
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
  email: 'user@example.com',
  displayName: 'MemoX User',
  photoUrl: null,
  grantedScopes: <String>{googleDriveAppDataScope},
  driveAuthorizationState: DriveAuthorizationState.authorized,
  linkedAt: 1,
  lastSignedInAt: 1,
);

const _driveMissingLink = CloudAccountLink(
  provider: CloudProvider.google,
  subjectId: 'google-user-001',
  email: 'user@example.com',
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
}) {
  return GoogleAccountAuthSession(
    profile: const GoogleAccountProfile(
      subjectId: 'google-user-001',
      email: 'user@example.com',
      displayName: 'MemoX User',
      photoUrl: null,
    ),
    grantedScopes: grantedScopes,
    driveAuthorizationState: driveAuthorizationState,
  );
}

final class _FakeGoogleAccountAuthService implements GoogleAccountAuthService {
  _FakeGoogleAccountAuthService({
    this.restoreResult = const GoogleAccountAuthResult.signedOut(),
    this.signInResult = const GoogleAccountAuthResult.signedOut(),
    this.requiresPlatformSignInButton = false,
  });

  final StreamController<GoogleAccountAuthResult> _events =
      StreamController<GoogleAccountAuthResult>.broadcast();

  GoogleAccountAuthResult restoreResult;
  GoogleAccountAuthResult signInResult;
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
  ) async {
    return restoreResult;
  }

  @override
  Future<GoogleAccountAuthResult> signInAndAuthorizeDriveAppData(
    GoogleOAuthConfig config,
  ) async {
    return signInResult;
  }

  @override
  Future<GoogleAccountAuthResult> authorizeDriveAppData(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  ) async {
    return signInResult;
  }

  @override
  Future<DriveAccessTokenResult> getDriveAppDataAccessToken(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  ) async {
    return const DriveAccessTokenResult.reauthorizationRequired();
  }

  @override
  Future<void> signOutLocal() async {
    signOutCount += 1;
  }

  Future<void> dispose() => _events.close();
}

final class _SpeakCall {
  const _SpeakCall({
    required this.text,
    required this.language,
    required this.rate,
    this.voiceName,
  });

  final String text;
  final TtsLanguage language;
  final double rate;
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
      TtsVoice(name: '${language.name} system voice', language: language),
    ];
  }

  @override
  Future<void> speak(
    String text, {
    required TtsLanguage language,
    required double rate,
    String? voiceName,
  }) async {
    speakCalls.add(
      _SpeakCall(
        text: text,
        language: language,
        rate: rate,
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
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
