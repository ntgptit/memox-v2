import 'package:flutter/widgets.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

abstract final class MxFeatureSpacing {
  static const double none = AppSpacing.none;
  static const double xxs = AppSpacing.xxs;
  static const double xs = AppSpacing.xs;
  static const double sm = AppSpacing.sm;
  static const double md = AppSpacing.md;
  static const double lg = AppSpacing.lg;
  static const double xl = AppSpacing.xl;
  static const double xxl = AppSpacing.xxl;
  static const double xxxl = AppSpacing.xxxl;
  static const double xxxxl = AppSpacing.xxxxl;
}

abstract final class MxFeatureSizes {
  static const double reorderPanelHeight = 520;
  static const double flashcardReorderPanelHeight = 560;
}

abstract final class MxFeatureRadii {
  static const BorderRadius heroPanel = AppRadius.card;
  static const BorderRadius md = AppRadius.borderMd;
  static const BorderRadius full = AppRadius.borderFull;
}
