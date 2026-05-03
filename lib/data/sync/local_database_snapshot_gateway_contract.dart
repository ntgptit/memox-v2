import 'dart:typed_data';

import '../../domain/entities/drive_sync_models.dart';

abstract interface class LocalDatabaseSnapshotGateway {
  int get currentSchemaVersion;

  Future<Uint8List> exportDatabase();

  Future<DriveSyncRestoreEffect> restoreDatabase(Uint8List databaseBytes);
}
