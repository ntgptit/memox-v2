import '../datasources/local/app_database.dart';
import 'local_database_snapshot_gateway_contract.dart';
import 'local_database_snapshot_gateway_stub.dart'
    if (dart.library.io) 'local_database_snapshot_gateway_io.dart'
    if (dart.library.html) 'local_database_snapshot_gateway_web.dart';

LocalDatabaseSnapshotGateway createLocalDatabaseSnapshotGateway(
  AppDatabase database,
) {
  return createPlatformLocalDatabaseSnapshotGateway(database);
}
