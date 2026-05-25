import 'dart:convert';
import 'dart:typed_data';

import '../../core/config/google_oauth_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/logging/app_logger.dart';
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

part 'google_drive_sync_repository_helpers.dart';

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
    AppLogger? logger,
  }) : _accountRepository = accountRepository,
       _authService = authService,
       _googleOAuthConfig = googleOAuthConfig,
       _driveClient = driveClient,
       _databaseSnapshotGateway = databaseSnapshotGateway,
       _settingsSnapshotStore = settingsSnapshotStore,
       _metadataStore = metadataStore,
       _snapshotCodec = snapshotCodec,
       _clock = clock,
       _idGenerator = idGenerator,
       _logger = logger ?? const NoopAppLogger();

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
  final AppLogger _logger;

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
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Failed to load Google Drive sync status.',
        error,
        stackTrace,
      );
      return _mapDriveException(error);
    }
  }

  @override
  Future<DriveSyncRunResult> uploadLocalSnapshot() async {
    final context = await _loadReadyContext();
    if (!context.isReady) {
      return DriveSyncRunResult.noChanges(context.status);
    }

    try {
      final local = await _createLocalSnapshot();
      final remote = await _loadRemoteSnapshot(context.accessToken);
      if (remote != null && local.fingerprint == remote.fingerprint) {
        await _saveMetadata(
          accountSubjectId: context.link!.subjectId,
          localFingerprint: local.fingerprint,
          remote: remote,
        );
        return DriveSyncRunResult.noChanges(_syncedStatus(remote));
      }

      final uploaded = await _uploadLocalSnapshot(
        accessToken: context.accessToken,
        local: local,
        remote: remote,
        accountSubjectId: context.link!.subjectId,
      );
      return DriveSyncRunResult.uploadedLocal(uploaded);
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Failed to upload local snapshot to Google Drive.',
        error,
        stackTrace,
      );
      final status = _mapDriveException(error);
      return DriveSyncRunResult.failed(status, error.toString());
    }
  }

  @override
  Future<DriveSyncRunResult> restoreDriveSnapshot() async {
    final context = await _loadReadyContext();
    if (!context.isReady) {
      return DriveSyncRunResult.noChanges(context.status);
    }

    try {
      final remote = await _loadRemoteSnapshot(context.accessToken);
      if (remote == null) {
        return const DriveSyncRunResult.noChanges(
          DriveSyncStatus.noRemoteSnapshot(),
        );
      }

      final local = await _createLocalSnapshot();
      if (local.fingerprint == remote.fingerprint) {
        await _saveMetadata(
          accountSubjectId: context.link!.subjectId,
          localFingerprint: local.fingerprint,
          remote: remote,
        );
        return DriveSyncRunResult.noChanges(_syncedStatus(remote));
      }

      return _restoreRemoteSnapshot(
        accessToken: context.accessToken,
        remote: remote,
        accountSubjectId: context.link!.subjectId,
      );
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Failed to restore Google Drive snapshot.',
        error,
        stackTrace,
      );
      final status = _mapDriveException(error);
      return DriveSyncRunResult.failed(status, error.toString());
    }
  }
}
