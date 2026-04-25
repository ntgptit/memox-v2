import 'package:flutter/material.dart';

import 'schemes/dark_theme.dart';
import 'schemes/light_theme.dart';

/// Single entry point for the MemoX theme system.
///
/// Consumers outside `lib/core/theme/**` should import concrete token files
/// directly (e.g. `tokens/app_spacing.dart`, `tokens/app_radius.dart`) and
/// pick the active colors / typography from `Theme.of(context)` at render time.
abstract final class AppTheme {
  static ThemeData light() => buildLightTheme();
  static ThemeData dark() => buildDarkTheme();
}
