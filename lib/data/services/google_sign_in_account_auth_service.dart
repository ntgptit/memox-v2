import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/config/google_oauth_config.dart';
import '../../domain/entities/cloud_account_link.dart';
import '../../domain/services/google_account_auth_service.dart';

final class GoogleSignInAccountAuthService implements GoogleAccountAuthService {
  GoogleSignInAccountAuthService({GoogleSignIn? signIn})
    : _signIn = signIn ?? GoogleSignIn.instance;

  static const List<String> _driveAppDataScopes = <String>[
    googleDriveAppDataScope,
  ];

  final GoogleSignIn _signIn;
  final StreamController<GoogleAccountAuthResult> _events =
      StreamController<GoogleAccountAuthResult>.broadcast();
  Future<void>? _initializeFuture;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;
  GoogleSignInAccount? _currentAccount;

  @override
  Stream<GoogleAccountAuthResult> get authenticationEvents => _events.stream;

  @override
  bool get supportsInteractiveSignIn => _signIn.supportsAuthenticate();

  @override
  bool get requiresPlatformSignInButton => !supportsInteractiveSignIn;

  @override
  Future<void> initialize(GoogleOAuthConfig config) {
    return _initializeFuture ??= _initialize(config);
  }

  Future<void> _initialize(GoogleOAuthConfig config) async {
    await _signIn.initialize(
      clientId: _resolveClientId(config),
      serverClientId: config.serverClientId,
    );
    _authSubscription = _signIn.authenticationEvents.listen(
      _handleAuthenticationEvent,
      onError: _handleAuthenticationError,
    );
  }

  String? _resolveClientId(GoogleOAuthConfig config) {
    if (kIsWeb) {
      return config.webClientId;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => config.iosClientId,
      TargetPlatform.android ||
      TargetPlatform.fuchsia ||
      TargetPlatform.linux ||
      TargetPlatform.windows => null,
    };
  }

  @override
  Future<GoogleAccountAuthResult> restoreLightweightSession(
    GoogleOAuthConfig config,
  ) async {
    if (!config.isConfiguredForCurrentPlatform) {
      return const GoogleAccountAuthResult.unconfigured();
    }
    try {
      await initialize(config);
      final future = _signIn.attemptLightweightAuthentication();
      if (future == null) {
        return const GoogleAccountAuthResult.signedOut();
      }
      final account = await future;
      if (account == null) {
        return const GoogleAccountAuthResult.signedOut();
      }
      _currentAccount = account;
      return _authorizeExistingScopes(account);
    } on GoogleSignInException catch (error) {
      return _mapGoogleException(error);
    } on Object catch (error) {
      return GoogleAccountAuthResult.failure(error.toString());
    }
  }

  @override
  Future<GoogleAccountAuthResult> signInAndAuthorizeDriveAppData(
    GoogleOAuthConfig config,
  ) async {
    if (!config.isConfiguredForCurrentPlatform) {
      return const GoogleAccountAuthResult.unconfigured();
    }
    try {
      await initialize(config);
      if (!supportsInteractiveSignIn) {
        return const GoogleAccountAuthResult.unsupported();
      }
      final account = await _signIn.authenticate(
        scopeHint: _driveAppDataScopes,
      );
      _currentAccount = account;
      return _authorizeDriveAppData(account, promptIfNecessary: true);
    } on GoogleSignInException catch (error) {
      return _mapGoogleException(error);
    } on Object catch (error) {
      return GoogleAccountAuthResult.failure(error.toString());
    }
  }

  @override
  Future<GoogleAccountAuthResult> authorizeDriveAppData(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  ) async {
    if (!config.isConfiguredForCurrentPlatform) {
      return const GoogleAccountAuthResult.unconfigured();
    }
    try {
      await initialize(config);
      final account = await _currentAccountForLink(link);
      if (account == null) {
        return const GoogleAccountAuthResult.signedOut();
      }
      return _authorizeDriveAppData(account, promptIfNecessary: true);
    } on GoogleSignInException catch (error) {
      return _mapGoogleException(error);
    } on Object catch (error) {
      return GoogleAccountAuthResult.failure(error.toString());
    }
  }

  @override
  Future<DriveAccessTokenResult> getDriveAppDataAccessToken(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  ) async {
    if (!config.isConfiguredForCurrentPlatform) {
      return const DriveAccessTokenResult.unconfigured();
    }
    try {
      await initialize(config);
      final account = await _currentAccountForLink(link);
      if (account == null) {
        return const DriveAccessTokenResult.signedOut();
      }
      final authorization = await account.authorizationClient
          .authorizationForScopes(_driveAppDataScopes);
      if (authorization == null) {
        return const DriveAccessTokenResult.reauthorizationRequired();
      }
      return DriveAccessTokenResult.success(authorization.accessToken);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        return const DriveAccessTokenResult.reauthorizationRequired();
      }
      return DriveAccessTokenResult.failure(error.description);
    } on Object catch (error) {
      return DriveAccessTokenResult.failure(error.toString());
    }
  }

  @override
  Future<void> signOutLocal() {
    _currentAccount = null;
    return _signIn.signOut();
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
    await _events.close();
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        _currentAccount = event.user;
        _events.add(
          await _authorizeDriveAppData(event.user, promptIfNecessary: true),
        );
      case GoogleSignInAuthenticationEventSignOut():
        _currentAccount = null;
        _events.add(const GoogleAccountAuthResult.signedOut());
    }
  }

  void _handleAuthenticationError(Object error) {
    if (error is GoogleSignInException) {
      _events.add(_mapGoogleException(error));
      return;
    }
    _events.add(GoogleAccountAuthResult.failure(error.toString()));
  }

  Future<GoogleAccountAuthResult> _authorizeExistingScopes(
    GoogleSignInAccount account,
  ) async {
    final authorization = await account.authorizationClient
        .authorizationForScopes(_driveAppDataScopes);
    final session = _sessionFromAccount(
      account,
      grantedScopes: authorization == null
          ? const <String>{}
          : const <String>{googleDriveAppDataScope},
      driveAuthorizationState: authorization == null
          ? DriveAuthorizationState.authorizationRequired
          : DriveAuthorizationState.authorized,
    );
    if (authorization == null) {
      return GoogleAccountAuthResult.driveAuthorizationRequired(session);
    }
    return GoogleAccountAuthResult.success(session);
  }

  Future<GoogleAccountAuthResult> _authorizeDriveAppData(
    GoogleSignInAccount account, {
    required bool promptIfNecessary,
  }) async {
    try {
      final authorization =
          await account.authorizationClient.authorizationForScopes(
            _driveAppDataScopes,
          ) ??
          (promptIfNecessary
              ? await account.authorizationClient.authorizeScopes(
                  _driveAppDataScopes,
                )
              : null);
      final session = _sessionFromAccount(
        account,
        grantedScopes: authorization == null
            ? const <String>{}
            : const <String>{googleDriveAppDataScope},
        driveAuthorizationState: authorization == null
            ? DriveAuthorizationState.authorizationRequired
            : DriveAuthorizationState.authorized,
      );
      if (authorization == null) {
        return GoogleAccountAuthResult.driveAuthorizationRequired(session);
      }
      return GoogleAccountAuthResult.success(session);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        return GoogleAccountAuthResult.driveAuthorizationRequired(
          _sessionFromAccount(
            account,
            grantedScopes: const <String>{},
            driveAuthorizationState: DriveAuthorizationState.denied,
          ),
        );
      }
      return _mapGoogleException(error);
    }
  }

  Future<GoogleSignInAccount?> _currentAccountForLink(
    CloudAccountLink link,
  ) async {
    final currentAccount = _currentAccount;
    if (currentAccount != null && currentAccount.id == link.subjectId) {
      return currentAccount;
    }
    if (kIsWeb) {
      return null;
    }
    final future = _signIn.attemptLightweightAuthentication();
    if (future == null) {
      return null;
    }
    final account = await future;
    if (account == null || account.id != link.subjectId) {
      return null;
    }
    _currentAccount = account;
    return account;
  }

  GoogleAccountAuthSession _sessionFromAccount(
    GoogleSignInAccount account, {
    required Set<String> grantedScopes,
    required DriveAuthorizationState driveAuthorizationState,
  }) {
    return GoogleAccountAuthSession(
      profile: GoogleAccountProfile(
        subjectId: account.id,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      ),
      grantedScopes: grantedScopes,
      driveAuthorizationState: driveAuthorizationState,
    );
  }

  GoogleAccountAuthResult _mapGoogleException(GoogleSignInException error) {
    return switch (error.code) {
      GoogleSignInExceptionCode.canceled ||
      GoogleSignInExceptionCode.interrupted =>
        const GoogleAccountAuthResult.canceled(),
      GoogleSignInExceptionCode.uiUnavailable =>
        const GoogleAccountAuthResult.unsupported(),
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError =>
        GoogleAccountAuthResult.failure(error.description),
      GoogleSignInExceptionCode.unknownError ||
      GoogleSignInExceptionCode.userMismatch => GoogleAccountAuthResult.failure(
        error.description,
      ),
    };
  }
}
