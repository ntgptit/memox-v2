import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/states/mx_empty_state.dart';

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
