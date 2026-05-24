part of 'google_drive_sync_repository.dart';

extension _GoogleDriveSyncRepositoryHelpers on GoogleDriveSyncRepository {
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
      const status = DriveSyncStatus.failure('Drive snapshot is invalid.');
      return const DriveSyncRunResult.failed(status, 'Drive snapshot is invalid.');
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
  }) => _metadataStore.save(
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

  DriveSyncStatus _syncedStatus(DriveSyncRemoteSnapshot remote) => DriveSyncStatus(
      kind: DriveSyncStatusKind.synced,
      lastSyncedAt: _clock.nowEpochMillis(),
      remote: remote,
    );
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
