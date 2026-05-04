// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drive_sync_settings_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DriveSyncSettingsController)
final driveSyncSettingsControllerProvider =
    DriveSyncSettingsControllerProvider._();

final class DriveSyncSettingsControllerProvider
    extends
        $AsyncNotifierProvider<
          DriveSyncSettingsController,
          DriveSyncSettingsState
        > {
  DriveSyncSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driveSyncSettingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driveSyncSettingsControllerHash();

  @$internal
  @override
  DriveSyncSettingsController create() => DriveSyncSettingsController();
}

String _$driveSyncSettingsControllerHash() =>
    r'8f084b2174fb56adb6f4c087455353707b2b1b78';

abstract class _$DriveSyncSettingsController
    extends $AsyncNotifier<DriveSyncSettingsState> {
  FutureOr<DriveSyncSettingsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<DriveSyncSettingsState>, DriveSyncSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<DriveSyncSettingsState>,
                DriveSyncSettingsState
              >,
              AsyncValue<DriveSyncSettingsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
