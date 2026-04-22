import 'package:flutter/material.dart';

import '../app_elevation.dart';
import '../app_radius.dart';

abstract final class CardThemeBuilder {
  static CardThemeData build(ColorScheme scheme) {
    return CardThemeData(
      color: scheme.surfaceContainerLow,
      shadowColor: scheme.shadow,
      surfaceTintColor: scheme.surfaceTint,
      elevation: AppElevation.card,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
    );
  }
}
