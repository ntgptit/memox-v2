import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_sizes.dart';
import '../../../core/theme/app_opacity.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Opinionated list tile with stronger title weight, optional leading tile
/// icon, trailing chevron or custom widget, and consistent paddings.
class MxListTile extends StatelessWidget {
  const MxListTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.dense = false,
    this.selected = false,
    this.showChevron = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool dense;
  final bool selected;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final listTileTheme = theme.listTileTheme;

    final effectiveLeading =
        leading ??
        (leadingIcon != null
            ? Container(
                width: AppSpacing.xxxxl, // 40
                height: AppSpacing.xxxxl, // 40
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: AppRadius.borderMd,
                ),
                alignment: Alignment.center,
                child: Icon(
                  leadingIcon,
                  size: AppIconSizes.md,
                  color: scheme.onSecondaryContainer,
                ),
              )
            : null);

    final effectiveTrailing =
        trailing ??
        (showChevron
            ? Icon(
                Icons.chevron_right,
                size: AppIconSizes.lg,
                color: scheme.onSurfaceVariant,
              )
            : null);

    return ListTile(
      leading: effectiveLeading,
      title: Text(
        title,
        style:
            (dense ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)
                ?.copyWith(color: scheme.onSurface),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : null,
      trailing: effectiveTrailing,
      onTap: onTap,
      onLongPress: onLongPress,
      selected: selected,
      selectedTileColor:
          listTileTheme.selectedTileColor ??
          scheme.secondaryContainer.withValues(alpha: AppOpacity.half),
      contentPadding:
          listTileTheme.contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
      visualDensity: dense
          ? VisualDensity.compact
          : listTileTheme.visualDensity,
      shape:
          listTileTheme.shape ??
          const RoundedRectangleBorder(borderRadius: AppRadius.card),
    );
  }
}
