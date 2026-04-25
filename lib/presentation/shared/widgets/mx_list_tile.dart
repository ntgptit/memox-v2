import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/theme/tokens/app_spacing.dart';
import 'mx_text.dart';

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
                  color: scheme.primaryContainer,
                  borderRadius: AppRadius.borderSm,
                ),
                alignment: Alignment.center,
                child: Icon(
                  leadingIcon,
                  size: AppIconSizes.md,
                  color: scheme.onPrimaryContainer,
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
      title: MxText(
        title,
        role: dense ? MxTextRole.tileTitle : MxTextRole.listTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: MxText(
                subtitle!,
                role: MxTextRole.listSubtitle,
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
