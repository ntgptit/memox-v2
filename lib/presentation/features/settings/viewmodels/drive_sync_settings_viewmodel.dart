import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/sync_providers.dart';
import '../../../../domain/entities/drive_sync_models.dart';

part 'drive_sync_settings_viewmodel.g.dart';

enum DriveSyncSettingsMessage {
  none,
  uploaded,
  restored,
  noChanges,
  canceled,
  failed,
}

final class DriveSyncSettingsState {
  const DriveSyncSettingsState({
    required this.status,
    this.pendingConflict,
    this.message = DriveSyncSettingsMessage.none,
    this.isBusy = false,
    this.technicalMessage,
  });

  final DriveSyncStatus status;
  final DriveSyncConflict? pendingConflict;
  final DriveSyncSettingsMessage message;
  final bool isBusy;
  final String? technicalMessage;

  DriveSyncStatusKind get kind => status.kind;

  int? get lastSyncedAt => status.lastSyncedAt;

  String? get remoteDeviceLabel => status.remote?.manifest.deviceLabel;

  bool get canSync =>
      !isBusy &&
      (kind == DriveSyncStatusKind.ready ||
          kind == DriveSyncStatusKind.noRemoteSnapshot ||
          kind == DriveSyncStatusKind.synced ||
          kind == DriveSyncStatusKind.localChanges ||
          kind == DriveSyncStatusKind.remoteChanges ||
          kind == DriveSyncStatusKind.failure);

  DriveSyncSettingsState copyWith({
    DriveSyncStatus? status,
    DriveSyncConflict? pendingConflict,
    bool clearPendingConflict = false,
    DriveSyncSettingsMessage? message,
    bool? isBusy,
    String? technicalMessage,
    bool clearTechnicalMessage = false,
  }) {
    return DriveSyncSettingsState(
      status: status ?? this.status,
      pendingConflict: clearPendingConflict
          ? null
          : pendingConflict ?? this.pendingConflict,
      message: message ?? this.message,
      isBusy: isBusy ?? this.isBusy,
      technicalMessage: clearTechnicalMessage
          ? null
          : technicalMessage ?? this.technicalMessage,
    );
  }
}

@riverpod
class DriveSyncSettingsController extends _$DriveSyncSettingsController {
  @override
  Future<DriveSyncSettingsState> build() async {
    final useCase = await ref.watch(loadDriveSyncStatusUseCaseProvider.future);
    final status = await useCase.execute();
    return _stateFromStatus(status);
  }

  Future<void> refresh() async {
    // guard:retry-reviewed
    final useCase = await ref.read(loadDriveSyncStatusUseCaseProvider.future);
    final status = await useCase.execute();
    if (!ref.mounted) {
      return;
    }
    state = AsyncData(_stateFromStatus(status));
  }

  Future<void> syncNow() async {
    // guard:retry-reviewed
    final current = state.value;
    if (current == null || !current.canSync) {
      return;
    }
    state = AsyncData(current.copyWith(isBusy: true));
    final useCase = await ref.read(
      syncGoogleDriveSnapshotUseCaseProvider.future,
    );
    final result = await useCase.execute();
    await _applyResult(result);
  }

  Future<void> resolveConflict(DriveSyncConflictChoice choice) async {
    // guard:retry-reviewed
    final current = state.value;
    final conflict = current?.pendingConflict;
    if (current == null || conflict == null || current.isBusy) {
      return;
    }
    state = AsyncData(current.copyWith(isBusy: true));
    final useCase = await ref.read(
      resolveDriveSyncConflictUseCaseProvider.future,
    );
    final result = await useCase.execute(conflict, choice);
    await _applyResult(result);
  }

  Future<void> _applyResult(DriveSyncRunResult result) async {
    if (result.restoreEffect != DriveSyncRestoreEffect.none) {
      await ref
          .read(driveSyncRuntimeEffectsProvider)
          .apply(result.restoreEffect);
    }
    if (!ref.mounted) {
      return;
    }
    state = AsyncData(_stateFromResult(result));
  }

  DriveSyncSettingsState _stateFromResult(DriveSyncRunResult result) {
    return DriveSyncSettingsState(
      status: result.status,
      pendingConflict: result.conflict,
      message: switch (result.kind) {
        DriveSyncActionKind.uploadedLocal => DriveSyncSettingsMessage.uploaded,
        DriveSyncActionKind.restoredRemote => DriveSyncSettingsMessage.restored,
        DriveSyncActionKind.noChanges => DriveSyncSettingsMessage.noChanges,
        DriveSyncActionKind.canceled => DriveSyncSettingsMessage.canceled,
        DriveSyncActionKind.failed => DriveSyncSettingsMessage.failed,
        DriveSyncActionKind.needsConflictResolution =>
          DriveSyncSettingsMessage.none,
        DriveSyncActionKind.none => DriveSyncSettingsMessage.none,
      },
      technicalMessage: result.message ?? result.status.message,
    );
  }

  DriveSyncSettingsState _stateFromStatus(DriveSyncStatus status) {
    return DriveSyncSettingsState(
      status: status,
      technicalMessage: status.message,
    );
  }
}
