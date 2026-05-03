import '../entities/drive_sync_models.dart';

abstract interface class DriveSyncRepository {
  Future<DriveSyncStatus> loadStatus();

  Future<DriveSyncRunResult> syncNow();

  Future<DriveSyncRunResult> resolveConflict(
    DriveSyncConflict conflict,
    DriveSyncConflictChoice choice,
  );
}
