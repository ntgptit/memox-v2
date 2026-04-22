import 'package:flutter/widgets.dart';

import 'app_icon_sizes.dart';
import 'app_motion.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// Feature-facing token surface.
///
/// Feature-layer files cannot import the raw token files
/// (`app_spacing.dart`, `app_radius.dart`, `app_icon_sizes.dart`) — those are
/// owned by `core/theme/**` and `presentation/shared/**`. Features read
/// spacing / radius / icon-size through the facades in this file, which
/// re-expose the underlying values without duplicating them.
///
/// Rule of thumb when adding a new constant:
/// 1. Add it once to the appropriate raw token file (`AppSpacing`, etc.).
/// 2. If features need it, expose it here with the same name. Do NOT invent
///    a new number — the raw file is the source of truth.

// ---------------------------------------------------------------------------
// Spacing
// ---------------------------------------------------------------------------

/// Feature-facing spacing tokens. Mirrors [AppSpacing].
abstract final class MxSpace {
  static const double none = AppSpacing.none;
  static const double xxs = AppSpacing.xxs;
  static const double xs = AppSpacing.xs;
  static const double sm = AppSpacing.sm;
  static const double md = AppSpacing.md;
  static const double lg = AppSpacing.lg;
  static const double xl = AppSpacing.xl;
  static const double xxl = AppSpacing.xxl;
  static const double xxxl = AppSpacing.xxxl;
  static const double xxxxl = AppSpacing.xxxxl;

  // Semantic presets (opinionated paddings).
  static const EdgeInsets screenHorizontal = AppSpacing.screenHorizontal;
  static const EdgeInsets screenVertical = AppSpacing.screenVertical;
  static const EdgeInsets screen = AppSpacing.screen;
  static const EdgeInsets card = AppSpacing.card;
  static const EdgeInsets listItem = AppSpacing.listItem;
  static const EdgeInsets dialog = AppSpacing.dialog;
  static const EdgeInsets sheet = AppSpacing.sheet;
}

// ---------------------------------------------------------------------------
// Radius
// ---------------------------------------------------------------------------

/// Feature-facing corner-radius tokens. Mirrors [AppRadius].
abstract final class MxRadii {
  static const double none = AppRadius.none;
  static const double xs = AppRadius.xs;
  static const double sm = AppRadius.sm;
  static const double md = AppRadius.md;
  static const double lg = AppRadius.lg;
  static const double xl = AppRadius.xl;
  static const double xxl = AppRadius.xxl;
  static const double full = AppRadius.full;

  // BorderRadius helpers.
  static const BorderRadius borderXs = AppRadius.borderXs;
  static const BorderRadius borderSm = AppRadius.borderSm;
  static const BorderRadius borderMd = AppRadius.borderMd;
  static const BorderRadius borderLg = AppRadius.borderLg;
  static const BorderRadius borderXl = AppRadius.borderXl;
  static const BorderRadius borderFull = AppRadius.borderFull;

  // Semantic presets.
  static const BorderRadius card = AppRadius.card;
  static const BorderRadius cardLarge = AppRadius.cardLarge;
  static const BorderRadius button = AppRadius.button;
  static const BorderRadius chip = AppRadius.chip;
}

// ---------------------------------------------------------------------------
// Icon sizes
// ---------------------------------------------------------------------------

/// Feature-facing icon-size tokens. Mirrors [AppIconSizes].
abstract final class MxIconSize {
  static const double xxs = AppIconSizes.xxs;
  static const double xs = AppIconSizes.xs;
  static const double sm = AppIconSizes.sm;
  static const double md = AppIconSizes.md;
  static const double lg = AppIconSizes.lg;
  static const double xl = AppIconSizes.xl;
  static const double xxl = AppIconSizes.xxl;
  static const double xxxl = AppIconSizes.xxxl;
}

// ---------------------------------------------------------------------------
// Motion
// ---------------------------------------------------------------------------

/// Feature-facing motion durations. Mirrors [AppDurations].
abstract final class MxDurations {
  static const Duration instant = AppDurations.instant;
  static const Duration xs = AppDurations.xs;
  static const Duration sm = AppDurations.sm;
  static const Duration md = AppDurations.md;
  static const Duration lg = AppDurations.lg;
  static const Duration xl = AppDurations.xl;
  static const Duration xxl = AppDurations.xxl;

  static const Duration press = AppDurations.press;
  static const Duration stateChange = AppDurations.stateChange;
  static const Duration fade = AppDurations.fade;
  static const Duration slide = AppDurations.slide;
  static const Duration page = AppDurations.page;
}

/// Feature-facing motion curves. Mirrors [AppCurves].
abstract final class MxCurves {
  static const Curve standard = AppCurves.standard;
  static const Curve standardAccelerate = AppCurves.standardAccelerate;
  static const Curve standardDecelerate = AppCurves.standardDecelerate;
  static const Curve emphasized = AppCurves.emphasized;
  static const Curve emphasizedAccelerate = AppCurves.emphasizedAccelerate;
  static const Curve emphasizedDecelerate = AppCurves.emphasizedDecelerate;
}
