import '../entities/drive_sync_models.dart';
import '../repositories/drive_sync_repository.dart';

final class LoadDriveSyncStatusUseCase {
  const LoadDriveSyncStatusUseCase(this._repository);

  final DriveSyncRepository _repository;

  Future<DriveSyncStatus> execute() => _repository.loadStatus();
}

final class SyncGoogleDriveSnapshotUseCase {
  const SyncGoogleDriveSnapshotUseCase(this._repository);

  final DriveSyncRepository _repository;

  Future<DriveSyncRunResult> execute() => _repository.syncNow();
}

final class ResolveDriveSyncConflictUseCase {
  const ResolveDriveSyncConflictUseCase(this._repository);

  final DriveSyncRepository _repository;

  Future<DriveSyncRunResult> execute(
    DriveSyncConflict conflict,
    DriveSyncConflictChoice choice,
  ) {
    return _repository.resolveConflict(conflict, choice);
  }
}
