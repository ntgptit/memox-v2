import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/deck_detail_viewmodel.dart';

class DeckHeaderSection extends StatelessWidget {
  const DeckHeaderSection({
    required this.state,
    required this.onBack,
    required this.onOpenActions,
    required this.onOpenBreadcrumb,
    super.key,
  });

  final DeckDetailState state;
  final VoidCallback onBack;
  final VoidCallback onOpenActions;
  final ValueChanged<String> onOpenBreadcrumb;

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
            Expanded(child: MxText(state.name, role: MxTextRole.pageTitle)),
            MxIconButton(
              icon: Icons.more_horiz_rounded,
              tooltip: l10n.decksMoreActionsTooltip,
              onPressed: onOpenActions,
            ),
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
