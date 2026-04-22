import 'package:flutter/widgets.dart';

/// Window-size thresholds, aligned with Material 3 window size classes.
///
/// Thresholds only — no layout decisions (content width, page padding, etc.)
/// live here. Those belong to `app_layout.dart` so the responsive system
/// keeps a clean split between "how big is the window" and "what does that
/// mean for this component".
abstract final class AppBreakpoints {
  /// 0–599: phones portrait.
  static const double compact = 600;

  /// 600–839: small tablets, phones landscape.
  static const double medium = 840;

  /// 840–1199: tablets, small laptops.
  static const double expanded = 1200;

  /// 1200–1599: desktops.
  static const double large = 1600;

  /// 1600+: extra large displays.
  static const double extraLarge = 1920;
}

enum WindowSize { compact, medium, expanded, large, extraLarge }

extension WindowSizeX on BuildContext {
  WindowSize get windowSize {
    final width = MediaQuery.sizeOf(this).width;
    if (width < AppBreakpoints.compact) return WindowSize.compact;
    if (width < AppBreakpoints.medium) return WindowSize.medium;
    if (width < AppBreakpoints.expanded) return WindowSize.expanded;
    if (width < AppBreakpoints.large) return WindowSize.large;
    return WindowSize.extraLarge;
  }

  bool get isCompact => windowSize == WindowSize.compact;
  bool get isMediumOrLarger => windowSize.index >= WindowSize.medium.index;
  bool get isExpandedOrLarger => windowSize.index >= WindowSize.expanded.index;
}
