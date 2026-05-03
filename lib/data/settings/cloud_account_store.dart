import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/cloud_account_link.dart';
import '../../domain/repositories/cloud_account_repository.dart';

final class CloudAccountStore implements CloudAccountRepository {
  const CloudAccountStore(this._preferences);

  final SharedPreferences _preferences;

  @override
  Future<CloudAccountLink?> load() async {
    final rawValue = _preferences.getString(
      AppConstants.sharedPrefsCloudAccountLinkKey,
    );
    if (rawValue == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      return _decodeLink(decoded);
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    }
  }

  @override
  Future<void> save(CloudAccountLink link) {
    return _preferences.setString(
      AppConstants.sharedPrefsCloudAccountLinkKey,
      jsonEncode(_encodeLink(link)),
    );
  }

  @override
  Future<void> clear() {
    return _preferences.remove(AppConstants.sharedPrefsCloudAccountLinkKey);
  }

  CloudAccountLink? _decodeLink(Map<String, dynamic> data) {
    final schemaVersion = data['schemaVersion'];
    final provider = data['provider'];
    final subjectId = data['subjectId'];
    final email = data['email'];
    final linkedAt = data['linkedAt'];
    final lastSignedInAt = data['lastSignedInAt'];
    final driveAuthorizationState = data['driveAuthorizationState'];
    final scopes = data['grantedScopes'];

    if (schemaVersion != CloudAccountLink.currentSchemaVersion ||
        provider != CloudProvider.google.name ||
        subjectId is! String ||
        subjectId.isEmpty ||
        email is! String ||
        email.isEmpty ||
        linkedAt is! int ||
        lastSignedInAt is! int ||
        driveAuthorizationState is! String ||
        scopes is! List) {
      return null;
    }

    return CloudAccountLink(
      schemaVersion: schemaVersion,
      provider: CloudProvider.google,
      subjectId: subjectId,
      email: email,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      grantedScopes: scopes.whereType<String>().toSet(),
      driveAuthorizationState: DriveAuthorizationState.values.byName(
        driveAuthorizationState,
      ),
      linkedAt: linkedAt,
      lastSignedInAt: lastSignedInAt,
    );
  }

  Map<String, Object?> _encodeLink(CloudAccountLink link) {
    return <String, Object?>{
      'schemaVersion': link.schemaVersion,
      'provider': link.provider.name,
      'subjectId': link.subjectId,
      'email': link.email,
      'displayName': link.displayName,
      'photoUrl': link.photoUrl,
      'grantedScopes': link.grantedScopes.toList(growable: false)..sort(),
      'driveAuthorizationState': link.driveAuthorizationState.name,
      'linkedAt': link.linkedAt,
      'lastSignedInAt': link.lastSignedInAt,
    };
  }
}
