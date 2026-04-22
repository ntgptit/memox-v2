import 'package:flutter/animation.dart';

/// Animation duration tokens, aligned with Material 3 motion spec.
abstract final class AppDurations {
  static const Duration instant = Duration.zero;
  static const Duration xs = Duration(milliseconds: 100);
  static const Duration sm = Duration(milliseconds: 150);
  static const Duration md = Duration(milliseconds: 200);
  static const Duration lg = Duration(milliseconds: 300);
  static const Duration xl = Duration(milliseconds: 450);
  static const Duration xxl = Duration(milliseconds: 600);

  // --- Semantic durations ---
  static const Duration press = xs;
  static const Duration stateChange = sm;
  static const Duration fade = md;
  static const Duration slide = lg;
  static const Duration page = lg;
  static const Duration cardFlip = xl;
}

/// Easing curves aligned with Material 3 motion.
abstract final class AppCurves {
  static const Curve standard = Cubic(0.2, 0, 0, 1);
  static const Curve standardAccelerate = Cubic(0.3, 0, 1, 1);
  static const Curve standardDecelerate = Cubic(0, 0, 0, 1);

  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
  static const Curve emphasizedAccelerate = Cubic(0.3, 0, 0.8, 0.15);
  static const Curve emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1);
}
