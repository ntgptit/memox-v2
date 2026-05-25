import 'package:flutter/material.dart';

import '../../../core/theme/extensions/theme_extensions.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import '../motion/mx_motion.dart';
import 'mx_tappable.dart';
import 'mx_text.dart';

/// Single tab in [MxTabBar]: a label and an optional count badge.
@immutable
class MxTabBarItem {
  const MxTabBarItem({required this.label, this.count});

  final String label;
  final int? count;
}

// guard:raw-size-reviewed indicator stroke thickness per Design System tab bar
const double _kMxTabBarIndicatorHeight = 3;
// guard:raw-size-reviewed track bottom rule thickness per Design System
const double _kMxTabBarTrackHeight = 1;

/// Top-level tab bar with an underline indicator under the selected label.
///
/// Distinct from [BulkAddTabs]-style pill switches: this is the "page section"
/// tabs (Học phần / Thư mục / Lớp học pattern) called out in CLAUDE.md as
/// a missing shared catalogue widget.
class MxTabBar extends StatelessWidget {
  const MxTabBar({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final List<MxTabBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: scheme.outlineVariant.withValues(
              alpha: AppOpacity.ghostBorder,
            ),
            width: _kMxTabBarTrackHeight,
          ),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            _MxTabBarTab(
              item: items[i],
              isSelected: i == selectedIndex,
              onTap: () => onChanged(i),
            ),
        ],
      ),
    );
  }
}

class _MxTabBarTab extends StatelessWidget {
  const _MxTabBarTab({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final MxTabBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = isSelected ? scheme.primary : scheme.onSurfaceVariant;
    return MxTappable(
      shape: const RoundedRectangleBorder(),
      onTap: onTap,
      semanticsLabel: item.label,
      child: AnimatedContainer(
        duration: MxDurations.stateChange,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: scheme.primary.withValues(
                alpha: isSelected ? AppOpacity.full : AppOpacity.transparent,
              ),
              width: _kMxTabBarIndicatorHeight,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MxText(item.label, role: MxTextRole.tileTitle, color: foreground),
            if (item.count != null) ...[
              const MxGap(AppSpacing.sm),
              _MxTabBarCountBadge(count: item.count!, isActive: isSelected),
            ],
          ],
        ),
      ),
    );
  }
}

class _MxTabBarCountBadge extends StatelessWidget {
  const _MxTabBarCountBadge({required this.count, required this.isActive});

  final int count;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mx = context.mxColors;
    final bg = isActive
        ? scheme.primary.withValues(alpha: AppOpacity.ghostBorder)
        : mx.streak.withValues(alpha: AppOpacity.disabledSurface);
    final fg = isActive ? scheme.primary : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.borderFull,
      ),
      child: MxText(count.toString(), role: MxTextRole.badge, color: fg),
    );
  }
}
