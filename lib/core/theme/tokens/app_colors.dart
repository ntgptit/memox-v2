import 'package:flutter/material.dart';

/// Centralized color tokens used by the MemoX themes.
///
/// Palette direction: Tokyo Admin inspired, adapted for MemoX learning flows.
/// Light mode follows Tokyo Pure Light: cool blue text, white paper, soft
/// blue-gray page background. Dark mode follows Tokyo Nebula: deep navy page,
/// indigo paper, muted outlines, and a violet primary accent.
///
/// Every token declared here must have at least one active consumer
/// (theme scheme builder or `MxColorsExtension`). When adding a new
/// role, wire the consumer first. Semantic tokens (success / warning /
/// info / rating / mastery / streak) carry their own hex values instead
/// of aliasing raw palette tokens so a future divergence is a one-line
/// edit.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Light-theme palette — Tokyo Pure Light adapted.
  // ---------------------------------------------------------------------------

  static const Color lightPrimary10 = Color(0xFF000C57);
  static const Color lightPrimary40 = Color(0xFF5265F5);
  static const Color lightPrimary80 = Color(0xFFAAB5FF);
  static const Color lightPrimary90 = Color(0xFFEFF2FF);
  static const Color lightPrimary100 = Color(0xFFFFFFFF);

  static const Color lightSecondary10 = Color(0xFF242E6F);
  static const Color lightSecondary40 = Color(0xFF6E759F);
  static const Color lightSecondary90 = Color(0xFFF1F3FA);

  static const Color lightTertiary10 = Color(0xFF00364A);
  static const Color lightTertiary40 = Color(0xFF33C2FF);
  static const Color lightTertiary90 = Color(0xFFE3F7FF);

  static const Color lightError10 = Color(0xFF5B0011);
  static const Color lightError40 = Color(0xFFE5163C);
  static const Color lightError90 = Color(0xFFFFE6EB);

  static const Color lightSurface = Color(0xFFF2F5F9);
  static const Color lightSurfaceBright = Color(0xFFFFFFFF);
  static const Color lightSurfaceDim = Color(0xFFE7ECF3);
  static const Color lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerLow = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainer = Color(0xFFF9FAFD);
  static const Color lightSurfaceContainerHigh = Color(0xFFF5F7FB);
  static const Color lightSurfaceContainerHighest = Color(0xFFEAF0F7);

  static const Color lightNeutral10 = Color(0xFF223354);
  static const Color lightNeutral20 = Color(0xFF2D3F63);
  static const Color lightNeutral40 = Color(0xFF6E759F);
  static const Color lightNeutralVariant60 = Color(0xFF9FA2BF);
  static const Color lightNeutralVariant90 = Color(0xFFD8DEEB);

  // Semantic light tokens (each has its own hex — not aliased, so future
  // divergence from tertiary/primary is a one-line edit).
  static const Color lightSuccess10 = Color(0xFF174A05);
  static const Color lightSuccess40 = Color(0xFF57CA22);
  static const Color lightSuccess90 = Color(0xFFE7F9DE);

  static const Color lightWarning10 = Color(0xFF5C3600);
  static const Color lightWarning40 = Color(0xFFFFA319);
  static const Color lightWarning90 = Color(0xFFFFF1D9);

  static const Color lightInfo10 = Color(0xFF00364A);
  static const Color lightInfo40 = Color(0xFF33C2FF);
  static const Color lightInfo90 = Color(0xFFE3F7FF);

  static const Color lightMastery = Color(0xFF57CA22);
  static const Color lightStreak = Color(0xFFFFA319);

  static const Color lightRatingAgain = Color(0xFFFF1943);
  static const Color lightRatingGood = Color(0xFF33C2FF);
  static const Color lightRatingEasy = Color(0xFF57CA22);

  // ---------------------------------------------------------------------------
  // Dark-theme palette — Tokyo Nebula adapted.
  // ---------------------------------------------------------------------------

  static const Color primary20 = Color(0xFF221D55);
  static const Color primary30 = Color(0xFF2B304D);
  static const Color primary40 = Color(0xFF5E50C8);
  static const Color primary80 = Color(0xFF8C7CF0);
  static const Color primary90 = Color(0xFFE8E5FF);

  static const Color secondary20 = Color(0xFF242A48);
  static const Color secondary30 = Color(0xFF2B304D);
  static const Color secondary80 = Color(0xFF9EA4C1);
  static const Color secondary90 = Color(0xFFE6E9F5);

  static const Color tertiary20 = Color(0xFF06344A);
  static const Color tertiary30 = Color(0xFF0A4A66);
  static const Color tertiary80 = Color(0xFF33C2FF);
  static const Color tertiary90 = Color(0xFFD9F5FF);

  static const Color error20 = Color(0xFF5B0011);
  static const Color error30 = Color(0xFF7A0A1F);
  static const Color error80 = Color(0xFFFF5575);
  static const Color error90 = Color(0xFFFFDDE5);

  static const Color neutral10 = Color(0xFF111633);
  static const Color neutral70 = Color(0xFF9EA4C1);
  static const Color neutral90 = Color(0xFFE6E9F5);
  static const Color neutral95 = Color(0xFFFFFFFF);

  static const Color darkNavy5 = Color(0xFF070C27);
  static const Color darkNavy10 = Color(0xFF0B102D);
  static const Color darkNavy15 = Color(0xFF111633);
  static const Color darkNavy20 = Color(0xFF161B3A);
  static const Color darkNavy25 = Color(0xFF1D2344);
  static const Color darkNavy30 = Color(0xFF272C48);
  static const Color darkNavy40 = Color(0xFF353B61);
  static const Color darkNavyOutline = Color(0xFF3B4168);
  static const Color darkNavyOutlineVariant = Color(0xFF272C48);

  // Semantic dark tokens.
  static const Color success30 = Color(0xFF174A05);
  static const Color success80 = Color(0xFF57CA22);
  static const Color success90 = Color(0xFFDFF7D6);

  static const Color warning30 = Color(0xFF5C3600);
  static const Color warning80 = Color(0xFFFFA319);
  static const Color warning90 = Color(0xFFFFEDCC);

  static const Color info30 = Color(0xFF0A4A66);
  static const Color info80 = Color(0xFF33C2FF);
  static const Color info90 = Color(0xFFD9F5FF);

  static const Color ratingAgain = Color(0xFFFF1943);
  static const Color ratingGood = Color(0xFF33C2FF);
  static const Color ratingEasy = Color(0xFF57CA22);
}
