import 'app_database.dart';

final class LocalTransactionRunner {
  const LocalTransactionRunner(this._database);

  final AppDatabase _database;

  Future<T> write<T>(Future<T> Function(AppDatabase database) action) {
    return _database.transaction<T>(() => action(_database));
  }
}
