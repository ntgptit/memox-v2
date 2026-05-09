import 'package:flutter/material.dart';

import '../tokens/app_elevation.dart';
import '../tokens/app_opacity.dart';
import '../tokens/app_radius.dart';

abstract final class CardThemeBuilder {
  static CardThemeData build(ColorScheme scheme) {
    return CardThemeData(
      color: scheme.surfaceContainerLow,
      shadowColor: scheme.shadow.withValues(
        alpha: scheme.brightness == Brightness.light ? 0.32 : 0.60,
      ),
      surfaceTintColor: scheme.surfaceTint.withValues(
        alpha: AppOpacity.transparent,
      ),
      elevation: AppElevation.card,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
    );
  }
}
