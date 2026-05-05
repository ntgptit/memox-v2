import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/account_providers.dart';
import 'package:memox/app/di/sync_providers.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/router/route_names.dart';
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
import 'package:memox/presentation/features/settings/screens/account_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/audio_speech_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/learning_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox/presentation/features/settings/viewmodels/drive_sync_settings_viewmodel.dart';
import 'package:memox/presentation/features/study/providers/study_settings_defaults_notifier.dart';
import 'package:memox/presentation/features/tts/providers/tts_settings_notifier.dart';
import 'package:memox/presentation/shared/layouts/mx_space.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';
import 'package:memox/presentation/shared/widgets/mx_segmented_control.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _speechPreviewButtonKey = ValueKey<String>(
  'settings-speech-preview-button',
);
const _speechVoiceOptionsButtonKey = ValueKey<String>(
  'settings-speech-voice-options-button',
);
const _speechTextToSpeechToggleKey = ValueKey<String>(
  'settings-speech-tts-toggle',
);
const _speechVoiceSelectionRowKey = ValueKey<String>(
  'settings-speech-voice-selection-row',
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DT1 onOpen: renders settings page with default controls', (
    tester,
  ) async {
    final harness = await _pumpSettings(tester);

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('No Google account is linked.'), findsOneWidget);
    expect(find.text('Personalization'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Light'), findsNothing);
    expect(find.text('System'), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Learning experience'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Learning experience'), findsOneWidget);
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
        child: const LearningSettingsScreen(),
        settle: false,
        studySettingsStoreFuture: completer.future,
      );
      await tester.pump();

      expect(find.text('Learning experience'), findsWidgets);
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
        child: const AudioSpeechSettingsScreen(),
        settle: false,
        ttsSettingsStoreFuture: completer.future,
      );
      await tester.pump();

      expect(find.text('Audio & Speech'), findsWidgets);
      expect(find.text('Loading speech settings'), findsOneWidget);
      expect(find.byType(MxLoadingState), findsOneWidget);
    },
  );

  testWidgets('DT1 onDisplay: uses soft minimal tonal settings islands', (
    tester,
  ) async {
    await _pumpSettings(tester);

    expect(
      find.descendant(
        of: find.byType(MxCard).first,
        matching: find.text('Account'),
      ),
      findsNothing,
    );
    expect(
      tester
          .widgetList<MxCard>(find.byType(MxCard))
          .map((card) => card.variant),
      everyElement(MxCardVariant.filled),
    );
    expect(
      _overviewCardForKey(tester, 'settings-overview-account-row').onTap,
      isNotNull,
    );
    expect(find.text('Personalization'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.byType(Divider), findsWidgets);
    await tester.scrollUntilVisible(
      find.text('Audio & Speech'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(
      _overviewCardForKey(tester, 'settings-overview-audio-speech-row').onTap,
      isNotNull,
    );
  });

  testWidgets(
    'DT5 onDisplay: settings overview hides Google sign-in when OAuth config is missing',
    (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await _pumpSettings(tester);

        expect(
          find.text('Add Google OAuth client IDs to enable account linking.'),
          findsOneWidget,
        );
        expect(find.text('Sign in with Google'), findsNothing);
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
    expect(find.textContaining('user@example.com'), findsOneWidget);
    expect(find.textContaining('Google Drive ready'), findsOneWidget);
    expect(
      tester.widget<CircleAvatar>(find.byType(CircleAvatar).first).radius,
      MxSpace.xxl + MxSpace.md,
    );
    expect(
      find.byKey(const ValueKey<String>('settings-overview-account-row')),
      findsOneWidget,
    );
    expect(find.text('Sign out'), findsNothing);
    expect(find.byTooltip('Sign out'), findsNothing);
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
      expect(
        find.textContaining('Google Drive reconnect required'),
        findsOneWidget,
      );
      expect(find.text('Reconnect Google Drive'), findsNothing);
      expect(find.text('Sign out'), findsNothing);
      expect(find.byTooltip('Sign out'), findsNothing);
    },
  );

  testWidgets(
    'DT8 onDisplay: renders web Drive scope reconnect action for runtime account',
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

      expect(
        find.textContaining('Google Drive reconnect required'),
        findsOneWidget,
      );
      expect(find.text('Reconnect Google Drive'), findsNothing);
      expect(find.text('Sign out'), findsNothing);
      expect(find.byTooltip('Sign out'), findsNothing);
    },
  );

  testWidgets(
    'DT12 onDisplay: web stored Drive-ready account without runtime auth requires reconnect',
    (tester) async {
      final preferences = await SharedPreferences.getInstance();
      final store = CloudAccountStore(preferences);
      await store.save(_driveReadyLink);
      final repository = _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus.needsDriveAuthorization(),
      );

      await _pumpSettings(
        tester,
        googleConfig: _configuredGoogle,
        googleAuth: _FakeGoogleAccountAuthService(
          requiresPlatformSignInButton: true,
        ),
        driveSyncRepository: repository,
      );

      expect(find.text('MemoX User'), findsOneWidget);
      expect(
        find.textContaining('Google Drive reconnect required'),
        findsOneWidget,
      );
      expect(find.text('Google Drive ready'), findsNothing);
      expect(find.text('Reconnect Google Drive'), findsNothing);
      expect(find.text('Sign out'), findsNothing);
      expect(find.byTooltip('Sync now'), findsNothing);
    },
  );

  testWidgets('DT13 onDisplay: Account detail shows Drive sync failure', (
    tester,
  ) async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.failure(
        'Google Drive API has not been used in project.',
      ),
    );

    await _pumpSettings(
      tester,
      child: const AccountSettingsScreen(),
      driveSyncRepository: repository,
    );

    expect(find.text('Drive sync failed. Try again.'), findsOneWidget);
    expect(
      find.text('Google Drive API has not been used in project.'),
      findsOneWidget,
    );
    expect(find.byTooltip('Sync now'), findsOneWidget);
  });

  testWidgets(
    'DT14 onDisplay: Account detail Drive sync load error uses one failure surface',
    (tester) async {
      final repository = _FakeDriveSyncRepository(
        loadStatusError: StateError('sync provider unavailable'),
      );

      await _pumpSettings(
        tester,
        child: const AccountSettingsScreen(),
        driveSyncRepository: repository,
      );

      expect(find.text('Drive sync failed. Try again.'), findsOneWidget);
      expect(find.text('Bad state: sync provider unavailable'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
      expect(find.text('Something went wrong.'), findsNothing);
      expect(find.byTooltip('Sync now'), findsOneWidget);
    },
  );

  testWidgets('DT15 onDisplay: shows last synced metadata when available', (
    tester,
  ) async {
    final lastSyncedAt = DateTime(2026, 1, 2, 3, 4).millisecondsSinceEpoch;
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: DriveSyncStatus(
        kind: DriveSyncStatusKind.synced,
        lastSyncedAt: lastSyncedAt,
      ),
    );

    await _pumpSettings(
      tester,
      child: const AccountSettingsScreen(),
      driveSyncRepository: repository,
    );

    expect(find.text('Google Drive is up to date.'), findsOneWidget);
    expect(find.textContaining('Last synced:'), findsOneWidget);
  });

  testWidgets('DT16 onDisplay: overview hides detail-only actions', (
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

    await tester.scrollUntilVisible(
      find.text('Audio & Speech'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Sign out'), findsNothing);
    expect(find.byTooltip('Sync now'), findsNothing);
    expect(find.text('Drive sync'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('settings-study-new-batch-row')),
      findsNothing,
    );
    expect(find.byKey(_speechTextToSpeechToggleKey), findsNothing);
    expect(find.byKey(_speechPreviewButtonKey), findsNothing);
    expect(find.byKey(_speechVoiceOptionsButtonKey), findsNothing);
  });

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
      expect(find.text('Personalization'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(
        tester.getRect(find.text('Language')).bottom,
        lessThanOrEqualTo(viewportHeight),
      );
    },
  );

  testWidgets('DT2 onDisplay: renders audio and speech overview row', (
    tester,
  ) async {
    await _pumpSettings(tester);

    await tester.scrollUntilVisible(
      find.text('Audio & Speech'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Audio & Speech'), findsOneWidget);
    expect(find.text('Text-to-Speech'), findsOneWidget);
    expect(find.text('Off · System voice'), findsOneWidget);
    expect(find.text('Voice selection'), findsNothing);
    expect(find.text('Front language'), findsNothing);
    expect(find.text('Back language'), findsNothing);
    expect(find.text('Voice options'), findsNothing);
    expect(find.byTooltip('Voice options'), findsNothing);
    expect(find.text('Front voice'), findsNothing);
    expect(find.text('Back voice'), findsNothing);
  });

  testWidgets('DT3 onDisplay: renders study defaults overview summary', (
    tester,
  ) async {
    await _pumpSettings(tester);

    await tester.scrollUntilVisible(
      find.text('Learning experience'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Learning experience'), findsOneWidget);
    expect(find.text('Study defaults'), findsOneWidget);
    expect(find.text('New 10 cards · Review 20 cards'), findsOneWidget);
    expect(find.text('New Study batch size'), findsNothing);
    expect(find.text('Review batch size'), findsNothing);
    expect(find.text('Shuffle flashcards'), findsNothing);
    expect(find.text('Shuffle answers'), findsNothing);
    expect(find.text('Prioritize overdue cards'), findsNothing);
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
        find.text('Learning experience'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('New 20 cards · Review 5 cards'), findsOneWidget);
    },
  );

  testWidgets('DT1 onNavigate: account overview opens account detail', (
    tester,
  ) async {
    await _pumpSettingsRouter(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('settings-overview-account-row')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AccountSettingsScreen), findsOneWidget);
  });

  testWidgets('DT2 onNavigate: account detail contains Drive sync actions', (
    tester,
  ) async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
    );
    await _pumpSettingsRouter(tester, driveSyncRepository: repository);

    await tester.tap(
      find.byKey(const ValueKey<String>('settings-overview-account-row')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AccountSettingsScreen), findsOneWidget);
    expect(find.text('Drive sync'), findsOneWidget);
    expect(find.byTooltip('Sync now'), findsOneWidget);
  });

  testWidgets('DT3 onNavigate: learning overview opens learning detail', (
    tester,
  ) async {
    await _pumpSettingsRouter(tester);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('settings-overview-learning-row')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('settings-overview-learning-row')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LearningSettingsScreen), findsOneWidget);
  });

  testWidgets('DT4 onNavigate: audio overview opens audio detail', (
    tester,
  ) async {
    await _pumpSettingsRouter(tester);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('settings-overview-audio-speech-row')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('settings-overview-audio-speech-row')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AudioSpeechSettingsScreen), findsOneWidget);
  });

  testWidgets(
    'DT1 onUpdate: personalization rows update theme and locale providers',
    (tester) async {
      final harness = await _pumpSettings(tester);

      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>('settings-personalization-theme-row'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey<String>('settings-personalization-theme-row'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(harness.container.read(themeModeProvider), ThemeMode.dark);
      expect(find.text('Settings updated.'), findsOneWidget);

      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>('settings-personalization-language-row'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey<String>('settings-personalization-language-row'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vietnamese'));
      await tester.pumpAndSettle();

      expect(harness.container.read(localeProvider), const Locale('vi'));
    },
  );

  testWidgets(
    'DT2 onUpdate: compact text-scale sheets still update providers',
    (tester) async {
      final harness = await _pumpSettings(
        tester,
        mediaQueryData: const MediaQueryData(
          size: Size(320, 640),
          textScaler: TextScaler.linear(1.4),
        ),
      );

      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>('settings-personalization-theme-row'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey<String>('settings-personalization-theme-row'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(harness.container.read(themeModeProvider), ThemeMode.dark);

      await tester.ensureVisible(
        find.byKey(
          const ValueKey<String>('settings-personalization-language-row'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey<String>('settings-personalization-language-row'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Vietnamese'));
      await tester.pumpAndSettle();

      expect(harness.container.read(localeProvider), const Locale('vi'));
    },
  );

  testWidgets(
    'DT3 onUpdate: speech controls persist settings and preview selected language',
    (tester) async {
      final harness = await _pumpSettings(
        tester,
        child: const AudioSpeechSettingsScreen(),
      );

      await tester.scrollUntilVisible(
        find.byKey(_speechTextToSpeechToggleKey),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(_speechTextToSpeechToggleKey),
          matching: find.byType(Switch),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_speechVoiceSelectionRowKey));
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

      await tester.ensureVisible(find.byKey(_speechPreviewButtonKey));
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
      final harness = await _pumpSettings(
        tester,
        child: const AudioSpeechSettingsScreen(),
      );

      expect(find.text('Front voice'), findsNothing);
      expect(find.text('Back voice'), findsNothing);
      expect(harness.tts.availableVoiceRequests, isEmpty);
      expect(find.byKey(_speechVoiceOptionsButtonKey), findsNothing);

      await tester.scrollUntilVisible(
        find.byKey(_speechVoiceSelectionRowKey),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_speechVoiceSelectionRowKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_speechVoiceOptionsButtonKey));
      await tester.pumpAndSettle();

      expect(find.text('Hide voice options'), findsNothing);
      expect(find.byTooltip('Hide voice options'), findsOneWidget);
      expect(find.text('Front voice'), findsOneWidget);
      expect(find.text('Back voice'), findsNothing);
      expect(harness.tts.availableVoiceRequests, [TtsLanguage.korean]);
    },
  );

  testWidgets(
    'DT5 onUpdate: study default controls persist batch sizes and shared toggles',
    (tester) async {
      final harness = await _pumpSettings(
        tester,
        child: const LearningSettingsScreen(),
      );

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('settings-study-new-batch-row')),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('settings-study-new-batch-row')),
      );
      await tester.pumpAndSettle();
      expect(find.text('5-20 cards'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey<String>('settings-study-new-batch-increase')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ModalBarrier).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('settings-study-review-batch-row')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('settings-study-review-batch-row')),
      );
      await tester.pumpAndSettle();
      expect(find.text('5-50 cards'), findsOneWidget);
      await tester.tap(
        find.byKey(
          const ValueKey<String>('settings-study-review-batch-decrease'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ModalBarrier).last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Shuffle flashcards'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch).at(2));
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
        child: const AccountSettingsScreen(),
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
        child: const AccountSettingsScreen(),
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
        child: const AccountSettingsScreen(),
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
        child: const AccountSettingsScreen(),
        googleConfig: _configuredGoogle,
        googleAuth: googleAuth,
      );

      await tester.tap(find.byTooltip('Sign out'));
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

  testWidgets('DT10 onUpdate: web reconnect event enables Drive sync', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final store = CloudAccountStore(preferences);
    await store.save(_driveReadyLink);
    final googleAuth = _FakeGoogleAccountAuthService(
      requiresPlatformSignInButton: true,
    );
    final repository = _FakeDriveSyncRepository(
      loadStatusResults: const <DriveSyncStatus>[
        DriveSyncStatus.needsDriveAuthorization(),
        DriveSyncStatus.noRemoteSnapshot(),
      ],
    );

    await _pumpSettings(
      tester,
      child: const SettingsScreen(),
      googleConfig: _configuredGoogle,
      googleAuth: googleAuth,
      driveSyncRepository: repository,
    );
    expect(
      find.textContaining('Google Drive reconnect required'),
      findsOneWidget,
    );

    googleAuth.emit(
      GoogleAccountAuthResult.success(
        _session(
          grantedScopes: const <String>{googleDriveAppDataScope},
          driveAuthorizationState: DriveAuthorizationState.authorized,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Google Drive ready'), findsOneWidget);
    expect(find.byTooltip('Sync now'), findsNothing);
  });

  testWidgets('DT11 onUpdate: Drive sync upload result is visible', (
    tester,
  ) async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
      uploadResult: DriveSyncRunResult.uploadedLocal(
        const DriveSyncStatus(kind: DriveSyncStatusKind.synced),
      ),
    );
    await _pumpSettings(
      tester,
      child: const AccountSettingsScreen(),
      driveSyncRepository: repository,
    );

    await tester.tap(find.byTooltip('Sync now'));
    await tester.pumpAndSettle();
    expect(find.text('Choose sync direction'), findsOneWidget);
    await tester.tap(find.text('Upload local data to Drive'));
    await tester.pumpAndSettle();
    expect(find.text('Upload local data?'), findsOneWidget);
    await tester.tap(find.text('Upload to Drive'));
    await tester.pumpAndSettle();

    expect(find.text('Google Drive is up to date.'), findsOneWidget);
    expect(find.text('Local data backed up to Google Drive.'), findsNothing);
    expect(repository.syncNowCount, 0);
    expect(repository.uploadLocalCount, 1);
  });

  testWidgets('DT14 onUpdate: Drive sync restore requires confirmation', (
    tester,
  ) async {
    final remote = _remoteSnapshot();
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: DriveSyncStatus(
        kind: DriveSyncStatusKind.ready,
        remote: remote,
      ),
      restoreResult: DriveSyncRunResult.restoredRemote(
        DriveSyncStatus(kind: DriveSyncStatusKind.synced, remote: remote),
        DriveSyncRestoreEffect.refreshDatabaseProvider,
      ),
    );
    await _pumpSettings(
      tester,
      child: const AccountSettingsScreen(),
      driveSyncRepository: repository,
    );

    await tester.tap(find.byTooltip('Sync now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Download Drive data to this device'));
    await tester.pumpAndSettle();
    expect(find.text('Restore Drive copy?'), findsOneWidget);
    await tester.tap(find.text('Restore from Drive'));
    await tester.pumpAndSettle();

    expect(find.text('Google Drive is up to date.'), findsOneWidget);
    expect(find.text('Drive copy restored.'), findsNothing);
    expect(repository.restoreDriveCount, 1);
  });

  testWidgets('DT15 onUpdate: canceling sync confirmation does not upload', (
    tester,
  ) async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
      uploadResult: DriveSyncRunResult.uploadedLocal(
        const DriveSyncStatus(kind: DriveSyncStatusKind.synced),
      ),
    );
    await _pumpSettings(
      tester,
      child: const AccountSettingsScreen(),
      driveSyncRepository: repository,
    );

    await tester.tap(find.byTooltip('Sync now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Upload local data to Drive'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.uploadLocalCount, 0);
    expect(find.text('Local data backed up to Google Drive.'), findsNothing);
  });

  testWidgets('DT12 onUpdate: web Drive scope reconnect enables Drive sync', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final store = CloudAccountStore(preferences);
    await store.save(_driveReadyLink);
    final googleAuth = _FakeGoogleAccountAuthService(
      requiresPlatformSignInButton: true,
      signInResult: GoogleAccountAuthResult.success(
        _session(
          grantedScopes: const <String>{googleDriveAppDataScope},
          driveAuthorizationState: DriveAuthorizationState.authorized,
        ),
      ),
    );
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
    );

    final harness = await _pumpSettings(
      tester,
      child: const AccountSettingsScreen(),
      googleConfig: _configuredGoogle,
      googleAuth: googleAuth,
      driveSyncRepository: repository,
    );
    googleAuth.emit(
      GoogleAccountAuthResult.driveAuthorizationRequired(
        _session(
          grantedScopes: const <String>{},
          driveAuthorizationState:
              DriveAuthorizationState.authorizationRequired,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reconnect Google Drive').first);
    await tester.pumpAndSettle();

    expect(find.text('Google Drive ready'), findsOneWidget);
    final status = await harness.container.read(
      driveSyncSettingsControllerProvider.future,
    );
    expect(status.kind, DriveSyncStatusKind.noRemoteSnapshot);
  });

  testWidgets(
    'DT13 onUpdate: Drive sync failure shows diagnostic without duplicate generic copy',
    (tester) async {
      const diagnostic = 'Google Drive API has not been used in project.';
      final repository = _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
        uploadResult: DriveSyncRunResult.failed(
          const DriveSyncStatus.failure(diagnostic),
          diagnostic,
        ),
      );

      await _pumpSettings(
        tester,
        child: const AccountSettingsScreen(),
        driveSyncRepository: repository,
      );

      await tester.tap(find.byTooltip('Sync now'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload local data to Drive'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload to Drive'));
      await tester.pumpAndSettle();

      expect(find.text('Drive sync failed. Try again.'), findsOneWidget);
      expect(find.text(diagnostic), findsOneWidget);
      expect(find.byTooltip('Sync now'), findsOneWidget);
    },
  );
}

Future<_SettingsHarness> _pumpSettings(
  WidgetTester tester, {
  Widget child = const SettingsScreen(),
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
            path: RoutePaths.settingsAudioSpeechSegment,
            name: RouteNames.settingsAudioSpeech,
            builder: (context, state) => const AudioSpeechSettingsScreen(),
          ),
        ],
      ),
    ],
  );

  addTearDown(container.dispose);
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

MxCard _overviewCardForKey(WidgetTester tester, String key) {
  final cardFinder = find.ancestor(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(MxCard),
  );
  return tester.widget<MxCard>(cardFinder.first);
}

final class _FakeDriveSyncRepository implements DriveSyncRepository {
  _FakeDriveSyncRepository({
    DriveSyncStatus? loadStatusResult,
    List<DriveSyncStatus>? loadStatusResults,
    DriveSyncRunResult? syncResult,
    DriveSyncRunResult? uploadResult,
    DriveSyncRunResult? restoreResult,
    DriveSyncRunResult? resolveResult,
    this.loadStatusError,
  }) : loadStatusResult = loadStatusResult ?? const DriveSyncStatus.signedOut(),
       _loadStatusResults = loadStatusResults?.toList() ?? <DriveSyncStatus>[],
       syncResult =
           syncResult ??
           DriveSyncRunResult.noChanges(const DriveSyncStatus.signedOut()),
       uploadResult =
           uploadResult ??
           DriveSyncRunResult.noChanges(const DriveSyncStatus.signedOut()),
       restoreResult =
           restoreResult ??
           DriveSyncRunResult.noChanges(const DriveSyncStatus.signedOut()),
       resolveResult =
           resolveResult ??
           DriveSyncRunResult.canceled(const DriveSyncStatus.ready());

  DriveSyncStatus loadStatusResult;
  final List<DriveSyncStatus> _loadStatusResults;
  final DriveSyncRunResult syncResult;
  final DriveSyncRunResult uploadResult;
  final DriveSyncRunResult restoreResult;
  final DriveSyncRunResult resolveResult;
  final Object? loadStatusError;
  int syncNowCount = 0;
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
  Future<DriveSyncRunResult> syncNow() async {
    syncNowCount += 1;
    return syncResult;
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

DriveSyncRemoteSnapshot _remoteSnapshot() {
  return DriveSyncRemoteSnapshot(
    manifest: const DriveSyncManifest(
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
}

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

class _RouterTestApp extends StatelessWidget {
  const _RouterTestApp({required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
