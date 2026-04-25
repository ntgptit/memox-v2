import 'package:flutter/material.dart';

/// Corner radius scale.
abstract final class AppRadius {
  static const double none = 0;
  static const double xs = 4;
  static const double sm = 6;
  static const double md = 10;
  static const double semi = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Pill / fully rounded.
  static const double full = 9999;

  // --- Radius ---
  static const Radius radiusXs = Radius.circular(xs);
  static const Radius radiusSm = Radius.circular(sm);
  static const Radius radiusMd = Radius.circular(md);
  static const Radius radiusSemi = Radius.circular(semi);
  static const Radius radiusLg = Radius.circular(lg);
  static const Radius radiusXl = Radius.circular(xl);
  static const Radius radiusXxl = Radius.circular(xxl);
  static const Radius radiusFull = Radius.circular(full);

  // --- BorderRadius ---
  static const BorderRadius borderXs = BorderRadius.all(radiusXs);
  static const BorderRadius borderSm = BorderRadius.all(radiusSm);
  static const BorderRadius borderMd = BorderRadius.all(radiusMd);
  static const BorderRadius borderSemi = BorderRadius.all(radiusSemi);
  static const BorderRadius borderLg = BorderRadius.all(radiusLg);
  static const BorderRadius borderXl = BorderRadius.all(radiusXl);
  static const BorderRadius borderXxl = BorderRadius.all(radiusXxl);
  static const BorderRadius borderFull = BorderRadius.all(radiusFull);

  // --- Semantic component radii ---
  static const BorderRadius button = borderSm;
  static const BorderRadius buttonSmall = borderSm;
  static const BorderRadius buttonPill = borderFull;
  static const BorderRadius chip = borderFull;
  static const BorderRadius card = borderMd;
  static const BorderRadius cardLarge = borderSemi;
  static const BorderRadius dialog = borderLg;
  static const BorderRadius bottomSheet = BorderRadius.vertical(top: radiusLg);
  static const BorderRadius input = borderMd;
  static const BorderRadius image = borderMd;
  static const BorderRadius banner = borderMd;
}
