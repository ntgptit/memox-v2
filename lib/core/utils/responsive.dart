import 'package:flutter/widgets.dart';

import '../theme/responsive/app_breakpoints.dart';

// -----------------------------------------------------------------------------
// Responsive primitives
// -----------------------------------------------------------------------------
//
// This file is the LOW-LEVEL primitive layer for tier-aware values. It is
// intentionally small and opinion-free.
//
// Contract (read before adding callers):
//
//   1. Any layout decision that is repeated across screens — page padding,
//      content-column width, section gap, grid columns, rail width, dialog
//      width — MUST live in `core/theme/responsive/app_layout.dart` (`AppLayout` +
//      `LayoutContext` extension). Features read those via
//      `context.pagePadding`, `context.contentMaxWidth(role)`,
//      `context.sectionGap`, `context.gridColumns(...)`, etc.
//
//   2. `context.responsive<T>(...)` and `context.adaptive<T>(...)` are the
//      ONLY allowed escape hatch, for genuinely one-off tier-aware values
//      that do NOT correspond to a layout role (e.g. a local animation
//      curve, a grid extent override for a single feature). If you find
//      yourself writing the same `context.responsive` call on three screens,
//      promote it to `AppLayout`.
//
//   3. NEVER branch on `MediaQuery.sizeOf(context).width > N`, `Orientation`,
//      or raw breakpoint numbers inside widgets. Go through
//      `context.windowSize` / `context.isCompact` / `context.isExpandedOrLarger`
//      or one of the APIs above.
//
// If you are tempted to reach for a "responsive column count" helper: use
// `context.gridColumns()` on `LayoutContext`. The legacy
// `responsiveColumnCount` free function was removed — it duplicated
// `AppLayout.gridColumns`.
// -----------------------------------------------------------------------------

/// Value picker that returns the best match for the current [WindowSize].
///
/// Only [compact] is required. Any missing tier falls through to the next
/// smaller tier that *is* provided. Think mobile-first defaults with
/// progressive enhancement for larger windows.
///
/// Prefer the role-based APIs on `AppLayout` / `LayoutContext` for anything
/// that could plausibly be reused. Use this primitive for genuine one-offs
/// only.
///
/// ```dart
/// final extent = context.responsive<double>(
///   compact: 160,
///   expanded: 220,
///   large: 260,
/// );
/// ```
@immutable
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.extraLarge,
  });

  final T compact;
  final T? medium;
  final T? expanded;
  final T? large;
  final T? extraLarge;

  T resolve(WindowSize size) {
    switch (size) {
      case WindowSize.extraLarge:
        return extraLarge ?? large ?? expanded ?? medium ?? compact;
      case WindowSize.large:
        return large ?? expanded ?? medium ?? compact;
      case WindowSize.expanded:
        return expanded ?? medium ?? compact;
      case WindowSize.medium:
        return medium ?? compact;
      case WindowSize.compact:
        return compact;
    }
  }
}

extension ResponsiveContext on BuildContext {
  /// Pick a value that scales with the active [WindowSize]. Missing tiers
  /// fall back to the next smaller tier that was provided.
  ///
  /// Use this ONLY for one-off tier-aware values. Anything that is a
  /// recurring layout rule belongs in `AppLayout`.
  T responsive<T>({
    required T compact,
    T? medium,
    T? expanded,
    T? large,
    T? extraLarge,
  }) {
    return ResponsiveValue<T>(
      compact: compact,
      medium: medium,
      expanded: expanded,
      large: large,
      extraLarge: extraLarge,
    ).resolve(windowSize);
  }

  /// Short-circuit for the common "phone vs everything else" split.
  ///
  /// Prefer `isExpandedOrLarger` directly when you only need the boolean.
  /// Use `adaptive` when you need to pick between two values inline.
  T adaptive<T>({required T compact, required T expanded}) {
    return isExpandedOrLarger ? expanded : compact;
  }
}
