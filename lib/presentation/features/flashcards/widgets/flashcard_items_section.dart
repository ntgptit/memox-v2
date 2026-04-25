import 'package:flutter/material.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_term_row.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';

class FlashcardItemsSection extends StatelessWidget {
  const FlashcardItemsSection({
    required this.state,
    required this.deckId,
    required this.selection,
    required this.onToggleSelection,
    required this.onOpenActions,
    super.key,
  });

  final FlashcardListState state;
  final String deckId;
  final Set<String> selection;
  final ValueChanged<String> onToggleSelection;
  final ValueChanged<FlashcardListItemState> onOpenActions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < state.items.length; index++) ...[
          MxTermRow(
            term: state.items[index].front,
            definition: state.items[index].back,
            caption: state.items[index].note,
            selected: selection.contains(state.items[index].id),
            onTap: () {
              if (selection.isNotEmpty) {
                onToggleSelection(state.items[index].id);
                return;
              }
              context.pushFlashcardEdit(
                deckId: deckId,
                flashcardId: state.items[index].id,
              );
            },
            onLongPress: () {
              if (selection.isNotEmpty) {
                onToggleSelection(state.items[index].id);
                return;
              }
              onOpenActions(state.items[index]);
            },
          ),
          if (index < state.items.length - 1) const MxGap(MxSpace.sm),
        ],
      ],
    );
  }
}
