import '../../core/config/google_oauth_config.dart';
import '../entities/cloud_account_link.dart';

enum GoogleAccountAuthStatus {
  success,
  signedOut,
  canceled,
  unconfigured,
  unsupported,
  driveAuthorizationRequired,
  failure,
}

enum DriveAccessTokenStatus {
  success,
  signedOut,
  unconfigured,
  reauthorizationRequired,
  failure,
}

final class GoogleAccountProfile {
  const GoogleAccountProfile({
    required this.subjectId,
    required this.email,
    required this.displayName,
    required this.photoUrl,
  });

  final String subjectId;
  final String email;
  final String? displayName;
  final String? photoUrl;
}

final class GoogleAccountAuthSession {
  const GoogleAccountAuthSession({
    required this.profile,
    required this.grantedScopes,
    required this.driveAuthorizationState,
  });

  final GoogleAccountProfile profile;
  final Set<String> grantedScopes;
  final DriveAuthorizationState driveAuthorizationState;
}

final class GoogleAccountAuthResult {
  const GoogleAccountAuthResult({
    required this.status,
    this.session,
    this.technicalMessage,
  });

  const GoogleAccountAuthResult.success(GoogleAccountAuthSession session)
    : this(status: GoogleAccountAuthStatus.success, session: session);

  const GoogleAccountAuthResult.signedOut()
    : this(status: GoogleAccountAuthStatus.signedOut);

  const GoogleAccountAuthResult.canceled()
    : this(status: GoogleAccountAuthStatus.canceled);

  const GoogleAccountAuthResult.unconfigured()
    : this(status: GoogleAccountAuthStatus.unconfigured);

  const GoogleAccountAuthResult.unsupported()
    : this(status: GoogleAccountAuthStatus.unsupported);

  const GoogleAccountAuthResult.driveAuthorizationRequired(
    GoogleAccountAuthSession session,
  ) : this(
        status: GoogleAccountAuthStatus.driveAuthorizationRequired,
        session: session,
      );

  const GoogleAccountAuthResult.failure([String? technicalMessage])
    : this(
        status: GoogleAccountAuthStatus.failure,
        technicalMessage: technicalMessage,
      );

  final GoogleAccountAuthStatus status;
  final GoogleAccountAuthSession? session;
  final String? technicalMessage;
}

final class DriveAccessTokenResult {
  const DriveAccessTokenResult({
    required this.status,
    this.accessToken,
    this.technicalMessage,
  });

  const DriveAccessTokenResult.success(String accessToken)
    : this(status: DriveAccessTokenStatus.success, accessToken: accessToken);

  const DriveAccessTokenResult.signedOut()
    : this(status: DriveAccessTokenStatus.signedOut);

  const DriveAccessTokenResult.unconfigured()
    : this(status: DriveAccessTokenStatus.unconfigured);

  const DriveAccessTokenResult.reauthorizationRequired()
    : this(status: DriveAccessTokenStatus.reauthorizationRequired);

  const DriveAccessTokenResult.failure([String? technicalMessage])
    : this(
        status: DriveAccessTokenStatus.failure,
        technicalMessage: technicalMessage,
      );

  final DriveAccessTokenStatus status;
  final String? accessToken;
  final String? technicalMessage;
}

abstract interface class GoogleAccountAuthService {
  Stream<GoogleAccountAuthResult> get authenticationEvents;
  bool get supportsInteractiveSignIn;
  bool get requiresPlatformSignInButton;

  Future<void> initialize(GoogleOAuthConfig config);
  Future<GoogleAccountAuthResult> restoreLightweightSession(
    GoogleOAuthConfig config,
  );
  Future<GoogleAccountAuthResult> signInAndAuthorizeDriveAppData(
    GoogleOAuthConfig config,
  );
  Future<GoogleAccountAuthResult> authorizeDriveAppData(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  );
  Future<DriveAccessTokenResult> getDriveAppDataAccessToken(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  );
  Future<void> signOutLocal();
}
