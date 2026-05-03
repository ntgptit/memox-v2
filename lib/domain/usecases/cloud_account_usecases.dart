import '../../core/config/google_oauth_config.dart';
import '../../core/services/clock.dart';
import '../entities/cloud_account_link.dart';
import '../repositories/cloud_account_repository.dart';
import '../services/google_account_auth_service.dart';

final class LoadCloudAccountLinkUseCase {
  const LoadCloudAccountLinkUseCase(this._repository);

  final CloudAccountRepository _repository;

  Future<CloudAccountLink?> execute() => _repository.load();
}

final class RestoreGoogleAccountUseCase {
  const RestoreGoogleAccountUseCase({
    required CloudAccountRepository repository,
    required GoogleAccountAuthService authService,
    required GoogleOAuthConfig config,
    required Clock clock,
  }) : _repository = repository,
       _authService = authService,
       _config = config,
       _clock = clock;

  final CloudAccountRepository _repository;
  final GoogleAccountAuthService _authService;
  final GoogleOAuthConfig _config;
  final Clock _clock;

  Future<CloudAccountActionResult> execute() async {
    if (!_config.isConfiguredForCurrentPlatform) {
      return const CloudAccountActionResult.unconfigured();
    }
    final authResult = await _authService.restoreLightweightSession(_config);
    return _persistAuthResult(authResult);
  }

  Future<CloudAccountActionResult> _persistAuthResult(
    GoogleAccountAuthResult result,
  ) async {
    return persistCloudAccountAuthResult(
      result: result,
      repository: _repository,
      clock: _clock,
      clearOnSignedOut: false,
    );
  }
}

final class SignInGoogleAccountUseCase {
  const SignInGoogleAccountUseCase({
    required CloudAccountRepository repository,
    required GoogleAccountAuthService authService,
    required GoogleOAuthConfig config,
    required Clock clock,
  }) : _repository = repository,
       _authService = authService,
       _config = config,
       _clock = clock;

  final CloudAccountRepository _repository;
  final GoogleAccountAuthService _authService;
  final GoogleOAuthConfig _config;
  final Clock _clock;

  Future<CloudAccountActionResult> execute() async {
    if (!_config.isConfiguredForCurrentPlatform) {
      return const CloudAccountActionResult.unconfigured();
    }
    final authResult = await _authService.signInAndAuthorizeDriveAppData(
      _config,
    );
    return persistCloudAccountAuthResult(
      result: authResult,
      repository: _repository,
      clock: _clock,
      clearOnSignedOut: false,
    );
  }
}

final class AuthorizeGoogleDriveUseCase {
  const AuthorizeGoogleDriveUseCase({
    required CloudAccountRepository repository,
    required GoogleAccountAuthService authService,
    required GoogleOAuthConfig config,
    required Clock clock,
  }) : _repository = repository,
       _authService = authService,
       _config = config,
       _clock = clock;

  final CloudAccountRepository _repository;
  final GoogleAccountAuthService _authService;
  final GoogleOAuthConfig _config;
  final Clock _clock;

  Future<CloudAccountActionResult> execute(CloudAccountLink link) async {
    if (!_config.isConfiguredForCurrentPlatform) {
      return const CloudAccountActionResult.unconfigured();
    }
    final authResult = await _authService.authorizeDriveAppData(_config, link);
    return persistCloudAccountAuthResult(
      result: authResult,
      repository: _repository,
      clock: _clock,
      clearOnSignedOut: false,
    );
  }
}

final class SignOutGoogleAccountUseCase {
  const SignOutGoogleAccountUseCase({
    required CloudAccountRepository repository,
    required GoogleAccountAuthService authService,
  }) : _repository = repository,
       _authService = authService;

  final CloudAccountRepository _repository;
  final GoogleAccountAuthService _authService;

  Future<void> execute() async {
    await _authService.signOutLocal();
    await _repository.clear();
  }
}

final class PersistGoogleAccountAuthResultUseCase {
  const PersistGoogleAccountAuthResultUseCase({
    required CloudAccountRepository repository,
    required Clock clock,
  }) : _repository = repository,
       _clock = clock;

  final CloudAccountRepository _repository;
  final Clock _clock;

  Future<CloudAccountActionResult> execute(
    GoogleAccountAuthResult result, {
    bool clearOnSignedOut = false,
  }) {
    return persistCloudAccountAuthResult(
      result: result,
      repository: _repository,
      clock: _clock,
      clearOnSignedOut: clearOnSignedOut,
    );
  }
}

final class GetDriveAppDataAccessTokenUseCase {
  const GetDriveAppDataAccessTokenUseCase({
    required CloudAccountRepository repository,
    required GoogleAccountAuthService authService,
    required GoogleOAuthConfig config,
  }) : _repository = repository,
       _authService = authService,
       _config = config;

  final CloudAccountRepository _repository;
  final GoogleAccountAuthService _authService;
  final GoogleOAuthConfig _config;

  Future<DriveAccessTokenResult> execute() async {
    final link = await _repository.load();
    if (link == null) {
      return const DriveAccessTokenResult.signedOut();
    }
    return _authService.getDriveAppDataAccessToken(_config, link);
  }
}

final class CloudAccountActionResult {
  const CloudAccountActionResult({
    required this.status,
    this.link,
    this.technicalMessage,
  });

  const CloudAccountActionResult.success(CloudAccountLink link)
    : this(status: AccountLinkStatus.signedIn, link: link);

  const CloudAccountActionResult.needsDriveAuthorization(CloudAccountLink link)
    : this(status: AccountLinkStatus.needsDriveAuthorization, link: link);

  const CloudAccountActionResult.signedOut()
    : this(status: AccountLinkStatus.signedOut);

  const CloudAccountActionResult.unconfigured()
    : this(status: AccountLinkStatus.unconfigured);

  const CloudAccountActionResult.unsupported()
    : this(status: AccountLinkStatus.unsupported);

  const CloudAccountActionResult.error([String? technicalMessage])
    : this(status: AccountLinkStatus.error, technicalMessage: technicalMessage);

  final AccountLinkStatus status;
  final CloudAccountLink? link;
  final String? technicalMessage;
}

Future<CloudAccountActionResult> persistCloudAccountAuthResult({
  required GoogleAccountAuthResult result,
  required CloudAccountRepository repository,
  required Clock clock,
  required bool clearOnSignedOut,
}) async {
  switch (result.status) {
    case GoogleAccountAuthStatus.success:
      final existing = await repository.load();
      final link = _linkFromSession(result.session!, clock, existing);
      await repository.save(link);
      return CloudAccountActionResult.success(link);
    case GoogleAccountAuthStatus.driveAuthorizationRequired:
      final existing = await repository.load();
      final link = _linkFromSession(result.session!, clock, existing);
      await repository.save(link);
      return CloudAccountActionResult.needsDriveAuthorization(link);
    case GoogleAccountAuthStatus.signedOut:
      if (clearOnSignedOut) {
        await repository.clear();
      }
      return const CloudAccountActionResult.signedOut();
    case GoogleAccountAuthStatus.unconfigured:
      return const CloudAccountActionResult.unconfigured();
    case GoogleAccountAuthStatus.unsupported:
      return const CloudAccountActionResult.unsupported();
    case GoogleAccountAuthStatus.canceled:
      return const CloudAccountActionResult.signedOut();
    case GoogleAccountAuthStatus.failure:
      return CloudAccountActionResult.error(result.technicalMessage);
  }
}

CloudAccountLink _linkFromSession(
  GoogleAccountAuthSession session,
  Clock clock,
  CloudAccountLink? existing,
) {
  final now = clock.nowEpochMillis();
  final shouldPreserveLinkedAt =
      existing != null &&
      existing.provider == CloudProvider.google &&
      existing.subjectId == session.profile.subjectId;
  return CloudAccountLink(
    provider: CloudProvider.google,
    subjectId: session.profile.subjectId,
    email: session.profile.email,
    displayName: session.profile.displayName,
    photoUrl: session.profile.photoUrl,
    grantedScopes: session.grantedScopes,
    driveAuthorizationState: session.driveAuthorizationState,
    linkedAt: shouldPreserveLinkedAt ? existing.linkedAt : now,
    lastSignedInAt: now,
  );
}
