import 'package:flutter/material.dart';

import '../app_radius.dart';
import '../app_typography.dart';

abstract final class PopupMenuThemeBuilder {
  static PopupMenuThemeData build(ColorScheme scheme) {
    return PopupMenuThemeData(
      color: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      textStyle: AppTypography.bodyMedium.copyWith(color: scheme.onSurface),
    );
  }

  static MenuThemeData menu(ColorScheme scheme) {
    return MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(2),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: AppRadius.card),
        ),
      ),
    );
  }
}
