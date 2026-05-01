import 'package:flutter/widgets.dart';

import '../../../core/theme/tokens/app_radius.dart';

abstract final class MxFeatureSizes {
  static const double reorderPanelHeight = 520;
  static const double flashcardReorderPanelHeight = 560;

  static const double _reorderPanelMinHeight = 280;
  static const double _flashcardReorderPanelMinHeight = 320;
  static const double _reorderPanelHeightRatio = 0.62;
  static const double _flashcardReorderPanelHeightRatio = 0.68;

  static double reorderPanelHeightFor(BuildContext context) {
    final availableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.paddingOf(context).vertical;

    return (availableHeight * _reorderPanelHeightRatio)
        .clamp(_reorderPanelMinHeight, reorderPanelHeight)
        .toDouble();
  }

  static double flashcardReorderPanelHeightFor(BuildContext context) {
    final availableHeight =
        MediaQuery.sizeOf(context).height -
        MediaQuery.paddingOf(context).vertical;

    return (availableHeight * _flashcardReorderPanelHeightRatio)
        .clamp(_flashcardReorderPanelMinHeight, flashcardReorderPanelHeight)
        .toDouble();
  }
}

abstract final class MxFeatureRadii {
  static const BorderRadius heroPanel = AppRadius.card;
  static const BorderRadius md = AppRadius.borderLg;
  static const BorderRadius full = AppRadius.borderFull;
}
