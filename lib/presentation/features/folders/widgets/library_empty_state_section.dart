import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/mx_empty_state.dart';

class LibraryEmptyStateSection extends StatelessWidget {
  const LibraryEmptyStateSection({required this.onCreateFolder, super.key});

  final VoidCallback onCreateFolder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      icon: Icons.folder_open_outlined,
      title: l10n.libraryEmptyTitle,
      message: l10n.libraryEmptyMessage,
      actionLabel: l10n.libraryCreateFolderTooltip,
      actionLeadingIcon: Icons.add,
      onAction: onCreateFolder,
    );
  }
}

/// Shown when a scope-local Library search matches no top-level folder. Kept
/// visually distinct from [LibraryEmptyStateSection] so a non-empty library is
/// never mistaken for an empty one. Mirrors Folder Detail's no-results surface.
class LibrarySearchNoResultsSection extends StatelessWidget {
  const LibrarySearchNoResultsSection({required this.onClearSearch, super.key});

  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      icon: Icons.search_off_outlined,
      title: l10n.foldersNoResultsTitle,
      message: l10n.foldersNoResultsMessage,
      actionLabel: l10n.foldersClearSearchAction,
      actionLeadingIcon: Icons.search_off_outlined,
      onAction: onClearSearch,
    );
  }
}
