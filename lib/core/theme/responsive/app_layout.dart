import 'package:flutter/widgets.dart';

import 'app_breakpoints.dart';
import '../tokens/app_spacing.dart';

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
  /// guard:raw-size-reviewed compact button content threshold keeps icon-label
  /// rows from overflowing when a parent surface becomes narrower than a
  /// comfortable mobile button.
  static const double _buttonIconWidthFloor = 72;

  /// guard:raw-size-reviewed very narrow host width where empty state content
  /// must spend less horizontal space on padding so the action remains tappable.
  static const double _emptyStateDensePaddingWidth = 160;

  /// guard:raw-size-reviewed row width where the decorative folder tile
  /// leading tile can fit without starving the text column on compact surfaces.
  static const double _folderTileLeadingWidthFloor = 180;

  /// guard:raw-size-reviewed row width where trailing progress/action metadata
  /// can fit beside folder title and captions without making the row untappable.
  static const double _folderTileTrailingWidthFloor = 280;

  /// guard:raw-size-reviewed row width where a study-set trailing action can
  /// sit beside title/meta content without starving the text column.
  static const double _studySetTileInlineTrailingWidthFloor = 400;

  /// guard:raw-size-reviewed local width where section actions should move
  /// under the heading so compact/mobile copy keeps a readable line length.
  static const double _sectionActionInlineWidthFloor = 400;

  /// guard:raw-size-reviewed text scale where section actions stack even on a
  /// wider host because the title needs more vertical room.
  static const double _sectionActionLargeTextScale = 1.3;

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

  // --- Shared component density --------------------------------------------

  /// Whether an action button has enough local width to show decorative icons.
  static bool showsButtonIcons({
    required bool hasBoundedWidth,
    required double maxWidth,
  }) => !hasBoundedWidth || maxWidth >= _buttonIconWidthFloor;

  /// Whether empty-state padding should collapse on a very narrow host.
  static bool usesDenseEmptyStatePadding(double width) =>
      width <= _emptyStateDensePaddingWidth;

  /// Whether a folder tile has enough local width to show its leading icon tile.
  static bool showsFolderTileLeading({
    required bool hasBoundedWidth,
    required double maxWidth,
  }) => !hasBoundedWidth || maxWidth >= _folderTileLeadingWidthFloor;

  /// Whether a folder tile has enough local width to show trailing metadata.
  static bool showsFolderTileTrailing({
    required bool hasBoundedWidth,
    required double maxWidth,
  }) => !hasBoundedWidth || maxWidth >= _folderTileTrailingWidthFloor;

  /// Whether a study-set trailing action should sit under the text column.
  static bool stacksStudySetTileTrailing({
    required bool hasBoundedWidth,
    required double maxWidth,
  }) => hasBoundedWidth && maxWidth < _studySetTileInlineTrailingWidthFloor;

  /// Whether a section action should move below its heading on compact hosts.
  static bool stacksSectionAction({
    required bool hasBoundedWidth,
    required double maxWidth,
    required double textScale,
  }) =>
      textScale >= _sectionActionLargeTextScale ||
      (hasBoundedWidth && maxWidth < _sectionActionInlineWidthFloor);
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
