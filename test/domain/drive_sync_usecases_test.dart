import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/entities/drive_sync_models.dart';
import 'package:memox/domain/repositories/drive_sync_repository.dart';
import 'package:memox/domain/usecases/drive_sync_usecases.dart';

void main() {
  test('LoadDriveSyncStatusUseCase delegates to repository', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
    );
    final useCase = LoadDriveSyncStatusUseCase(repository);

    final status = await useCase.execute();

    expect(status.kind, DriveSyncStatusKind.noRemoteSnapshot);
    expect(repository.loadStatusCount, 1);
  });

  test('UploadLocalDriveSnapshotUseCase delegates to repository', () async {
    final repository = _FakeDriveSyncRepository(
      uploadResult: const DriveSyncRunResult.uploadedLocal(
        DriveSyncStatus(kind: DriveSyncStatusKind.synced),
      ),
    );
    final useCase = UploadLocalDriveSnapshotUseCase(repository);

    final result = await useCase.execute();

    expect(result.kind, DriveSyncActionKind.uploadedLocal);
    expect(repository.uploadLocalCount, 1);
  });

  test('RestoreDriveSnapshotUseCase delegates to repository', () async {
    final repository = _FakeDriveSyncRepository(
      restoreResult: const DriveSyncRunResult.restoredRemote(
        DriveSyncStatus(kind: DriveSyncStatusKind.synced),
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
    DriveSyncRunResult? uploadResult,
    DriveSyncRunResult? restoreResult,
  }) : loadStatusResult = loadStatusResult ?? const DriveSyncStatus.signedOut(),
       uploadResult =
           uploadResult ??
           const DriveSyncRunResult.noChanges(DriveSyncStatus.signedOut()),
       restoreResult =
           restoreResult ??
           const DriveSyncRunResult.noChanges(DriveSyncStatus.signedOut());

  final DriveSyncStatus loadStatusResult;
  final DriveSyncRunResult uploadResult;
  final DriveSyncRunResult restoreResult;
  int loadStatusCount = 0;
  int uploadLocalCount = 0;
  int restoreDriveCount = 0;

  @override
  Future<DriveSyncStatus> loadStatus() async {
    loadStatusCount += 1;
    return loadStatusResult;
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
}
