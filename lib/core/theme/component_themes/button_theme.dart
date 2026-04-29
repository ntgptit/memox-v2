import 'package:flutter/material.dart';

import '../tokens/app_elevation.dart';
import '../tokens/app_icon_sizes.dart';
import '../tokens/app_opacity.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_typography.dart';
import 'focus_theme.dart';

abstract final class ButtonThemeBuilder {
  static const double _minHeight = kMinInteractiveDimension;
  static const EdgeInsetsGeometry _padding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xl,
    vertical: AppSpacing.md,
  );
  static const EdgeInsetsGeometry _textPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );

  static ElevatedButtonThemeData filled(ColorScheme scheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: scheme.onSurface.withValues(
          alpha: AppOpacity.disabledSurface,
        ),
        disabledForegroundColor: scheme.onSurface.withValues(
          alpha: AppOpacity.disabled,
        ),
        elevation: AppElevation.button,
        shadowColor: scheme.primary,
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
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        disabledBackgroundColor: scheme.onSurface.withValues(
          alpha: AppOpacity.disabledSurface,
        ),
        disabledForegroundColor: scheme.onSurface.withValues(
          alpha: AppOpacity.disabled,
        ),
        minimumSize: const Size(0, _minHeight),
        padding: _padding,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        textStyle: AppTypography.labelLarge,
        side: BorderSide(color: scheme.outlineVariant),
      ),
    );
  }

  static OutlinedButtonThemeData outlined(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: scheme.surfaceContainerLow,
        foregroundColor: scheme.primary,
        disabledForegroundColor: scheme.onSurface.withValues(
          alpha: AppOpacity.disabled,
        ),
        minimumSize: const Size(0, _minHeight),
        padding: _padding,
        side: BorderSide(color: scheme.outlineVariant),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        textStyle: AppTypography.labelLarge,
      ),
    );
  }

  static TextButtonThemeData text(ColorScheme scheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        disabledForegroundColor: scheme.onSurface.withValues(
          alpha: AppOpacity.disabled,
        ),
        minimumSize: const Size(0, _minHeight),
        padding: _textPadding,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        textStyle: AppTypography.labelLarge,
      ),
    );
  }

  static IconButtonThemeData icon(ColorScheme scheme) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurfaceVariant,
        disabledForegroundColor: scheme.onSurface.withValues(
          alpha: AppOpacity.disabled,
        ),
        minimumSize: const Size.square(_minHeight),
        fixedSize: const Size.square(_minHeight),
        iconSize: AppIconSizes.md,
        backgroundColor: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
      ).copyWith(overlayColor: AppFocus.overlayProperty(scheme.onSurface)),
    );
  }

  static FloatingActionButtonThemeData fab(ColorScheme scheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.borderSemi),
    );
  }
}
