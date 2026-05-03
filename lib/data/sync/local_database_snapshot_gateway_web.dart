import 'dart:typed_data';

import 'package:drift/wasm.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/drive_sync_models.dart';
import '../datasources/local/app_database.dart';
import 'local_database_snapshot_gateway_contract.dart';

LocalDatabaseSnapshotGateway createPlatformLocalDatabaseSnapshotGateway(
  AppDatabase database,
) {
  return _WebLocalDatabaseSnapshotGateway(database);
}

final class _WebLocalDatabaseSnapshotGateway
    implements LocalDatabaseSnapshotGateway {
  const _WebLocalDatabaseSnapshotGateway(this._database);

  static final Uri _sqlite3Uri = Uri.parse('sqlite3.wasm');
  static final Uri _driftWorkerUri = Uri.parse('drift_worker.dart.js');

  final AppDatabase _database;

  @override
  int get currentSchemaVersion => _database.schemaVersion;

  @override
  Future<Uint8List> exportDatabase() async {
    final probe = await WasmDatabase.probe(
      databaseName: AppConstants.localDatabaseName,
      sqlite3Uri: _sqlite3Uri,
      driftWorkerUri: _driftWorkerUri,
    );
    final existing = _findExisting(probe);
    if (existing == null) {
      return Uint8List(0);
    }
    final bytes = await probe.exportDatabase(existing);
    return bytes ?? Uint8List(0);
  }

  @override
  Future<DriveSyncRestoreEffect> restoreDatabase(Uint8List databaseBytes) async {
    await _database.close();
    final probe = await WasmDatabase.probe(
      databaseName: AppConstants.localDatabaseName,
      sqlite3Uri: _sqlite3Uri,
      driftWorkerUri: _driftWorkerUri,
    );

    for (final existing in probe.existingDatabases) {
      if (existing.$2 == AppConstants.localDatabaseName) {
        await probe.deleteDatabase(existing);
      }
    }

    final opened = await WasmDatabase.open(
      databaseName: AppConstants.localDatabaseName,
      sqlite3Uri: _sqlite3Uri,
      driftWorkerUri: _driftWorkerUri,
      initializeDatabase: () => databaseBytes,
      enableMigrations: false,
    );
    await opened.resolvedExecutor.close();
    return DriveSyncRestoreEffect.reloadApp;
  }

  ExistingDatabase? _findExisting(WasmProbeResult probe) {
    for (final existing in probe.existingDatabases) {
      if (existing.$2 == AppConstants.localDatabaseName) {
        return existing;
      }
    }
    return null;
  }
}
