import 'package:flutter/material.dart';

import '../tokens/app_icon_sizes.dart';

abstract final class IconThemeBuilder {
  static IconThemeData primary(ColorScheme scheme) =>
      IconThemeData(color: scheme.onSurface, size: AppIconSizes.md);

  static IconThemeData onPrimary(ColorScheme scheme) =>
      IconThemeData(color: scheme.onPrimary, size: AppIconSizes.md);
}
