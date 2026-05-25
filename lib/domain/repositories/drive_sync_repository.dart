import '../entities/drive_sync_models.dart';

abstract interface class DriveSyncRepository {
  Future<DriveSyncStatus> loadStatus();

  Future<DriveSyncRunResult> uploadLocalSnapshot();

  Future<DriveSyncRunResult> restoreDriveSnapshot();
}
