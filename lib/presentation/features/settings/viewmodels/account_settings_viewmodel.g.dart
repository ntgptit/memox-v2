// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_settings_viewmodel.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AccountSettingsController)
final accountSettingsControllerProvider = AccountSettingsControllerProvider._();

final class AccountSettingsControllerProvider
    extends
        $AsyncNotifierProvider<
          AccountSettingsController,
          AccountSettingsState
        > {
  AccountSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountSettingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountSettingsControllerHash();

  @$internal
  @override
  AccountSettingsController create() => AccountSettingsController();
}

String _$accountSettingsControllerHash() =>
    r'fc69787cef256fd5bbd5726c3daabbcc8095a3a1';

abstract class _$AccountSettingsController
    extends $AsyncNotifier<AccountSettingsState> {
  FutureOr<AccountSettingsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<AccountSettingsState>, AccountSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AccountSettingsState>,
                AccountSettingsState
              >,
              AsyncValue<AccountSettingsState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
