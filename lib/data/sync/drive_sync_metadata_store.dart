import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/id_generator.dart';
import '../../domain/entities/drive_sync_models.dart';

final class DriveSyncMetadataStore {
  const DriveSyncMetadataStore(this._preferences);

  final SharedPreferences _preferences;

  DriveSyncMetadata? loadForAccount(String subjectId) {
    final raw = _preferences.getString(
      AppConstants.sharedPrefsDriveSyncMetadataKey,
    );
    if (raw == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }
      final metadata = _decode(decoded);
      if (metadata == null || !metadata.matchesAccount(subjectId)) {
        return null;
      }
      return metadata;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<void> save(DriveSyncMetadata metadata) {
    return _preferences.setString(
      AppConstants.sharedPrefsDriveSyncMetadataKey,
      jsonEncode(_encode(metadata)),
    );
  }

  Future<void> clear() {
    return _preferences.remove(AppConstants.sharedPrefsDriveSyncMetadataKey);
  }

  Future<String> loadOrCreateDeviceId(IdGenerator idGenerator) async {
    final existing = _preferences.getString(
      AppConstants.sharedPrefsDriveSyncDeviceIdKey,
    );
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final next = idGenerator.nextId();
    await _preferences.setString(
      AppConstants.sharedPrefsDriveSyncDeviceIdKey,
      next,
    );
    return next;
  }

  DriveSyncMetadata? _decode(Map<String, dynamic> data) {
    final accountSubjectId = data['accountSubjectId'];
    final manifestFileId = data['manifestFileId'];
    final snapshotFileId = data['snapshotFileId'];
    final remoteFingerprint = data['remoteFingerprint'];
    final localFingerprint = data['localFingerprint'];
    final remoteManifestVersion = data['remoteManifestVersion'];
    final remoteSnapshotVersion = data['remoteSnapshotVersion'];
    final lastSyncedAt = data['lastSyncedAt'];

    if (accountSubjectId is! String ||
        accountSubjectId.isEmpty ||
        manifestFileId is! String ||
        manifestFileId.isEmpty ||
        snapshotFileId is! String ||
        snapshotFileId.isEmpty ||
        remoteFingerprint is! String ||
        remoteFingerprint.isEmpty ||
        localFingerprint is! String ||
        localFingerprint.isEmpty ||
        remoteManifestVersion is! String ||
        remoteSnapshotVersion is! String ||
        lastSyncedAt is! int) {
      return null;
    }

    return DriveSyncMetadata(
      accountSubjectId: accountSubjectId,
      manifestFileId: manifestFileId,
      snapshotFileId: snapshotFileId,
      remoteFingerprint: remoteFingerprint,
      localFingerprint: localFingerprint,
      remoteManifestVersion: remoteManifestVersion,
      remoteSnapshotVersion: remoteSnapshotVersion,
      lastSyncedAt: lastSyncedAt,
    );
  }

  Map<String, Object?> _encode(DriveSyncMetadata metadata) {
    return <String, Object?>{
      'accountSubjectId': metadata.accountSubjectId,
      'manifestFileId': metadata.manifestFileId,
      'snapshotFileId': metadata.snapshotFileId,
      'remoteFingerprint': metadata.remoteFingerprint,
      'localFingerprint': metadata.localFingerprint,
      'remoteManifestVersion': metadata.remoteManifestVersion,
      'remoteSnapshotVersion': metadata.remoteSnapshotVersion,
      'lastSyncedAt': metadata.lastSyncedAt,
    };
  }
}
