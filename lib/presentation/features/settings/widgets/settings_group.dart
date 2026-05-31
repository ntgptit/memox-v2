import 'package:flutter/material.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/theme/tokens/app_opacity.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_badge.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_icon_tile.dart';
import '../../../shared/widgets/mx_loading_state.dart';
import '../../../shared/widgets/mx_tappable.dart';
import '../../../shared/widgets/mx_text.dart';

enum SettingsGroupStyle { standard, hub }

enum SettingsRowStyle { standard, hub }

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.onTap,
    this.contentPadding = const EdgeInsets.all(MxSpace.lg),
    this.style = SettingsGroupStyle.standard,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;
  final SettingsGroupStyle style;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isHub = style == SettingsGroupStyle.hub;
    final titleRole = isHub ? MxTextRole.overline : MxTextRole.formLabel;
    final titleText = isHub ? StringUtils.uppercased(title) : title;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: isHub
              ? const EdgeInsets.only(
                  left: MxSpace.xs,
                  right: MxSpace.xs,
                  bottom: MxSpace.sm,
                )
              : EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MxText(
                      titleText,
                      role: titleRole,
                      color: scheme.onSurfaceVariant,
                    ),
                    if (subtitle != null) ...[
                      const MxGap(MxSpace.xxs),
                      MxText(subtitle!, role: MxTextRole.formHelper),
                    ],
                  ],
                ),
              ),
              ?action,
            ],
          ),
        ),
        if (!isHub) const MxGap(MxSpace.sm),
        MxCard(
          variant: MxCardVariant.filled,
          padding: contentPadding,
          onTap: onTap,
          borderRadius: isHub ? AppRadius.borderLg : null,
          child: child,
        ),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.valueTone = MxBadgeTone.neutral,
    this.onTap,
    this.showChevron = true,
    this.preserveSubtitleOnCompact = false,
    this.iconTone = MxIconTileTone.primarySoft,
    this.style = SettingsRowStyle.standard,
    this.enabled = true,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final MxBadgeTone valueTone;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool preserveSubtitleOnCompact;
  final MxIconTileTone iconTone;
  final SettingsRowStyle style;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isHub = style == SettingsRowStyle.hub;
    final showSubtitle =
        subtitle != null &&
        (context.showsSupportingCopy || preserveSubtitleOnCompact);
    final horizontalPadding = isHub ? MxSpace.md + MxSpace.xxs : MxSpace.lg;
    final verticalPadding = isHub ? MxSpace.md + MxSpace.xxs : 0.0;
    final minHeight = isHub
        ? _settingsHubIconTileSize
        : MxSpace.xxl + MxSpace.xxl + MxSpace.lg;
    final content = Opacity(
      opacity: enabled ? AppOpacity.full : AppOpacity.half,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Row(
            children: [
              MxIconTile(
                icon: icon,
                tone: iconTone,
                size: isHub ? _settingsHubIconTileSize : null,
                iconSize: isHub ? AppIconSizes.md : null,
              ),
              MxGap(isHub ? MxSpace.md + MxSpace.xxs : MxSpace.lg),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MxText(
                      title,
                      role: MxTextRole.listTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (showSubtitle) ...[
                      const MxGap(MxSpace.xxs),
                      MxText(
                        subtitle!,
                        role: MxTextRole.listSubtitle,
                        maxLines: context.showsSupportingCopy ? 2 : 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const MxGap(MxSpace.sm),
                Flexible(
                  child: MxBadge(label: value, tone: valueTone),
                ),
              ],
              if (trailing != null) ...[const MxGap(MxSpace.sm), trailing!],
              if (showChevron) ...[
                const MxGap(MxSpace.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: MxSpace.xxl,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (onTap == null || !enabled) {
      return content;
    }

    return MxTappable(
      shape: const RoundedRectangleBorder(),
      onTap: onTap,
      showOverlay: false,
      child: content,
    );
  }
}

class SettingsLoadingRow extends StatelessWidget {
  const SettingsLoadingRow({
    this.icon = Icons.settings_outlined,
    this.title,
    this.titleWidth = 132,
    this.subtitleWidth = 180,
    this.showChevron = true,
    this.style = SettingsRowStyle.standard,
    super.key,
  });

  final IconData icon;
  final String? title;
  final double titleWidth;
  final double subtitleWidth;
  final bool showChevron;
  final SettingsRowStyle style;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isHub = style == SettingsRowStyle.hub;
    final horizontalPadding = isHub ? MxSpace.md + MxSpace.xxs : MxSpace.lg;
    final verticalPadding = isHub ? MxSpace.md + MxSpace.xxs : 0.0;
    final minHeight = isHub
        ? _settingsHubIconTileSize
        : MxSpace.xxl + MxSpace.xxl + MxSpace.lg;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Row(
          children: [
            MxIconTile(
              icon: icon,
              tone: MxIconTileTone.disabled,
              size: isHub ? _settingsHubIconTileSize : null,
              iconSize: isHub ? AppIconSizes.md : null,
            ),
            MxGap(isHub ? MxSpace.md + MxSpace.xxs : MxSpace.lg),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title == null
                      ? MxSkeleton(width: titleWidth, height: MxSpace.md)
                      : MxText(
                          title!,
                          role: MxTextRole.listTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  const MxGap(MxSpace.sm),
                  MxSkeleton(width: subtitleWidth, height: MxSpace.sm),
                ],
              ),
            ),
            if (showChevron) ...[
              const MxGap(MxSpace.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: MxSpace.xxl,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// guard:raw-size-reviewed the mobile UI kit Settings hub uses a compact
// 36 dp leading tile inside navigation rows.
const double _settingsHubIconTileSize = 36;
