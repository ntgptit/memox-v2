import 'package:flutter/material.dart';

import '../tokens/app_elevation.dart';
import '../tokens/app_radius.dart';

abstract final class CardThemeBuilder {
  static CardThemeData build(ColorScheme scheme) => CardThemeData(
    color: scheme.surfaceContainerLowest,
    shadowColor: scheme.shadow.withValues(
      alpha: scheme.brightness == Brightness.light ? 0.32 : 0.60,
    ),
    surfaceTintColor: scheme.surfaceTint,
    elevation: AppElevation.card,
    margin: EdgeInsets.zero,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
  );
}
