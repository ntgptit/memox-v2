import 'package:flutter/material.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';
import 'flashcard_detail_card_row.dart';

class FlashcardItemsSection extends StatelessWidget {
  const FlashcardItemsSection({
    required this.state,
    required this.deckId,
    required this.selection,
    required this.onToggleSelection,
    required this.onOpenActions,
    required this.onSpeak,
    super.key,
  });

  final FlashcardListState state;
  final String deckId;
  final Set<String> selection;
  final ValueChanged<String> onToggleSelection;
  final ValueChanged<FlashcardListItemState> onOpenActions;
  final ValueChanged<FlashcardListItemState> onSpeak;

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      key: const ValueKey('flashcard_lazy_items'),
      itemCount: state.items.length,
      itemBuilder: (context, index) => _FlashcardItemRow(
        item: state.items[index],
        deckId: deckId,
        selection: selection,
        onToggleSelection: onToggleSelection,
        onOpenActions: onOpenActions,
        onSpeak: onSpeak,
      ),
      separatorBuilder: (context, index) => const MxGap(MxSpace.sm),
    );
  }
}

class _FlashcardItemRow extends StatelessWidget {
  const _FlashcardItemRow({
    required this.item,
    required this.deckId,
    required this.selection,
    required this.onToggleSelection,
    required this.onOpenActions,
    required this.onSpeak,
  });

  final FlashcardListItemState item;
  final String deckId;
  final Set<String> selection;
  final ValueChanged<String> onToggleSelection;
  final ValueChanged<FlashcardListItemState> onOpenActions;
  final ValueChanged<FlashcardListItemState> onSpeak;

  @override
  Widget build(BuildContext context) {
    return FlashcardDetailCardRow(
      item: item,
      selected: selection.contains(item.id),
      onTap: () {
        if (selection.isNotEmpty) {
          onToggleSelection(item.id);
          return;
        }
        context.pushFlashcardEdit(deckId: deckId, flashcardId: item.id);
      },
      onLongPress: () {
        if (selection.isNotEmpty) {
          onToggleSelection(item.id);
          return;
        }
        onOpenActions(item);
      },
      onSpeak: () => onSpeak(item),
      onSelect: () => onToggleSelection(item.id),
    );
  }
}
