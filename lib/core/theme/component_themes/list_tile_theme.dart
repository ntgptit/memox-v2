import 'package:flutter/material.dart';

import '../tokens/app_opacity.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

abstract final class ListTileThemeBuilder {
  static ListTileThemeData build(ColorScheme scheme) {
    return ListTileThemeData(
      iconColor: scheme.onSurfaceVariant,
      textColor: scheme.onSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      selectedColor: scheme.onSecondaryContainer,
      selectedTileColor: scheme.secondaryContainer.withValues(
        alpha: AppOpacity.half,
      ),
      tileColor: Colors.transparent,
      horizontalTitleGap: AppSpacing.md,
      minVerticalPadding: AppSpacing.xs,
      visualDensity: VisualDensity.standard,
      style: ListTileStyle.list,
      enableFeedback: true,
    );
  }
}
