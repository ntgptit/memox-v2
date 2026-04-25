import 'package:flutter/material.dart';

import '../tokens/app_opacity.dart';

/// Focus + state-layer tokens.
///
/// Material 3 drives focus/hover/pressed/selected visuals through
/// [WidgetStateProperty] overlays derived from the color scheme. The values
/// here pin MemoX's opacity contract so every interactive surface — buttons,
/// inputs, list tiles, nav rails — renders the same focus ring strength,
/// hover fill, and pressed darken.
///
/// Consumers:
///   * [ButtonThemeBuilder], [IconButtonThemeData] → `overlayColor` + focus ring
///   * [InputThemeBuilder]                        → focused border + cursor
///   * [ListTileThemeBuilder]                     → hover/focus fill
///
/// Rules:
///   * Never hand-roll focus rings with `Container + Border` — use
///     [AppFocus.outline] or the Material `focused` state.
///   * Never hard-code alpha values for hover/pressed — read from [AppFocus]
///     or [AppOpacity].
abstract final class AppFocus {
  /// State-layer opacity for hover on a color surface.
  static const double hoverOpacity = AppOpacity.hover; // 0.08

  /// State-layer opacity for focus on a color surface.
  static const double focusOpacity = 0.12;

  /// State-layer opacity for pressed on a color surface.
  static const double pressedOpacity = 0.16;

  /// State-layer opacity for selected surfaces.
  static const double selectedOpacity = 0.12;

  /// Thickness of the focus outline ring.
  static const double ringWidth = 2.0;

  /// Builds a focus ring outline using the scheme's primary color.
  static BorderSide outline(ColorScheme scheme) =>
      BorderSide(color: scheme.primary, width: ringWidth);

  /// Standard overlay-color resolver for interactive surfaces. Returns a
  /// tinted overlay against [base] that honors hover/focus/pressed/selected.
  ///
  /// Use as: `overlayColor: WidgetStateProperty.resolveWith(
  ///   (states) => AppFocus.overlay(scheme.onSurface, states))`
  static Color? overlay(Color base, Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return base.withValues(alpha: pressedOpacity);
    }
    if (states.contains(WidgetState.focused)) {
      return base.withValues(alpha: focusOpacity);
    }
    if (states.contains(WidgetState.hovered)) {
      return base.withValues(alpha: hoverOpacity);
    }
    if (states.contains(WidgetState.selected)) {
      return base.withValues(alpha: selectedOpacity);
    }
    return null;
  }

  /// `WidgetStateProperty<Color?>` factory for overlay tint from [base].
  static WidgetStateProperty<Color?> overlayProperty(Color base) {
    return WidgetStateProperty.resolveWith((states) => overlay(base, states));
  }
}
