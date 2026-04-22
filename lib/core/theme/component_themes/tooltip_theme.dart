import 'package:flutter/material.dart';

import '../app_radius.dart';
import '../app_spacing.dart';

abstract final class TooltipThemeBuilder {
  static TooltipThemeData build(ColorScheme scheme) {
    return TooltipThemeData(
      decoration: BoxDecoration(
        color: scheme.inverseSurface.withValues(alpha: 0.92),
        borderRadius: AppRadius.borderSm,
      ),
      textStyle: TextStyle(
        color: scheme.onInverseSurface,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      margin: const EdgeInsets.all(AppSpacing.xs),
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(milliseconds: 1500),
      preferBelow: true,
    );
  }
}
