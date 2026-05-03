import 'dart:convert';

import '../../domain/entities/drive_sync_models.dart';

abstract final class DriveSyncJson {
  const DriveSyncJson._();

  static String encodeCanonicalJson(Object? value) {
    return jsonEncode(_canonicalize(value));
  }

  static Map<String, Object?> encodeManifest(DriveSyncManifest manifest) {
    return <String, Object?>{
      'manifestVersion': manifest.manifestVersion,
      'snapshotFormatVersion': manifest.snapshotFormatVersion,
      'appId': manifest.appId,
      'appDatabaseSchemaVersion': manifest.appDatabaseSchemaVersion,
      'createdAt': manifest.createdAt,
      'deviceId': manifest.deviceId,
      'deviceLabel': manifest.deviceLabel,
      'databaseSha256': manifest.databaseSha256,
      'settingsSha256': manifest.settingsSha256,
      'snapshotSizeBytes': manifest.snapshotSizeBytes,
      if (manifest.snapshotFileId != null)
        'snapshotFileId': manifest.snapshotFileId,
      if (manifest.snapshotFileVersion != null)
        'snapshotFileVersion': manifest.snapshotFileVersion,
    };
  }

  static DriveSyncManifest? decodeManifest(Object? value) {
    if (value is! Map<String, dynamic>) {
      return null;
    }

    final manifestVersion = value['manifestVersion'];
    final snapshotFormatVersion = value['snapshotFormatVersion'];
    final appId = value['appId'];
    final appDatabaseSchemaVersion = value['appDatabaseSchemaVersion'];
    final createdAt = value['createdAt'];
    final deviceId = value['deviceId'];
    final deviceLabel = value['deviceLabel'];
    final databaseSha256 = value['databaseSha256'];
    final settingsSha256 = value['settingsSha256'];
    final snapshotSizeBytes = value['snapshotSizeBytes'];

    if (manifestVersion is! int ||
        snapshotFormatVersion is! int ||
        appId is! String ||
        appDatabaseSchemaVersion is! int ||
        createdAt is! int ||
        deviceId is! String ||
        deviceId.isEmpty ||
        deviceLabel is! String ||
        databaseSha256 is! String ||
        settingsSha256 is! String ||
        snapshotSizeBytes is! int) {
      return null;
    }

    return DriveSyncManifest(
      manifestVersion: manifestVersion,
      snapshotFormatVersion: snapshotFormatVersion,
      appId: appId,
      appDatabaseSchemaVersion: appDatabaseSchemaVersion,
      createdAt: createdAt,
      deviceId: deviceId,
      deviceLabel: deviceLabel,
      databaseSha256: databaseSha256,
      settingsSha256: settingsSha256,
      snapshotSizeBytes: snapshotSizeBytes,
      snapshotFileId: value['snapshotFileId'] as String?,
      snapshotFileVersion: value['snapshotFileVersion'] as String?,
    );
  }

  static Map<String, Object?>? decodeJsonObject(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return Map<String, Object?>.from(decoded);
      }
      return null;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  static Object? _canonicalize(Object? value) {
    if (value is Map) {
      final sortedKeys = value.keys.whereType<String>().toList(growable: false)
        ..sort();
      return <String, Object?>{
        for (final key in sortedKeys) key: _canonicalize(value[key]),
      };
    }
    if (value is Iterable) {
      return value.map(_canonicalize).toList(growable: false);
    }
    return value;
  }
}
