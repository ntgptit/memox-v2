import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/account_providers.dart';
import 'package:memox/app/di/sync_providers.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/app/router/route_guards.dart';
import 'package:memox/core/config/google_oauth_config.dart';
import 'package:memox/domain/entities/cloud_account_link.dart';
import 'package:memox/domain/entities/drive_sync_models.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/repositories/drive_sync_repository.dart';
import 'package:memox/domain/services/google_account_auth_service.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/flashcards/screens/deck_import_screen.dart';
import 'package:memox/presentation/features/settings/screens/account_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/audio_speech_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/learning_settings_screen.dart';
import 'package:memox/presentation/features/settings/screens/settings_screen.dart';
import 'package:memox/presentation/features/study/providers/study_entry_notifier.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_entry_screen.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DT1 onNavigate: study session path resolves to session screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouteGuardsProvider.overrideWith(
            (ref) => const AppRouteGuards(
              initialLocation: '/library/study/session/session-001',
            ),
          ),
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_activeSnapshot)),
          studyEntryStateProvider(
            'session',
            'session-001',
          ).overrideWith((ref) => Future.value(_unexpectedEntryState)),
        ],
        child: const _RouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudySessionScreen), findsOneWidget);
    expect(find.byType(StudyEntryScreen), findsNothing);
  });

  testWidgets('DT2 onNavigate: deck import path hides shell navigation', (
    tester,
  ) async {
    await _pumpRoute(tester, '/library/deck/deck-001/import');
    await tester.pumpAndSettle();

    expect(find.byType(DeckImportScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('DT3 onNavigate: settings root keeps shell navigation', (
    tester,
  ) async {
    await _pumpRoute(tester, '/settings');
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);
  });

  testWidgets('DT4 onNavigate: settings account route hides shell navigation', (
    tester,
  ) async {
    await _pumpRoute(tester, '/settings/account');
    await tester.pumpAndSettle();

    expect(find.byType(AccountSettingsScreen), findsOneWidget);
    expect(find.text('Drive sync'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets(
    'DT5 onNavigate: settings learning route hides shell navigation',
    (tester) async {
      await _pumpRoute(tester, '/settings/learning');
      await tester.pumpAndSettle();

      expect(find.byType(LearningSettingsScreen), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);
    },
  );

  testWidgets('DT6 onNavigate: settings audio route hides shell navigation', (
    tester,
  ) async {
    await _pumpRoute(tester, '/settings/audio-speech');
    await tester.pumpAndSettle();

    expect(find.byType(AudioSpeechSettingsScreen), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(NavigationRail), findsNothing);
  });
}

Future<void> _pumpRoute(WidgetTester tester, String initialLocation) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appRouteGuardsProvider.overrideWith(
          (ref) => AppRouteGuards(initialLocation: initialLocation),
        ),
        googleOAuthConfigProvider.overrideWithValue(_configuredGoogle),
        googleAccountAuthServiceProvider.overrideWithValue(
          _FakeGoogleAccountAuthService(),
        ),
        driveSyncRepositoryProvider.overrideWith(
          (ref) async => _FakeDriveSyncRepository(),
        ),
      ],
      child: const _RouterApp(),
    ),
  );
}

class _RouterApp extends ConsumerWidget {
  const _RouterApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(appRouterProvider),
    );
}

final _activeSnapshot = StudySessionSnapshot(
  session: _session(SessionStatus.inProgress),
  currentItem: StudySessionItem(
    id: 'item-001',
    sessionId: 'session-001',
    flashcard: _card(id: 'card-001', front: 'front 1', back: 'back 1'),
    studyMode: StudyMode.guess,
    modeOrder: 1,
    roundIndex: 1,
    queuePosition: 1,
    sourcePool: SessionItemSourcePool.due,
    status: SessionItemStatus.pending,
    completedAt: null,
  ),
  sessionFlashcards: [_card(id: 'card-001', front: 'front 1', back: 'back 1')],
  summary: const StudySummary(
    totalCards: 1,
    completedAttempts: 0,
    correctAttempts: 0,
    incorrectAttempts: 0,
    increasedBoxCount: 0,
    decreasedBoxCount: 0,
    remainingCount: 1,
  ),
  canFinalize: false,
);

const _unexpectedEntryState = StudyEntryState(
  entryType: StudyEntryType.deck,
  entryRefId: 'deck-001',
  newStudyDefaults: _settings,
  reviewDefaults: _settings,
  resumeCandidate: null,
);

const _settings = StudySettingsSnapshot(
  batchSize: 10,
  shuffleFlashcards: false,
  shuffleAnswers: false,
  prioritizeOverdue: true,
);

StudySession _session(SessionStatus status) => StudySession(
    id: 'session-001',
    entryType: StudyEntryType.deck,
    entryRefId: 'deck-001',
    studyType: StudyType.srsReview,
    studyFlow: StudyFlow.srsFillReview,
    settings: _settings,
    status: status,
    startedAt: 0,
    endedAt: null,
    restartedFromSessionId: null,
  );

StudyFlashcardRef _card({
  required String id,
  required String front,
  required String back,
}) => StudyFlashcardRef(
    id: id,
    deckId: 'deck-001',
    front: front,
    back: back,
    sourcePool: SessionItemSourcePool.due,
  );

final _configuredGoogle = GoogleOAuthConfig.fromValues(
  webClientId: 'web-client-id.apps.googleusercontent.com',
  serverClientId: 'server-client-id.apps.googleusercontent.com',
);

final class _FakeGoogleAccountAuthService implements GoogleAccountAuthService {
  @override
  Stream<GoogleAccountAuthResult> get authenticationEvents =>
      const Stream<GoogleAccountAuthResult>.empty();

  @override
  bool get requiresPlatformSignInButton => false;

  @override
  bool get supportsInteractiveSignIn => true;

  @override
  Future<void> initialize(GoogleOAuthConfig config) async {}

  @override
  Future<GoogleAccountAuthResult> restoreLightweightSession(
    GoogleOAuthConfig config,
  ) async => const GoogleAccountAuthResult.signedOut();

  @override
  Future<GoogleAccountAuthResult> signInAndAuthorizeDriveAppData(
    GoogleOAuthConfig config,
  ) async => const GoogleAccountAuthResult.canceled();

  @override
  Future<GoogleAccountAuthResult> authorizeDriveAppData(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  ) async => const GoogleAccountAuthResult.canceled();

  @override
  Future<DriveAccessTokenResult> getDriveAppDataAccessToken(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  ) async => const DriveAccessTokenResult.reauthorizationRequired();

  @override
  Future<void> signOutLocal() async {}
}

final class _FakeDriveSyncRepository implements DriveSyncRepository {
  @override
  Future<DriveSyncStatus> loadStatus() async => const DriveSyncStatus.signedOut();

  @override
  Future<DriveSyncRunResult> syncNow() async => const DriveSyncRunResult.noChanges(DriveSyncStatus.signedOut());

  @override
  Future<DriveSyncRunResult> uploadLocalSnapshot() async => const DriveSyncRunResult.noChanges(DriveSyncStatus.signedOut());

  @override
  Future<DriveSyncRunResult> restoreDriveSnapshot() async => const DriveSyncRunResult.noChanges(DriveSyncStatus.signedOut());

  @override
  Future<DriveSyncRunResult> resolveConflict(
    DriveSyncConflict conflict,
    DriveSyncConflictChoice choice,
  ) async => const DriveSyncRunResult.canceled(DriveSyncStatus.signedOut());
}
