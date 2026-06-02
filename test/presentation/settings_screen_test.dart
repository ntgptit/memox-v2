import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/account_providers.dart';
import 'package:memox/app/di/providers.dart';
import 'package:memox/app/di/study/study_settings_providers.dart';
import 'package:memox/app/di/sync_providers.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/app/services/drive_sync_runtime_effects.dart';
import 'package:memox/core/config/google_oauth_config.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/core/theme/app_theme.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/settings/cloud_account_store.dart';
import 'package:memox/data/settings/study_settings_store.dart';
import 'package:memox/domain/entities/cloud_account_link.dart';
import 'package:memox/domain/entities/drive_sync_models.dart';
import 'package:memox/domain/repositories/drive_sync_repository.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
import 'package:memox/domain/services/google_account_auth_service.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/value_objects/tag_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/settings/providers/tag_management_notifier.dart';
import 'package:memox/presentation/features/settings/screens/account_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/audio_speech_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/learning_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/tag_management_screen.dart';
import 'package:memox/presentation/features/settings/viewmodels/account_settings_viewmodel.dart';
import 'package:memox/presentation/features/settings/viewmodels/drive_sync_settings_viewmodel.dart';
import 'package:memox/presentation/features/settings/viewmodels/study_settings_defaults_viewmodel.dart';
import 'package:memox/presentation/features/settings/widgets/settings_group.dart';
import 'package:memox/presentation/features/tts/providers/tts_settings_notifier.dart';
import 'package:memox/presentation/shared/widgets/mx_badge.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';
import 'package:memox/presentation/shared/widgets/mx_icon_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_list_tile.dart';
import 'package:memox/presentation/shared/widgets/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/mx_progress_indicator.dart';
import 'package:memox/presentation/shared/widgets/mx_segmented_control.dart';
import 'package:memox/presentation/shared/widgets/mx_tappable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_screen_test_harness.dart';

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
    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('Sign in & sync'), findsOneWidget);
    expect(find.text('STUDY'), findsOneWidget);
    expect(find.text('Manage tags'), findsOneWidget);
    expect(find.text('APP'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Light'), findsNothing);
    expect(find.text('SOON'), findsNWidgets(2));
    await tester.scrollUntilVisible(
      find.text('ABOUT'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('About MemoX'), findsOneWidget);
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
      final completer = Completer<TtsSettingsRepository>();
      addTearDown(() async {
        if (!completer.isCompleted) {
          completer.complete(_FakeTtsSettingsRepository());
        }
      });

      await _pumpSettings(
        tester,
        child: const AudioSpeechSettingsScreen(),
        settle: false,
        ttsSettingsRepositoryFuture: completer.future,
      );
      await tester.pump();

      expect(find.text('Audio & speech'), findsWidgets);
      expect(find.text('Loading speech settings'), findsOneWidget);
      expect(find.byType(MxLoadingState), findsOneWidget);
    },
  );

  testWidgets('DT1 onDisplay: uses tokenized settings status islands', (
    tester,
  ) async {
    await _pumpSettings(tester);

    expect(
      find.descendant(
        of: find.byType(MxCard).first,
        matching: find.text('ACCOUNT'),
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
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('settings-overview-account-row')),
        matching: find.byType(MxIconTile),
      ),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey<String>('settings-overview-account-row')),
          )
          .height,
      greaterThanOrEqualTo(64),
    );
    expect(find.text('STUDY'), findsOneWidget);
    expect(find.text('Manage tags'), findsOneWidget);
    expect(find.text('APP'), findsOneWidget);
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('settings-personalization-theme-row'),
        ),
        matching: find.byType(MxTappable),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('settings-personalization-theme-row'),
        ),
        matching: find.byType(MxIconTile),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('settings-personalization-theme-row'),
        ),
        matching: find.byType(MxBadge),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('settings-personalization-theme-row'),
        ),
        matching: find.byType(MxListTile),
      ),
      findsNothing,
    );
    expect(
      tester
          .widget<MxCard>(
            find
                .ancestor(
                  of: find.byKey(
                    const ValueKey<String>(
                      'settings-personalization-theme-row',
                    ),
                  ),
                  matching: find.byType(MxCard),
                )
                .first,
          )
          .padding,
      EdgeInsets.zero,
    );
    expect(find.text('SOON'), findsNWidgets(2));
    expect(find.byType(Divider), findsWidgets);
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('settings-overview-audio-speech-row'),
        ),
        matching: find.byType(MxTappable),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('settings-overview-audio-speech-row'),
        ),
        matching: find.byType(MxIconTile),
      ),
      findsOneWidget,
    );
  });

  testWidgets('DT17 onDisplay: overview keeps row skeletons while loading', (
    tester,
  ) async {
    final accountCompleter = Completer<GoogleAccountAuthResult>();
    final studyCompleter = Completer<StudySettingsStore>();
    final speechCompleter = Completer<TtsSettingsRepository>();
    final versionCompleter = Completer<String>();
    addTearDown(() async {
      if (!accountCompleter.isCompleted) {
        accountCompleter.complete(const GoogleAccountAuthResult.signedOut());
      }
      if (!studyCompleter.isCompleted) {
        studyCompleter.complete(
          StudySettingsStore(await SharedPreferences.getInstance()),
        );
      }
      if (!speechCompleter.isCompleted) {
        speechCompleter.complete(_FakeTtsSettingsRepository());
      }
      if (!versionCompleter.isCompleted) {
        versionCompleter.complete('1.4.2 (build 248)');
      }
    });

    await _pumpSettings(
      tester,
      settle: false,
      googleAuth: _FakeGoogleAccountAuthService(
        restoreFuture: accountCompleter.future,
      ),
      studySettingsStoreFuture: studyCompleter.future,
      ttsSettingsRepositoryFuture: speechCompleter.future,
      appVersionLabelFuture: versionCompleter.future,
    );
    await tester.pump();

    expect(find.text('ACCOUNT'), findsOneWidget);
    expect(find.text('STUDY'), findsOneWidget);
    expect(find.text('APP'), findsOneWidget);
    expect(find.byType(SettingsLoadingRow), findsNWidgets(3));
    expect(find.byType(MxLoadingState), findsNothing);

    await tester.scrollUntilVisible(
      find.text('ABOUT'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();

    expect(find.text('ABOUT'), findsOneWidget);
    expect(find.byType(SettingsLoadingRow), findsWidgets);
  });

  testWidgets('DT21 onDisplay: hub hosts navigation rows only', (tester) async {
    await _pumpSettings(tester);

    expect(find.byType(Switch), findsNothing);
    expect(find.byType(Slider), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.byType(MxSegmentedControl), findsNothing);
  });

  testWidgets('DT22 onDisplay: row semantics include subtitle context', (
    tester,
  ) async {
    final semanticsHandle = tester.ensureSemantics();
    try {
      await _pumpSettings(tester);

      final label = tester
          .getSemantics(
            find.byKey(const ValueKey<String>('settings-overview-account-row')),
          )
          .label;
      expect(label, contains('Sign in & sync'));
      expect(label, contains('Save your progress across devices'));
    } finally {
      semanticsHandle.dispose();
    }
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

    expect(find.text('Account & sync'), findsOneWidget);
    expect(find.text('alex@memox.app · synced 2 min ago'), findsOneWidget);
    expect(find.textContaining('Google Drive ready'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('settings-overview-account-row')),
      findsOneWidget,
    );
    expect(find.text('Sign out'), findsNothing);
    expect(find.byTooltip('Sign out'), findsNothing);
  });

  testWidgets('DT18 onDisplay: signed-out overview matches sync entry mock', (
    tester,
  ) async {
    await _pumpSettings(tester);

    expect(find.text('Sign in & sync'), findsOneWidget);
    expect(find.text('Save your progress across devices'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsNothing);
  });

  testWidgets('DT19 onDisplay: signing-in overview shows progress state', (
    tester,
  ) async {
    final signInCompleter = Completer<GoogleAccountAuthResult>();
    addTearDown(() {
      if (!signInCompleter.isCompleted) {
        signInCompleter.complete(const GoogleAccountAuthResult.signedOut());
      }
    });
    final googleAuth = _FakeGoogleAccountAuthService(
      signInFuture: signInCompleter.future,
    );
    final harness = await _pumpSettings(tester, googleAuth: googleAuth);

    unawaited(
      harness.container
          .read(accountSettingsControllerProvider.notifier)
          .signIn(),
    );
    await tester.pump();

    expect(find.text('Account & sync'), findsOneWidget);
    expect(find.text('Signing in...'), findsOneWidget);
    expect(find.byType(MxCircularProgress), findsOneWidget);
    expect(find.text('Sign in with Google'), findsNothing);
  });

  testWidgets('DT20 onDisplay: sync error renders retry chip on hub', (
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
      driveSyncRepository: _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus.failure(
          'Google Drive API has not been used in project.',
        ),
      ),
    );

    expect(find.text('Account & sync'), findsOneWidget);
    expect(
      find.text('alex@memox.app · last synced 2 days ago'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsWidgets);
    expect(find.byTooltip('Sync now'), findsNothing);
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

      expect(find.text('Account & sync'), findsOneWidget);
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

      expect(find.text('Account & sync'), findsOneWidget);
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
    expect(find.byTooltip('Sync now'), findsNothing);
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
      find.text('Audio & speech'),
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

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('Account & sync'), findsOneWidget);
      expect(find.text('alex@memox.app · synced 2 min ago'), findsOneWidget);
      expect(find.textContaining('Google Drive ready'), findsNothing);
      expect(find.text('STUDY'), findsOneWidget);
      expect(find.text('Learning'), findsOneWidget);
      expect(find.text('Audio & speech'), findsOneWidget);
      expect(
        tester.getRect(find.text('Audio & speech')).bottom,
        lessThanOrEqualTo(viewportHeight),
      );
    },
  );

  testWidgets('DT2 onDisplay: renders audio and speech overview row', (
    tester,
  ) async {
    await _pumpSettings(tester);

    await tester.scrollUntilVisible(
      find.text('Audio & speech'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Audio & speech'), findsOneWidget);
    expect(find.text('Korean voice · 0.9× speed'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(
          const ValueKey<String>('settings-overview-audio-speech-row'),
        ),
        matching: find.byType(MxBadge),
      ),
      findsNothing,
    );
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
      find.text('Learning'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Learning'), findsOneWidget);
    expect(find.text('20 cards / day · 5 study modes'), findsOneWidget);
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
        find.text('Learning'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('20 cards / day · 5 study modes'), findsOneWidget);
    },
  );

  testWidgets('DT1 onNavigate: account overview opens account detail', (
    tester,
  ) async {
    await _pumpSettingsRouter(tester);

    await tester.tap(
      _overviewCardFinderForKey('settings-overview-account-row'),
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
      _overviewCardFinderForKey('settings-overview-account-row'),
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

  testWidgets('DT5 onNavigate: manage tags row opens route shell', (
    tester,
  ) async {
    await _pumpSettingsRouter(tester);

    await tester.tap(
      find.byKey(const ValueKey<String>('settings-overview-manage-tags-row')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SettingsTagManagementScreen), findsOneWidget);
    // With an empty stream override the screen shows its empty state.
    expect(find.text('No tags yet'), findsOneWidget);
  });

  testWidgets('DT6 onNavigate: about row opens MemoX dialog', (tester) async {
    await _pumpSettingsRouter(tester);

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('settings-overview-about-row')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('settings-overview-about-row')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AboutDialog), findsOneWidget);
    expect(find.text('MemoX'), findsWidgets);
    expect(find.text('1.4.2 (build 248)'), findsOneWidget);
  });

  testWidgets('DT7 onNavigate: sync error retry chip opens account detail', (
    tester,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final store = CloudAccountStore(preferences);
    await store.save(_driveReadyLink);

    await _pumpSettingsRouter(
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
      driveSyncRepository: _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus.failure(
          'Google Drive API has not been used in project.',
        ),
      ),
    );

    await tester.tap(
      _overviewCardFinderForKey('settings-overview-account-row'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AccountSettingsScreen), findsOneWidget);
  });

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

      final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
      sliders[0].onChanged?.call(0.7);
      await tester.pumpAndSettle();
      sliders[1].onChanged?.call(1.3);
      await tester.pumpAndSettle();
      sliders[2].onChanged?.call(0.6);
      await tester.pumpAndSettle();

      final settings = await harness.container.read(ttsSettingsProvider.future);
      expect(settings.autoPlay, isTrue);
      expect(settings.frontLanguage, TtsLanguage.english);
      expect(settings.rate, 0.7);
      expect(settings.pitch, 1.3);
      expect(settings.volume, 0.6);

      await tester.ensureVisible(find.byKey(_speechPreviewButtonKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_speechPreviewButtonKey));
      await tester.pumpAndSettle();

      expect(harness.tts.speakCalls, hasLength(1));
      expect(harness.tts.speakCalls.single.language, TtsLanguage.english);
      expect(harness.tts.speakCalls.single.rate, 0.7);
      expect(harness.tts.speakCalls.single.pitch, 1.3);
      expect(harness.tts.speakCalls.single.volume, 0.6);
    },
  );

  testWidgets('DT4 onUpdate: speech preview failure shows safe feedback only', (
    tester,
  ) async {
    const technicalDetail = 'PlatformException(tts_engine_secret)';
    await _pumpSettings(
      tester,
      child: const AudioSpeechSettingsScreen(),
      ttsService: _FakeTtsService(speakError: StateError(technicalDetail)),
    );

    await tester.tap(find.byKey(_speechVoiceSelectionRowKey));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(_speechPreviewButtonKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(_speechPreviewButtonKey));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong.'), findsOneWidget);
    expect(find.textContaining(technicalDetail), findsNothing);
    expect(find.textContaining('PlatformException'), findsNothing);
  });

  testWidgets(
    'DT5 onDisplay: speech primary voice summary hides raw platform voice id',
    (tester) async {
      const rawVoiceId = 'ko-kr-x-ism-local';
      await _pumpSettings(
        tester,
        child: const AudioSpeechSettingsScreen(),
        ttsSettingsRepositoryFuture: Future<TtsSettingsRepository>.value(
          _FakeTtsSettingsRepository(
            settings: const TtsSettings(
              autoPlay: false,
              frontLanguage: TtsLanguage.korean,
              rate: TtsSettings.defaultRate,
              pitch: TtsSettings.defaultPitch,
              volume: TtsSettings.defaultVolume,
              frontVoiceName: rawVoiceId,
            ),
          ),
        ),
      );

      expect(find.text('Device voice'), findsOneWidget);
      expect(find.text(rawVoiceId), findsNothing);
    },
  );

  testWidgets(
    'DT6 onDisplay: audio settings excludes unrelated settings controls',
    (tester) async {
      await _pumpSettings(tester, child: const AudioSpeechSettingsScreen());

      expect(find.text('Sign in & sync'), findsNothing);
      expect(find.text('Drive sync'), findsNothing);
      expect(find.text('Learning'), findsNothing);
      expect(find.text('Manage tags'), findsNothing);
      expect(find.text('Progress'), findsNothing);
      expect(find.text('Global search'), findsNothing);
      expect(find.text('Flashcard history'), findsNothing);
      expect(find.byKey(_speechTextToSpeechToggleKey), findsOneWidget);
      expect(find.byKey(_speechVoiceSelectionRowKey), findsOneWidget);
    },
  );

  testWidgets(
    'DT7 onUpdate: speech voice options stay collapsed until requested',
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
      await tester.ensureVisible(
        find.byType(DropdownButtonFormField<String>).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      expect(find.text('Korean voice 1 · Device · Male'), findsOneWidget);
      expect(find.text('Korean voice 1 · Online'), findsOneWidget);
      expect(find.text('ko-kr-x-ism-local'), findsNothing);
      await tester.tap(find.text('Korean voice 1 · Device · Male'));
      await tester.pumpAndSettle();
      expect(find.text('Back voice'), findsNothing);
      expect(harness.tts.availableVoiceRequests, [TtsLanguage.korean]);
    },
  );

  testWidgets(
    'DT8 onUpdate: selected speech voice and custom preview text flow through',
    (tester) async {
      final harness = await _pumpSettings(
        tester,
        child: const AudioSpeechSettingsScreen(),
      );

      await tester.tap(find.byKey(_speechVoiceSelectionRowKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(_speechVoiceOptionsButtonKey));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byType(DropdownButtonFormField<String>).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Korean voice 1 · Device · Male'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '  custom sample  ');
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(_speechPreviewButtonKey));
      await tester.pumpAndSettle();

      expect(harness.tts.speakCalls, hasLength(1));
      expect(harness.tts.speakCalls.single.text, 'custom sample');
      expect(harness.tts.speakCalls.single.voiceName, 'ko-kr-x-ism-local');

      final languageControls = tester
          .widgetList<MxSegmentedControl<TtsLanguage>>(
            find.byType(MxSegmentedControl<TtsLanguage>),
          )
          .toList();
      languageControls.first.onChanged({TtsLanguage.english});
      await tester.pumpAndSettle();

      final settings = await harness.container.read(ttsSettingsProvider.future);
      expect(settings.frontLanguage, TtsLanguage.english);
      expect(settings.frontVoiceName, isNull);
      expect(harness.tts.availableVoiceRequests, [
        TtsLanguage.korean,
        TtsLanguage.english,
      ]);
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
      expect(find.byType(MxIconTile), findsWidgets);
      expect(find.byType(MxBadge), findsWidgets);
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

      expect(link?.email, 'alex@memox.app');
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
    'DT8b onDisplay: Account detail renders unsupported state safely',
    (tester) async {
      await _pumpSettings(
        tester,
        child: const AccountSettingsScreen(),
        googleConfig: _configuredGoogle,
        googleAuth: _FakeGoogleAccountAuthService(
          restoreResult: const GoogleAccountAuthResult.unsupported(),
        ),
      );

      expect(
        find.text('Use Android, iOS, or web to link Google account.'),
        findsOneWidget,
      );
      expect(find.text('Sign in with Google'), findsOneWidget);
      final signInButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Sign in with Google'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(signInButton.onPressed, isNull);
    },
  );

  testWidgets(
    'DT7b onUpdate: failed Google sign-in hides technical auth detail',
    (tester) async {
      const technicalDetail = 'accessToken=secret-token\nStackTrace: auth';
      final harness = await _pumpSettings(
        tester,
        child: const AccountSettingsScreen(),
        googleConfig: _configuredGoogle,
        googleAuth: _FakeGoogleAccountAuthService(
          signInResult: const GoogleAccountAuthResult.failure(technicalDetail),
        ),
      );

      await tester.tap(find.text('Sign in with Google'));
      await tester.pumpAndSettle();

      final repository = await harness.container.read(
        cloudAccountRepositoryProvider.future,
      );

      expect(await repository.load(), isNull);
      expect(find.text('Google sign-in failed. Try again.'), findsWidgets);
      expect(find.text(technicalDetail), findsNothing);
      expect(find.textContaining('secret-token'), findsNothing);
      expect(find.textContaining('StackTrace'), findsNothing);
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

      expect(link?.email, 'alex@memox.app');
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
      // New: confirmation dialog before sign-out — tap the danger primary
      // action ("Sign out") inside the dialog to proceed.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign out'));
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

  testWidgets(
    'DT9b onUpdate: disconnect clears account and preserves local data',
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

      await tester.tap(find.text('Disconnect Google'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Disconnect Google'),
      );
      await tester.pumpAndSettle();

      final repository = await harness.container.read(
        cloudAccountRepositoryProvider.future,
      );
      final studyStore = await harness.container.read(
        studySettingsStoreProvider.future,
      );

      expect(await repository.load(), isNull);
      expect(googleAuth.disconnectCount, 1);
      expect(googleAuth.signOutCount, 0);
      expect(studyStore.loadNewStudyDefaults().batchSize, 12);
      expect(
        find.text('Google account disconnected. Drive access tokens revoked.'),
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

    expect(find.text('alex@memox.app · synced 2 min ago'), findsOneWidget);
    expect(find.byTooltip('Sync now'), findsNothing);
  });

  testWidgets('DT11 onUpdate: Drive sync upload result is visible', (
    tester,
  ) async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
      uploadResult: const DriveSyncRunResult.uploadedLocal(
        DriveSyncStatus(kind: DriveSyncStatusKind.synced),
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
    expect(find.text('Local data backed up to Google Drive.'), findsOneWidget);
    expect(repository.uploadLocalCount, 1);
  });

  testWidgets(
    'DT14 onUpdate: Drive sync restore opens destructive warning before restore',
    (tester) async {
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
    expect(
      find.textContaining('Recent local changes that were not uploaded may be lost'),
      findsOneWidget,
    );
    expect(repository.restoreDriveCount, 0);
    await tester.tap(find.text('Restore from Drive'));
    await tester.pumpAndSettle();

    expect(find.text('Google Drive is up to date.'), findsOneWidget);
    expect(find.text('Drive copy restored.'), findsOneWidget);
    expect(repository.restoreDriveCount, 1);
    },
  );

  testWidgets('DT15 onUpdate: canceling sync confirmation does not upload', (
    tester,
  ) async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
      uploadResult: const DriveSyncRunResult.uploadedLocal(
        DriveSyncStatus(kind: DriveSyncStatusKind.synced),
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

  testWidgets(
    'DT15b onUpdate: canceling restore confirmation does not restore',
    (tester) async {
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
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repository.restoreDriveCount, 0);
      expect(find.text('Drive copy restored.'), findsNothing);
    },
  );

  testWidgets('DT14b onUpdate: Drive sync restore failure shows safe feedback', (
    tester,
  ) async {
    const diagnostic = 'Restore snapshot failed.';
    final remote = _remoteSnapshot();
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: DriveSyncStatus(
        kind: DriveSyncStatusKind.ready,
        remote: remote,
      ),
      restoreResult: const DriveSyncRunResult.failed(
        DriveSyncStatus.failure(diagnostic),
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
    await tester.tap(find.text('Download Drive data to this device'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore from Drive'));
    await tester.pumpAndSettle();

    expect(repository.restoreDriveCount, 1);
    expect(find.text('Drive sync failed. Try again.'), findsOneWidget);
    expect(find.text(diagnostic), findsOneWidget);
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
        uploadResult: const DriveSyncRunResult.failed(
          DriveSyncStatus.failure(diagnostic),
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
