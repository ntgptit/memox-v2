import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';
import 'app_spacing.dart';

/// Role-based width for centered content columns.
///
/// A screen picks a role; the layout layer maps the role to a concrete
/// max-width per window size. Screens never hardcode pixel widths.
enum MxContentWidth {
  /// Single column optimized for reading (body copy, forms).
  reading,

  /// Wide list/detail column — dashboards, library listings.
  wide,

  /// Hero / illustration-heavy layouts that can breathe on desktop.
  hero,

  /// No cap — full available width.
  full,
}

/// Centralized layout specs.
///
/// Holds every repeated layout rule in the app: page padding, content-column
/// width, rail width, section gap, grid columns, dialog width. Every screen
/// and shell reads from this class so a change here propagates everywhere.
///
/// Rule of thumb when you feel the need for a "responsive number":
/// 1. If it is a layout rule (padding, width, gap), add or read it here.
/// 2. If it is a typography / color / radius token, use the token layers.
/// 3. Only `core/theme/` + `presentation/shared/layouts/` should hold raw
///    pixel numbers. Features describe layout through roles and tokens.
abstract final class AppLayout {
  // --- Rail / navigation ----------------------------------------------------

  /// Width of the extended navigation rail (drawer-style) on large screens.
  static const double railWidth = 256;

  // --- Page padding --------------------------------------------------------

  /// Horizontal padding for a top-level page gutter. Grows with window size
  /// so desktop layouts don't look cramped against the viewport edge.
  static EdgeInsets pagePadding(WindowSize size) {
    switch (size) {
      case WindowSize.compact:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
      case WindowSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
      case WindowSize.expanded:
      case WindowSize.large:
      case WindowSize.extraLarge:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xxl);
    }
  }

  /// Top padding for a top-level page body.
  static double pageTopPadding(WindowSize size) =>
      size.index >= WindowSize.expanded.index ? AppSpacing.xl : AppSpacing.lg;

  /// Bottom padding for a top-level page body.
  static double pageBottomPadding(WindowSize size, {bool hasFab = false}) =>
      hasFab ? AppSpacing.xxxl : AppSpacing.xl;

  /// Full page insets for a scrollable body.
  static EdgeInsets pageInsets(WindowSize size, {bool hasFab = false}) {
    final horizontal = pagePadding(size);
    return EdgeInsets.fromLTRB(
      horizontal.left,
      pageTopPadding(size),
      horizontal.right,
      pageBottomPadding(size, hasFab: hasFab),
    );
  }

  // --- Content width --------------------------------------------------------

  /// Max width for a centered content column at [role] on [size].
  /// Returns `double.infinity` when the role opts out of capping.
  static double contentMaxWidth(MxContentWidth role, WindowSize size) {
    switch (role) {
      case MxContentWidth.reading:
        return 720;
      case MxContentWidth.wide:
        return size == WindowSize.compact ? double.infinity : 1120;
      case MxContentWidth.hero:
        return size.index >= WindowSize.large.index ? 1440 : 1120;
      case MxContentWidth.full:
        return double.infinity;
    }
  }

  // --- Section gap ---------------------------------------------------------

  /// Vertical gap between top-level sections on a page.
  static double sectionGap(WindowSize size) =>
      size.index >= WindowSize.expanded.index ? AppSpacing.xxl : AppSpacing.lg;

  // --- Grid columns ---------------------------------------------------------

  /// Default column count for card grids. [base] multiplies the scale so a
  /// denser grid can opt into `base: 2` and still keep the tier ramp.
  static int gridColumns(WindowSize size, {int base = 1}) {
    switch (size) {
      case WindowSize.compact:
        return base;
      case WindowSize.medium:
        return base * 2;
      case WindowSize.expanded:
        return base * 3;
      case WindowSize.large:
        return base * 4;
      case WindowSize.extraLarge:
        return base * 6;
    }
  }

  // --- Dialog / sheet -------------------------------------------------------

  /// Max width for a centered dialog on a wide window. Dialogs stay
  /// full-width on compact.
  static double dialogMaxWidth(WindowSize size) =>
      size == WindowSize.compact ? double.infinity : 560;
}

/// Ergonomics: read layout specs straight off [BuildContext] so feature code
/// doesn't keep re-deriving the window size.
extension LayoutContext on BuildContext {
  EdgeInsets get pagePadding => AppLayout.pagePadding(windowSize);
  double get pageTopPadding => AppLayout.pageTopPadding(windowSize);
  double pageBottomPadding({bool hasFab = false}) =>
      AppLayout.pageBottomPadding(windowSize, hasFab: hasFab);
  EdgeInsets pageInsets({bool hasFab = false}) =>
      AppLayout.pageInsets(windowSize, hasFab: hasFab);
  double contentMaxWidth(MxContentWidth role) =>
      AppLayout.contentMaxWidth(role, windowSize);
  double get sectionGap => AppLayout.sectionGap(windowSize);
  int gridColumns({int base = 1}) =>
      AppLayout.gridColumns(windowSize, base: base);
  double get dialogMaxWidth => AppLayout.dialogMaxWidth(windowSize);
}
