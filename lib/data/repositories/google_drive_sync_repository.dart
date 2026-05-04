import 'dart:convert';
import 'dart:typed_data';

import '../../core/config/google_oauth_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/clock.dart';
import '../../core/services/id_generator.dart';
import '../../domain/entities/cloud_account_link.dart';
import '../../domain/entities/drive_sync_models.dart';
import '../../domain/repositories/cloud_account_repository.dart';
import '../../domain/repositories/drive_sync_repository.dart';
import '../../domain/services/google_account_auth_service.dart';
import '../sync/app_settings_snapshot_store.dart';
import '../sync/drive_sync_json.dart';
import '../sync/drive_sync_metadata_store.dart';
import '../sync/drive_sync_snapshot_codec.dart';
import '../sync/google_drive_app_data_client.dart';
import '../sync/local_database_snapshot_gateway_contract.dart';

final class GoogleDriveSyncRepository implements DriveSyncRepository {
  const GoogleDriveSyncRepository({
    required CloudAccountRepository accountRepository,
    required GoogleAccountAuthService authService,
    required GoogleOAuthConfig googleOAuthConfig,
    required DriveAppDataClient driveClient,
    required LocalDatabaseSnapshotGateway databaseSnapshotGateway,
    required AppSettingsSnapshotStore settingsSnapshotStore,
    required DriveSyncMetadataStore metadataStore,
    required DriveSyncSnapshotCodec snapshotCodec,
    required Clock clock,
    required IdGenerator idGenerator,
  }) : _accountRepository = accountRepository,
       _authService = authService,
       _googleOAuthConfig = googleOAuthConfig,
       _driveClient = driveClient,
       _databaseSnapshotGateway = databaseSnapshotGateway,
       _settingsSnapshotStore = settingsSnapshotStore,
       _metadataStore = metadataStore,
       _snapshotCodec = snapshotCodec,
       _clock = clock,
       _idGenerator = idGenerator;

  final CloudAccountRepository _accountRepository;
  final GoogleAccountAuthService _authService;
  final GoogleOAuthConfig _googleOAuthConfig;
  final DriveAppDataClient _driveClient;
  final LocalDatabaseSnapshotGateway _databaseSnapshotGateway;
  final AppSettingsSnapshotStore _settingsSnapshotStore;
  final DriveSyncMetadataStore _metadataStore;
  final DriveSyncSnapshotCodec _snapshotCodec;
  final Clock _clock;
  final IdGenerator _idGenerator;

  @override
  Future<DriveSyncStatus> loadStatus() async {
    final context = await _loadReadyContext();
    if (!context.isReady) {
      return context.status;
    }

    try {
      final remote = await _loadRemoteSnapshot(context.accessToken);
      if (remote == null) {
        return const DriveSyncStatus.noRemoteSnapshot();
      }
      final metadata = _metadataStore.loadForAccount(context.link!.subjectId);
      if (metadata != null &&
          metadata.remoteFingerprint == remote.fingerprint &&
          metadata.remoteSnapshotVersion == remote.snapshotFileVersion) {
        return DriveSyncStatus(
          kind: DriveSyncStatusKind.synced,
          lastSyncedAt: metadata.lastSyncedAt,
          remote: remote,
        );
      }
      return DriveSyncStatus(
        kind: DriveSyncStatusKind.ready,
        lastSyncedAt: metadata?.lastSyncedAt,
        remote: remote,
      );
    } on Object catch (error) {
      return _mapDriveException(error);
    }
  }

  @override
  Future<DriveSyncRunResult> syncNow() async {
    final context = await _loadReadyContext();
    if (!context.isReady) {
      return DriveSyncRunResult.noChanges(context.status);
    }

    try {
      final local = await _createLocalSnapshot();
      final remote = await _loadRemoteSnapshot(context.accessToken);
      final metadata = _metadataStore.loadForAccount(context.link!.subjectId);

      if (remote == null) {
        final uploaded = await _uploadLocalSnapshot(
          accessToken: context.accessToken,
          local: local,
          remote: null,
          accountSubjectId: context.link!.subjectId,
        );
        return DriveSyncRunResult.uploadedLocal(uploaded);
      }

      if (local.fingerprint == remote.fingerprint) {
        await _saveMetadata(
          accountSubjectId: context.link!.subjectId,
          localFingerprint: local.fingerprint,
          remote: remote,
        );
        return DriveSyncRunResult.noChanges(
          DriveSyncStatus(
            kind: DriveSyncStatusKind.synced,
            lastSyncedAt: _clock.nowEpochMillis(),
            remote: remote,
          ),
        );
      }

      if (metadata != null) {
        final localChanged = metadata.localFingerprint != local.fingerprint;
        final remoteChanged =
            metadata.remoteFingerprint != remote.fingerprint ||
            metadata.remoteSnapshotVersion != remote.snapshotFileVersion;

        if (localChanged && !remoteChanged) {
          final uploaded = await _uploadLocalSnapshot(
            accessToken: context.accessToken,
            local: local,
            remote: remote,
            accountSubjectId: context.link!.subjectId,
          );
          return DriveSyncRunResult.uploadedLocal(uploaded);
        }

        if (!localChanged && remoteChanged) {
          final conflict = DriveSyncConflict(
            localFingerprint: local.fingerprint,
            remote: remote,
            reason: 'Remote snapshot changed since the last sync.',
          );
          return DriveSyncRunResult.conflict(
            DriveSyncStatus(
              kind: DriveSyncStatusKind.conflict,
              lastSyncedAt: metadata.lastSyncedAt,
              remote: remote,
              conflict: conflict,
            ),
            conflict,
          );
        }
      }

      final conflict = DriveSyncConflict(
        localFingerprint: local.fingerprint,
        remote: remote,
        reason: 'Local and Drive snapshots diverged.',
      );
      return DriveSyncRunResult.conflict(
        DriveSyncStatus(
          kind: DriveSyncStatusKind.conflict,
          lastSyncedAt: metadata?.lastSyncedAt,
          remote: remote,
          conflict: conflict,
        ),
        conflict,
      );
    } on Object catch (error) {
      final status = _mapDriveException(error);
      return DriveSyncRunResult.failed(status, error.toString());
    }
  }

  @override
  Future<DriveSyncRunResult> resolveConflict(
    DriveSyncConflict conflict,
    DriveSyncConflictChoice choice,
  ) async {
    final context = await _loadReadyContext();
    if (!context.isReady) {
      return DriveSyncRunResult.noChanges(context.status);
    }

    if (choice == DriveSyncConflictChoice.cancel) {
      return DriveSyncRunResult.canceled(
        DriveSyncStatus(
          kind: DriveSyncStatusKind.ready,
          remote: conflict.remote,
        ),
      );
    }

    try {
      if (choice == DriveSyncConflictChoice.keepLocal) {
        final local = await _createLocalSnapshot();
        final uploaded = await _uploadLocalSnapshot(
          accessToken: context.accessToken,
          local: local,
          remote: conflict.remote,
          accountSubjectId: context.link!.subjectId,
        );
        return DriveSyncRunResult.uploadedLocal(uploaded);
      }

      final restored = await _restoreRemoteSnapshot(
        accessToken: context.accessToken,
        remote: conflict.remote,
        accountSubjectId: context.link!.subjectId,
      );
      return restored;
    } on Object catch (error) {
      final status = _mapDriveException(error);
      return DriveSyncRunResult.failed(status, error.toString());
    }
  }

  DriveSyncStatus _mapDriveException(Object error) {
    if (error is GoogleDriveAppDataException) {
      if (_isAuthorizationFailure(error)) {
        return const DriveSyncStatus.needsDriveAuthorization();
      }
      return DriveSyncStatus.failure(error.message);
    }

    return DriveSyncStatus.failure(error.toString());
  }

  bool _isAuthorizationFailure(GoogleDriveAppDataException error) {
    if (error.statusCode == 401) {
      return true;
    }
    if (error.statusCode != 403) {
      return false;
    }
    return switch (error.reason) {
      'authError' || 'insufficientPermissions' || 'invalidCredentials' => true,
      _ => false,
    };
  }

  Future<_DriveSyncContext> _loadReadyContext() async {
    if (!_googleOAuthConfig.isConfiguredForCurrentPlatform) {
      return const _DriveSyncContext(
        status: DriveSyncStatus.unconfigured(),
        accessToken: '',
      );
    }

    final link = await _accountRepository.load();
    if (link == null) {
      return const _DriveSyncContext(
        status: DriveSyncStatus.signedOut(),
        accessToken: '',
      );
    }
    if (!link.driveAppDataAuthorized) {
      return const _DriveSyncContext(
        status: DriveSyncStatus.needsDriveAuthorization(),
        accessToken: '',
      );
    }

    final tokenResult = await _authService.getDriveAppDataAccessToken(
      _googleOAuthConfig,
      link,
    );
    switch (tokenResult.status) {
      case DriveAccessTokenStatus.success:
        return _DriveSyncContext(
          status: const DriveSyncStatus.ready(),
          accessToken: tokenResult.accessToken!,
          link: link,
        );
      case DriveAccessTokenStatus.signedOut:
        return const _DriveSyncContext(
          status: DriveSyncStatus.signedOut(),
          accessToken: '',
        );
      case DriveAccessTokenStatus.unconfigured:
        return const _DriveSyncContext(
          status: DriveSyncStatus.unconfigured(),
          accessToken: '',
        );
      case DriveAccessTokenStatus.reauthorizationRequired:
        return const _DriveSyncContext(
          status: DriveSyncStatus.needsDriveAuthorization(),
          accessToken: '',
        );
      case DriveAccessTokenStatus.failure:
        return _DriveSyncContext(
          status: DriveSyncStatus.failure(
            tokenResult.technicalMessage ?? 'Could not access Google Drive.',
          ),
          accessToken: '',
        );
    }
  }

  Future<DriveSyncSnapshot> _createLocalSnapshot() async {
    final databaseBytes = await _databaseSnapshotGateway.exportDatabase();
    final settings = _settingsSnapshotStore.load();
    final deviceId = await _metadataStore.loadOrCreateDeviceId(_idGenerator);
    return _snapshotCodec.encode(
      databaseBytes: databaseBytes,
      settings: settings,
      appDatabaseSchemaVersion: _databaseSnapshotGateway.currentSchemaVersion,
      createdAt: _clock.nowEpochMillis(),
      deviceId: deviceId,
      deviceLabel: 'MemoX device',
    );
  }

  Future<DriveSyncRemoteSnapshot?> _loadRemoteSnapshot(
    String accessToken,
  ) async {
    final manifestFile = await _driveClient.findFileByName(
      accessToken: accessToken,
      name: AppConstants.driveSyncManifestFileName,
    );
    if (manifestFile == null) {
      return null;
    }

    final manifestBytes = await _driveClient.downloadFile(
      accessToken: accessToken,
      fileId: manifestFile.id,
    );
    final manifestJson = DriveSyncJson.decodeJsonObject(
      utf8.decode(manifestBytes),
    );
    final manifest = DriveSyncJson.decodeManifest(manifestJson);
    if (manifest == null ||
        manifest.manifestVersion != DriveSyncManifest.currentManifestVersion ||
        manifest.snapshotFormatVersion !=
            DriveSyncManifest.currentSnapshotFormatVersion ||
        manifest.appId != DriveSyncManifest.currentAppId) {
      throw const GoogleDriveAppDataException(
        'Drive sync manifest is invalid or unsupported.',
      );
    }

    final snapshotFile = await _driveClient.findFileByName(
      accessToken: accessToken,
      name: AppConstants.driveSyncSnapshotFileName,
    );
    if (snapshotFile == null) {
      throw const GoogleDriveAppDataException(
        'Drive sync snapshot file is missing.',
      );
    }

    final remoteManifest = manifest.copyWith(
      snapshotFileId: snapshotFile.id,
      snapshotFileVersion: snapshotFile.version,
    );
    return DriveSyncRemoteSnapshot(
      manifest: remoteManifest,
      manifestFileId: manifestFile.id,
      manifestFileVersion: manifestFile.version,
      snapshotFileId: snapshotFile.id,
      snapshotFileVersion: snapshotFile.version,
      modifiedAt: manifestFile.modifiedAt ?? snapshotFile.modifiedAt,
    );
  }

  Future<DriveSyncStatus> _uploadLocalSnapshot({
    required String accessToken,
    required DriveSyncSnapshot local,
    required DriveSyncRemoteSnapshot? remote,
    required String accountSubjectId,
  }) async {
    final snapshotFile = remote == null
        ? await _driveClient.createFile(
            accessToken: accessToken,
            name: AppConstants.driveSyncSnapshotFileName,
            mimeType: AppConstants.driveSyncMimeType,
            bytes: local.archiveBytes,
            appProperties: const <String, String>{'kind': 'snapshot'},
          )
        : await _driveClient.updateFile(
            accessToken: accessToken,
            fileId: remote.snapshotFileId,
            mimeType: AppConstants.driveSyncMimeType,
            bytes: local.archiveBytes,
            appProperties: const <String, String>{'kind': 'snapshot'},
          );

    final manifest = local.manifest.copyWith(
      snapshotFileId: snapshotFile.id,
      snapshotFileVersion: snapshotFile.version,
      createdAt: _clock.nowEpochMillis(),
    );
    final manifestBytes = Uint8List.fromList(
      utf8.encode(
        DriveSyncJson.encodeCanonicalJson(
          DriveSyncJson.encodeManifest(manifest),
        ),
      ),
    );

    final manifestFile = remote == null
        ? await _driveClient.createFile(
            accessToken: accessToken,
            name: AppConstants.driveSyncManifestFileName,
            mimeType: AppConstants.driveSyncManifestMimeType,
            bytes: manifestBytes,
            appProperties: const <String, String>{'kind': 'manifest'},
          )
        : await _driveClient.updateFile(
            accessToken: accessToken,
            fileId: remote.manifestFileId,
            mimeType: AppConstants.driveSyncManifestMimeType,
            bytes: manifestBytes,
            appProperties: const <String, String>{'kind': 'manifest'},
          );

    final uploadedRemote = DriveSyncRemoteSnapshot(
      manifest: manifest,
      manifestFileId: manifestFile.id,
      manifestFileVersion: manifestFile.version,
      snapshotFileId: snapshotFile.id,
      snapshotFileVersion: snapshotFile.version,
      modifiedAt: manifestFile.modifiedAt ?? snapshotFile.modifiedAt,
    );
    await _saveMetadata(
      accountSubjectId: accountSubjectId,
      localFingerprint: local.fingerprint,
      remote: uploadedRemote,
    );
    return DriveSyncStatus(
      kind: DriveSyncStatusKind.synced,
      lastSyncedAt: _clock.nowEpochMillis(),
      remote: uploadedRemote,
    );
  }

  Future<DriveSyncRunResult> _restoreRemoteSnapshot({
    required String accessToken,
    required DriveSyncRemoteSnapshot remote,
    required String accountSubjectId,
  }) async {
    if (remote.manifest.appDatabaseSchemaVersion >
        _databaseSnapshotGateway.currentSchemaVersion) {
      final status = DriveSyncStatus(
        kind: DriveSyncStatusKind.unsupportedSchema,
        remote: remote,
      );
      return DriveSyncRunResult.failed(
        status,
        'Drive snapshot was created by a newer database schema.',
      );
    }

    final archiveBytes = await _driveClient.downloadFile(
      accessToken: accessToken,
      fileId: remote.snapshotFileId,
    );
    final snapshot = _snapshotCodec.decode(archiveBytes);
    if (snapshot == null || snapshot.fingerprint != remote.fingerprint) {
      final status = DriveSyncStatus.failure('Drive snapshot is invalid.');
      return DriveSyncRunResult.failed(status, 'Drive snapshot is invalid.');
    }

    await _settingsSnapshotStore.restore(snapshot.settings);
    final effect = await _databaseSnapshotGateway.restoreDatabase(
      snapshot.databaseBytes,
    );
    await _saveMetadata(
      accountSubjectId: accountSubjectId,
      localFingerprint: snapshot.fingerprint,
      remote: remote,
    );

    return DriveSyncRunResult.restoredRemote(
      DriveSyncStatus(
        kind: DriveSyncStatusKind.synced,
        lastSyncedAt: _clock.nowEpochMillis(),
        remote: remote,
      ),
      effect,
    );
  }

  Future<void> _saveMetadata({
    required String accountSubjectId,
    required String localFingerprint,
    required DriveSyncRemoteSnapshot remote,
  }) {
    return _metadataStore.save(
      DriveSyncMetadata(
        accountSubjectId: accountSubjectId,
        manifestFileId: remote.manifestFileId,
        snapshotFileId: remote.snapshotFileId,
        remoteFingerprint: remote.fingerprint,
        localFingerprint: localFingerprint,
        remoteManifestVersion: remote.manifestFileVersion,
        remoteSnapshotVersion: remote.snapshotFileVersion,
        lastSyncedAt: _clock.nowEpochMillis(),
      ),
    );
  }
}

final class _DriveSyncContext {
  const _DriveSyncContext({
    required this.status,
    required this.accessToken,
    this.link,
  });

  final DriveSyncStatus status;
  final String accessToken;
  final CloudAccountLink? link;

  bool get isReady =>
      status.kind == DriveSyncStatusKind.ready &&
      accessToken.isNotEmpty &&
      link != null;
}
