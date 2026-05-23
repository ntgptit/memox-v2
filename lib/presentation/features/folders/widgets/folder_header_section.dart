import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_breakpoints.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_breadcrumb_bar.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

class FolderHeaderSection extends StatelessWidget {
  const FolderHeaderSection({
    required this.state,
    required this.onBack,
    required this.onOpenActions,
    required this.onOpenBreadcrumb,
    super.key,
  });

  final FolderDetailState state;
  final VoidCallback onBack;
  final VoidCallback onOpenActions;
  final ValueChanged<String> onOpenBreadcrumb;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaryLine = _resolveSummary(l10n);
    final showSummary =
        context.showsSupportingCopy || state.mode != FolderDetailMode.unlocked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FolderHeaderTitleRow(
          title: state.header.name,
          isCompact: context.isCompact,
          onBack: onBack,
          onOpenActions: onOpenActions,
        ),
        const MxGap(MxSpace.sm),
        MxBreadcrumbBar(
          items: [
            for (var index = 0; index < state.header.breadcrumb.length; index++)
              MxBreadcrumb(
                label: state.header.breadcrumb[index].label,
                onTap:
                    index == state.header.breadcrumb.length - 1 ||
                        state.header.breadcrumb[index].folderId == null
                    ? null
                    : () => onOpenBreadcrumb(
                        state.header.breadcrumb[index].folderId!,
                      ),
              ),
          ],
        ),
        if (showSummary) ...[
          const MxGap(MxSpace.xs),
          MxText(
            summaryLine,
            role: MxTextRole.sectionSubtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  String _resolveSummary(AppLocalizations l10n) {
    return switch (state.mode) {
      FolderDetailMode.unlocked => l10n.foldersSummaryUnlocked,
      FolderDetailMode.subfolders => l10n.foldersStatusSubfolders(
        state.subfolders.length,
      ),
      FolderDetailMode.decks => l10n.foldersStatusDecks(
        state.decks.length,
        state.decks.fold<int>(0, (sum, item) => sum + item.cardCount),
      ),
    };
  }
}

class _FolderHeaderTitleRow extends StatelessWidget {
  const _FolderHeaderTitleRow({
    required this.title,
    required this.isCompact,
    required this.onBack,
    required this.onOpenActions,
  });

  final String title;
  final bool isCompact;
  final VoidCallback onBack;
  final VoidCallback onOpenActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final back = MxIconButton.toolbar(
      icon: Icons.arrow_back,
      tooltip: l10n.commonBack,
      onPressed: onBack,
    );
    final more = MxIconButton.toolbar(
      icon: Icons.more_horiz_rounded,
      tooltip: l10n.foldersMoreActionsTooltip,
      onPressed: onOpenActions,
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: MxSpace.sm,
            runSpacing: MxSpace.xs,
            children: [back, more],
          ),
          const MxGap(MxSpace.xs),
          MxText(title, role: MxTextRole.pageTitle),
        ],
      );
    }

    return Row(
      children: [
        back,
        const MxGap(MxSpace.sm),
        Expanded(child: MxText(title, role: MxTextRole.pageTitle)),
        more,
      ],
    );
  }
}
