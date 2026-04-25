import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import '../widgets/mx_tappable.dart';

enum MxActionSheetItemTone { neutral, destructive }

/// Value object for one entry rendered by [MxActionSheetList].
class MxActionSheetItem<T> {
  const MxActionSheetItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.trailing,
    this.enabled = true,
    this.tone = MxActionSheetItemTone.neutral,
  });

  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool enabled;
  final MxActionSheetItemTone tone;
}

/// Compact, theme-safe action list for bottom sheets and contextual menus.
class MxActionSheetList<T> extends StatelessWidget {
  const MxActionSheetList({
    required this.items,
    this.onSelected,
    this.selectedValue,
    this.popOnSelect = true,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.shrinkWrap = true,
    super.key,
  });

  final List<MxActionSheetItem<T>> items;
  final ValueChanged<T>? onSelected;
  final T? selectedValue;
  final bool popOnSelect;
  final EdgeInsetsGeometry padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics:
          physics ?? (shrinkWrap ? const NeverScrollableScrollPhysics() : null),
      itemCount: items.length,
      separatorBuilder: (context, index) => const MxGap(AppSpacing.xs),
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedValue != null && item.value == selectedValue;

        return _MxActionSheetTile<T>(
          item: item,
          isSelected: isSelected,
          onSelected: onSelected,
          popOnSelect: popOnSelect,
        );
      },
    );
  }
}

class _MxActionSheetTile<T> extends StatelessWidget {
  const _MxActionSheetTile({
    required this.item,
    required this.isSelected,
    required this.onSelected,
    required this.popOnSelect,
  });

  final MxActionSheetItem<T> item;
  final bool isSelected;
  final ValueChanged<T>? onSelected;
  final bool popOnSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDestructive = item.tone == MxActionSheetItemTone.destructive;

    final backgroundColor = switch ((isSelected, isDestructive)) {
      (true, true) => scheme.errorContainer,
      (true, false) => scheme.primaryContainer,
      (false, _) => scheme.surface.withValues(alpha: AppOpacity.transparent),
    };

    final foregroundColor = isDestructive ? scheme.error : scheme.onSurface;
    final subtitleColor = isDestructive
        ? scheme.error
        : scheme.onSurfaceVariant;
    final effectiveTrailing =
        item.trailing ??
        (isSelected
            ? Icon(
                Icons.check_rounded,
                size: AppIconSizes.md,
                color: foregroundColor,
              )
            : null);

    return Opacity(
      opacity: item.enabled ? AppOpacity.full : AppOpacity.disabled,
      child: MxTappable(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
        onTap: () => _handleTap(context),
        enabled: item.enabled,
        backgroundColor: backgroundColor,
        overlayBaseColor: foregroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: item.subtitle == null
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: AppIconSizes.md, color: foregroundColor),
                const MxGap(AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label,
                      style: textTheme.bodyLarge?.copyWith(
                        color: foregroundColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.subtitle != null) ...[
                      const MxGap(AppSpacing.xxs),
                      Text(
                        item.subtitle!,
                        style: textTheme.bodyMedium?.copyWith(
                          color: subtitleColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (effectiveTrailing != null) ...[
                const MxGap(AppSpacing.sm),
                effectiveTrailing,
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    onSelected?.call(item.value);
    if (popOnSelect) {
      Navigator.of(context).pop(item.value);
    }
  }
}
