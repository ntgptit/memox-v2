import '../datasources/local/app_database.dart';
import 'local_database_snapshot_gateway_contract.dart';

LocalDatabaseSnapshotGateway createPlatformLocalDatabaseSnapshotGateway(
  AppDatabase database,
) {
  return _UnsupportedLocalDatabaseSnapshotGateway(database);
}

final class _UnsupportedLocalDatabaseSnapshotGateway
    implements LocalDatabaseSnapshotGateway {
  const _UnsupportedLocalDatabaseSnapshotGateway(this._database);

  final AppDatabase _database;

  @override
  int get currentSchemaVersion => _database.schemaVersion;

  @override
  Future<Never> exportDatabase() {
    throw UnsupportedError('Database snapshot export is not supported.');
  }

  @override
  Future<Never> restoreDatabase(databaseBytes) {
    throw UnsupportedError('Database snapshot restore is not supported.');
  }
}
