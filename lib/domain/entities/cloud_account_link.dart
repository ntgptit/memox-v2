import 'package:flutter/foundation.dart';

const String googleDriveAppDataScope =
    'https://www.googleapis.com/auth/drive.appdata';

enum CloudProvider { google }

enum DriveAuthorizationState {
  notRequested,
  authorized,
  authorizationRequired,
  denied,
}

enum AccountLinkStatus {
  signedOut,
  signedIn,
  needsDriveAuthorization,
  unconfigured,
  unsupported,
  error,
}

@immutable
class CloudAccountLink {
  const CloudAccountLink({
    required this.provider,
    required this.subjectId,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.grantedScopes,
    required this.driveAuthorizationState,
    required this.linkedAt,
    required this.lastSignedInAt,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

  final int schemaVersion;
  final CloudProvider provider;
  final String subjectId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final Set<String> grantedScopes;
  final DriveAuthorizationState driveAuthorizationState;
  final int linkedAt;
  final int lastSignedInAt;

  bool get driveAppDataAuthorized =>
      driveAuthorizationState == DriveAuthorizationState.authorized &&
      grantedScopes.contains(googleDriveAppDataScope);

  CloudAccountLink copyWith({
    Set<String>? grantedScopes,
    DriveAuthorizationState? driveAuthorizationState,
    int? lastSignedInAt,
  }) {
    return CloudAccountLink(
      provider: provider,
      subjectId: subjectId,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      grantedScopes: grantedScopes ?? this.grantedScopes,
      driveAuthorizationState:
          driveAuthorizationState ?? this.driveAuthorizationState,
      linkedAt: linkedAt,
      lastSignedInAt: lastSignedInAt ?? this.lastSignedInAt,
      schemaVersion: schemaVersion,
    );
  }
}
