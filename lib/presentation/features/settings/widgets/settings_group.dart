import 'package:flutter/material.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_badge.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_icon_tile.dart';
import '../../../shared/widgets/mx_tappable.dart';
import '../../../shared/widgets/mx_text.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.onTap,
    this.contentPadding = const EdgeInsets.all(MxSpace.lg),
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry contentPadding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MxText(
                    title,
                    role: MxTextRole.formLabel,
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
        const MxGap(MxSpace.sm),
        MxCard(
          variant: MxCardVariant.filled,
          padding: contentPadding,
          onTap: onTap,
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
    this.valueTone = MxBadgeTone.neutral,
    this.onTap,
    this.showChevron = true,
    this.preserveSubtitleOnCompact = false,
    this.iconTone = MxIconTileTone.primarySoft,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final MxBadgeTone valueTone;
  final VoidCallback? onTap;
  final bool showChevron;
  final bool preserveSubtitleOnCompact;
  final MxIconTileTone iconTone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final showSubtitle =
        subtitle != null &&
        (context.showsSupportingCopy || preserveSubtitleOnCompact);
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: MxSpace.lg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: MxSpace.xxl + MxSpace.xxl + MxSpace.lg,
        ),
        child: Row(
          children: [
            MxIconTile(icon: icon, tone: iconTone),
            const MxGap(MxSpace.lg),
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

    if (onTap == null) {
      return content;
    }

    return MxTappable(
      shape: const RoundedRectangleBorder(),
      semanticsLabel: title,
      onTap: onTap,
      showOverlay: false,
      child: content,
    );
  }
}
