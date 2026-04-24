import 'package:flutter/material.dart';

import '../app_elevation.dart';
import '../app_typography.dart';

abstract final class AppBarThemeBuilder {
  static AppBarTheme build(ColorScheme scheme) {
    return AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: scheme.surfaceTint,
      shadowColor: scheme.shadow,
      elevation: AppElevation.appBar,
      scrolledUnderElevation: AppElevation.appBarScrolled,
      centerTitle: false,
      titleSpacing: 8,
      toolbarHeight: 56,
      iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      actionsIconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 24),
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      toolbarTextStyle: AppTypography.bodyMedium.copyWith(
        color: scheme.onSurface,
      ),
      systemOverlayStyle: null,
    );
  }
}
