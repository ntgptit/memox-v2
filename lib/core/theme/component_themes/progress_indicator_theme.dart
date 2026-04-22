import 'package:flutter/material.dart';

abstract final class ProgressIndicatorThemeBuilder {
  static ProgressIndicatorThemeData build(ColorScheme scheme) {
    return ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.surfaceContainerHighest,
      circularTrackColor: scheme.surfaceContainerHighest,
      refreshBackgroundColor: scheme.surfaceContainerHigh,
      linearMinHeight: 6,
    );
  }
}
