import 'package:flutter/material.dart';

/// Centralized color tokens used by the MemoX themes.
///
/// Naming is intentionally split:
/// - `light*` tokens apply to the light theme only
/// - unprefixed tokens are kept for the dark theme and shared dark-safe
///   semantics
///
/// Keep only tokens that are actively consumed by `light_theme.dart`,
/// `dark_theme.dart`, or `theme_extensions.dart`.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Light-theme palette
  // ---------------------------------------------------------------------------

  // Brand / seed colors approved for light mode.
  static const Color lightPrimary10 = Color(0xFF121C52);
  static const Color lightPrimary40 = Color(0xFF24389C);
  static const Color lightPrimary70 = Color(0xFF9EACE0);
  static const Color lightPrimary90 = Color(0xFFE1E6F7);
  static const Color lightPrimary100 = Color(0xFFFFFFFF);

  static const Color lightSecondary20 = Color(0xFF6E4A0B);
  static const Color lightSecondary50 = Color(0xFFFFB74D);
  static const Color lightSecondary95 = Color(0xFFFFF3DE);

  static const Color lightTertiary20 = Color(0xFF1D5F58);
  static const Color lightTertiary40 = Color(0xFF4DB6AC);
  static const Color lightTertiary90 = Color(0xFFD8F2EF);

  static const Color lightError20 = Color(0xFF410002);
  static const Color lightError50 = Color(0xFFBA1A1A);
  static const Color lightError95 = Color(0xFFFFDAD6);

  // Light surfaces from the latest palette spec.
  static const Color lightSurface = Color(0xFFF7F9FB);
  static const Color lightSurfaceBright = Color(0xFFF7F9FB);
  static const Color lightSurfaceDim = Color(0xFFE0E3E5);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF2F4F6);
  static const Color lightSurfaceContainer = Color(0xFFECEEF0);
  static const Color lightSurfaceContainerHigh = Color(0xFFE6E8EA);
  static const Color lightSurfaceContainerHighest = Color(0xFFE0E3E5);

  static const Color lightNeutral10 = Color(0xFF191C1E);
  static const Color lightNeutral20 = Color(0xFF2E3133);
  static const Color lightNeutral40 = Color(0xFF454652);
  static const Color lightNeutralVariant60 = Color(0xFF757684);
  static const Color lightNeutralVariant90 = Color(0xFFC5C5D4);

  static const Color lightSuccess30 = lightTertiary20;
  static const Color lightSuccess60 = lightTertiary40;
  static const Color lightSuccess95 = lightTertiary90;

  static const Color lightWarning30 = lightSecondary20;
  static const Color lightWarning50 = lightSecondary50;
  static const Color lightWarning95 = lightSecondary95;

  static const Color lightInfo30 = lightPrimary10;
  static const Color lightInfo50 = lightPrimary40;
  static const Color lightInfo95 = lightPrimary90;

  static const Color lightMastery = Color(0xFF004E1A);
  static const Color lightStreak = Color(0xFFF97316);

  static const Color lightRatingAgain = Color(0xFFE57373);
  static const Color lightRatingHard = lightWarning50;
  static const Color lightRatingGood = lightSuccess60;
  static const Color lightRatingEasy = lightMastery;

  // ---------------------------------------------------------------------------
  // Dark-theme palette
  // ---------------------------------------------------------------------------

  static const Color primary20 = Color(0xFF2B2596);
  static const Color primary30 = Color(0xFF3F36BD);
  static const Color primary40 = Color(0xFF4F46E5);
  static const Color primary70 = Color(0xFFA5B4FC);
  static const Color primary90 = Color(0xFFE0E7FF);

  static const Color secondary20 = Color(0xFF78350F);
  static const Color secondary30 = Color(0xFF92400E);
  static const Color secondary70 = Color(0xFFFBBF24);
  static const Color secondary90 = Color(0xFFFDE68A);

  static const Color tertiary20 = Color(0xFF115E59);
  static const Color tertiary30 = Color(0xFF0F766E);
  static const Color tertiary70 = Color(0xFF5EEAD4);
  static const Color tertiary90 = Color(0xFFCCFBF1);

  static const Color error20 = Color(0xFF7F1D1D);
  static const Color error30 = Color(0xFF991B1B);
  static const Color error80 = Color(0xFFFCA5A5);
  static const Color error90 = Color(0xFFFECACA);

  static const Color neutral10 = Color(0xFF111218);
  static const Color neutral70 = Color(0xFFA8AAB8);
  static const Color neutral90 = Color(0xFFE4E5EC);
  static const Color neutral95 = Color(0xFFF2F3F7);

  static const Color darkNavy5 = Color(0xFF080B22);
  static const Color darkNavy10 = Color(0xFF0A0E27);
  static const Color darkNavy15 = Color(0xFF11162F);
  static const Color darkNavy20 = Color(0xFF161C38);
  static const Color darkNavy25 = Color(0xFF1B2242);
  static const Color darkNavy30 = Color(0xFF22294F);
  static const Color darkNavy40 = Color(0xFF2E3660);
  static const Color darkNavyOutline = Color(0xFF2A3157);
  static const Color darkNavyOutlineVariant = Color(0xFF1F2646);

  static const Color success30 = Color(0xFF14532D);
  static const Color success60 = Color(0xFF22C55E);
  static const Color success90 = Color(0xFFBBF7D0);

  static const Color warning30 = Color(0xFF854D0E);
  static const Color warning60 = Color(0xFFFACC15);
  static const Color warning90 = Color(0xFFFEF08A);

  static const Color info30 = Color(0xFF1E40AF);
  static const Color info60 = Color(0xFF60A5FA);
  static const Color info90 = Color(0xFFBFDBFE);

  static const Color ratingAgain = Color(0xFFEF4444);
  static const Color ratingHard = Color(0xFFF59E0B);
  static const Color ratingGood = Color(0xFF22C55E);
  static const Color ratingEasy = Color(0xFF14B8A6);
}
