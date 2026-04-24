import 'package:flutter/material.dart';

import '../app_elevation.dart';
import '../app_typography.dart';

abstract final class NavigationBarThemeBuilder {
  static NavigationBarThemeData bar(ColorScheme scheme) {
    return NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      // Keep the selected pill on the app's single accent (indigo) — using
      // `secondaryContainer` here leaks the Amber palette into navigation on
      // dark mode and clashes with the "one accent" design contract.
      indicatorColor: scheme.primaryContainer,
      surfaceTintColor: scheme.surfaceTint,
      shadowColor: scheme.shadow,
      elevation: AppElevation.navigationBar,
      height: 72,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith(
        (states) => IconThemeData(
          size: 24,
          color: states.contains(WidgetState.selected)
              ? scheme.onPrimaryContainer
              : scheme.onSurfaceVariant,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => AppTypography.labelMedium.copyWith(
          color: states.contains(WidgetState.selected)
              ? scheme.onSurface
              : scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  static NavigationRailThemeData rail(ColorScheme scheme) {
    return NavigationRailThemeData(
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      selectedIconTheme: IconThemeData(
        color: scheme.onPrimaryContainer,
        size: 24,
      ),
      unselectedIconTheme: IconThemeData(
        color: scheme.onSurfaceVariant,
        size: 24,
      ),
      selectedLabelTextStyle: AppTypography.labelMedium.copyWith(
        color: scheme.onSurface,
      ),
      unselectedLabelTextStyle: AppTypography.labelMedium.copyWith(
        color: scheme.onSurfaceVariant,
      ),
      useIndicator: true,
      labelType: NavigationRailLabelType.all,
    );
  }
}
