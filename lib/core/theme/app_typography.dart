import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_breakpoints.dart';

/// MemoX typography — Material 3 type scale, tuned for readable flashcards.
///
/// Uses Plus Jakarta Sans as the single app-wide sans family. The package
/// dependency is resolved centrally here so feature code keeps consuming
/// `Theme.of(context).textTheme.*` without local font overrides.
abstract final class AppTypography {
  static const String fontFamily = 'Plus Jakarta Sans';
  static const String? monoFontFamily = null;

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 64 / 57,
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 52 / 45,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 44 / 36,
    letterSpacing: 0,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 40 / 32,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    letterSpacing: 0,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 28 / 22,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.1,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: 0.4,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 16 / 11,
    letterSpacing: 0.5,
  );

  /// The full [TextTheme] used to build [ThemeData.textTheme]. Mobile-first
  /// base scale — wider windows get a tier-aware rescale via [scaledTextTheme].
  static const TextTheme _baseTextTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );

  static TextTheme get textTheme =>
      GoogleFonts.plusJakartaSansTextTheme(_baseTextTheme);

  // ---------------------------------------------------------------------------
  // Responsive scaling
  //
  // Body / label sizes stay FIXED across tiers — accessibility and legibility
  // demand that body copy is the same physical size on phone and desktop.
  // Only display / headline / title roles scale up, because large viewports
  // benefit from a stronger visual hierarchy for hero content.
  //
  // Applied once at app-shell build time (see `MemoxApp.build`) via a
  // `MaterialApp.builder` that wraps the child in a `Theme(...)` overlay.
  // Features do not call these helpers directly.
  // ---------------------------------------------------------------------------

  /// Multiplier for display / headline / title roles per [WindowSize].
  /// Compact = 1.0 (unchanged). Scales modestly — Material 3 type ramp is
  /// already high-contrast, so 10–15% is enough to feel "desktop-y".
  static double displayScale(WindowSize size) {
    switch (size) {
      case WindowSize.compact:
      case WindowSize.medium:
        return 1.0;
      case WindowSize.expanded:
        return 1.06;
      case WindowSize.large:
        return 1.12;
      case WindowSize.extraLarge:
        return 1.18;
    }
  }

  /// Returns a [TextTheme] with display/headline/title scaled for [size].
  /// Body and label styles are returned unchanged.
  static TextTheme scaledTextTheme(TextTheme base, WindowSize size) {
    final factor = displayScale(size);
    if (factor == 1.0) return base;
    TextStyle? scale(TextStyle? s) =>
        s?.copyWith(fontSize: (s.fontSize ?? 14) * factor);
    return base.copyWith(
      displayLarge: scale(base.displayLarge),
      displayMedium: scale(base.displayMedium),
      displaySmall: scale(base.displaySmall),
      headlineLarge: scale(base.headlineLarge),
      headlineMedium: scale(base.headlineMedium),
      headlineSmall: scale(base.headlineSmall),
      titleLarge: scale(base.titleLarge),
      // titleMedium / titleSmall stay at body-adjacent sizes — don't scale.
    );
  }
}
