import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_folder_tile.dart';
import '../../../shared/widgets/mx_study_set_tile.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

class FolderTreeSection extends StatelessWidget {
  const FolderTreeSection({
    required this.state,
    required this.onOpenSubfolder,
    super.key,
  });

  final FolderDetailState state;
  final ValueChanged<String> onOpenSubfolder;

  @override
  Widget build(BuildContext context) {
    if (state.isSubfolderMode) {
      final l10n = AppLocalizations.of(context);
      return Column(
        children: [
          for (var index = 0; index < state.subfolders.length; index++) ...[
            MxFolderTile(
              name: state.subfolders[index].name,
              icon: state.subfolders[index].icon,
              caption: l10n.libraryFolderStats(
                state.subfolders[index].deckCount,
                state.subfolders[index].itemCount,
              ),
              onTap: () => onOpenSubfolder(state.subfolders[index].id),
            ),
            if (index < state.subfolders.length - 1) const MxDivider(),
          ],
        ],
      );
    }

    return Column(
      children: [
        for (var index = 0; index < state.decks.length; index++) ...[
          MxStudySetTile(
            title: state.decks[index].name,
            icon: Icons.style_outlined,
            metaLine: AppLocalizations.of(context).foldersDeckCardProgress(
              state.decks[index].cardCount,
              state.decks[index].dueToday,
            ),
            onTap: () => context.pushDeckDetail(state.decks[index].id),
            trailing: MxText(
              AppLocalizations.of(
                context,
              ).commonPercentValue(state.decks[index].masteryPercent),
              role: MxTextRole.tileTrailing,
            ),
          ),
          if (index < state.decks.length - 1) const MxDivider(),
        ],
      ],
    );
  }
}
