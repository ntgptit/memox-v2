import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Theme extension exposing MemoX semantic colors that are not part of
/// the standard [ColorScheme] (success, warning, info, rating grades, etc.).
///
/// This is the ONLY role of this file. Tokens (spacing/radii/icon sizes,
/// opacity), the layout spec, the gap widget, and the repetition-order
/// mapping each live in their own files.
@immutable
class MxColorsExtension extends ThemeExtension<MxColorsExtension> {
  const MxColorsExtension({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.ratingAgain,
    required this.ratingHard,
    required this.ratingGood,
    required this.ratingEasy,
    required this.mastery,
    required this.streak,
  });

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  final Color ratingAgain;
  final Color ratingHard;
  final Color ratingGood;
  final Color ratingEasy;
  final Color mastery;
  final Color streak;

  /// Map a [RepetitionColorRole] semantic role to its concrete color for the
  /// active theme brightness. Consumers should call this via
  /// `customColors.repetitionColor(role)` instead of indexing into a raw seed
  /// palette list.
  Color repetitionColor(RepetitionColorRole role) {
    switch (role) {
      case RepetitionColorRole.first:
        return ratingEasy;
      case RepetitionColorRole.early:
        return ratingGood;
      case RepetitionColorRole.mid:
        return info;
      case RepetitionColorRole.advanced:
        return warning;
      case RepetitionColorRole.mastered:
        return success;
    }
  }

  /// Resolve a mastery/progress color tier from the current completion value.
  ///
  /// Light mode follows the provided low / mid / high legend:
  /// rose → amber → mastery green. Dark mode keeps the same semantic split
  /// using its own extension values.
  Color masteryProgress(double value) {
    final clamped = value.clamp(0.0, 1.0).toDouble();
    if (clamped < 0.34) return ratingAgain;
    if (clamped < 0.67) return warning;
    return mastery;
  }

  static const light = MxColorsExtension(
    success: AppColors.lightSuccess60,
    onSuccess: AppColors.lightNeutral10,
    successContainer: AppColors.lightSuccess95,
    onSuccessContainer: AppColors.lightSuccess30,
    warning: AppColors.lightWarning50,
    onWarning: AppColors.lightNeutral10,
    warningContainer: AppColors.lightWarning95,
    onWarningContainer: AppColors.lightWarning30,
    info: AppColors.lightInfo50,
    onInfo: AppColors.lightNeutral10,
    infoContainer: AppColors.lightInfo95,
    onInfoContainer: AppColors.lightInfo30,
    ratingAgain: AppColors.lightRatingAgain,
    ratingHard: AppColors.lightRatingHard,
    ratingGood: AppColors.lightRatingGood,
    ratingEasy: AppColors.lightRatingEasy,
    mastery: AppColors.lightMastery,
    streak: AppColors.lightStreak,
  );

  static const dark = MxColorsExtension(
    success: AppColors.success60,
    onSuccess: AppColors.neutral10,
    successContainer: AppColors.success30,
    onSuccessContainer: AppColors.success90,
    warning: AppColors.warning60,
    onWarning: AppColors.neutral10,
    warningContainer: AppColors.warning30,
    onWarningContainer: AppColors.warning90,
    info: AppColors.info60,
    onInfo: AppColors.neutral10,
    infoContainer: AppColors.info30,
    onInfoContainer: AppColors.info90,
    ratingAgain: AppColors.ratingAgain,
    ratingHard: AppColors.ratingHard,
    ratingGood: AppColors.ratingGood,
    ratingEasy: AppColors.ratingEasy,
    mastery: AppColors.success60,
    streak: AppColors.warning60,
  );

  @override
  MxColorsExtension copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? ratingAgain,
    Color? ratingHard,
    Color? ratingGood,
    Color? ratingEasy,
    Color? mastery,
    Color? streak,
  }) {
    return MxColorsExtension(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
      ratingAgain: ratingAgain ?? this.ratingAgain,
      ratingHard: ratingHard ?? this.ratingHard,
      ratingGood: ratingGood ?? this.ratingGood,
      ratingEasy: ratingEasy ?? this.ratingEasy,
      mastery: mastery ?? this.mastery,
      streak: streak ?? this.streak,
    );
  }

  @override
  MxColorsExtension lerp(ThemeExtension<MxColorsExtension>? other, double t) {
    if (other is! MxColorsExtension) return this;
    return MxColorsExtension(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      onSuccessContainer: Color.lerp(
        onSuccessContainer,
        other.onSuccessContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      onWarningContainer: Color.lerp(
        onWarningContainer,
        other.onWarningContainer,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
      ratingAgain: Color.lerp(ratingAgain, other.ratingAgain, t)!,
      ratingHard: Color.lerp(ratingHard, other.ratingHard, t)!,
      ratingGood: Color.lerp(ratingGood, other.ratingGood, t)!,
      ratingEasy: Color.lerp(ratingEasy, other.ratingEasy, t)!,
      mastery: Color.lerp(mastery, other.mastery, t)!,
      streak: Color.lerp(streak, other.streak, t)!,
    );
  }
}

extension MxColorsContext on BuildContext {
  MxColorsExtension get mxColors =>
      Theme.of(this).extension<MxColorsExtension>() ?? MxColorsExtension.light;
}

// ---------------------------------------------------------------------------
// Repetition color roles (UI-layer proxy for the repetition-order concept).
//
// Kept in this file intentionally: the guard rule
// `theme_repetition_semantic_colors` pins these symbols to
// `theme_extensions.dart` so the semantic mapping contract stays findable.
// ---------------------------------------------------------------------------

/// Semantic role tiers for spaced-repetition indicators.
enum RepetitionColorRole { first, early, mid, advanced, mastered }

/// UI-layer proxy for the repetition-order domain concept. Presentation
/// adapters project the real domain value onto one of these tiers before
/// reaching the theme layer.
enum RepetitionOrder { first, early, mid, advanced, mastered }

extension RepetitionOrderRole on RepetitionOrder {
  RepetitionColorRole get repetitionColorRole {
    switch (this) {
      case RepetitionOrder.first:
        return RepetitionColorRole.first;
      case RepetitionOrder.early:
        return RepetitionColorRole.early;
      case RepetitionOrder.mid:
        return RepetitionColorRole.mid;
      case RepetitionOrder.advanced:
        return RepetitionColorRole.advanced;
      case RepetitionOrder.mastered:
        return RepetitionColorRole.mastered;
    }
  }
}

/// Convenience resolver: map a [RepetitionOrder] straight to its themed
/// color by delegating through the semantic [RepetitionColorRole].
Color getRepetitionColor(
  RepetitionOrder repetitionOrder,
  MxColorsExtension customColors,
) {
  return customColors.repetitionColor(repetitionOrder.repetitionColorRole);
}
