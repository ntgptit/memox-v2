import 'package:flutter/material.dart';

import '../../../core/theme/app_layout.dart';

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
    super.key,
  });

  final Widget child;

  /// Content-width role. Defaults to [MxContentWidth.wide].
  final MxContentWidth width;

  /// Override the horizontal gutter. Defaults to
  /// `AppLayout.pagePadding(windowSize)` so padding scales with window size.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final maxWidth = context.contentMaxWidth(width);
    final gutter = padding ?? context.pagePadding;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: gutter, child: child),
      ),
    );
  }
}
