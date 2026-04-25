import 'package:flutter/material.dart';

import '../tokens/app_opacity.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';

abstract final class SegmentedButtonThemeBuilder {
  static SegmentedButtonThemeData build(ColorScheme scheme) {
    return SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return scheme.surfaceContainerLow;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return scheme.onSurface.withValues(alpha: AppOpacity.disabled);
          }
          if (states.contains(WidgetState.selected)) {
            return scheme.onPrimary;
          }
          return scheme.onSurfaceVariant;
        }),
        side: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return BorderSide(color: scheme.primary);
          }
          return BorderSide(color: scheme.outlineVariant);
        }),
        shape: WidgetStateProperty.all(
          const RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
        textStyle: WidgetStateProperty.all(AppTypography.labelLarge),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        minimumSize: WidgetStateProperty.all(const Size(0, 40)),
      ),
    );
  }
}
