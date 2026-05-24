import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_folder_tile.dart';
import '../models/library_folder.dart';

/// Sliver-based folder list for the library overview.
///
/// Lazy-builds each row so a large library does not blow up the first frame.
class LibraryFolderSliver extends StatelessWidget {
  const LibraryFolderSliver({
    required this.folders,
    required this.onOpenFolder,
    this.onOpenActions,
    super.key,
  });

  final List<LibraryFolder> folders;
  final ValueChanged<String> onOpenFolder;
  final ValueChanged<LibraryFolder>? onOpenActions;

  @override
  Widget build(BuildContext context) => SliverList.separated(
      itemCount: folders.length,
      itemBuilder: (context, index) => _LibraryFolderRow(
        folder: folders[index],
        onOpenFolder: onOpenFolder,
        onOpenActions: onOpenActions,
      ),
      separatorBuilder: (context, index) => const MxGap(MxSpace.sm),
    );
}

class _LibraryFolderRow extends StatelessWidget {
  const _LibraryFolderRow({
    required this.folder,
    required this.onOpenFolder,
    this.onOpenActions,
  });

  final LibraryFolder folder;
  final ValueChanged<String> onOpenFolder;
  final ValueChanged<LibraryFolder>? onOpenActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = l10n.libraryFolderStats(
      folder.subfolderCount,
      folder.deckCount,
      folder.itemCount,
    );
    final dueSuffix = folder.dueCardCount > 0
        ? ' ${l10n.libraryDeckDueSuffix(folder.dueCardCount)}'
        : '';
    return MxFolderTile(
      name: folder.name,
      icon: folder.icon,
      caption: '$stats$dueSuffix',
      masteryPercent: folder.masteryPercent,
      onTap: () => onOpenFolder(folder.id),
      onLongPress: onOpenActions == null ? null : () => onOpenActions!(folder),
    );
  }
}
