import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart' as gap;

/// Axis-aware gap wrapper used across MemoX.
///
/// [MxGap] delegates to the `gap` package so the spacing direction follows the
/// surrounding `Flex` or scrollable automatically. Do not re-introduce a
/// second constructor such as `.h`; the single-constructor API is intentional
/// so the axis cannot be selected incorrectly at call sites.
///
/// The size must come from a spacing token — `MxSpace.*` in features,
/// `AppSpacing.*` in shared widgets / component themes.
class MxGap extends StatelessWidget {
  const MxGap(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return gap.Gap(size);
  }
}

/// Sliver counterpart of [MxGap].
class MxSliverGap extends StatelessWidget {
  const MxSliverGap(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return gap.SliverGap(size);
  }
}
