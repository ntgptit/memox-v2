import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_folder_tile.dart';
import '../models/library_folder.dart';

class LibraryFolderList extends StatelessWidget {
  const LibraryFolderList({
    required this.folders,
    required this.onOpenFolder,
    super.key,
  });

  final List<LibraryFolder> folders;
  final ValueChanged<String> onOpenFolder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < folders.length; index++) ...[
          MxFolderTile(
            name: folders[index].name,
            icon: folders[index].icon,
            caption: AppLocalizations.of(context).libraryFolderStats(
              folders[index].deckCount,
              folders[index].itemCount,
            ),
            masteryPercent: folders[index].masteryPercent,
            onTap: () => onOpenFolder(folders[index].id),
          ),
          if (index < folders.length - 1) const MxDivider(),
        ],
      ],
    );
  }
}
