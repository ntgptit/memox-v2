import 'package:flutter/material.dart';

import '../../../core/theme/tokens/app_spacing.dart';
import '../layouts/mx_gap.dart';
import 'mx_card.dart';
import 'mx_icon_tile.dart';
import 'mx_text.dart';

/// Home-style summary card for a review queue or next-action surface.
class MxDueSummaryCard extends StatelessWidget {
  const MxDueSummaryCard({
    required this.label,
    required this.title,
    required this.message,
    required this.action,
    this.icon = Icons.school_outlined,
    super.key,
  });

  final String label;
  final String title;
  final String message;
  final IconData icon;
  final Widget action;

  @override
  Widget build(BuildContext context) => MxCard(
      variant: MxCardVariant.outlined,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MxIconTile(icon: icon, tone: MxIconTileTone.primarySoft),
                const MxGap(AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MxText(label, role: MxTextRole.formLabel),
                      const MxGap(AppSpacing.xs),
                      MxText(
                        title,
                        role: MxTextRole.sectionTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const MxGap(AppSpacing.xs),
                      MxText(
                        message,
                        role: MxTextRole.tileMeta,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: action,
          ),
        ],
      ),
    );
}
