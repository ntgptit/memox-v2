import 'package:flutter/material.dart';

/// Centralized color tokens used by the MemoX themes.
///
/// Naming split:
/// - `light*` tokens apply to the light theme only
/// - unprefixed tokens belong to the dark theme
///
/// Tone numbers are consistent within each brightness so dev can
/// predict the palette without checking: light role palettes use
/// `{10, 40, 90}` (+ `100` = white on primary); dark role palettes use
/// `{20, 30, 80, 90}`. Neutral and `darkNavy*` scales are independent
/// by design.
///
/// Every token declared here must have at least one active consumer
/// (theme scheme builder or `MxColorsExtension`). When adding a new
/// role, wire the consumer first. Semantic tokens (success / warning /
/// info / rating / mastery / streak) carry their own hex values instead
/// of aliasing raw palette tokens so a future divergence is a one-line
/// edit.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Light-theme palette — role tones: {10, 40, 90, 100}
  // ---------------------------------------------------------------------------

  static const Color lightPrimary10 = Color(0xFF121C52);
  static const Color lightPrimary40 = Color(0xFF24389C);
  static const Color lightPrimary80 = Color(0xFF9EACE0);
  static const Color lightPrimary90 = Color(0xFFE1E6F7);
  static const Color lightPrimary100 = Color(0xFFFFFFFF);

  static const Color lightSecondary10 = Color(0xFF312E81);
  static const Color lightSecondary40 = Color(0xFF6366F1);
  static const Color lightSecondary90 = Color(0xFFEEF2FF);

  static const Color lightTertiary10 = Color(0xFF1D5F58);
  static const Color lightTertiary40 = Color(0xFF4DB6AC);
  static const Color lightTertiary90 = Color(0xFFD8F2EF);

  static const Color lightError10 = Color(0xFF410002);
  static const Color lightError40 = Color(0xFFBA1A1A);
  static const Color lightError90 = Color(0xFFFFDAD6);

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

  // Semantic light tokens (each has its own hex — not aliased, so future
  // divergence from tertiary/primary is a one-line edit).
  static const Color lightSuccess10 = Color(0xFF1D5F58);
  static const Color lightSuccess40 = Color(0xFF4DB6AC);
  static const Color lightSuccess90 = Color(0xFFD8F2EF);

  static const Color lightWarning10 = Color(0xFF78350F);
  static const Color lightWarning40 = Color(0xFFF59E0B);
  static const Color lightWarning90 = Color(0xFFFEF3C7);

  static const Color lightInfo10 = Color(0xFF121C52);
  static const Color lightInfo40 = Color(0xFF24389C);
  static const Color lightInfo90 = Color(0xFFE1E6F7);

  static const Color lightMastery = Color(0xFF004E1A);
  static const Color lightStreak = Color(0xFFF97316);

  static const Color lightRatingAgain = Color(0xFFE57373);
  static const Color lightRatingGood = Color(0xFF4DB6AC);
  static const Color lightRatingEasy = Color(0xFF004E1A);

  // ---------------------------------------------------------------------------
  // Dark-theme palette — role tones: {20, 30, 80, 90}
  // ---------------------------------------------------------------------------

  static const Color primary20 = Color(0xFF2B2596);
  static const Color primary30 = Color(0xFF3F36BD);
  static const Color primary40 = Color(0xFF4F46E5);
  static const Color primary80 = Color(0xFFA5B4FC);
  static const Color primary90 = Color(0xFFE0E7FF);

  static const Color secondary20 = Color(0xFF1E1B4B);
  static const Color secondary30 = Color(0xFF312E81);
  static const Color secondary80 = Color(0xFFC7D2FE);
  static const Color secondary90 = Color(0xFFEEF2FF);

  static const Color tertiary20 = Color(0xFF115E59);
  static const Color tertiary30 = Color(0xFF0F766E);
  static const Color tertiary80 = Color(0xFF5EEAD4);
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

  // Semantic dark tokens.
  static const Color success30 = Color(0xFF14532D);
  static const Color success80 = Color(0xFF22C55E);
  static const Color success90 = Color(0xFFBBF7D0);

  static const Color warning30 = Color(0xFF854D0E);
  static const Color warning80 = Color(0xFFFACC15);
  static const Color warning90 = Color(0xFFFEF08A);

  static const Color info30 = Color(0xFF1E40AF);
  static const Color info80 = Color(0xFF60A5FA);
  static const Color info90 = Color(0xFFBFDBFE);

  static const Color ratingAgain = Color(0xFFEF4444);
  static const Color ratingGood = Color(0xFF22C55E);
  static const Color ratingEasy = Color(0xFF14B8A6);
}
