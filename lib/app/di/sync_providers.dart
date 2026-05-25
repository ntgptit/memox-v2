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
import '../logging/app_talker.dart';
import '../services/drive_sync_runtime_effects.dart';
import 'account_providers.dart';
import 'content/content_core_providers.dart';
import 'providers.dart';

part 'sync_providers.g.dart';

@Riverpod(keepAlive: true)
http.Client driveSyncHttpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

@riverpod
DriveAppDataClient googleDriveAppDataClient(Ref ref) =>
    GoogleDriveAppDataClient(ref.watch(driveSyncHttpClientProvider));

@riverpod
DriveSyncSnapshotCodec driveSyncSnapshotCodec(Ref ref) =>
    const DriveSyncSnapshotCodec();

@riverpod
LocalDatabaseSnapshotGateway localDatabaseSnapshotGateway(Ref ref) =>
    createLocalDatabaseSnapshotGateway(ref.watch(appDatabaseProvider));

@riverpod
Future<AppSettingsSnapshotStore> appSettingsSnapshotStore(Ref ref) async =>
    AppSettingsSnapshotStore(await ref.watch(sharedPreferencesProvider.future));

@riverpod
Future<DriveSyncMetadataStore> driveSyncMetadataStore(Ref ref) async =>
    DriveSyncMetadataStore(await ref.watch(sharedPreferencesProvider.future));

@riverpod
Future<DriveSyncRepository> driveSyncRepository(Ref ref) async =>
    GoogleDriveSyncRepository(
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

@riverpod
Future<LoadDriveSyncStatusUseCase> loadDriveSyncStatusUseCase(Ref ref) async =>
    LoadDriveSyncStatusUseCase(
      await ref.watch(driveSyncRepositoryProvider.future),
    );

@riverpod
Future<UploadLocalDriveSnapshotUseCase> uploadLocalDriveSnapshotUseCase(
  Ref ref,
) async => UploadLocalDriveSnapshotUseCase(
  await ref.watch(driveSyncRepositoryProvider.future),
);

@riverpod
Future<RestoreDriveSnapshotUseCase> restoreDriveSnapshotUseCase(
  Ref ref,
) async => RestoreDriveSnapshotUseCase(
  await ref.watch(driveSyncRepositoryProvider.future),
);

@riverpod
AppReloadService appReloadService(Ref ref) => createAppReloadService();

@riverpod
DriveSyncRuntimeEffects driveSyncRuntimeEffects(Ref ref) =>
    RiverpodDriveSyncRuntimeEffects(
      ref: ref,
      appReloadService: ref.watch(appReloadServiceProvider),
    );
