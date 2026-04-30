import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_empty_state.dart';
import '../../../shared/widgets/mx_primary_button.dart';

enum FolderEmptyStateMode { unlocked, subfolders, decks, noResults }

class FolderEmptyStateSection extends StatelessWidget {
  const FolderEmptyStateSection({
    required this.mode,
    required this.onCreateSubfolder,
    required this.onCreateDeck,
    required this.onClearSearch,
    super.key,
  });

  final FolderEmptyStateMode mode;
  final VoidCallback onCreateSubfolder;
  final VoidCallback onCreateDeck;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final content = _resolveContent(l10n);
    final actions = _buildActions(l10n);
    return Column(
      children: [
        MxEmptyState(
          title: content.title,
          message: content.message,
          icon: content.icon,
        ),
        if (actions.isNotEmpty) ...[
          const MxGap(MxSpace.lg),
          Wrap(
            spacing: MxSpace.sm,
            runSpacing: MxSpace.sm,
            alignment: WrapAlignment.center,
            children: actions,
          ),
        ],
      ],
    );
  }

  _FolderEmptyContent _resolveContent(AppLocalizations l10n) {
    return switch (mode) {
      FolderEmptyStateMode.unlocked => _FolderEmptyContent(
        title: l10n.foldersEmptyTitle,
        message: l10n.foldersEmptyMessage,
        icon: Icons.folder_open_outlined,
      ),
      FolderEmptyStateMode.subfolders => _FolderEmptyContent(
        title: l10n.foldersEmptySubfoldersTitle,
        message: l10n.foldersEmptySubfoldersMessage,
        icon: Icons.create_new_folder_outlined,
      ),
      FolderEmptyStateMode.decks => _FolderEmptyContent(
        title: l10n.foldersEmptyDecksTitle,
        message: l10n.foldersEmptyDecksMessage,
        icon: Icons.style_outlined,
      ),
      FolderEmptyStateMode.noResults => _FolderEmptyContent(
        title: l10n.foldersNoResultsTitle,
        message: l10n.foldersNoResultsMessage,
        icon: Icons.search_off_outlined,
      ),
    };
  }

  List<Widget> _buildActions(AppLocalizations l10n) {
    return switch (mode) {
      FolderEmptyStateMode.unlocked => const <Widget>[],
      FolderEmptyStateMode.subfolders => [
        MxPrimaryButton(
          label: l10n.foldersNewSubfolderTooltip,
          leadingIcon: Icons.create_new_folder_outlined,
          onPressed: onCreateSubfolder,
        ),
      ],
      FolderEmptyStateMode.decks => [
        MxPrimaryButton(
          label: l10n.foldersNewDeckTooltip,
          leadingIcon: Icons.style_outlined,
          onPressed: onCreateDeck,
        ),
      ],
      FolderEmptyStateMode.noResults => [
        MxPrimaryButton(
          label: l10n.foldersClearSearchAction,
          leadingIcon: Icons.search_off_outlined,
          onPressed: onClearSearch,
        ),
      ],
    };
  }
}

class _FolderEmptyContent {
  const _FolderEmptyContent({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;
}
