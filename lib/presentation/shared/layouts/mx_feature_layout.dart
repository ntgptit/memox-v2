import 'package:flutter/widgets.dart';

import '../../../core/theme/tokens/app_radius.dart';

abstract final class MxFeatureSizes {
  static const double reorderPanelHeight = 520;
  static const double flashcardReorderPanelHeight = 560;
}

abstract final class MxFeatureRadii {
  static const BorderRadius heroPanel = AppRadius.card;
  static const BorderRadius md = AppRadius.borderMd;
  static const BorderRadius full = AppRadius.borderFull;
}
