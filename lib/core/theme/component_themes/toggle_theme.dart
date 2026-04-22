import 'package:flutter/material.dart';

import '../app_opacity.dart';
import 'focus_theme.dart';

/// Form-control surfaces: switch, checkbox, radio, slider.
///
/// Kept as one file because they share the same state-layer + selected-color
/// contract (primary when on, onSurfaceVariant when off, disabled at
/// [AppOpacity.disabled]).
abstract final class ToggleThemeBuilder {
  static SwitchThemeData switchTheme(ColorScheme scheme) {
    return SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: AppOpacity.disabled);
        }
        if (states.contains(WidgetState.selected)) return scheme.onPrimary;
        return scheme.outline;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: AppOpacity.disabledSurface);
        }
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return scheme.surfaceContainerHighest;
      }),
      trackOutlineColor: WidgetStatePropertyAll(scheme.outline),
      overlayColor: AppFocus.overlayProperty(scheme.primary),
    );
  }

  static CheckboxThemeData checkbox(ColorScheme scheme) {
    return CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: AppOpacity.disabledSurface);
        }
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return null;
      }),
      checkColor: WidgetStatePropertyAll(scheme.onPrimary),
      side: BorderSide(color: scheme.outline, width: 2),
      overlayColor: AppFocus.overlayProperty(scheme.primary),
    );
  }

  static RadioThemeData radio(ColorScheme scheme) {
    return RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withValues(alpha: AppOpacity.disabled);
        }
        if (states.contains(WidgetState.selected)) return scheme.primary;
        return scheme.outline;
      }),
      overlayColor: AppFocus.overlayProperty(scheme.primary),
    );
  }

  static SliderThemeData slider(ColorScheme scheme) {
    return SliderThemeData(
      activeTrackColor: scheme.primary,
      inactiveTrackColor:
          scheme.primary.withValues(alpha: AppOpacity.disabledSurface),
      thumbColor: scheme.primary,
      overlayColor:
          scheme.primary.withValues(alpha: AppFocus.focusOpacity),
      valueIndicatorColor: scheme.inverseSurface,
      valueIndicatorTextStyle:
          TextStyle(color: scheme.onInverseSurface, fontSize: 12),
      trackHeight: 4,
    );
  }
}
