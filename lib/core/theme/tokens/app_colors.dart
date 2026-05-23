import 'package:flutter/material.dart';

/// Centralized color tokens used by the MemoX themes.
///
/// Palette direction: Tokyo Admin inspired, adapted for MemoX learning flows.
/// Light mode follows Tokyo Pure Light: cool blue text, white paper, soft
/// blue-gray page background. Dark mode follows Tokyo Nebula: deep navy page,
/// indigo paper, muted outlines, and a violet primary accent.
///
/// Tokens here are palette/source values, not Material role names. Map them
/// into `ColorScheme` in `schemes/*` or into MemoX semantic roles in
/// `MxColorsExtension`. Semantic tokens (success / warning / info / rating /
/// mastery / streak) carry their own hex values instead of aliasing raw palette
/// tokens so a future divergence is a one-line edit.
abstract final class AppColors {
  // Material 3 role families used below:
  // - Primary: main brand/action color and selected states.
  // - Secondary: supporting accent for lower-emphasis actions and controls.
  // - Tertiary: contrasting accent for highlights, charts, and informative UI.
  // - Error: destructive, invalid, or failed states.
  // - Surface/Neutral: app backgrounds, containers, and readable foregrounds.
  // - Neutral Variant: outlines, dividers, and medium-emphasis foregrounds.

  // ---------------------------------------------------------------------------
  // Light-theme palette — Tokyo Pure Light adapted.
  // ---------------------------------------------------------------------------

  // Primary family: brand source color and primary action roles.
  // Mirrors the light tokens imported by
  // `docs/system-design/MemoX Design System/ui_kits/mobile/index.html`.
  static const Color lightPrimary10 = Color(0xFF000C57);
  static const Color lightPrimary40 = Color(0xFF5265F5);
  static const Color lightPrimary80 = Color(0xFFAAB5FF);
  static const Color lightPrimary90 = Color(0xFFE0E5FE);
  static const Color lightPrimary100 = Color(0xFFFFFFFF);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnPrimaryContainer = Color(0xFF1A2580);

  // Secondary family: supporting accent with quieter emphasis than primary.
  static const Color lightSecondary10 = Color(0xFF242E6F);
  static const Color lightSecondary40 = Color(0xFF6E7CD9);
  static const Color lightSecondary90 = Color(0xFFF1F3FA);

  // Tertiary family: contrasting accent for informative/highlighted UI.
  static const Color lightTertiary10 = Color(0xFF00364A);
  static const Color lightTertiary40 = Color(0xFF004E1A);
  static const Color lightTertiary90 = Color(0xFFE3F7FF);

  // Error family: invalid, destructive, or failed-state roles.
  static const Color lightError10 = Color(0xFF5B0011);
  static const Color lightError40 = Color(0xFFDC2D4E);
  static const Color lightError90 = Color(0xFFFFE6EB);

  // Surface family: page backgrounds and container elevations.
  static const Color lightSurface = Color(0xFFF7F9FE);
  static const Color lightSurfaceBright = Color(0xFFFFFFFF);
  static const Color lightSurfaceDim = Color(0xFFDAE0EF);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFF1F4FB);
  static const Color lightSurfaceContainer = Color(0xFFE9EDF7);
  static const Color lightSurfaceContainerHigh = Color(0xFFE2E7F3);
  static const Color lightSurfaceContainerHighest = Color(0xFFDAE0EF);

  // Neutral family: foreground text/icons; neutral variant covers outlines
  // and medium-emphasis foregrounds.
  static const Color lightNeutral10 = Color(0xFF0F1638);
  static const Color lightNeutral20 = Color(0xFF4A5278);
  static const Color lightNeutral40 = Color(0xFF4A5278);
  static const Color lightNeutralVariant60 = Color(0xFF7C85AB);
  static const Color lightNeutralVariant90 = Color(0xFFC5CBE3);

  // Semantic light tokens (each has its own hex — not aliased, so future
  // divergence from tertiary/primary is a one-line edit).
  static const Color lightSuccess10 = Color(0xFF174A05);
  static const Color lightSuccess40 = Color(0xFF2BA88B);
  static const Color lightSuccess90 = Color(0xFFE7F9DE);

  static const Color lightWarning10 = Color(0xFF5C3600);
  static const Color lightWarning40 = Color(0xFFF59E0B);
  static const Color lightWarning90 = Color(0xFFFFF1D9);

  static const Color lightInfo10 = Color(0xFF00364A);
  static const Color lightInfo40 = Color(0xFF33C2FF);
  static const Color lightInfo90 = Color(0xFFE3F7FF);

  static const Color lightMastery = Color(0xFF1F8A5B);
  static const Color lightStreak = Color(0xFFF97316);

  static const Color lightRatingAgain = Color(0xFFE57373);
  static const Color lightRatingHard = Color(0xFFF59E0B);
  static const Color lightRatingGood = Color(0xFF5265F5);
  static const Color lightRatingEasy = Color(0xFF2BA88B);

  // ---------------------------------------------------------------------------
  // Dark-theme palette — Tokyo Nebula adapted.
  // ---------------------------------------------------------------------------

  // Primary family: brand source color and primary action roles.
  // Mirrors `docs/system-design/MemoX Design System/ui_kits/mobile/index.html`
  // scoped `.memox-dark` tokens.
  static const Color darkPrimary20 = Color(0xFF221D55);
  static const Color darkPrimary30 = Color(0xFF2B304D);
  static const Color darkPrimary40 = Color(0xFF5E50C8);
  static const Color darkPrimary80 = Color(0xFF5265F5);
  static const Color darkPrimary90 = Color(0xFFE8E5FF);
  static const Color darkOnPrimary = Color(0xFFFFFFFF);

  // Secondary family: supporting accent with quieter emphasis than primary.
  static const Color darkSecondary20 = Color(0xFF242A48);
  static const Color darkSecondary30 = Color(0xFF2B304D);
  static const Color darkSecondary80 = Color(0xFFA4ACD0);
  static const Color darkSecondary90 = Color(0xFFE6E9F5);

  // Tertiary family: contrasting accent for informative/highlighted UI.
  static const Color darkTertiary20 = Color(0xFF06344A);
  static const Color darkTertiary30 = Color(0xFF0A4A66);
  static const Color darkTertiary80 = Color(0xFF33C2FF);
  static const Color darkTertiary90 = Color(0xFFD9F5FF);

  // Error family: invalid, destructive, or failed-state roles.
  static const Color darkError20 = Color(0xFF5B0011);
  static const Color darkError30 = Color(0xFF7A0A1F);
  static const Color darkError80 = Color(0xFFFF8FA3);
  static const Color darkError90 = Color(0xFFFFDDE5);

  // Neutral family: foreground text/icons for dark surfaces.
  static const Color darkNeutral10 = Color(0xFF111633);
  static const Color darkNeutral70 = Color(0xFFA4ACD0);
  static const Color darkNeutral90 = Color(0xFFE4E8FA);
  static const Color darkNeutral95 = Color(0xFFE4E8FA);

  // Surface and neutral-variant family: dark page backgrounds, containers,
  // outlines, dividers, and medium-emphasis foregrounds.
  static const Color darkNavy5 = Color(0xFF0A0E27);
  static const Color darkNavy10 = Color(0xFF131A3A);
  static const Color darkNavy15 = Color(0xFF1B2249);
  static const Color darkNavy20 = Color(0xFF232B5A);
  static const Color darkNavy25 = Color(0xFF2C356E);
  static const Color darkNavy30 = Color(0xFF353D7E);
  static const Color darkNavy40 = Color(0xFF232B5A);
  static const Color darkNavyDim = Color(0xFF060925);
  static const Color darkNavyOutline = Color(0xFF5A6BAE);
  static const Color darkNavyOutlineVariant = Color(0xFF2A3267);

  // Semantic dark tokens.
  static const Color darkSuccess30 = Color(0xFF174A05);
  static const Color darkSuccess80 = Color(0xFF6FE0BD);
  static const Color darkSuccess90 = Color(0xFFDFF7D6);

  static const Color darkWarning30 = Color(0xFF5C3600);
  static const Color darkWarning80 = Color(0xFFFFA319);
  static const Color darkWarning90 = Color(0xFFFFEDCC);
  static const Color darkStreak = Color(0xFFFFAE6E);

  static const Color darkInfo30 = Color(0xFF0A4A66);
  static const Color darkInfo80 = Color(0xFF33C2FF);
  static const Color darkInfo90 = Color(0xFFD9F5FF);

  static const Color darkRatingAgain = Color(0xFFFF8FA3);
  static const Color darkRatingGood = Color(0xFF33C2FF);
  static const Color darkRatingEasy = Color(0xFF6FE0BD);
}
