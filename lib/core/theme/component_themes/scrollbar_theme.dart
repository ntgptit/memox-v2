import 'package:flutter/material.dart';

import '../tokens/app_opacity.dart';

abstract final class ScrollbarThemeBuilder {
  static ScrollbarThemeData build(ColorScheme scheme) {
    return ScrollbarThemeData(
      thumbVisibility: const WidgetStatePropertyAll(false),
      trackVisibility: const WidgetStatePropertyAll(false),
      thickness: const WidgetStatePropertyAll(8),
      radius: const Radius.circular(4),
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.dragged)) {
          return scheme.onSurface.withValues(alpha: AppOpacity.handle);
        }
        if (states.contains(WidgetState.hovered)) {
          return scheme.onSurface.withValues(alpha: 0.32);
        }
        return scheme.onSurface.withValues(alpha: AppOpacity.disabledSurface);
      }),
      trackColor: WidgetStatePropertyAll(
        scheme.onSurface.withValues(alpha: AppOpacity.hover),
      ),
      crossAxisMargin: 2,
      mainAxisMargin: 2,
      interactive: true,
    );
  }
}
