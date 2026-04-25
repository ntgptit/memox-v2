import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_folder_tile.dart';
import '../../../shared/widgets/mx_study_progress_action.dart';
import '../../../shared/widgets/mx_study_set_tile.dart';
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
      final items = state.subfolders;
      return Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _SubfolderRow(item: items[index], onOpenSubfolder: onOpenSubfolder),
            if (index < items.length - 1) const MxDivider(),
          ],
        ],
      );
    }

    final decks = state.decks;
    return Column(
      children: [
        for (var index = 0; index < decks.length; index++) ...[
          _DeckRow(item: decks[index]),
          if (index < decks.length - 1) const MxDivider(),
        ],
      ],
    );
  }
}

/// Sliver-based renderer for a folder's children (subfolders or decks).
///
/// Returns a [SliverList.separated] so rows are lazily built — important
/// when a folder owns dozens of items and the parent screen is a
/// [CustomScrollView].
class FolderTreeSliver extends StatelessWidget {
  const FolderTreeSliver({
    required this.state,
    required this.onOpenSubfolder,
    super.key,
  });

  final FolderDetailState state;
  final ValueChanged<String> onOpenSubfolder;

  @override
  Widget build(BuildContext context) {
    if (state.isSubfolderMode) {
      final items = state.subfolders;
      return SliverList.separated(
        itemCount: items.length,
        itemBuilder: (context, index) =>
            _SubfolderRow(item: items[index], onOpenSubfolder: onOpenSubfolder),
        separatorBuilder: (context, index) => const MxDivider(),
      );
    }

    final decks = state.decks;
    return SliverList.separated(
      itemCount: decks.length,
      itemBuilder: (context, index) => _DeckRow(item: decks[index]),
      separatorBuilder: (context, index) => const MxDivider(),
    );
  }
}

class _SubfolderRow extends StatelessWidget {
  const _SubfolderRow({required this.item, required this.onOpenSubfolder});

  final FolderSubfolderItem item;
  final ValueChanged<String> onOpenSubfolder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxFolderTile(
      name: item.name,
      icon: item.icon,
      caption: l10n.libraryFolderStats(item.deckCount, item.itemCount),
      onTap: () => onOpenSubfolder(item.id),
      trailing: MxStudyProgressAction(
        key: ValueKey('folder_recursive_study_${item.id}'),
        masteryPercent: item.masteryPercent,
        cardCount: item.itemCount,
        tooltip: l10n.studyStartAction,
        onPressed: () =>
            context.goStudyEntry(entryType: 'folder', entryRefId: item.id),
      ),
    );
  }
}

class _DeckRow extends StatelessWidget {
  const _DeckRow({required this.item});

  final FolderDeckItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxStudySetTile(
      title: item.name,
      icon: Icons.style_outlined,
      metaLine: l10n.foldersDeckCardProgress(item.cardCount, item.dueToday),
      onTap: () => context.pushDeckDetail(item.id),
      trailing: MxStudyProgressAction(
        key: ValueKey('deck_study_${item.id}'),
        masteryPercent: item.masteryPercent,
        cardCount: item.cardCount,
        tooltip: l10n.studyStartAction,
        onPressed: () =>
            context.goStudyEntry(entryType: 'deck', entryRefId: item.id),
      ),
    );
  }
}
