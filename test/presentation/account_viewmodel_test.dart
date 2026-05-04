import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/account_providers.dart';
import 'package:memox/app/di/content_providers.dart';
import 'package:memox/app/di/sync_providers.dart';
import 'package:memox/core/config/google_oauth_config.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/data/settings/cloud_account_store.dart';
import 'package:memox/domain/entities/cloud_account_link.dart';
import 'package:memox/domain/entities/drive_sync_models.dart';
import 'package:memox/domain/repositories/cloud_account_repository.dart';
import 'package:memox/domain/repositories/drive_sync_repository.dart';
import 'package:memox/domain/services/google_account_auth_service.dart';
import 'package:memox/presentation/features/settings/viewmodels/account_settings_viewmodel.dart';
import 'package:memox/presentation/features/settings/viewmodels/drive_sync_settings_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/content_repository_harness.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'DT1 onOpen: missing OAuth config produces unconfigured account state',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() {
        debugDefaultTargetPlatformOverride = null;
      });
      final container = _createContainer(
        config: GoogleOAuthConfig.fromValues(),
        auth: _FakeGoogleAccountAuthService(),
      );
      addTearDown(container.dispose);

      final state = await container.read(
        accountSettingsControllerProvider.future,
      );

      expect(state.status, AccountLinkStatus.unconfigured);
      expect(state.canSignIn, isFalse);
    },
  );

  test(
    'DT2 onOpen: stored Drive-ready account is restored for display',
    () async {
      final preferences = await SharedPreferences.getInstance();
      await CloudAccountStore(preferences).save(_driveReadyLink);
      final container = _createContainer(auth: _FakeGoogleAccountAuthService());
      addTearDown(container.dispose);

      final state = await container.read(
        accountSettingsControllerProvider.future,
      );

      expect(state.status, AccountLinkStatus.signedIn);
      expect(state.link?.email, 'user@example.com');
    },
  );

  test(
    'DT1 onUpdate: sign-in success stores Drive-ready Google account',
    () async {
      final container = _createContainer(
        auth: _FakeGoogleAccountAuthService(
          signInResult: GoogleAccountAuthResult.success(
            _session(
              grantedScopes: const <String>{googleDriveAppDataScope},
              driveAuthorizationState: DriveAuthorizationState.authorized,
            ),
          ),
        ),
      );
      addTearDown(container.dispose);

      await container.read(accountSettingsControllerProvider.future);
      await container.read(accountSettingsControllerProvider.notifier).signIn();
      final state = container
          .read(accountSettingsControllerProvider)
          .requireValue;
      final repository = await container.read(
        cloudAccountRepositoryProvider.future,
      );
      final link = await repository.load();

      expect(state.status, AccountLinkStatus.signedIn);
      expect(link?.driveAppDataAuthorized, isTrue);
    },
  );

  test('DT2 onUpdate: canceled sign-in keeps store empty', () async {
    final container = _createContainer(
      auth: _FakeGoogleAccountAuthService(
        signInResult: const GoogleAccountAuthResult.canceled(),
      ),
    );
    addTearDown(container.dispose);

    await container.read(accountSettingsControllerProvider.future);
    await container.read(accountSettingsControllerProvider.notifier).signIn();
    final state = container
        .read(accountSettingsControllerProvider)
        .requireValue;
    final repository = await container.read(
      cloudAccountRepositoryProvider.future,
    );

    expect(state.status, AccountLinkStatus.signedOut);
    expect(await repository.load(), isNull);
  });

  test(
    'DT3 onUpdate: denied Drive scope stores account requiring reconnect',
    () async {
      final container = _createContainer(
        auth: _FakeGoogleAccountAuthService(
          signInResult: GoogleAccountAuthResult.driveAuthorizationRequired(
            _session(
              grantedScopes: const <String>{},
              driveAuthorizationState: DriveAuthorizationState.denied,
            ),
          ),
        ),
      );
      addTearDown(container.dispose);

      await container.read(accountSettingsControllerProvider.future);
      await container.read(accountSettingsControllerProvider.notifier).signIn();
      final state = container
          .read(accountSettingsControllerProvider)
          .requireValue;
      final repository = await container.read(
        cloudAccountRepositoryProvider.future,
      );
      final link = await repository.load();

      expect(state.status, AccountLinkStatus.needsDriveAuthorization);
      expect(link?.email, 'user@example.com');
      expect(link?.driveAppDataAuthorized, isFalse);
    },
  );

  test(
    'DT4 onUpdate: reconnecting Drive updates stored scope and state',
    () async {
      final preferences = await SharedPreferences.getInstance();
      await CloudAccountStore(preferences).save(_driveMissingLink);
      final container = _createContainer(
        auth: _FakeGoogleAccountAuthService(
          authorizeResult: GoogleAccountAuthResult.success(
            _session(
              grantedScopes: const <String>{googleDriveAppDataScope},
              driveAuthorizationState: DriveAuthorizationState.authorized,
            ),
          ),
        ),
      );
      addTearDown(container.dispose);

      await container.read(accountSettingsControllerProvider.future);
      await container
          .read(accountSettingsControllerProvider.notifier)
          .reconnectDrive();
      final state = container
          .read(accountSettingsControllerProvider)
          .requireValue;
      final repository = await container.read(
        cloudAccountRepositoryProvider.future,
      );
      final link = await repository.load();

      expect(state.status, AccountLinkStatus.signedIn);
      expect(link?.driveAppDataAuthorized, isTrue);
    },
  );

  test(
    'DT5 onUpdate: reconnecting Drive refreshes Drive sync status',
    () async {
      final preferences = await SharedPreferences.getInstance();
      await CloudAccountStore(preferences).save(_driveMissingLink);
      final syncRepository = _FakeDriveSyncRepository();
      final container = _createContainer(
        auth: _FakeGoogleAccountAuthService(
          authorizeResult: GoogleAccountAuthResult.success(
            _session(
              grantedScopes: const <String>{googleDriveAppDataScope},
              driveAuthorizationState: DriveAuthorizationState.authorized,
            ),
          ),
        ),
        syncRepository: syncRepository,
      );
      addTearDown(container.dispose);

      await container.read(accountSettingsControllerProvider.future);
      await container.read(driveSyncSettingsControllerProvider.future);
      expect(syncRepository.loadStatusCount, 1);

      await container
          .read(accountSettingsControllerProvider.notifier)
          .reconnectDrive();
      await container.read(driveSyncSettingsControllerProvider.future);

      expect(syncRepository.loadStatusCount, 2);
    },
  );

  test(
    'DT6 onUpdate: access token request does not persist token material',
    () async {
      final preferences = await SharedPreferences.getInstance();
      await CloudAccountStore(preferences).save(_driveReadyLink);
      final container = _createContainer(
        auth: _FakeGoogleAccountAuthService(
          accessTokenResult:
              const DriveAccessTokenResult.reauthorizationRequired(),
        ),
      );
      addTearDown(container.dispose);

      final useCase = await container.read(
        getDriveAppDataAccessTokenUseCaseProvider.future,
      );
      final result = await useCase.execute();
      final rawAccount = preferences.getString(
        AppConstants.sharedPrefsCloudAccountLinkKey,
      );

      expect(result.status, DriveAccessTokenStatus.reauthorizationRequired);
      expect(rawAccount, isNot(contains('accessToken')));
      expect(rawAccount, isNot(contains('refreshToken')));
      expect(rawAccount, isNot(contains('idToken')));
    },
  );

  test(
    'DT7 onUpdate: authentication event enters busy state before persistence completes',
    () async {
      final auth = _FakeGoogleAccountAuthService();
      final repository = _PausingCloudAccountRepository();
      final container = _createContainer(
        auth: auth,
        accountRepository: repository,
      );
      addTearDown(container.dispose);
      final states = <AsyncValue<AccountSettingsState>>[];
      final subscription = container.listen<AsyncValue<AccountSettingsState>>(
        accountSettingsControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await container.read(accountSettingsControllerProvider.future);
      states.clear();

      auth.emit(
        GoogleAccountAuthResult.success(
          _session(
            grantedScopes: const <String>{googleDriveAppDataScope},
            driveAuthorizationState: DriveAuthorizationState.authorized,
          ),
        ),
      );
      await repository.saveStarted.future;

      final busyState = states
          .lastWhere((value) => value.hasValue && value.requireValue.isBusy)
          .requireValue;
      expect(busyState.isBusy, isTrue);
      expect(busyState.status, AccountLinkStatus.signedOut);

      repository.allowSave();
      await repository.saveCompleted.future;
      await Future<void>.delayed(Duration.zero);
      final finalState = container
          .read(accountSettingsControllerProvider)
          .requireValue;

      expect(finalState.isBusy, isFalse);
      expect(finalState.status, AccountLinkStatus.signedIn);
      expect(finalState.link?.driveAppDataAuthorized, isTrue);
    },
  );
}

ProviderContainer _createContainer({
  GoogleOAuthConfig? config,
  required _FakeGoogleAccountAuthService auth,
  CloudAccountRepository? accountRepository,
  DriveSyncRepository? syncRepository,
}) {
  final container = ProviderContainer(
    overrides: [
      googleOAuthConfigProvider.overrideWithValue(
        config ??
            GoogleOAuthConfig.fromValues(
              webClientId: 'web-client-id.apps.googleusercontent.com',
              serverClientId: 'server-client-id.apps.googleusercontent.com',
            ),
      ),
      googleAccountAuthServiceProvider.overrideWithValue(auth),
      if (accountRepository != null)
        cloudAccountRepositoryProvider.overrideWith(
          (ref) async => accountRepository,
        ),
      if (syncRepository != null)
        driveSyncRepositoryProvider.overrideWith((ref) async => syncRepository),
      clockProvider.overrideWithValue(TestClock(DateTime.utc(2026, 5, 3, 9))),
    ],
  );
  return container;
}

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
    this.signInResult = const GoogleAccountAuthResult.signedOut(),
    this.authorizeResult,
    this.accessTokenResult =
        const DriveAccessTokenResult.reauthorizationRequired(),
  });

  final StreamController<GoogleAccountAuthResult> _events =
      StreamController<GoogleAccountAuthResult>.broadcast();

  GoogleAccountAuthResult restoreResult =
      const GoogleAccountAuthResult.signedOut();
  GoogleAccountAuthResult signInResult;
  GoogleAccountAuthResult? authorizeResult;
  DriveAccessTokenResult accessTokenResult;

  @override
  Stream<GoogleAccountAuthResult> get authenticationEvents => _events.stream;

  @override
  bool get supportsInteractiveSignIn => true;

  @override
  bool get requiresPlatformSignInButton => false;

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
    return authorizeResult ?? signInResult;
  }

  @override
  Future<DriveAccessTokenResult> getDriveAppDataAccessToken(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  ) async {
    return accessTokenResult;
  }

  @override
  Future<void> signOutLocal() async {}

  void emit(GoogleAccountAuthResult result) {
    _events.add(result);
  }
}

final class _PausingCloudAccountRepository implements CloudAccountRepository {
  final Completer<void> saveStarted = Completer<void>();
  final Completer<void> _allowSave = Completer<void>();
  final Completer<void> saveCompleted = Completer<void>();

  CloudAccountLink? _link;

  @override
  Future<CloudAccountLink?> load() async => _link;

  @override
  Future<void> save(CloudAccountLink link) async {
    if (!saveStarted.isCompleted) {
      saveStarted.complete();
    }
    await _allowSave.future;
    _link = link;
    if (!saveCompleted.isCompleted) {
      saveCompleted.complete();
    }
  }

  @override
  Future<void> clear() async {
    _link = null;
  }

  void allowSave() {
    if (!_allowSave.isCompleted) {
      _allowSave.complete();
    }
  }
}

final class _FakeDriveSyncRepository implements DriveSyncRepository {
  int loadStatusCount = 0;

  @override
  Future<DriveSyncStatus> loadStatus() async {
    loadStatusCount += 1;
    return const DriveSyncStatus.needsDriveAuthorization();
  }

  @override
  Future<DriveSyncRunResult> resolveConflict(
    DriveSyncConflict conflict,
    DriveSyncConflictChoice choice,
  ) async {
    return DriveSyncRunResult.canceled(
      const DriveSyncStatus.needsDriveAuthorization(),
    );
  }

  @override
  Future<DriveSyncRunResult> syncNow() async {
    return DriveSyncRunResult.noChanges(
      const DriveSyncStatus.needsDriveAuthorization(),
    );
  }
}
