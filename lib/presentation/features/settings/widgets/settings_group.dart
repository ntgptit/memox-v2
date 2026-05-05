import 'package:flutter/material.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_text.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.title,
    required this.child,
    this.subtitle,
    this.action,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? action;
  final VoidCallback? onTap;
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
        MxCard(variant: MxCardVariant.filled, onTap: onTap, child: child),
      ],
    );
  }
}
