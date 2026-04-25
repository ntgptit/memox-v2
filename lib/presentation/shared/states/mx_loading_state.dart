import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../widgets/mx_progress_indicator.dart';
import '../layouts/mx_gap.dart';
import '../widgets/mx_text.dart';

/// Full-area loading placeholder with optional label.
class MxLoadingState extends StatelessWidget {
  const MxLoadingState({
    this.message,
    this.progressSize = MxProgressSize.large,
    super.key,
  });

  final String? message;
  final MxProgressSize progressSize;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxCircularProgress(size: progressSize),
          if (message != null) ...[
            const MxGap(AppSpacing.lg),
            MxText(message!, role: MxTextRole.stateMessage),
          ],
        ],
      ),
    );
  }
}

/// Skeleton placeholder block with subtle pulse animation.
class MxSkeleton extends StatefulWidget {
  const MxSkeleton({
    this.width,
    this.height = 14,
    this.borderRadius = AppRadius.borderSm,
    super.key,
  });

  final double? width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<MxSkeleton> createState() => _MxSkeletonState();
}

class _MxSkeletonState extends State<MxSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(
              scheme.surfaceContainerHigh,
              scheme.surfaceContainerHighest,
              t,
            ),
            borderRadius: widget.borderRadius,
          ),
        );
      },
    );
  }
}
