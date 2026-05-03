import 'dart:typed_data';

enum DriveSyncStatusKind {
  signedOut,
  unconfigured,
  needsDriveAuthorization,
  ready,
  noRemoteSnapshot,
  synced,
  localChanges,
  remoteChanges,
  conflict,
  unsupportedSchema,
  failure,
}

enum DriveSyncConflictChoice { keepLocal, useDriveCopy, cancel }

enum DriveSyncActionKind {
  none,
  uploadedLocal,
  restoredRemote,
  noChanges,
  needsConflictResolution,
  canceled,
  failed,
}

enum DriveSyncRestoreEffect { none, refreshDatabaseProvider, reloadApp }

final class DriveSyncManifest {
  const DriveSyncManifest({
    required this.manifestVersion,
    required this.snapshotFormatVersion,
    required this.appId,
    required this.appDatabaseSchemaVersion,
    required this.createdAt,
    required this.deviceId,
    required this.deviceLabel,
    required this.databaseSha256,
    required this.settingsSha256,
    required this.snapshotSizeBytes,
    this.snapshotFileId,
    this.snapshotFileVersion,
  });

  static const int currentManifestVersion = 1;
  static const int currentSnapshotFormatVersion = 1;
  static const String currentAppId = 'memox';

  final int manifestVersion;
  final int snapshotFormatVersion;
  final String appId;
  final int appDatabaseSchemaVersion;
  final int createdAt;
  final String deviceId;
  final String deviceLabel;
  final String databaseSha256;
  final String settingsSha256;
  final int snapshotSizeBytes;
  final String? snapshotFileId;
  final String? snapshotFileVersion;

  String get fingerprint =>
      '$appId:$snapshotFormatVersion:$appDatabaseSchemaVersion:'
      '$databaseSha256:$settingsSha256';

  DriveSyncManifest copyWith({
    int? createdAt,
    int? snapshotSizeBytes,
    String? snapshotFileId,
    String? snapshotFileVersion,
  }) {
    return DriveSyncManifest(
      manifestVersion: manifestVersion,
      snapshotFormatVersion: snapshotFormatVersion,
      appId: appId,
      appDatabaseSchemaVersion: appDatabaseSchemaVersion,
      createdAt: createdAt ?? this.createdAt,
      deviceId: deviceId,
      deviceLabel: deviceLabel,
      databaseSha256: databaseSha256,
      settingsSha256: settingsSha256,
      snapshotSizeBytes: snapshotSizeBytes ?? this.snapshotSizeBytes,
      snapshotFileId: snapshotFileId ?? this.snapshotFileId,
      snapshotFileVersion: snapshotFileVersion ?? this.snapshotFileVersion,
    );
  }
}

final class DriveSyncSnapshot {
  const DriveSyncSnapshot({
    required this.manifest,
    required this.archiveBytes,
    required this.databaseBytes,
    required this.settings,
  });

  final DriveSyncManifest manifest;
  final Uint8List archiveBytes;
  final Uint8List databaseBytes;
  final Map<String, Object?> settings;

  String get fingerprint => manifest.fingerprint;
}

final class DriveSyncRemoteSnapshot {
  const DriveSyncRemoteSnapshot({
    required this.manifest,
    required this.manifestFileId,
    required this.manifestFileVersion,
    required this.snapshotFileId,
    required this.snapshotFileVersion,
    required this.modifiedAt,
  });

  final DriveSyncManifest manifest;
  final String manifestFileId;
  final String manifestFileVersion;
  final String snapshotFileId;
  final String snapshotFileVersion;
  final int? modifiedAt;

  String get fingerprint => manifest.fingerprint;
}

final class DriveSyncMetadata {
  const DriveSyncMetadata({
    required this.accountSubjectId,
    required this.manifestFileId,
    required this.snapshotFileId,
    required this.remoteFingerprint,
    required this.localFingerprint,
    required this.remoteManifestVersion,
    required this.remoteSnapshotVersion,
    required this.lastSyncedAt,
  });

  final String accountSubjectId;
  final String manifestFileId;
  final String snapshotFileId;
  final String remoteFingerprint;
  final String localFingerprint;
  final String remoteManifestVersion;
  final String remoteSnapshotVersion;
  final int lastSyncedAt;

  bool matchesAccount(String subjectId) => accountSubjectId == subjectId;
}

final class DriveSyncConflict {
  const DriveSyncConflict({
    required this.localFingerprint,
    required this.remote,
    required this.reason,
  });

  final String localFingerprint;
  final DriveSyncRemoteSnapshot remote;
  final String reason;
}

final class DriveSyncStatus {
  const DriveSyncStatus({
    required this.kind,
    this.lastSyncedAt,
    this.remote,
    this.conflict,
    this.message,
  });

  const DriveSyncStatus.signedOut() : this(kind: DriveSyncStatusKind.signedOut);

  const DriveSyncStatus.unconfigured()
    : this(kind: DriveSyncStatusKind.unconfigured);

  const DriveSyncStatus.needsDriveAuthorization()
    : this(kind: DriveSyncStatusKind.needsDriveAuthorization);

  const DriveSyncStatus.noRemoteSnapshot()
    : this(kind: DriveSyncStatusKind.noRemoteSnapshot);

  const DriveSyncStatus.ready() : this(kind: DriveSyncStatusKind.ready);

  const DriveSyncStatus.failure(String message)
    : this(kind: DriveSyncStatusKind.failure, message: message);

  final DriveSyncStatusKind kind;
  final int? lastSyncedAt;
  final DriveSyncRemoteSnapshot? remote;
  final DriveSyncConflict? conflict;
  final String? message;
}

final class DriveSyncRunResult {
  const DriveSyncRunResult({
    required this.kind,
    required this.status,
    this.conflict,
    this.restoreEffect = DriveSyncRestoreEffect.none,
    this.message,
  });

  const DriveSyncRunResult.noChanges(DriveSyncStatus status)
    : this(kind: DriveSyncActionKind.noChanges, status: status);

  const DriveSyncRunResult.uploadedLocal(DriveSyncStatus status)
    : this(kind: DriveSyncActionKind.uploadedLocal, status: status);

  const DriveSyncRunResult.restoredRemote(
    DriveSyncStatus status,
    DriveSyncRestoreEffect effect,
  ) : this(
        kind: DriveSyncActionKind.restoredRemote,
        status: status,
        restoreEffect: effect,
      );

  const DriveSyncRunResult.conflict(
    DriveSyncStatus status,
    DriveSyncConflict conflict,
  ) : this(
        kind: DriveSyncActionKind.needsConflictResolution,
        status: status,
        conflict: conflict,
      );

  const DriveSyncRunResult.canceled(DriveSyncStatus status)
    : this(kind: DriveSyncActionKind.canceled, status: status);

  const DriveSyncRunResult.failed(DriveSyncStatus status, String message)
    : this(kind: DriveSyncActionKind.failed, status: status, message: message);

  final DriveSyncActionKind kind;
  final DriveSyncStatus status;
  final DriveSyncConflict? conflict;
  final DriveSyncRestoreEffect restoreEffect;
  final String? message;
}
