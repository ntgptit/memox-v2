import 'package:flutter/material.dart';

import '../tokens/app_opacity.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_typography.dart';
import 'focus_theme.dart';

abstract final class PopupMenuThemeBuilder {
  static PopupMenuThemeData build(ColorScheme scheme) {
    return PopupMenuThemeData(
      color: scheme.surfaceContainerLow,
      surfaceTintColor: scheme.surfaceTint.withValues(
        alpha: AppOpacity.transparent,
      ),
      elevation: 2,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      textStyle: AppTypography.bodyMedium.copyWith(color: scheme.onSurface),
    );
  }

  static MenuThemeData menu(ColorScheme scheme) {
    return MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        shadowColor: WidgetStatePropertyAll(scheme.shadow),
        surfaceTintColor: WidgetStatePropertyAll(
          scheme.surfaceTint.withValues(alpha: AppOpacity.transparent),
        ),
        elevation: const WidgetStatePropertyAll(2),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.card),
        ),
      ),
    );
  }

  static MenuButtonThemeData menuButton(ColorScheme scheme) {
    return MenuButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(scheme.onSurface),
        iconColor: WidgetStatePropertyAll(scheme.onSurfaceVariant),
        textStyle: WidgetStatePropertyAll(
          AppTypography.bodyMedium.copyWith(color: scheme.onSurface),
        ),
        overlayColor: AppFocus.overlayProperty(scheme.onSurface),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.borderMd),
        ),
      ),
    );
  }
}
