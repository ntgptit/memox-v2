import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_spacing.dart';
import 'mx_tappable.dart';

/// Compact page indicator dots used under the flashcard carousel and other
/// swipeable card hero areas.
class MxPageDots extends StatelessWidget {
  const MxPageDots({
    required this.count,
    required this.activeIndex,
    this.onDotTap,
    super.key,
  });

  final int count;
  final int activeIndex;
  final ValueChanged<int>? onDotTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Builder(
            builder: (context) {
              final isActive = i == activeIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                child: MxTappable(
                  shape: isActive
                      ? const StadiumBorder()
                      : const CircleBorder(),
                  onTap: onDotTap == null ? null : () => onDotTap!(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: isActive
                        ? AppSpacing
                              .sm // guard:raw-size-reviewed active dot uses sm token
                        : AppSpacing
                              .xs, // guard:raw-size-reviewed inactive dot uses xs token
                    height: AppSpacing
                        .xs, // guard:raw-size-reviewed dot height uses xs token
                    decoration: BoxDecoration(
                      color: isActive
                          ? scheme.primary
                          : scheme.onSurfaceVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
