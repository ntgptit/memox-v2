import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_deck_card.dart';
import '../../../shared/widgets/mx_folder_tile.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

/// Sliver-based renderer for a folder's children (subfolders or decks).
///
/// Returns a [SliverList.separated] so rows are lazily built — important
/// when a folder owns dozens of items and the parent screen is a
/// [CustomScrollView].
class FolderTreeSliver extends StatelessWidget {
  const FolderTreeSliver({
    required this.state,
    required this.onOpenSubfolder,
    this.onOpenSubfolderActions,
    this.onOpenDeckActions,
    super.key,
  });

  final FolderDetailState state;
  final ValueChanged<String> onOpenSubfolder;
  final ValueChanged<FolderSubfolderItem>? onOpenSubfolderActions;
  final ValueChanged<FolderDeckItem>? onOpenDeckActions;

  @override
  Widget build(BuildContext context) {
    if (state.isSubfolderMode) {
      final items = state.subfolders;
      return SliverList.separated(
        itemCount: items.length,
        itemBuilder: (context, index) => _SubfolderRow(
          item: items[index],
          onOpenSubfolder: onOpenSubfolder,
          onOpenActions: onOpenSubfolderActions,
        ),
        separatorBuilder: (context, index) => const MxGap(MxSpace.sm),
      );
    }

    final decks = state.decks;
    return SliverList.separated(
      itemCount: decks.length,
      itemBuilder: (context, index) =>
          _DeckCard(item: decks[index], onOpenActions: onOpenDeckActions),
      separatorBuilder: (context, index) => const MxGap(MxSpace.sm),
    );
  }
}

class _SubfolderRow extends StatelessWidget {
  const _SubfolderRow({
    required this.item,
    required this.onOpenSubfolder,
    this.onOpenActions,
  });

  final FolderSubfolderItem item;
  final ValueChanged<String> onOpenSubfolder;
  final ValueChanged<FolderSubfolderItem>? onOpenActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final stats = l10n.libraryFolderStats(
      item.subfolderCount,
      item.deckCount,
      item.itemCount,
    );
    final dueSuffix = item.dueCardCount > 0
        ? ' ${l10n.libraryDeckDueSuffix(item.dueCardCount)}'
        : '';
    return MxFolderTile(
      name: item.name,
      icon: item.icon,
      caption: '$stats$dueSuffix',
      masteryPercent: item.masteryPercent,
      onTap: () => onOpenSubfolder(item.id),
      onLongPress: onOpenActions == null ? null : () => onOpenActions!(item),
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({required this.item, this.onOpenActions});

  final FolderDeckItem item;
  final ValueChanged<FolderDeckItem>? onOpenActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = l10n.foldersDeckStats(item.cardCount);
    final due = item.dueToday > 0
        ? ' ${l10n.libraryDeckDueSuffix(item.dueToday)}'
        : ' · ${l10n.libraryDeckAllCaughtUp}';
    return MxDeckCard(
      title: item.name,
      icon: Icons.style_outlined,
      metaLine: '$cards$due',
      masteryPercent: item.masteryPercent,
      onTap: () => context.pushFlashcardList(item.id),
      onLongPress: onOpenActions == null ? null : () => onOpenActions!(item),
    );
  }
}
