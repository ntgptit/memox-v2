import 'package:flutter/material.dart';

/// Material 3 elevation tokens (dp).
///
/// In M3, elevation is expressed primarily via surfaceTint + tonal color,
/// but shadow elevation is still used for dialogs and floating elements.
abstract final class AppElevation {
  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 3;
  static const double level3 = 6;
  static const double level4 = 8;
  static const double level5 = 12;

  // --- Semantic elevations ---
  static const double appBar = level1;
  static const double appBarScrolled = level2;
  static const double card = level1;
  static const double cardRaised = level2;
  static const double cardHovered = level3;
  static const double button = level0;
  static const double buttonPressed = level1;
  static const double fab = level3;
  static const double fabHovered = level4;
  static const double dialog = level3;
  static const double bottomSheet = level3;
  static const double menu = level2;
  static const double snackbar = level3;
  static const double navigationBar = level2;
  static const double drawer = level1;
}

/// Soft custom shadows, used sparingly when tonal elevation is not enough
/// (e.g. floating sticky headers or overlay cards).
abstract final class AppShadows {
  static const List<BoxShadow> none = <BoxShadow>[];

  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x149FA2BF), blurRadius: 3, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x299FA2BF), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x2E9FA2BF), blurRadius: 16, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x529FA2BF), blurRadius: 2, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x269FA2BF), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x3D9FA2BF), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x339FA2BF), blurRadius: 32, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x529FA2BF), blurRadius: 8, offset: Offset(0, 4)),
  ];
}
