import 'package:flutter/widgets.dart';

/// Axis-agnostic gap widget.
///
/// Use [MxGap] for vertical spacing and [MxGap.h] for horizontal spacing.
/// The size must come from a spacing token — `MxSpace.*` in features,
/// `AppSpacing.*` in shared widgets / component themes.
class MxGap extends StatelessWidget {
  const MxGap(this.size, {super.key}) : _horizontal = false;
  const MxGap.h(this.size, {super.key}) : _horizontal = true;

  final double size;
  final bool _horizontal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _horizontal ? size : null,
      height: _horizontal ? null : size,
    );
  }
}
