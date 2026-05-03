import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/drive_sync_models.dart';
import '../datasources/local/app_database.dart';
import 'local_database_snapshot_gateway_contract.dart';

LocalDatabaseSnapshotGateway createPlatformLocalDatabaseSnapshotGateway(
  AppDatabase database,
) {
  return _IoLocalDatabaseSnapshotGateway(database);
}

final class _IoLocalDatabaseSnapshotGateway
    implements LocalDatabaseSnapshotGateway {
  const _IoLocalDatabaseSnapshotGateway(this._database);

  final AppDatabase _database;

  @override
  int get currentSchemaVersion => _database.schemaVersion;

  @override
  Future<Uint8List> exportDatabase() async {
    final tempDirectory = await getTemporaryDirectory();
    final snapshotPath = p.join(
      tempDirectory.path,
      '${AppConstants.localDatabaseName}-sync-${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    final snapshotFile = File(snapshotPath);
    if (snapshotFile.existsSync()) {
      await snapshotFile.delete();
    }

    await _database.exclusively(() async {
      await _database.customStatement('VACUUM INTO ?', <Object?>[snapshotPath]);
    });

    try {
      return await snapshotFile.readAsBytes();
    } finally {
      if (snapshotFile.existsSync()) {
        await snapshotFile.delete();
      }
    }
  }

  @override
  Future<DriveSyncRestoreEffect> restoreDatabase(Uint8List databaseBytes) async {
    final databaseFile = await _databaseFile();
    await _database.close();
    await _backupIfExists(databaseFile);
    await databaseFile.writeAsBytes(databaseBytes, flush: true);
    await _deleteIfExists(File('${databaseFile.path}-wal'));
    await _deleteIfExists(File('${databaseFile.path}-shm'));
    return DriveSyncRestoreEffect.refreshDatabaseProvider;
  }

  Future<File> _databaseFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(
      p.join(directory.path, '${AppConstants.localDatabaseName}.sqlite'),
    );
  }

  Future<void> _backupIfExists(File file) async {
    if (!file.existsSync()) {
      return;
    }
    final backupPath =
        '${file.path}.bak.${DateTime.now().millisecondsSinceEpoch}';
    await file.copy(backupPath);
  }

  Future<void> _deleteIfExists(File file) async {
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
