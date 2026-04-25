import 'package:flutter/material.dart';

import '../../../shared/layouts/mx_feature_layout.dart';
import '../../../shared/widgets/mx_reorderable_list.dart';
import '../../../shared/widgets/mx_term_row.dart';
import '../viewmodels/flashcard_list_viewmodel.dart';

class FlashcardReorderList extends StatelessWidget {
  const FlashcardReorderList({
    required this.state,
    required this.orderedIds,
    required this.onReorder,
    super.key,
  });

  final FlashcardListState state;
  final List<String> orderedIds;
  final ReorderCallback onReorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MxFeatureSizes.flashcardReorderPanelHeightFor(context),
      child: MxReorderableList.builder(
        itemCount: orderedIds.length,
        buildDefaultDragHandles: true,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final item = state.items.firstWhere(
            (flashcard) => flashcard.id == orderedIds[index],
          );
          return KeyedSubtree(
            key: ValueKey(item.id),
            child: MxTermRow(
              term: item.front,
              definition: item.back,
              caption: item.note,
            ),
          );
        },
      ),
    );
  }
}
