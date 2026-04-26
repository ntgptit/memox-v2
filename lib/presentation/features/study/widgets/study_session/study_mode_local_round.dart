import '../../../../../domain/enums/study_enums.dart';
import '../../../../../domain/study/entities/study_models.dart';

List<StudySessionItem> pendingModeRoundItems(StudySessionSnapshot snapshot) {
  final items = snapshot.currentRoundItems
      .where((item) => item.status == SessionItemStatus.pending)
      .toList(growable: true);
  if (items.isEmpty) {
    final currentItem = snapshot.currentItem;
    if (currentItem == null) {
      return const <StudySessionItem>[];
    }
    items.add(currentItem);
  }
  items.sort(
    (left, right) => left.queuePosition.compareTo(right.queuePosition),
  );
  return items;
}

int initialModeRoundIndex({
  required StudySessionSnapshot snapshot,
  required List<StudySessionItem> items,
}) {
  final currentItemId = snapshot.currentItem?.id;
  if (currentItemId == null) {
    return 0;
  }
  final index = items.indexWhere((item) => item.id == currentItemId);
  return index < 0 ? 0 : index;
}

String modeRoundKey(
  StudySessionSnapshot snapshot,
  List<StudySessionItem> items,
) {
  final currentItem = snapshot.currentItem;
  return [
    snapshot.session.id,
    currentItem?.modeOrder,
    currentItem?.roundIndex,
    for (final item in items) item.id,
  ].join(':');
}

double overallStudyProgress({
  required StudySessionSnapshot snapshot,
  double localCorrectCount = 0,
}) {
  final total = snapshot.summary.totalCards * snapshot.summary.totalModeCount;
  if (total <= 0) {
    return 0;
  }
  final correct = snapshot.summary.correctAttempts + localCorrectCount;
  return (correct / total).clamp(0, 1).toDouble();
}

double localCorrectGradeCount(Map<String, AttemptGrade> grades) {
  return grades.values
      .where((grade) => grade == AttemptGrade.correct)
      .length
      .toDouble();
}
