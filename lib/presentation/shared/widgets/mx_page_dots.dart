import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_spacing.dart';
import '../motion/mx_motion.dart';
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
    final localizations = MaterialLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Builder(
            builder: (context) {
              final isActive = i == activeIndex;
              final hasTap = onDotTap != null;
              final semanticsLabel = localizations.tabLabel(
                tabIndex: i + 1,
                tabCount: count,
              );

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                child: Semantics(
                  button: hasTap,
                  enabled: hasTap ? true : null,
                  selected: isActive,
                  label: semanticsLabel,
                  onTap: hasTap ? () => onDotTap!(i) : null,
                  child: ExcludeSemantics(
                    child: MxTappable(
                      shape: isActive
                          ? const StadiumBorder()
                          : const CircleBorder(),
                      onTap: hasTap ? () => onDotTap!(i) : null,
                      child: SizedBox.square(
                        dimension: kMinInteractiveDimension,
                        child: Center(
                          child: AnimatedContainer(
                            duration: MxDurations.stateChange,
                            width: isActive
                                ? AppSpacing
                                      .lg // guard:raw-size-reviewed active dot uses lg token
                                : AppSpacing
                                      .xs, // guard:raw-size-reviewed inactive dot uses xs token
                            height: isActive
                                ? AppSpacing
                                      .sm // guard:raw-size-reviewed active dot height uses sm token
                                : AppSpacing
                                      .xs, // guard:raw-size-reviewed inactive dot height uses xs token
                            decoration: BoxDecoration(
                              color: isActive
                                  ? scheme.primary
                                  : scheme.outlineVariant,
                              shape: isActive
                                  ? BoxShape.rectangle
                                  : BoxShape.circle,
                              borderRadius: isActive
                                  ? const BorderRadius.all(
                                      Radius.circular(AppSpacing.xs),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
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
