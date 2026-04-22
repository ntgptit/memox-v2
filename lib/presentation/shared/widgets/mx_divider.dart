import 'package:flutter/material.dart';

/// Themed horizontal divider. Width / thickness / color come from the active
/// theme's [DividerThemeData]; pass [indent] / [endIndent] when a row needs
/// to align the divider with a text column.
class MxDivider extends StatelessWidget {
  const MxDivider({
    this.indent = 0,
    this.endIndent = 0,
    super.key,
  });

  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      indent: indent,
      endIndent: endIndent,
    );
  }
}
