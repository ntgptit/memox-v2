// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driveSyncHttpClient)
final driveSyncHttpClientProvider = DriveSyncHttpClientProvider._();

final class DriveSyncHttpClientProvider
    extends $FunctionalProvider<http.Client, http.Client, http.Client>
    with $Provider<http.Client> {
  DriveSyncHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveSyncHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveSyncHttpClientHash();

  @$internal
  @override
  $ProviderElement<http.Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  http.Client create(Ref ref) {
    return driveSyncHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(http.Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<http.Client>(value),
    );
  }
}

String _$driveSyncHttpClientHash() =>
    r'ceecd753a064bc99d2fe5856feb4f4bd33586546';

@ProviderFor(googleDriveAppDataClient)
final googleDriveAppDataClientProvider = GoogleDriveAppDataClientProvider._();

final class GoogleDriveAppDataClientProvider
    extends
        $FunctionalProvider<
          DriveAppDataClient,
          DriveAppDataClient,
          DriveAppDataClient
        >
    with $Provider<DriveAppDataClient> {
  GoogleDriveAppDataClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'googleDriveAppDataClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$googleDriveAppDataClientHash();

  @$internal
  @override
  $ProviderElement<DriveAppDataClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriveAppDataClient create(Ref ref) {
    return googleDriveAppDataClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriveAppDataClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriveAppDataClient>(value),
    );
  }
}

String _$googleDriveAppDataClientHash() =>
    r'd3d6148880b6a4fc1bd1e406957bc1b9045c080b';

@ProviderFor(driveSyncSnapshotCodec)
final driveSyncSnapshotCodecProvider = DriveSyncSnapshotCodecProvider._();

final class DriveSyncSnapshotCodecProvider
    extends
        $FunctionalProvider<
          DriveSyncSnapshotCodec,
          DriveSyncSnapshotCodec,
          DriveSyncSnapshotCodec
        >
    with $Provider<DriveSyncSnapshotCodec> {
  DriveSyncSnapshotCodecProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveSyncSnapshotCodecProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveSyncSnapshotCodecHash();

  @$internal
  @override
  $ProviderElement<DriveSyncSnapshotCodec> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriveSyncSnapshotCodec create(Ref ref) {
    return driveSyncSnapshotCodec(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriveSyncSnapshotCodec value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriveSyncSnapshotCodec>(value),
    );
  }
}

String _$driveSyncSnapshotCodecHash() =>
    r'6a515324285c52c55fa56275af4c83e190e0d50a';

@ProviderFor(localDatabaseSnapshotGateway)
final localDatabaseSnapshotGatewayProvider =
    LocalDatabaseSnapshotGatewayProvider._();

final class LocalDatabaseSnapshotGatewayProvider
    extends
        $FunctionalProvider<
          LocalDatabaseSnapshotGateway,
          LocalDatabaseSnapshotGateway,
          LocalDatabaseSnapshotGateway
        >
    with $Provider<LocalDatabaseSnapshotGateway> {
  LocalDatabaseSnapshotGatewayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localDatabaseSnapshotGatewayProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localDatabaseSnapshotGatewayHash();

  @$internal
  @override
  $ProviderElement<LocalDatabaseSnapshotGateway> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalDatabaseSnapshotGateway create(Ref ref) {
    return localDatabaseSnapshotGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalDatabaseSnapshotGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalDatabaseSnapshotGateway>(value),
    );
  }
}

String _$localDatabaseSnapshotGatewayHash() =>
    r'db94680686b60d9fad789daf9c75a6464a11a228';

@ProviderFor(appSettingsSnapshotStore)
final appSettingsSnapshotStoreProvider = AppSettingsSnapshotStoreProvider._();

final class AppSettingsSnapshotStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppSettingsSnapshotStore>,
          AppSettingsSnapshotStore,
          FutureOr<AppSettingsSnapshotStore>
        >
    with
        $FutureModifier<AppSettingsSnapshotStore>,
        $FutureProvider<AppSettingsSnapshotStore> {
  AppSettingsSnapshotStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsSnapshotStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsSnapshotStoreHash();

  @$internal
  @override
  $FutureProviderElement<AppSettingsSnapshotStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AppSettingsSnapshotStore> create(Ref ref) {
    return appSettingsSnapshotStore(ref);
  }
}

String _$appSettingsSnapshotStoreHash() =>
    r'f37b211c4aa1c9eef1680d0a2bbbe826702d7fe2';

@ProviderFor(driveSyncMetadataStore)
final driveSyncMetadataStoreProvider = DriveSyncMetadataStoreProvider._();

final class DriveSyncMetadataStoreProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriveSyncMetadataStore>,
          DriveSyncMetadataStore,
          FutureOr<DriveSyncMetadataStore>
        >
    with
        $FutureModifier<DriveSyncMetadataStore>,
        $FutureProvider<DriveSyncMetadataStore> {
  DriveSyncMetadataStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveSyncMetadataStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveSyncMetadataStoreHash();

  @$internal
  @override
  $FutureProviderElement<DriveSyncMetadataStore> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriveSyncMetadataStore> create(Ref ref) {
    return driveSyncMetadataStore(ref);
  }
}

String _$driveSyncMetadataStoreHash() =>
    r'a6eaa9b2f214ff224deeef50fb86ac07ed751b2e';

@ProviderFor(driveSyncRepository)
final driveSyncRepositoryProvider = DriveSyncRepositoryProvider._();

final class DriveSyncRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriveSyncRepository>,
          DriveSyncRepository,
          FutureOr<DriveSyncRepository>
        >
    with
        $FutureModifier<DriveSyncRepository>,
        $FutureProvider<DriveSyncRepository> {
  DriveSyncRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveSyncRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveSyncRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<DriveSyncRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DriveSyncRepository> create(Ref ref) {
    return driveSyncRepository(ref);
  }
}

String _$driveSyncRepositoryHash() =>
    r'18f9d3fdba3fc0a1caacc923bf5055a7106d711e';

@ProviderFor(loadDriveSyncStatusUseCase)
final loadDriveSyncStatusUseCaseProvider =
    LoadDriveSyncStatusUseCaseProvider._();

final class LoadDriveSyncStatusUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<LoadDriveSyncStatusUseCase>,
          LoadDriveSyncStatusUseCase,
          FutureOr<LoadDriveSyncStatusUseCase>
        >
    with
        $FutureModifier<LoadDriveSyncStatusUseCase>,
        $FutureProvider<LoadDriveSyncStatusUseCase> {
  LoadDriveSyncStatusUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loadDriveSyncStatusUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loadDriveSyncStatusUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<LoadDriveSyncStatusUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<LoadDriveSyncStatusUseCase> create(Ref ref) {
    return loadDriveSyncStatusUseCase(ref);
  }
}

String _$loadDriveSyncStatusUseCaseHash() =>
    r'36c678799ae5e3e1d3bd9be5fe17750ef6ec28a7';

@ProviderFor(syncGoogleDriveSnapshotUseCase)
final syncGoogleDriveSnapshotUseCaseProvider =
    SyncGoogleDriveSnapshotUseCaseProvider._();

final class SyncGoogleDriveSnapshotUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<SyncGoogleDriveSnapshotUseCase>,
          SyncGoogleDriveSnapshotUseCase,
          FutureOr<SyncGoogleDriveSnapshotUseCase>
        >
    with
        $FutureModifier<SyncGoogleDriveSnapshotUseCase>,
        $FutureProvider<SyncGoogleDriveSnapshotUseCase> {
  SyncGoogleDriveSnapshotUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncGoogleDriveSnapshotUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncGoogleDriveSnapshotUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<SyncGoogleDriveSnapshotUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SyncGoogleDriveSnapshotUseCase> create(Ref ref) {
    return syncGoogleDriveSnapshotUseCase(ref);
  }
}

String _$syncGoogleDriveSnapshotUseCaseHash() =>
    r'15b1dcd535ab0c9f2c0cbd3032b7594548eecbf7';

@ProviderFor(uploadLocalDriveSnapshotUseCase)
final uploadLocalDriveSnapshotUseCaseProvider =
    UploadLocalDriveSnapshotUseCaseProvider._();

final class UploadLocalDriveSnapshotUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<UploadLocalDriveSnapshotUseCase>,
          UploadLocalDriveSnapshotUseCase,
          FutureOr<UploadLocalDriveSnapshotUseCase>
        >
    with
        $FutureModifier<UploadLocalDriveSnapshotUseCase>,
        $FutureProvider<UploadLocalDriveSnapshotUseCase> {
  UploadLocalDriveSnapshotUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uploadLocalDriveSnapshotUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uploadLocalDriveSnapshotUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<UploadLocalDriveSnapshotUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UploadLocalDriveSnapshotUseCase> create(Ref ref) {
    return uploadLocalDriveSnapshotUseCase(ref);
  }
}

String _$uploadLocalDriveSnapshotUseCaseHash() =>
    r'0a64b2e962d545e5c4b449283d8dda659cdb4879';

@ProviderFor(restoreDriveSnapshotUseCase)
final restoreDriveSnapshotUseCaseProvider =
    RestoreDriveSnapshotUseCaseProvider._();

final class RestoreDriveSnapshotUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<RestoreDriveSnapshotUseCase>,
          RestoreDriveSnapshotUseCase,
          FutureOr<RestoreDriveSnapshotUseCase>
        >
    with
        $FutureModifier<RestoreDriveSnapshotUseCase>,
        $FutureProvider<RestoreDriveSnapshotUseCase> {
  RestoreDriveSnapshotUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'restoreDriveSnapshotUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$restoreDriveSnapshotUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<RestoreDriveSnapshotUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RestoreDriveSnapshotUseCase> create(Ref ref) {
    return restoreDriveSnapshotUseCase(ref);
  }
}

String _$restoreDriveSnapshotUseCaseHash() =>
    r'db6a6e8002390e4b5c9638b56e05007208eb0d25';

@ProviderFor(resolveDriveSyncConflictUseCase)
final resolveDriveSyncConflictUseCaseProvider =
    ResolveDriveSyncConflictUseCaseProvider._();

final class ResolveDriveSyncConflictUseCaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<ResolveDriveSyncConflictUseCase>,
          ResolveDriveSyncConflictUseCase,
          FutureOr<ResolveDriveSyncConflictUseCase>
        >
    with
        $FutureModifier<ResolveDriveSyncConflictUseCase>,
        $FutureProvider<ResolveDriveSyncConflictUseCase> {
  ResolveDriveSyncConflictUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resolveDriveSyncConflictUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resolveDriveSyncConflictUseCaseHash();

  @$internal
  @override
  $FutureProviderElement<ResolveDriveSyncConflictUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ResolveDriveSyncConflictUseCase> create(Ref ref) {
    return resolveDriveSyncConflictUseCase(ref);
  }
}

String _$resolveDriveSyncConflictUseCaseHash() =>
    r'94dab5fcca6b1334e92e343ab5fe6c75cc8f61be';

@ProviderFor(appReloadService)
final appReloadServiceProvider = AppReloadServiceProvider._();

final class AppReloadServiceProvider
    extends
        $FunctionalProvider<
          AppReloadService,
          AppReloadService,
          AppReloadService
        >
    with $Provider<AppReloadService> {
  AppReloadServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appReloadServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appReloadServiceHash();

  @$internal
  @override
  $ProviderElement<AppReloadService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppReloadService create(Ref ref) {
    return appReloadService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppReloadService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppReloadService>(value),
    );
  }
}

String _$appReloadServiceHash() => r'554df28d21c1df2b07975a4c19c870f4457f1d9c';

@ProviderFor(driveSyncRuntimeEffects)
final driveSyncRuntimeEffectsProvider = DriveSyncRuntimeEffectsProvider._();

final class DriveSyncRuntimeEffectsProvider
    extends
        $FunctionalProvider<
          DriveSyncRuntimeEffects,
          DriveSyncRuntimeEffects,
          DriveSyncRuntimeEffects
        >
    with $Provider<DriveSyncRuntimeEffects> {
  DriveSyncRuntimeEffectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveSyncRuntimeEffectsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveSyncRuntimeEffectsHash();

  @$internal
  @override
  $ProviderElement<DriveSyncRuntimeEffects> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriveSyncRuntimeEffects create(Ref ref) {
    return driveSyncRuntimeEffects(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriveSyncRuntimeEffects value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriveSyncRuntimeEffects>(value),
    );
  }
}

String _$driveSyncRuntimeEffectsHash() =>
    r'20fb34bcfbe4576e8a6e44d7541ea75a7c5112f3';
