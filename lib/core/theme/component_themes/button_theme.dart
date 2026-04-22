import 'package:flutter/material.dart';

import '../app_opacity.dart';
import '../app_radius.dart';
import '../app_typography.dart';
import 'focus_theme.dart';

abstract final class ButtonThemeBuilder {
  static const double _minHeight = 44;
  static const EdgeInsetsGeometry _padding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 12);

  static ElevatedButtonThemeData filled(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: scheme.onSurface.withValues(alpha: AppOpacity.disabledSurface),
        disabledForegroundColor: scheme.onSurface.withValues(alpha: AppOpacity.disabled),
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size(0, _minHeight),
        padding: _padding,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        textStyle: AppTypography.labelLarge,
        animationDuration: const Duration(milliseconds: 150),
      ),
    );
  }

  static FilledButtonThemeData tonal(ColorScheme scheme) {
    return FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.secondaryContainer,
        foregroundColor: scheme.onSecondaryContainer,
        disabledBackgroundColor: scheme.onSurface.withValues(alpha: AppOpacity.disabledSurface),
        disabledForegroundColor: scheme.onSurface.withValues(alpha: AppOpacity.disabled),
        minimumSize: const Size(0, _minHeight),
        padding: _padding,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        textStyle: AppTypography.labelLarge,
      ),
    );
  }

  static OutlinedButtonThemeData outlined(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        disabledForegroundColor: scheme.onSurface.withValues(alpha: AppOpacity.disabled),
        minimumSize: const Size(0, _minHeight),
        padding: _padding,
        side: BorderSide(color: scheme.outline),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        textStyle: AppTypography.labelLarge,
      ),
    );
  }

  static TextButtonThemeData text(ColorScheme scheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        disabledForegroundColor: scheme.onSurface.withValues(alpha: AppOpacity.disabled),
        minimumSize: const Size(0, _minHeight),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        textStyle: AppTypography.labelLarge,
      ),
    );
  }

  static IconButtonThemeData icon(ColorScheme scheme) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        disabledForegroundColor: scheme.onSurface.withValues(alpha: AppOpacity.disabled),
        minimumSize: const Size(40, 40),
        fixedSize: const Size(40, 40),
        iconSize: 20,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonSmall),
      ).copyWith(
        overlayColor: AppFocus.overlayProperty(scheme.onSurface),
      ),
    );
  }

  static FloatingActionButtonThemeData fab(ColorScheme scheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      elevation: 3,
      focusElevation: 4,
      hoverElevation: 4,
      highlightElevation: 6,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderLg),
    );
  }
}
