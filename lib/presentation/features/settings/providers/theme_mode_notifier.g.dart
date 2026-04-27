// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide theme mode. Drives `MaterialApp.themeMode` through
/// [MemoxApp]. Default is [ThemeMode.system] so the platform choice
/// wins until the user overrides it in settings.
///
/// Kept as a plain [Notifier] (synchronous) — persistence will be
/// layered on later via a `SharedPreferences` datasource. When that
/// happens, swap this to `AsyncNotifier` + hydrate in `build()`.

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

/// App-wide theme mode. Drives `MaterialApp.themeMode` through
/// [MemoxApp]. Default is [ThemeMode.system] so the platform choice
/// wins until the user overrides it in settings.
///
/// Kept as a plain [Notifier] (synchronous) — persistence will be
/// layered on later via a `SharedPreferences` datasource. When that
/// happens, swap this to `AsyncNotifier` + hydrate in `build()`.
final class ThemeModeNotifierProvider
    extends $NotifierProvider<ThemeModeNotifier, ThemeMode> {
  /// App-wide theme mode. Drives `MaterialApp.themeMode` through
  /// [MemoxApp]. Default is [ThemeMode.system] so the platform choice
  /// wins until the user overrides it in settings.
  ///
  /// Kept as a plain [Notifier] (synchronous) — persistence will be
  /// layered on later via a `SharedPreferences` datasource. When that
  /// happens, swap this to `AsyncNotifier` + hydrate in `build()`.
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeNotifierHash() => r'308354cf18c193d19608a6be527a4c1246df8340';

/// App-wide theme mode. Drives `MaterialApp.themeMode` through
/// [MemoxApp]. Default is [ThemeMode.system] so the platform choice
/// wins until the user overrides it in settings.
///
/// Kept as a plain [Notifier] (synchronous) — persistence will be
/// layered on later via a `SharedPreferences` datasource. When that
/// happens, swap this to `AsyncNotifier` + hydrate in `build()`.

abstract class _$ThemeModeNotifier extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ThemeMode, ThemeMode>,
              ThemeMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
