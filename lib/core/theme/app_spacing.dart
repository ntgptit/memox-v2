import 'package:flutter/widgets.dart';

/// 4-point spacing scale.
///
/// Raw token layer — owned by `core/theme/`. Features must not import this
/// file directly (guard: `feature_theme_token_imports`). They read spacing
/// through `MxSpace` in `theme_extensions.dart`.
abstract final class AppSpacing {
  static const double none = 0;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;

  /// 16 — default content padding.
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 40;

  // --- Semantic paddings ---
  static const EdgeInsets screenHorizontal =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets screenVertical = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets screen = EdgeInsets.all(lg);
  static const EdgeInsets card = EdgeInsets.all(lg);
  static const EdgeInsets listItem =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets dialog = EdgeInsets.all(xxl);
  static const EdgeInsets sheet = EdgeInsets.fromLTRB(lg, md, lg, xxl);
}
