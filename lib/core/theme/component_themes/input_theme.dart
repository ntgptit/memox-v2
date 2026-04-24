import 'package:flutter/material.dart';

import '../app_opacity.dart';
import '../app_radius.dart';
import '../app_typography.dart';

abstract final class InputThemeBuilder {
  static InputDecorationTheme build(ColorScheme scheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      isDense: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      labelStyle: AppTypography.bodyMedium.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      floatingLabelStyle: AppTypography.bodySmall.copyWith(
        color: scheme.primary,
      ),
      helperStyle: AppTypography.bodySmall.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      errorStyle: AppTypography.bodySmall.copyWith(color: scheme.error),
      prefixIconColor: scheme.onSurfaceVariant,
      suffixIconColor: scheme.onSurfaceVariant,
      iconColor: scheme.onSurfaceVariant,
      border: _border(scheme.outlineVariant),
      enabledBorder: _border(scheme.outlineVariant),
      focusedBorder: _border(scheme.primary, width: 2),
      errorBorder: _border(scheme.error),
      focusedErrorBorder: _border(scheme.error, width: 2),
      disabledBorder: _border(
        scheme.outlineVariant.withValues(alpha: AppOpacity.half),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
