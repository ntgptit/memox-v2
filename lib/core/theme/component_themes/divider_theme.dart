import 'package:flutter/material.dart';

abstract final class DividerThemeBuilder {
  static DividerThemeData build(ColorScheme scheme) => DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    );
}
