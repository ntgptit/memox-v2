import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

/// Single entry point for the MemoX theme system.
///
/// Consumers outside `lib/core/theme/**` should import concrete token files
/// directly (e.g. `app_spacing.dart`, `app_radius.dart`) and pick the active
/// colors / typography from `Theme.of(context)` at render time.
abstract final class AppTheme {
  static ThemeData light() => buildLightTheme();
  static ThemeData dark() => buildDarkTheme();
}
