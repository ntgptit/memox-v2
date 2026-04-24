import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_section.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

class FolderSummarySection extends StatelessWidget {
  const FolderSummarySection({
    required this.state,
    required this.onStartStudy,
    super.key,
  });

  final FolderDetailState state;
  final VoidCallback onStartStudy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final subtitle = switch (state.mode) {
      FolderDetailMode.unlocked => l10n.foldersSummaryUnlocked,
      FolderDetailMode.subfolders => l10n.foldersStatusSubfolders(
        state.subfolders.length,
      ),
      FolderDetailMode.decks => l10n.foldersStatusDecks(
        state.decks.length,
        state.decks.fold<int>(0, (sum, item) => sum + item.cardCount),
      ),
    };

    return MxSection(
      title: state.header.name,
      subtitle: subtitle,
      action: MxSecondaryButton(
        label: l10n.studyStartAction,
        leadingIcon: Icons.play_arrow_rounded,
        variant: MxSecondaryVariant.tonal,
        onPressed: onStartStudy,
      ),
      child: const SizedBox.shrink(),
    );
  }
}
