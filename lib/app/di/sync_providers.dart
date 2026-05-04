import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/app_reload_service.dart';
import '../../data/repositories/google_drive_sync_repository.dart';
import '../../data/sync/app_settings_snapshot_store.dart';
import '../../data/sync/drive_sync_metadata_store.dart';
import '../../data/sync/drive_sync_snapshot_codec.dart';
import '../../data/sync/google_drive_app_data_client.dart';
import '../../data/sync/local_database_snapshot_gateway.dart';
import '../../data/sync/local_database_snapshot_gateway_contract.dart';
import '../../domain/repositories/drive_sync_repository.dart';
import '../../domain/usecases/drive_sync_usecases.dart';
import '../services/drive_sync_runtime_effects.dart';
import '../logging/app_talker.dart';
import 'account_providers.dart';
import 'content_providers.dart';
import 'providers.dart';
import 'study_providers.dart';

part 'sync_providers.g.dart';

@Riverpod(keepAlive: true)
http.Client driveSyncHttpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

@Riverpod(keepAlive: true)
DriveAppDataClient googleDriveAppDataClient(Ref ref) {
  return GoogleDriveAppDataClient(ref.watch(driveSyncHttpClientProvider));
}

@Riverpod(keepAlive: true)
DriveSyncSnapshotCodec driveSyncSnapshotCodec(Ref ref) {
  return const DriveSyncSnapshotCodec();
}

@Riverpod(keepAlive: true)
LocalDatabaseSnapshotGateway localDatabaseSnapshotGateway(Ref ref) {
  return createLocalDatabaseSnapshotGateway(ref.watch(appDatabaseProvider));
}

@Riverpod(keepAlive: true)
Future<AppSettingsSnapshotStore> appSettingsSnapshotStore(Ref ref) async {
  return AppSettingsSnapshotStore(
    await ref.watch(sharedPreferencesProvider.future),
  );
}

@Riverpod(keepAlive: true)
Future<DriveSyncMetadataStore> driveSyncMetadataStore(Ref ref) async {
  return DriveSyncMetadataStore(
    await ref.watch(sharedPreferencesProvider.future),
  );
}

@Riverpod(keepAlive: true)
Future<DriveSyncRepository> driveSyncRepository(Ref ref) async {
  return GoogleDriveSyncRepository(
    accountRepository: await ref.watch(cloudAccountRepositoryProvider.future),
    authService: ref.watch(googleAccountAuthServiceProvider),
    googleOAuthConfig: ref.watch(googleOAuthConfigProvider),
    driveClient: ref.watch(googleDriveAppDataClientProvider),
    databaseSnapshotGateway: ref.watch(localDatabaseSnapshotGatewayProvider),
    settingsSnapshotStore: await ref.watch(
      appSettingsSnapshotStoreProvider.future,
    ),
    metadataStore: await ref.watch(driveSyncMetadataStoreProvider.future),
    snapshotCodec: ref.watch(driveSyncSnapshotCodecProvider),
    clock: ref.watch(clockProvider),
    idGenerator: ref.watch(idGeneratorProvider),
    logger: TalkerAppLogger(ref.watch(talkerProvider)),
  );
}

@Riverpod(keepAlive: true)
Future<LoadDriveSyncStatusUseCase> loadDriveSyncStatusUseCase(Ref ref) async {
  return LoadDriveSyncStatusUseCase(
    await ref.watch(driveSyncRepositoryProvider.future),
  );
}

@Riverpod(keepAlive: true)
Future<SyncGoogleDriveSnapshotUseCase> syncGoogleDriveSnapshotUseCase(
  Ref ref,
) async {
  return SyncGoogleDriveSnapshotUseCase(
    await ref.watch(driveSyncRepositoryProvider.future),
  );
}

@Riverpod(keepAlive: true)
Future<UploadLocalDriveSnapshotUseCase> uploadLocalDriveSnapshotUseCase(
  Ref ref,
) async {
  return UploadLocalDriveSnapshotUseCase(
    await ref.watch(driveSyncRepositoryProvider.future),
  );
}

@Riverpod(keepAlive: true)
Future<RestoreDriveSnapshotUseCase> restoreDriveSnapshotUseCase(Ref ref) async {
  return RestoreDriveSnapshotUseCase(
    await ref.watch(driveSyncRepositoryProvider.future),
  );
}

@Riverpod(keepAlive: true)
Future<ResolveDriveSyncConflictUseCase> resolveDriveSyncConflictUseCase(
  Ref ref,
) async {
  return ResolveDriveSyncConflictUseCase(
    await ref.watch(driveSyncRepositoryProvider.future),
  );
}

@Riverpod(keepAlive: true)
AppReloadService appReloadService(Ref ref) {
  return createAppReloadService();
}

@Riverpod(keepAlive: true)
DriveSyncRuntimeEffects driveSyncRuntimeEffects(Ref ref) {
  return RiverpodDriveSyncRuntimeEffects(
    ref: ref,
    appReloadService: ref.watch(appReloadServiceProvider),
  );
}
