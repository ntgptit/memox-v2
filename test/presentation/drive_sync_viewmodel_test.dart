import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/sync_providers.dart';
import 'package:memox/app/services/drive_sync_runtime_effects.dart';
import 'package:memox/domain/entities/drive_sync_models.dart';
import 'package:memox/domain/repositories/drive_sync_repository.dart';
import 'package:memox/presentation/features/settings/viewmodels/drive_sync_settings_viewmodel.dart';

void main() {
  test('loading: maps signed-out repository status', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.signedOut(),
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    final state = await container.read(
      driveSyncSettingsControllerProvider.future,
    );

    expect(state.kind, DriveSyncStatusKind.signedOut);
    expect(state.canSync, isFalse);
  });

  test(
    'uploadLocalToDrive: uploaded result exposes uploaded message',
    () async {
      final repository = _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
        uploadResult: const DriveSyncRunResult.uploadedLocal(
          DriveSyncStatus(kind: DriveSyncStatusKind.synced),
        ),
      );
      final container = _container(repository: repository);
      addTearDown(container.dispose);

      await container.read(driveSyncSettingsControllerProvider.future);
      await container
          .read(driveSyncSettingsControllerProvider.notifier)
          .uploadLocalToDrive();

      final state = container.read(driveSyncSettingsControllerProvider).value!;
      expect(repository.uploadLocalCount, 1);
      expect(state.kind, DriveSyncStatusKind.synced);
      expect(state.message, DriveSyncSettingsMessage.uploaded);
    },
  );

  test('restoreDriveToLocal: restored result applies refresh effect', () async {
    final remote = _remoteSnapshot();
    final effects = _FakeDriveSyncRuntimeEffects();
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: DriveSyncStatus(
        kind: DriveSyncStatusKind.ready,
        remote: remote,
      ),
      restoreResult: DriveSyncRunResult.restoredRemote(
        DriveSyncStatus(kind: DriveSyncStatusKind.synced, remote: remote),
        DriveSyncRestoreEffect.refreshDatabaseProvider,
      ),
    );
    final container = _container(repository: repository, effects: effects);
    addTearDown(container.dispose);

    await container.read(driveSyncSettingsControllerProvider.future);
    await container
        .read(driveSyncSettingsControllerProvider.notifier)
        .restoreDriveToLocal();

    final state = container.read(driveSyncSettingsControllerProvider).value!;
    expect(repository.restoreDriveCount, 1);
    expect(effects.effects, <DriveSyncRestoreEffect>[
      DriveSyncRestoreEffect.refreshDatabaseProvider,
    ]);
    expect(state.kind, DriveSyncStatusKind.synced);
    expect(state.message, DriveSyncSettingsMessage.restored);
  });

  test('restoreDriveToLocal: duplicate call while busy is ignored', () async {
    final remote = _remoteSnapshot();
    final restoreCompleter = Completer<DriveSyncRunResult>();
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: DriveSyncStatus(
        kind: DriveSyncStatusKind.ready,
        remote: remote,
      ),
      restoreFuture: restoreCompleter.future,
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);
    final subscription = container.listen(
      driveSyncSettingsControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    await container.read(driveSyncSettingsControllerProvider.future);
    final controller = container.read(
      driveSyncSettingsControllerProvider.notifier,
    );
    final firstRun = controller.restoreDriveToLocal();
    await Future<void>.delayed(Duration.zero);
    await controller.restoreDriveToLocal();

    expect(repository.restoreDriveCount, 1);

    restoreCompleter.complete(
      DriveSyncRunResult.restoredRemote(
        DriveSyncStatus(kind: DriveSyncStatusKind.synced, remote: remote),
        DriveSyncRestoreEffect.refreshDatabaseProvider,
      ),
    );
    await firstRun;

    final state = container.read(driveSyncSettingsControllerProvider).value!;
    expect(state.message, DriveSyncSettingsMessage.restored);
  });

  test('restoreDriveToLocal: disabled when no remote snapshot', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    final initialState = await container.read(
      driveSyncSettingsControllerProvider.future,
    );
    await container
        .read(driveSyncSettingsControllerProvider.notifier)
        .restoreDriveToLocal();

    final state = container.read(driveSyncSettingsControllerProvider).value!;
    expect(initialState.canRestoreDrive, isFalse);
    expect(repository.restoreDriveCount, 0);
    expect(state.kind, DriveSyncStatusKind.noRemoteSnapshot);
  });

  test('restoreDriveToLocal: disabled when already synced', () async {
    final remote = _remoteSnapshot();
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: DriveSyncStatus(
        kind: DriveSyncStatusKind.synced,
        remote: remote,
      ),
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    final initialState = await container.read(
      driveSyncSettingsControllerProvider.future,
    );
    await container
        .read(driveSyncSettingsControllerProvider.notifier)
        .restoreDriveToLocal();

    final state = container.read(driveSyncSettingsControllerProvider).value!;
    expect(initialState.canSync, isFalse);
    expect(initialState.canRestoreDrive, isFalse);
    expect(repository.restoreDriveCount, 0);
    expect(state.kind, DriveSyncStatusKind.synced);
  });

  test('uploadLocalToDrive: blocked when needs reauthorization', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.needsDriveAuthorization(),
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    await container.read(driveSyncSettingsControllerProvider.future);
    await container
        .read(driveSyncSettingsControllerProvider.notifier)
        .uploadLocalToDrive();

    expect(repository.uploadLocalCount, 0);
  });

  test('refresh: after reauthorization, sync becomes available', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResults: const <DriveSyncStatus>[
        DriveSyncStatus.needsDriveAuthorization(),
        DriveSyncStatus.noRemoteSnapshot(),
      ],
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    final initialState = await container.read(
      driveSyncSettingsControllerProvider.future,
    );
    await container
        .read(driveSyncSettingsControllerProvider.notifier)
        .refresh();
    final state = container.read(driveSyncSettingsControllerProvider).value!;

    expect(initialState.canSync, isFalse);
    expect(state.kind, DriveSyncStatusKind.noRemoteSnapshot);
    expect(state.canSync, isTrue);
  });

  test('refresh: unexpected error becomes failure state', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    await container.read(driveSyncSettingsControllerProvider.future);
    repository.loadStatusError = StateError('refresh failed');
    await container
        .read(driveSyncSettingsControllerProvider.notifier)
        .refresh();
    final state = container.read(driveSyncSettingsControllerProvider).value!;

    expect(state.kind, DriveSyncStatusKind.failure);
    expect(state.technicalMessage, 'Bad state: refresh failed');
  });

  test('loading: failure status keeps technical message', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.failure(
        'Google Drive API is disabled.',
      ),
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    final state = await container.read(
      driveSyncSettingsControllerProvider.future,
    );

    expect(state.kind, DriveSyncStatusKind.failure);
    expect(state.canSync, isTrue);
    expect(state.technicalMessage, 'Google Drive API is disabled.');
  });

  test('loading: unsupported schema blocks manual sync', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: DriveSyncStatus(
        kind: DriveSyncStatusKind.unsupportedSchema,
        remote: _remoteSnapshot(),
      ),
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    final state = await container.read(
      driveSyncSettingsControllerProvider.future,
    );

    expect(state.kind, DriveSyncStatusKind.unsupportedSchema);
    expect(state.canSync, isFalse);
    expect(state.canUploadLocal, isFalse);
    expect(state.canRestoreDrive, isFalse);
  });

  test('loading: unexpected error becomes retryable failure state', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusError: StateError('sync provider unavailable'),
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    final state = await container.read(
      driveSyncSettingsControllerProvider.future,
    );

    expect(state.kind, DriveSyncStatusKind.failure);
    expect(state.technicalMessage, 'Bad state: sync provider unavailable');
  });
}

ProviderContainer _container({
  required _FakeDriveSyncRepository repository,
  _FakeDriveSyncRuntimeEffects? effects,
}) => ProviderContainer(
  overrides: [
    driveSyncRepositoryProvider.overrideWith((ref) async => repository),
    driveSyncRuntimeEffectsProvider.overrideWithValue(
      effects ?? _FakeDriveSyncRuntimeEffects(),
    ),
  ],
);

final class _FakeDriveSyncRepository implements DriveSyncRepository {
  _FakeDriveSyncRepository({
    DriveSyncStatus? loadStatusResult,
    List<DriveSyncStatus>? loadStatusResults,
    DriveSyncRunResult? uploadResult,
    DriveSyncRunResult? restoreResult,
    this.restoreFuture,
    this.loadStatusError,
  }) : loadStatusResult = loadStatusResult ?? const DriveSyncStatus.signedOut(),
       _loadStatusResults = loadStatusResults?.toList() ?? <DriveSyncStatus>[],
       uploadResult =
           uploadResult ??
           const DriveSyncRunResult.noChanges(DriveSyncStatus.signedOut()),
       restoreResult =
           restoreResult ??
           const DriveSyncRunResult.noChanges(DriveSyncStatus.signedOut());

  final DriveSyncStatus loadStatusResult;
  final List<DriveSyncStatus> _loadStatusResults;
  final DriveSyncRunResult uploadResult;
  final DriveSyncRunResult restoreResult;
  final Future<DriveSyncRunResult>? restoreFuture;
  Object? loadStatusError;
  int uploadLocalCount = 0;
  int restoreDriveCount = 0;

  @override
  Future<DriveSyncStatus> loadStatus() async {
    final error = loadStatusError;
    if (error != null) {
      throw error;
    }
    if (_loadStatusResults.isNotEmpty) {
      return _loadStatusResults.removeAt(0);
    }
    return loadStatusResult;
  }

  @override
  Future<DriveSyncRunResult> uploadLocalSnapshot() async {
    uploadLocalCount += 1;
    return uploadResult;
  }

  @override
  Future<DriveSyncRunResult> restoreDriveSnapshot() async {
    restoreDriveCount += 1;
    final future = restoreFuture;
    if (future != null) {
      return future;
    }
    return restoreResult;
  }
}

final class _FakeDriveSyncRuntimeEffects implements DriveSyncRuntimeEffects {
  final List<DriveSyncRestoreEffect> effects = <DriveSyncRestoreEffect>[];

  @override
  Future<void> apply(DriveSyncRestoreEffect effect) async {
    effects.add(effect);
  }
}

DriveSyncRemoteSnapshot _remoteSnapshot() => const DriveSyncRemoteSnapshot(
  manifest: DriveSyncManifest(
    manifestVersion: DriveSyncManifest.currentManifestVersion,
    snapshotFormatVersion: DriveSyncManifest.currentSnapshotFormatVersion,
    appId: DriveSyncManifest.currentAppId,
    appDatabaseSchemaVersion: 6,
    createdAt: 1,
    deviceId: 'remote-device',
    deviceLabel: 'Remote device',
    databaseSha256: 'db',
    settingsSha256: 'settings',
    snapshotSizeBytes: 2,
  ),
  manifestFileId: 'manifest-file',
  manifestFileVersion: 'manifest-version',
  snapshotFileId: 'snapshot-file',
  snapshotFileVersion: 'snapshot-version',
  modifiedAt: 1,
);
