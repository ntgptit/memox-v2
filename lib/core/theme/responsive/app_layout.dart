import 'package:flutter/widgets.dart';

import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';
import 'app_breakpoints.dart';

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
  /// guard:raw-size-reviewed phone width where the app switches from normal
  /// compact-window spacing to denser mobile component spacing.
  static const double _compactMobileWidth = 430;

  /// guard:raw-size-reviewed compact button content threshold keeps icon-label
  /// rows from overflowing when a parent surface becomes narrower than a
  /// comfortable mobile button.
  static const double _buttonIconWidthFloor = 72;

  /// guard:raw-size-reviewed compact Material 3 navigation bar height keeps
  /// destination labels visible while returning vertical room to phone screens.
  static const double _compactNavigationBarHeight = 68;

  /// guard:raw-size-reviewed normal dashboard/chart diameter used outside
  /// compact-mobile density.
  static const double _dashboardChartSize = 132;

  /// guard:raw-size-reviewed compact dashboard/chart diameter.
  static const double _compactDashboardChartSize = 112;

  /// guard:raw-size-reviewed normal dashboard/chart stroke width used outside
  /// compact-mobile density.
  static const double _dashboardChartStrokeWidth = 16;

  /// guard:raw-size-reviewed compact dashboard/chart stroke width.
  static const double _compactDashboardChartStrokeWidth = 12;

  /// guard:raw-size-reviewed normal state illustration circle.
  static const double _stateIllustrationSize = 72;

  /// guard:raw-size-reviewed compact state illustration circle.
  static const double _compactStateIllustrationSize = 60;

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
  /// sit beside title/meta content without starving the text column. Sized so
  /// the 98 px progress pill plus a 40 px leading icon and ~180 px title column
  /// stay inline on standard phone widths (360–430).
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

  /// Whether a physical viewport width should use compact-mobile density.
  static bool isCompactMobileWidth(double width) => width < _compactMobileWidth;

  // --- Page padding --------------------------------------------------------

  /// Horizontal padding for a top-level page gutter. Grows with window size
  /// so desktop layouts don't look cramped against the viewport edge.
  static EdgeInsets pagePadding(WindowSize size, {bool compactMobile = false}) {
    switch (size) {
      case WindowSize.compact:
        return EdgeInsets.symmetric(
          horizontal: compactMobile ? AppSpacing.md : AppSpacing.lg,
        );
      case WindowSize.medium:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
      case WindowSize.expanded:
      case WindowSize.large:
      case WindowSize.extraLarge:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xxl);
    }
  }

  /// Top padding for a top-level page body.
  static double pageTopPadding(WindowSize size, {bool compactMobile = false}) {
    if (compactMobile) return AppSpacing.md;
    return size.index >= WindowSize.expanded.index
        ? AppSpacing.xl
        : AppSpacing.lg;
  }

  /// Bottom padding for a top-level page body.
  static double pageBottomPadding(
    WindowSize size, {
    bool hasFab = false,
    bool compactMobile = false,
  }) {
    if (hasFab) return compactMobile ? AppSpacing.xxl : AppSpacing.xxxl;
    return compactMobile ? AppSpacing.lg : AppSpacing.xl;
  }

  /// Full page insets for a scrollable body.
  static EdgeInsets pageInsets(
    WindowSize size, {
    bool hasFab = false,
    bool compactMobile = false,
  }) {
    final horizontal = pagePadding(size, compactMobile: compactMobile);
    return EdgeInsets.fromLTRB(
      horizontal.left,
      pageTopPadding(size, compactMobile: compactMobile),
      horizontal.right,
      pageBottomPadding(size, hasFab: hasFab, compactMobile: compactMobile),
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
  static double sectionGap(WindowSize size, {bool compactMobile = false}) {
    if (compactMobile) return AppSpacing.md;
    return size.index >= WindowSize.expanded.index
        ? AppSpacing.xxl
        : AppSpacing.lg;
  }

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

  /// Whether compact surfaces should render explanatory/supporting copy.
  ///
  /// Compact mobile keeps decision-critical labels, statuses, actions, errors,
  /// empty-state recovery, and destructive warnings. Generic helper copy that
  /// repeats adjacent metrics should be hidden by the caller.
  static bool showsSupportingCopy(BuildContext context) =>
      !context.isCompactMobile;

  /// Default card padding for the active density. Compact-mobile uses the
  /// 16-dp `card` inset so Quizlet-style filled cards feel airy instead of
  /// table-row dense.
  static EdgeInsets cardPadding(BuildContext context) => AppSpacing.card;

  /// Default card corner radius for the active tier. Compact-mobile bumps to
  /// `xxl (24)` for the rounded Quizlet-mobile silhouette; ≥ medium keeps the
  /// `xl (20)` standard so wider layouts read as cards, not pills.
  static BorderRadius cardRadius(BuildContext context) =>
      context.isCompactMobile ? AppRadius.borderXxl : AppRadius.card;

  /// Larger card padding for visually prominent study/hero surfaces.
  static EdgeInsets prominentCardPadding(BuildContext context) =>
      EdgeInsets.all(context.isCompactMobile ? AppSpacing.lg : AppSpacing.xxl);

  /// Feature hero surface padding for the active density.
  static EdgeInsets heroPadding(BuildContext context) =>
      EdgeInsets.all(context.isCompactMobile ? AppSpacing.lg : AppSpacing.xl);

  /// List tile padding for the active density. Compact gets a chunkier
  /// vertical inset so rows read as tappable mobile cards, not table rows.
  static EdgeInsets listTilePadding(BuildContext context) =>
      EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: context.isCompactMobile ? AppSpacing.sm : AppSpacing.xs,
      );

  /// Minimum vertical padding inside a shared list tile. Drives the overall
  /// row height; compact-mobile gets the larger Quizlet-style ~64-dp row.
  static double listTileMinVerticalPadding(BuildContext context) =>
      context.isCompactMobile ? AppSpacing.md : AppSpacing.sm;

  /// Study-set leading icon tile size for the active density.
  static double studySetTileIconSize(BuildContext context) =>
      context.isCompactMobile ? 44 : 40;

  /// Default icon tile size for regular shared list rows.
  static double listTileIconSize(BuildContext context) =>
      context.isCompactMobile ? 44 : 40;

  /// Horizontal button padding for the active density.
  static double buttonHorizontalPadding(
    BuildContext context, {
    required double regular,
  }) => context.isCompactMobile ? AppSpacing.md : regular;

  /// Compact bottom navigation bar height. Returns null outside compact mobile
  /// so Material 3 keeps its standard desktop/tablet behavior.
  static double? navigationBarHeight(BuildContext context) =>
      context.isCompactMobile ? _compactNavigationBarHeight : null;

  /// Dashboard progress chart diameter for the active density.
  static double dashboardChartSize(BuildContext context) =>
      context.isCompactMobile
      ? _compactDashboardChartSize
      : _dashboardChartSize;

  /// Dashboard progress chart stroke for the active density.
  static double dashboardChartStrokeWidth(BuildContext context) =>
      context.isCompactMobile
      ? _compactDashboardChartStrokeWidth
      : _dashboardChartStrokeWidth;

  /// State illustration circle size for empty/error states.
  static double stateIllustrationSize(BuildContext context) =>
      context.isCompactMobile
      ? _compactStateIllustrationSize
      : _stateIllustrationSize;
}

/// Ergonomics: read layout specs straight off [BuildContext] so feature code
/// doesn't keep re-deriving the window size.
extension LayoutContext on BuildContext {
  bool get isCompactMobile =>
      AppLayout.isCompactMobileWidth(MediaQuery.sizeOf(this).width);
  bool get compactDensity => isCompactMobile;
  EdgeInsets get pagePadding =>
      AppLayout.pagePadding(windowSize, compactMobile: isCompactMobile);
  double get pageTopPadding =>
      AppLayout.pageTopPadding(windowSize, compactMobile: isCompactMobile);
  double pageBottomPadding({bool hasFab = false}) =>
      AppLayout.pageBottomPadding(
        windowSize,
        hasFab: hasFab,
        compactMobile: isCompactMobile,
      );
  EdgeInsets pageInsets({bool hasFab = false}) => AppLayout.pageInsets(
    windowSize,
    hasFab: hasFab,
    compactMobile: isCompactMobile,
  );
  double contentMaxWidth(MxContentWidth role) =>
      AppLayout.contentMaxWidth(role, windowSize);
  double get sectionGap =>
      AppLayout.sectionGap(windowSize, compactMobile: isCompactMobile);
  int gridColumns({int base = 1}) =>
      AppLayout.gridColumns(windowSize, base: base);
  double get dialogMaxWidth => AppLayout.dialogMaxWidth(windowSize);
  bool get showsSupportingCopy => AppLayout.showsSupportingCopy(this);
}
