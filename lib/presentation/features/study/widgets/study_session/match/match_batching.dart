import '../../../../../../domain/study/entities/study_models.dart';

const matchVisiblePairLimit = 5;

List<StudySessionItem> visibleMatchBatch(
  List<StudySessionItem> items,
  int startIndex,
) {
  final safeStart = startIndex < 0
      ? 0
      : startIndex > items.length
      ? items.length
      : startIndex;
  return items
      .skip(safeStart)
      .take(matchVisiblePairLimit)
      .toList(growable: false);
}

bool isVisibleMatchBatchComplete({
  required List<StudySessionItem> visibleItems,
  required Set<String> matchedItemIds,
}) {
  return visibleItems.isNotEmpty &&
      visibleItems.every((item) => matchedItemIds.contains(item.id));
}

int nextVisibleMatchBatchStart({
  required List<StudySessionItem> items,
  required Set<String> matchedItemIds,
}) {
  final nextIndex = items.indexWhere(
    (item) => !matchedItemIds.contains(item.id),
  );
  return nextIndex < 0 ? items.length : nextIndex;
}
