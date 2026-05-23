import 'package:flutter/material.dart';

import '../tokens/app_elevation.dart';
import '../tokens/app_opacity.dart';
import '../tokens/app_typography.dart';

abstract final class AppBarThemeBuilder {
  static AppBarTheme build(ColorScheme scheme) {
    return AppBarTheme(
      backgroundColor: scheme.surfaceContainerLow,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: scheme.surfaceTint.withValues(
        alpha: AppOpacity.transparent,
      ),
      shadowColor: scheme.shadow,
      elevation: AppElevation.appBar,
      scrolledUnderElevation: AppElevation.appBarScrolled,
      centerTitle: false,
      titleSpacing: 8,
      toolbarHeight: 60,
      iconTheme: IconThemeData(color: scheme.onSurface, size: 24),
      actionsIconTheme: IconThemeData(color: scheme.onSurfaceVariant, size: 24),
      titleTextStyle: AppTypography.titleLarge.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      toolbarTextStyle: AppTypography.bodyMedium.copyWith(
        color: scheme.onSurface,
      ),
      systemOverlayStyle: null,
    );
  }
}
