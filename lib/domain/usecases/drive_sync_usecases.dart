import '../entities/drive_sync_models.dart';
import '../repositories/drive_sync_repository.dart';

final class LoadDriveSyncStatusUseCase {
  const LoadDriveSyncStatusUseCase(this._repository);

  final DriveSyncRepository _repository;

  Future<DriveSyncStatus> execute() => _repository.loadStatus();
}

final class UploadLocalDriveSnapshotUseCase {
  const UploadLocalDriveSnapshotUseCase(this._repository);

  final DriveSyncRepository _repository;

  Future<DriveSyncRunResult> execute() => _repository.uploadLocalSnapshot();
}

final class RestoreDriveSnapshotUseCase {
  const RestoreDriveSnapshotUseCase(this._repository);

  final DriveSyncRepository _repository;

  Future<DriveSyncRunResult> execute() => _repository.restoreDriveSnapshot();
}
