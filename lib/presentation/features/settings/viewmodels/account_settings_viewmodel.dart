import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/account_providers.dart';
import '../../../../domain/entities/cloud_account_link.dart';
import '../../../../domain/services/google_account_auth_service.dart';
import '../../../../domain/usecases/cloud_account_usecases.dart';
import 'drive_sync_settings_viewmodel.dart';

part 'account_settings_viewmodel.g.dart';

enum AccountSettingsMessage {
  none,
  signInCanceled,
  signInFailed,
  driveAuthorizationRequired,
  signedOut,
}

class AccountSettingsState {
  const AccountSettingsState({
    required this.status,
    required this.requiresPlatformSignInButton,
    this.link,
    this.message = AccountSettingsMessage.none,
    this.isBusy = false,
  });

  final AccountLinkStatus status;
  final CloudAccountLink? link;
  final AccountSettingsMessage message;
  final bool isBusy;
  final bool requiresPlatformSignInButton;

  bool get canSignIn =>
      !isBusy &&
      status != AccountLinkStatus.unconfigured &&
      status != AccountLinkStatus.unsupported;

  bool get canSignOut =>
      !isBusy &&
      (status == AccountLinkStatus.signedIn ||
          status == AccountLinkStatus.needsDriveAuthorization);

  bool get canReconnectDrive =>
      !isBusy && status == AccountLinkStatus.needsDriveAuthorization;

  AccountSettingsState copyWith({
    AccountLinkStatus? status,
    CloudAccountLink? link,
    bool clearLink = false,
    AccountSettingsMessage? message,
    bool? isBusy,
    bool? requiresPlatformSignInButton,
  }) {
    return AccountSettingsState(
      status: status ?? this.status,
      link: clearLink ? null : link ?? this.link,
      message: message ?? this.message,
      isBusy: isBusy ?? this.isBusy,
      requiresPlatformSignInButton:
          requiresPlatformSignInButton ?? this.requiresPlatformSignInButton,
    );
  }
}

@riverpod
class AccountSettingsController extends _$AccountSettingsController {
  StreamSubscription<GoogleAccountAuthResult>? _authSubscription;

  @override
  Future<AccountSettingsState> build() async {
    final service = ref.watch(googleAccountAuthServiceProvider);
    _authSubscription ??= service.authenticationEvents.listen((result) {
      unawaited(_handleAuthenticationEvent(result));
    });
    ref.onDispose(() {
      unawaited(_authSubscription?.cancel());
      _authSubscription = null;
    });

    final config = ref.watch(googleOAuthConfigProvider);
    final requiresPlatformButton = service.requiresPlatformSignInButton;
    if (!config.isConfiguredForCurrentPlatform) {
      return AccountSettingsState(
        status: AccountLinkStatus.unconfigured,
        requiresPlatformSignInButton: requiresPlatformButton,
      );
    }

    final loadUseCase = await ref.watch(
      loadCloudAccountLinkUseCaseProvider.future,
    );
    final storedLink = await loadUseCase.execute();
    final restoreUseCase = await ref.watch(
      restoreGoogleAccountUseCaseProvider.future,
    );
    final restoreResult = await restoreUseCase.execute();
    return _stateFromActionResult(
      restoreResult,
      fallbackLink: storedLink,
      requiresPlatformSignInButton: requiresPlatformButton,
    );
  }

  Future<void> signIn() async {
    // guard:retry-reviewed
    await _runAction(() async {
      final useCase = await ref.read(signInGoogleAccountUseCaseProvider.future);
      return useCase.execute();
    });
  }

  Future<void> reconnectDrive() async {
    // guard:retry-reviewed
    final current = state.value;
    final link = current?.link;
    if (link == null) {
      await signIn();
      return;
    }

    await _runAction(() async {
      final authorizeUseCase = await ref.read(
        authorizeGoogleDriveUseCaseProvider.future,
      );
      final signInUseCase = await ref.read(
        signInGoogleAccountUseCaseProvider.future,
      );
      final result = await authorizeUseCase.execute(link);
      if (result.status == AccountLinkStatus.signedOut) {
        return signInUseCase.execute();
      }
      return result;
    });
  }

  Future<void> signOut() async {
    // guard:retry-reviewed
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(isBusy: true));
    final useCase = await ref.read(signOutGoogleAccountUseCaseProvider.future);
    await useCase.execute();
    if (!ref.mounted) {
      return;
    }
    state = AsyncData(
      AccountSettingsState(
        status: AccountLinkStatus.signedOut,
        message: AccountSettingsMessage.signedOut,
        requiresPlatformSignInButton: current.requiresPlatformSignInButton,
      ),
    );
    _refreshDriveSyncStatus();
  }

  Future<void> _handleAuthenticationEvent(
    GoogleAccountAuthResult result,
  ) async {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(isBusy: true));
    }
    final persistUseCase = await ref.read(
      persistGoogleAccountAuthResultUseCaseProvider.future,
    );
    final actionResult = await persistUseCase.execute(
      result,
      clearOnSignedOut: true,
    );
    if (!ref.mounted) {
      return;
    }
    final latest = state.value;
    final requiresPlatformButton =
        latest?.requiresPlatformSignInButton ??
        ref.read(googleAccountAuthServiceProvider).requiresPlatformSignInButton;
    state = AsyncData(
      _stateFromActionResult(
        actionResult,
        fallbackLink: latest?.link,
        requiresPlatformSignInButton: requiresPlatformButton,
      ),
    );
    _refreshDriveSyncStatus();
  }

  Future<void> _runAction(
    Future<CloudAccountActionResult> Function() action,
  ) async {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(current.copyWith(isBusy: true));
    final result = await action();
    if (!ref.mounted) {
      return;
    }
    state = AsyncData(
      _stateFromActionResult(
        result,
        fallbackLink: current.link,
        requiresPlatformSignInButton: current.requiresPlatformSignInButton,
      ),
    );
    _refreshDriveSyncStatus();
  }

  void _refreshDriveSyncStatus() {
    ref.invalidate(driveSyncSettingsControllerProvider);
  }

  AccountSettingsState _stateFromActionResult(
    CloudAccountActionResult result, {
    required CloudAccountLink? fallbackLink,
    required bool requiresPlatformSignInButton,
  }) {
    final link = result.link ?? fallbackLink;
    return switch (result.status) {
      AccountLinkStatus.signedIn => AccountSettingsState(
        status: AccountLinkStatus.signedIn,
        link: result.link,
        requiresPlatformSignInButton: requiresPlatformSignInButton,
      ),
      AccountLinkStatus.needsDriveAuthorization => AccountSettingsState(
        status: AccountLinkStatus.needsDriveAuthorization,
        link: result.link,
        message: AccountSettingsMessage.driveAuthorizationRequired,
        requiresPlatformSignInButton: requiresPlatformSignInButton,
      ),
      AccountLinkStatus.signedOut =>
        link == null
            ? AccountSettingsState(
                status: AccountLinkStatus.signedOut,
                message: AccountSettingsMessage.signInCanceled,
                requiresPlatformSignInButton: requiresPlatformSignInButton,
              )
            : AccountSettingsState(
                status: link.driveAppDataAuthorized
                    ? AccountLinkStatus.signedIn
                    : AccountLinkStatus.needsDriveAuthorization,
                link: link,
                requiresPlatformSignInButton: requiresPlatformSignInButton,
              ),
      AccountLinkStatus.unconfigured => AccountSettingsState(
        status: AccountLinkStatus.unconfigured,
        requiresPlatformSignInButton: requiresPlatformSignInButton,
      ),
      AccountLinkStatus.unsupported => AccountSettingsState(
        status: AccountLinkStatus.unsupported,
        requiresPlatformSignInButton: requiresPlatformSignInButton,
      ),
      AccountLinkStatus.error => AccountSettingsState(
        status: AccountLinkStatus.error,
        link: link,
        message: AccountSettingsMessage.signInFailed,
        requiresPlatformSignInButton: requiresPlatformSignInButton,
      ),
    };
  }
}
