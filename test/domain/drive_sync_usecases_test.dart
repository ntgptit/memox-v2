import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/entities/drive_sync_models.dart';
import 'package:memox/domain/repositories/drive_sync_repository.dart';
import 'package:memox/domain/usecases/drive_sync_usecases.dart';

void main() {
  test('DT1 if: LoadDriveSyncStatusUseCase delegates to repository', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
    );
    final useCase = LoadDriveSyncStatusUseCase(repository);

    final status = await useCase.execute();

    expect(status.kind, DriveSyncStatusKind.noRemoteSnapshot);
    expect(repository.loadStatusCount, 1);
  });

  test(
    'DT2 if: SyncGoogleDriveSnapshotUseCase delegates to repository',
    () async {
      final repository = _FakeDriveSyncRepository(
        syncResult: DriveSyncRunResult.uploadedLocal(
          const DriveSyncStatus(kind: DriveSyncStatusKind.synced),
        ),
      );
      final useCase = SyncGoogleDriveSnapshotUseCase(repository);

      final result = await useCase.execute();

      expect(result.kind, DriveSyncActionKind.uploadedLocal);
      expect(repository.syncNowCount, 1);
    },
  );

  test(
    'DT3 if: ResolveDriveSyncConflictUseCase forwards conflict choice',
    () async {
      final conflict = _conflict();
      final repository = _FakeDriveSyncRepository(
        resolveResult: DriveSyncRunResult.canceled(
          const DriveSyncStatus(kind: DriveSyncStatusKind.ready),
        ),
      );
      final useCase = ResolveDriveSyncConflictUseCase(repository);

      final result = await useCase.execute(
        conflict,
        DriveSyncConflictChoice.cancel,
      );

      expect(result.kind, DriveSyncActionKind.canceled);
      expect(repository.resolveConflictCount, 1);
      expect(repository.lastConflict, same(conflict));
      expect(repository.lastChoice, DriveSyncConflictChoice.cancel);
    },
  );

  test(
    'DT4 if: UploadLocalDriveSnapshotUseCase delegates to repository',
    () async {
      final repository = _FakeDriveSyncRepository(
        uploadResult: DriveSyncRunResult.uploadedLocal(
          const DriveSyncStatus(kind: DriveSyncStatusKind.synced),
        ),
      );
      final useCase = UploadLocalDriveSnapshotUseCase(repository);

      final result = await useCase.execute();

      expect(result.kind, DriveSyncActionKind.uploadedLocal);
      expect(repository.uploadLocalCount, 1);
    },
  );

  test('DT5 if: RestoreDriveSnapshotUseCase delegates to repository', () async {
    final repository = _FakeDriveSyncRepository(
      restoreResult: DriveSyncRunResult.restoredRemote(
        const DriveSyncStatus(kind: DriveSyncStatusKind.synced),
        DriveSyncRestoreEffect.refreshDatabaseProvider,
      ),
    );
    final useCase = RestoreDriveSnapshotUseCase(repository);

    final result = await useCase.execute();

    expect(result.kind, DriveSyncActionKind.restoredRemote);
    expect(repository.restoreDriveCount, 1);
  });
}

final class _FakeDriveSyncRepository implements DriveSyncRepository {
  _FakeDriveSyncRepository({
    DriveSyncStatus? loadStatusResult,
    DriveSyncRunResult? syncResult,
    DriveSyncRunResult? uploadResult,
    DriveSyncRunResult? restoreResult,
    DriveSyncRunResult? resolveResult,
  }) : loadStatusResult = loadStatusResult ?? const DriveSyncStatus.signedOut(),
       syncResult =
           syncResult ??
           DriveSyncRunResult.noChanges(const DriveSyncStatus.signedOut()),
       uploadResult =
           uploadResult ??
           DriveSyncRunResult.noChanges(const DriveSyncStatus.signedOut()),
       restoreResult =
           restoreResult ??
           DriveSyncRunResult.noChanges(const DriveSyncStatus.signedOut()),
       resolveResult =
           resolveResult ??
           DriveSyncRunResult.canceled(const DriveSyncStatus.ready());

  final DriveSyncStatus loadStatusResult;
  final DriveSyncRunResult syncResult;
  final DriveSyncRunResult uploadResult;
  final DriveSyncRunResult restoreResult;
  final DriveSyncRunResult resolveResult;
  int loadStatusCount = 0;
  int syncNowCount = 0;
  int uploadLocalCount = 0;
  int restoreDriveCount = 0;
  int resolveConflictCount = 0;
  DriveSyncConflict? lastConflict;
  DriveSyncConflictChoice? lastChoice;

  @override
  Future<DriveSyncStatus> loadStatus() async {
    loadStatusCount += 1;
    return loadStatusResult;
  }

  @override
  Future<DriveSyncRunResult> syncNow() async {
    syncNowCount += 1;
    return syncResult;
  }

  @override
  Future<DriveSyncRunResult> uploadLocalSnapshot() async {
    uploadLocalCount += 1;
    return uploadResult;
  }

  @override
  Future<DriveSyncRunResult> restoreDriveSnapshot() async {
    restoreDriveCount += 1;
    return restoreResult;
  }

  @override
  Future<DriveSyncRunResult> resolveConflict(
    DriveSyncConflict conflict,
    DriveSyncConflictChoice choice,
  ) async {
    resolveConflictCount += 1;
    lastConflict = conflict;
    lastChoice = choice;
    return resolveResult;
  }
}

DriveSyncConflict _conflict() {
  return DriveSyncConflict(
    localFingerprint: 'local',
    remote: _remoteSnapshot(),
    reason: 'test',
  );
}

DriveSyncRemoteSnapshot _remoteSnapshot() {
  return DriveSyncRemoteSnapshot(
    manifest: const DriveSyncManifest(
      manifestVersion: DriveSyncManifest.currentManifestVersion,
      snapshotFormatVersion: DriveSyncManifest.currentSnapshotFormatVersion,
      appId: DriveSyncManifest.currentAppId,
      appDatabaseSchemaVersion: 6,
      createdAt: 1,
      deviceId: 'remote-device',
      deviceLabel: 'Remote device',
      databaseSha256: 'db',
      settingsSha256: 'settings',
      snapshotSizeBytes: 2,
    ),
    manifestFileId: 'manifest-file',
    manifestFileVersion: 'manifest-version',
    snapshotFileId: 'snapshot-file',
    snapshotFileVersion: 'snapshot-version',
    modifiedAt: 1,
  );
}
