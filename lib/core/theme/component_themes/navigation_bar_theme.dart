import 'package:flutter/material.dart';

import '../tokens/app_elevation.dart';
import '../tokens/app_opacity.dart';
import '../tokens/app_typography.dart';

abstract final class NavigationBarThemeBuilder {
  static NavigationBarThemeData bar(ColorScheme scheme) {
    return NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primary,
      surfaceTintColor: scheme.surfaceTint.withValues(
        alpha: AppOpacity.transparent,
      ),
      shadowColor: scheme.shadow,
      elevation: AppElevation.navigationBar,
      height: 76,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 24,
          color: states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => AppTypography.labelMedium.copyWith(
          color: states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w600,
        ),
      ),
    );
  }

  static NavigationRailThemeData rail(ColorScheme scheme) {
    return NavigationRailThemeData(
      backgroundColor: scheme.surfaceContainerLow,
      indicatorColor: scheme.primary,
      selectedIconTheme: IconThemeData(color: scheme.onPrimary, size: 24),
      unselectedIconTheme: IconThemeData(
        color: scheme.onSurfaceVariant,
        size: 24,
      ),
      selectedLabelTextStyle: AppTypography.labelMedium.copyWith(
        color: scheme.primary,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelTextStyle: AppTypography.labelMedium.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      useIndicator: true,
      labelType: NavigationRailLabelType.all,
    );
  }
}
