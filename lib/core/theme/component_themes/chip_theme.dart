import 'package:flutter/material.dart';

import '../tokens/app_opacity.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

abstract final class ChipThemeBuilder {
  static ChipThemeData build(ColorScheme scheme) {
    return ChipThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      disabledColor: scheme.onSurface.withValues(alpha: 0.08),
      selectedColor: scheme.primaryContainer,
      secondarySelectedColor: scheme.primaryContainer,
      checkmarkColor: scheme.onPrimaryContainer,
      deleteIconColor: scheme.onSurfaceVariant,
      side: BorderSide(color: scheme.outlineVariant),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      labelStyle: AppTypography.labelLarge.copyWith(color: scheme.onSurface),
      secondaryLabelStyle: AppTypography.labelLarge.copyWith(
        color: scheme.onSecondaryContainer,
      ),
      brightness: scheme.brightness,
      shape: const StadiumBorder(),
      showCheckmark: true,
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 18),
      surfaceTintColor: scheme.surfaceTint.withValues(
        alpha: AppOpacity.transparent,
      ),
    );
  }

  static ChipThemeData pill(ColorScheme scheme) {
    return build(scheme).copyWith(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),
    );
  }
}
