import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_folder_tile.dart';
import '../../../shared/widgets/mx_study_progress_action.dart';
import '../models/library_folder.dart';

/// Sliver-based folder list for the library overview.
///
/// Lazy-builds each row so a large library does not blow up the first frame.
class LibraryFolderSliver extends StatelessWidget {
  const LibraryFolderSliver({
    required this.folders,
    required this.onOpenFolder,
    required this.onStartStudy,
    this.onOpenActions,
    super.key,
  });

  final List<LibraryFolder> folders;
  final ValueChanged<String> onOpenFolder;
  final ValueChanged<String> onStartStudy;
  final ValueChanged<LibraryFolder>? onOpenActions;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: folders.length,
      itemBuilder: (context, index) => _LibraryFolderRow(
        folder: folders[index],
        onOpenFolder: onOpenFolder,
        onStartStudy: onStartStudy,
        onOpenActions: onOpenActions,
      ),
      separatorBuilder: (context, index) => const MxDivider(),
    );
  }
}

class _LibraryFolderRow extends StatelessWidget {
  const _LibraryFolderRow({
    required this.folder,
    required this.onOpenFolder,
    required this.onStartStudy,
    this.onOpenActions,
  });

  final LibraryFolder folder;
  final ValueChanged<String> onOpenFolder;
  final ValueChanged<String> onStartStudy;
  final ValueChanged<LibraryFolder>? onOpenActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxFolderTile(
      name: folder.name,
      icon: folder.icon,
      caption: l10n.libraryFolderStats(
        folder.subfolderCount,
        folder.deckCount,
        folder.itemCount,
      ),
      supportingCaption: l10n.libraryFolderMastery(folder.masteryPercent),
      onTap: () => onOpenFolder(folder.id),
      onLongPress: onOpenActions == null ? null : () => onOpenActions!(folder),
      trailing: MxStudyProgressAction(
        key: ValueKey('library_folder_recursive_study_${folder.id}'),
        masteryPercent: folder.masteryPercent,
        badgeCount: folder.dueCardCount,
        tooltip: l10n.studyStartAction,
        onPressed: () => onStartStudy(folder.id),
      ),
    );
  }
}
