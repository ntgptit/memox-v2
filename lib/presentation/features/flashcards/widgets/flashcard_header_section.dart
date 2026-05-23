import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_text.dart';

class FlashcardHeaderSection extends StatelessWidget {
  const FlashcardHeaderSection({
    required this.title,
    required this.onBack,
    this.onShare,
    this.onOpenActions,
    super.key,
  });

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onShare;
  final VoidCallback? onOpenActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        MxIconButton.toolbar(
          icon: Icons.arrow_back,
          tooltip: l10n.commonBack,
          onPressed: onBack,
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: MxText(
            title,
            role: MxTextRole.sheetTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onShare != null) ...[
          const MxGap(MxSpace.xs),
          MxIconButton.toolbar(
            icon: Icons.share_outlined,
            tooltip: l10n.commonExport,
            onPressed: onShare,
          ),
        ],
        if (onOpenActions != null) ...[
          const MxGap(MxSpace.xs),
          MxIconButton.toolbar(
            icon: Icons.more_vert_rounded,
            tooltip: l10n.decksMoreActionsTooltip,
            onPressed: onOpenActions,
          ),
        ],
      ],
    );
  }
}
