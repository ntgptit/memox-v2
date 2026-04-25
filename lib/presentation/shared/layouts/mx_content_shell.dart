import 'package:flutter/material.dart';

import '../../../core/theme/responsive/app_layout.dart';

/// Caps a content column at a role-appropriate max width and applies the
/// current tier's page padding.
///
/// Use the [width] role instead of passing pixel numbers — that way every
/// screen is described in terms of intent (`reading`, `wide`, `hero`, or
/// `full`) and the layout layer decides the concrete width per tier.
class MxContentShell extends StatelessWidget {
  const MxContentShell({
    required this.child,
    this.width = MxContentWidth.wide,
    this.padding,
    this.applyVerticalPadding = false,
    this.hasFab = false,
    super.key,
  });

  final Widget child;

  /// Content-width role. Defaults to [MxContentWidth.wide].
  final MxContentWidth width;

  /// Override the horizontal gutter. Defaults to
  /// `AppLayout.pagePadding(windowSize)` or `AppLayout.pageInsets(...)` when
  /// [applyVerticalPadding] is true.
  final EdgeInsetsGeometry? padding;

  /// When true, apply the full page insets instead of horizontal gutter only.
  final bool applyVerticalPadding;

  /// Whether the page should reserve extra bottom clearance for a FAB.
  final bool hasFab;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.contentMaxWidth(width);
    final gutter =
        padding ??
        (applyVerticalPadding
            ? context.pageInsets(hasFab: hasFab)
            : context.pagePadding);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: gutter, child: child),
      ),
    );
  }
}
