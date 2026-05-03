import '../entities/cloud_account_link.dart';

abstract interface class CloudAccountRepository {
  Future<CloudAccountLink?> load();
  Future<void> save(CloudAccountLink link);
  Future<void> clear();
}
