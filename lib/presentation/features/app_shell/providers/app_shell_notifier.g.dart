// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_shell_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Currently selected tab index in the root [AppShell].
///
/// Lives at app level (not inside a feature) because tab state is
/// cross-feature and has to survive when features rebuild.
///
/// Index contract (see `AppShell._destinations`):
/// 0 Home · 1 Library · 2 Progress · 3 Settings.

@ProviderFor(AppShellNotifier)
final appShellProvider = AppShellNotifierProvider._();

/// Currently selected tab index in the root [AppShell].
///
/// Lives at app level (not inside a feature) because tab state is
/// cross-feature and has to survive when features rebuild.
///
/// Index contract (see `AppShell._destinations`):
/// 0 Home · 1 Library · 2 Progress · 3 Settings.
final class AppShellNotifierProvider
    extends $NotifierProvider<AppShellNotifier, int> {
  /// Currently selected tab index in the root [AppShell].
  ///
  /// Lives at app level (not inside a feature) because tab state is
  /// cross-feature and has to survive when features rebuild.
  ///
  /// Index contract (see `AppShell._destinations`):
  /// 0 Home · 1 Library · 2 Progress · 3 Settings.
  AppShellNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appShellProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appShellNotifierHash();

  @$internal
  @override
  AppShellNotifier create() => AppShellNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$appShellNotifierHash() => r'c693f5ca4cfacd04f5fc106985c49f1f32395825';

/// Currently selected tab index in the root [AppShell].
///
/// Lives at app level (not inside a feature) because tab state is
/// cross-feature and has to survive when features rebuild.
///
/// Index contract (see `AppShell._destinations`):
/// 0 Home · 1 Library · 2 Progress · 3 Settings.

abstract class _$AppShellNotifier extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
