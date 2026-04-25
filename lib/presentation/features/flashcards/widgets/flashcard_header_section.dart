import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';

class FlashcardHeaderSection extends StatelessWidget {
  const FlashcardHeaderSection({
    required this.state,
    required this.onBack,
    required this.onOpenBreadcrumb,
    this.onOpenActions,
    super.key,
  });

  final FlashcardListState state;
  final VoidCallback onBack;
  final ValueChanged<String> onOpenBreadcrumb;
  final VoidCallback? onOpenActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MxIconButton(
              icon: Icons.arrow_back,
              tooltip: l10n.commonBack,
              onPressed: onBack,
            ),
            const MxGap(MxSpace.sm),
            Expanded(child: MxText(state.deckName, role: MxTextRole.pageTitle)),
            if (onOpenActions != null) ...[
              const MxGap(MxSpace.sm),
              MxIconButton(
                icon: Icons.more_horiz_rounded,
                tooltip: l10n.decksMoreActionsTooltip,
                onPressed: onOpenActions,
              ),
            ],
          ],
        ),
        const MxGap(MxSpace.sm),
        MxBreadcrumbBar(
          items: [
            for (var index = 0; index < state.breadcrumb.length; index++)
              MxBreadcrumb(
                label: state.breadcrumb[index].label,
                onTap:
                    index == state.breadcrumb.length - 1 ||
                        state.breadcrumb[index].folderId == null
                    ? null
                    : () => onOpenBreadcrumb(state.breadcrumb[index].folderId!),
              ),
          ],
        ),
      ],
    );
  }
}
