import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/widgets/mx_folder_tile.dart';
import '../../../shared/widgets/mx_reorderable_list.dart';
import '../../../shared/widgets/mx_study_set_tile.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

class FolderReorderSection extends StatelessWidget {
  const FolderReorderSection({
    required this.state,
    required this.orderedIds,
    required this.onReorder,
    super.key,
  });

  final FolderDetailState state;
  final List<String> orderedIds;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    if (state.isSubfolderMode) {
      final orderedItems = [
        for (final id in orderedIds)
          state.subfolders.firstWhere((item) => item.id == id),
      ];
      return SizedBox(
        height: MxFeatureSizes.reorderPanelHeight,
        child: MxReorderableList.builder(
          itemCount: orderedItems.length,
          buildDefaultDragHandles: true,
          onReorder: onReorder,
          itemBuilder: (context, index) {
            final item = orderedItems[index];
            return KeyedSubtree(
              key: ValueKey(item.id),
              child: MxFolderTile(name: item.name, icon: item.icon),
            );
          },
        ),
      );
    }

    final orderedItems = [
      for (final id in orderedIds)
        state.decks.firstWhere((item) => item.id == id),
    ];
    return SizedBox(
      height: MxFeatureSizes.reorderPanelHeight,
      child: MxReorderableList.builder(
        itemCount: orderedItems.length,
        buildDefaultDragHandles: true,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final item = orderedItems[index];
          return KeyedSubtree(
            key: ValueKey(item.id),
            child: MxStudySetTile(
              title: item.name,
              icon: Icons.style_outlined,
              metaLine: AppLocalizations.of(
                context,
              ).foldersDeckCardProgress(item.cardCount, item.dueToday),
              trailing: MxText(
                AppLocalizations.of(
                  context,
                ).commonPercentValue(item.masteryPercent),
                role: MxTextRole.tileTrailing,
              ),
            ),
          );
        },
      ),
    );
  }
}
