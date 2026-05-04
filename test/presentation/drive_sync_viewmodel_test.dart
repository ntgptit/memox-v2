import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/sync_providers.dart';
import 'package:memox/app/services/drive_sync_runtime_effects.dart';
import 'package:memox/domain/entities/drive_sync_models.dart';
import 'package:memox/domain/repositories/drive_sync_repository.dart';
import 'package:memox/presentation/features/settings/viewmodels/drive_sync_settings_viewmodel.dart';

void main() {
  test('DT1 loading: maps signed-out repository status', () async {
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

  test('DT2 onSync: sync upload result becomes uploaded message', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
      syncResult: DriveSyncRunResult.uploadedLocal(
        const DriveSyncStatus(kind: DriveSyncStatusKind.synced),
      ),
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    await container.read(driveSyncSettingsControllerProvider.future);
    await container
        .read(driveSyncSettingsControllerProvider.notifier)
        .syncNow();

    final state = container.read(driveSyncSettingsControllerProvider).value!;
    expect(repository.syncNowCount, 1);
    expect(state.kind, DriveSyncStatusKind.synced);
    expect(state.message, DriveSyncSettingsMessage.uploaded);
  });

  test('DT13 onUploadLocal: upload command exposes uploaded message', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
      uploadResult: DriveSyncRunResult.uploadedLocal(
        const DriveSyncStatus(kind: DriveSyncStatusKind.synced),
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
  });

  test('DT14 onRestoreDrive: restore command applies restore effect', () async {
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

  test(
    'DT15 onRestoreDrive: restore command is disabled without remote snapshot',
    () async {
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
    },
  );

  test(
    'DT3 onSync: sync result stores pending conflict for UI sheet',
    () async {
      final conflict = _conflict();
      final repository = _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus(
          kind: DriveSyncStatusKind.ready,
        ),
        syncResult: DriveSyncRunResult.conflict(
          DriveSyncStatus(
            kind: DriveSyncStatusKind.conflict,
            conflict: conflict,
            remote: conflict.remote,
          ),
          conflict,
        ),
      );
      final container = _container(repository: repository);
      addTearDown(container.dispose);

      await container.read(driveSyncSettingsControllerProvider.future);
      await container
          .read(driveSyncSettingsControllerProvider.notifier)
          .syncNow();

      final state = container.read(driveSyncSettingsControllerProvider).value!;
      expect(state.kind, DriveSyncStatusKind.conflict);
      expect(state.pendingConflict, same(conflict));
      expect(state.message, DriveSyncSettingsMessage.none);
    },
  );

  test(
    'DT4 onResolve: resolving with Drive copy applies restore effect',
    () async {
      final conflict = _conflict();
      final effects = _FakeDriveSyncRuntimeEffects();
      final repository = _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus(
          kind: DriveSyncStatusKind.ready,
        ),
        syncResult: DriveSyncRunResult.conflict(
          DriveSyncStatus(
            kind: DriveSyncStatusKind.conflict,
            conflict: conflict,
            remote: conflict.remote,
          ),
          conflict,
        ),
        resolveResult: DriveSyncRunResult.restoredRemote(
          DriveSyncStatus(
            kind: DriveSyncStatusKind.synced,
            remote: conflict.remote,
          ),
          DriveSyncRestoreEffect.refreshDatabaseProvider,
        ),
      );
      final container = _container(repository: repository, effects: effects);
      addTearDown(container.dispose);

      await container.read(driveSyncSettingsControllerProvider.future);
      await container
          .read(driveSyncSettingsControllerProvider.notifier)
          .syncNow();
      await container
          .read(driveSyncSettingsControllerProvider.notifier)
          .resolveConflict(DriveSyncConflictChoice.useDriveCopy);

      final state = container.read(driveSyncSettingsControllerProvider).value!;
      expect(repository.lastChoice, DriveSyncConflictChoice.useDriveCopy);
      expect(effects.effects, <DriveSyncRestoreEffect>[
        DriveSyncRestoreEffect.refreshDatabaseProvider,
      ]);
      expect(state.kind, DriveSyncStatusKind.synced);
      expect(state.message, DriveSyncSettingsMessage.restored);
    },
  );

  test('DT5 onSync: reconnect-required state does not start sync', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.needsDriveAuthorization(),
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    await container.read(driveSyncSettingsControllerProvider.future);
    await container
        .read(driveSyncSettingsControllerProvider.notifier)
        .syncNow();

    expect(repository.syncNowCount, 0);
  });

  test('DT6 onRefreshRetry: refresh after reconnect enables sync', () async {
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

  test(
    'DT11 onRefreshRetry: unexpected refresh error becomes failure state',
    () async {
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
      expect(
        container.read(driveSyncSettingsControllerProvider).hasError,
        isFalse,
      );
    },
  );

  test('DT7 loading: failure status keeps technical message', () async {
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

  test(
    'DT9 loading: unexpected load error becomes retryable failure state',
    () async {
      final repository = _FakeDriveSyncRepository(
        loadStatusError: StateError('sync provider unavailable'),
      );
      final container = _container(repository: repository);
      addTearDown(container.dispose);

      final state = await container.read(
        driveSyncSettingsControllerProvider.future,
      );

      expect(state.kind, DriveSyncStatusKind.failure);
      expect(state.canSync, isTrue);
      expect(state.technicalMessage, 'Bad state: sync provider unavailable');
      expect(
        container.read(driveSyncSettingsControllerProvider).hasError,
        isFalse,
      );
    },
  );

  test('DT8 onSync: failure status can retry sync', () async {
    final repository = _FakeDriveSyncRepository(
      loadStatusResult: const DriveSyncStatus.failure(
        'Google Drive API is disabled.',
      ),
      syncResult: DriveSyncRunResult.uploadedLocal(
        const DriveSyncStatus(kind: DriveSyncStatusKind.synced),
      ),
    );
    final container = _container(repository: repository);
    addTearDown(container.dispose);

    await container.read(driveSyncSettingsControllerProvider.future);
    await container
        .read(driveSyncSettingsControllerProvider.notifier)
        .syncNow();
    final state = container.read(driveSyncSettingsControllerProvider).value!;

    expect(repository.syncNowCount, 1);
    expect(state.kind, DriveSyncStatusKind.synced);
    expect(state.message, DriveSyncSettingsMessage.uploaded);
  });

  test(
    'DT10 onSync: unexpected sync error becomes visible failure state',
    () async {
      final repository = _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus.noRemoteSnapshot(),
        syncError: StateError('Drive client failed before request'),
      );
      final container = _container(repository: repository);
      addTearDown(container.dispose);

      await container.read(driveSyncSettingsControllerProvider.future);
      await container
          .read(driveSyncSettingsControllerProvider.notifier)
          .syncNow();
      final state = container.read(driveSyncSettingsControllerProvider).value!;

      expect(repository.syncNowCount, 1);
      expect(state.kind, DriveSyncStatusKind.failure);
      expect(state.message, DriveSyncSettingsMessage.failed);
      expect(state.isBusy, isFalse);
      expect(
        state.technicalMessage,
        'Bad state: Drive client failed before request',
      );
    },
  );

  test(
    'DT12 onResolve: unexpected resolve error becomes visible failure state',
    () async {
      final conflict = _conflict();
      final repository = _FakeDriveSyncRepository(
        loadStatusResult: const DriveSyncStatus(
          kind: DriveSyncStatusKind.ready,
        ),
        syncResult: DriveSyncRunResult.conflict(
          DriveSyncStatus(
            kind: DriveSyncStatusKind.conflict,
            conflict: conflict,
            remote: conflict.remote,
          ),
          conflict,
        ),
        resolveError: StateError('restore effect failed'),
      );
      final container = _container(repository: repository);
      addTearDown(container.dispose);

      await container.read(driveSyncSettingsControllerProvider.future);
      await container
          .read(driveSyncSettingsControllerProvider.notifier)
          .syncNow();
      await container
          .read(driveSyncSettingsControllerProvider.notifier)
          .resolveConflict(DriveSyncConflictChoice.useDriveCopy);
      final state = container.read(driveSyncSettingsControllerProvider).value!;

      expect(repository.lastChoice, DriveSyncConflictChoice.useDriveCopy);
      expect(state.kind, DriveSyncStatusKind.failure);
      expect(state.message, DriveSyncSettingsMessage.failed);
      expect(state.technicalMessage, 'Bad state: restore effect failed');
    },
  );
}

ProviderContainer _container({
  required _FakeDriveSyncRepository repository,
  _FakeDriveSyncRuntimeEffects? effects,
}) {
  return ProviderContainer(
    overrides: [
      driveSyncRepositoryProvider.overrideWith((ref) async => repository),
      driveSyncRuntimeEffectsProvider.overrideWithValue(
        effects ?? _FakeDriveSyncRuntimeEffects(),
      ),
    ],
  );
}

final class _FakeDriveSyncRepository implements DriveSyncRepository {
  _FakeDriveSyncRepository({
    DriveSyncStatus? loadStatusResult,
    List<DriveSyncStatus>? loadStatusResults,
    DriveSyncRunResult? syncResult,
    DriveSyncRunResult? uploadResult,
    DriveSyncRunResult? restoreResult,
    DriveSyncRunResult? resolveResult,
    this.loadStatusError,
    this.syncError,
    this.resolveError,
  }) : loadStatusResult = loadStatusResult ?? const DriveSyncStatus.signedOut(),
       _loadStatusResults = loadStatusResults?.toList() ?? <DriveSyncStatus>[],
       syncResult =
           syncResult ??
           DriveSyncRunResult.noChanges(const DriveSyncStatus.signedOut()),
       uploadResult =
           uploadResult ??
           DriveSyncRunResult.noChanges(const DriveSyncStatus.signedOut()),
       restoreResult =
           restoreResult ??
           DriveSyncRunResult.noChanges(const DriveSyncStatus.signedOut()),
       resolveResult =
           resolveResult ??
           DriveSyncRunResult.canceled(const DriveSyncStatus.ready());

  final DriveSyncStatus loadStatusResult;
  final List<DriveSyncStatus> _loadStatusResults;
  final DriveSyncRunResult syncResult;
  final DriveSyncRunResult uploadResult;
  final DriveSyncRunResult restoreResult;
  final DriveSyncRunResult resolveResult;
  Object? loadStatusError;
  final Object? syncError;
  final Object? resolveError;
  int syncNowCount = 0;
  int uploadLocalCount = 0;
  int restoreDriveCount = 0;
  DriveSyncConflictChoice? lastChoice;

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
  Future<DriveSyncRunResult> syncNow() async {
    syncNowCount += 1;
    final error = syncError;
    if (error != null) {
      throw error;
    }
    return syncResult;
  }

  @override
  Future<DriveSyncRunResult> uploadLocalSnapshot() async {
    uploadLocalCount += 1;
    return uploadResult;
  }

  @override
  Future<DriveSyncRunResult> restoreDriveSnapshot() async {
    restoreDriveCount += 1;
    return restoreResult;
  }

  @override
  Future<DriveSyncRunResult> resolveConflict(
    DriveSyncConflict conflict,
    DriveSyncConflictChoice choice,
  ) async {
    lastChoice = choice;
    final error = resolveError;
    if (error != null) {
      throw error;
    }
    return resolveResult;
  }
}

final class _FakeDriveSyncRuntimeEffects implements DriveSyncRuntimeEffects {
  final List<DriveSyncRestoreEffect> effects = <DriveSyncRestoreEffect>[];

  @override
  Future<void> apply(DriveSyncRestoreEffect effect) async {
    effects.add(effect);
  }
}

DriveSyncConflict _conflict() {
  return DriveSyncConflict(
    localFingerprint: 'local',
    remote: _remoteSnapshot(),
    reason: 'test conflict',
  );
}

DriveSyncRemoteSnapshot _remoteSnapshot() {
  return DriveSyncRemoteSnapshot(
    manifest: const DriveSyncManifest(
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
}
