import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/sync_providers.dart';
import '../../../../core/errors/error_mapper.dart';
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
    this.message = DriveSyncSettingsMessage.none,
    this.isBusy = false,
    this.technicalMessage,
  });

  final DriveSyncStatus status;
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
          kind == DriveSyncStatusKind.localChanges ||
          kind == DriveSyncStatusKind.remoteChanges ||
          kind == DriveSyncStatusKind.failure);

  bool get canUploadLocal => canSync;

  bool get canRestoreDrive => canSync && status.remote != null;

  DriveSyncSettingsState copyWith({
    DriveSyncStatus? status,
    DriveSyncSettingsMessage? message,
    bool? isBusy,
    String? technicalMessage,
    bool clearTechnicalMessage = false,
  }) => DriveSyncSettingsState(
    status: status ?? this.status,
    message: message ?? this.message,
    isBusy: isBusy ?? this.isBusy,
    technicalMessage: clearTechnicalMessage
        ? null
        : technicalMessage ?? this.technicalMessage,
  );
}

@riverpod
class DriveSyncSettingsController extends _$DriveSyncSettingsController {
  @override
  Future<DriveSyncSettingsState> build() async {
    try {
      final useCase = await ref.watch(
        loadDriveSyncStatusUseCaseProvider.future,
      );
      final status = await useCase.execute();
      return _stateFromStatus(status);
    } on Object catch (error) {
      return _stateFromUnexpectedError(error);
    }
  }

  Future<void> refresh() async {
    try {
      final useCase = await ref.read(loadDriveSyncStatusUseCaseProvider.future);
      final status = await useCase.execute();
      if (!ref.mounted) {
        return;
      }
      state = AsyncData(_stateFromStatus(status));
    } on Object catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = AsyncData(_stateFromUnexpectedError(error));
    }
  }

  Future<void> uploadLocalToDrive() async {
    await _runDirectedSync(
      canRun: (state) => state.canUploadLocal,
      action: () async {
        final useCase = await ref.read(
          uploadLocalDriveSnapshotUseCaseProvider.future,
        );
        return useCase.execute();
      },
    );
  }

  Future<void> restoreDriveToLocal() async {
    await _runDirectedSync(
      canRun: (state) => state.canRestoreDrive,
      action: () async {
        final useCase = await ref.read(
          restoreDriveSnapshotUseCaseProvider.future,
        );
        return useCase.execute();
      },
    );
  }

  Future<void> _runDirectedSync({
    required bool Function(DriveSyncSettingsState state) canRun,
    required Future<DriveSyncRunResult> Function() action,
  }) async {
    final current = state.value;
    if (current == null || !canRun(current)) {
      return;
    }
    state = AsyncData(current.copyWith(isBusy: true));
    try {
      final result = await action();
      await _applyResult(result);
    } on Object catch (error) {
      if (!ref.mounted) {
        return;
      }
      state = AsyncData(
        _stateFromUnexpectedError(
          error,
          message: DriveSyncSettingsMessage.failed,
        ),
      );
    }
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

  DriveSyncSettingsState _stateFromResult(
    DriveSyncRunResult result,
  ) => DriveSyncSettingsState(
    status: result.status,
    message: switch (result.kind) {
      DriveSyncActionKind.uploadedLocal => DriveSyncSettingsMessage.uploaded,
      DriveSyncActionKind.restoredRemote => DriveSyncSettingsMessage.restored,
      DriveSyncActionKind.noChanges => DriveSyncSettingsMessage.noChanges,
      DriveSyncActionKind.canceled => DriveSyncSettingsMessage.canceled,
      DriveSyncActionKind.failed => DriveSyncSettingsMessage.failed,
      DriveSyncActionKind.none => DriveSyncSettingsMessage.none,
    },
    technicalMessage: result.message ?? result.status.message,
  );

  DriveSyncSettingsState _stateFromStatus(DriveSyncStatus status) =>
      DriveSyncSettingsState(status: status, technicalMessage: status.message);

  DriveSyncSettingsState _stateFromUnexpectedError(
    Object error, {
    DriveSyncSettingsMessage message = DriveSyncSettingsMessage.none,
  }) {
    final diagnostic = _diagnosticFrom(error);
    return DriveSyncSettingsState(
      status: DriveSyncStatus.failure(diagnostic),
      message: message,
      technicalMessage: diagnostic,
    );
  }

  String _diagnosticFrom(Object error) {
    final failure = ErrorMapper.map(error);
    return failure.technicalDetails ?? failure.message;
  }
}
