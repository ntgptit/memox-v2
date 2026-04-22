import 'package:flutter/material.dart';

import '../app_opacity.dart';

abstract final class TextSelectionThemeBuilder {
  static TextSelectionThemeData build(ColorScheme scheme) {
    return TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionColor: scheme.primary.withValues(alpha: AppOpacity.handle),
      selectionHandleColor: scheme.primary,
    );
  }
}
