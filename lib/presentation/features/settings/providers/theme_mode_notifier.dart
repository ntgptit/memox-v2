import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_notifier.g.dart';

/// App-wide theme mode. Drives `MaterialApp.themeMode` through
/// [MemoxApp]. Default is [ThemeMode.system] so the platform choice
/// wins until the user overrides it in settings.
///
/// Kept as a plain [Notifier] (synchronous) — persistence will be
/// layered on later via a `SharedPreferences` datasource. When that
/// happens, swap this to `AsyncNotifier` + hydrate in `build()`.
@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  ThemeMode build() => ThemeMode.system;

  void set(ThemeMode mode) => state = mode;

  void toggle() {
    state = switch (state) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.dark,
    };
  }
}
