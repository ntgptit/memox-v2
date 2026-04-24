import '../../enums/study_enums.dart';
import '../entities/study_models.dart';
import '../ports/study_repo.dart';

abstract class StudyStrategy {
  const StudyStrategy();

  StudyType get handleType;

  StudyFlow get flow;

  List<StudyMode> get modes;

  bool supportsEntry(StudyEntryType entryType);

  bool isPassingGrade(AttemptGrade grade) => grade.isPassing;

  bool isFailingGrade(AttemptGrade grade) => !isPassingGrade(grade);

  bool isFinalMode(StudyMode mode) => modes.last == mode;

  int modeOrder(StudyMode mode) {
    final index = modes.indexOf(mode);
    if (index < 0) {
      throw StateError('Mode $mode is not part of $handleType.');
    }
    return index + 1;
  }

  StudyMode modeForOrder(int order) {
    if (order < 1 || order > modes.length) {
      throw StateError('Mode order $order is not part of $handleType.');
    }
    return modes[order - 1];
  }

  Future<List<StudyFlashcardRef>> loadBatch(
    StudyContext context,
    StudyRepo repo,
  );
}

final class NewStudyStrategy extends StudyStrategy {
  const NewStudyStrategy();

  @override
  StudyType get handleType => StudyType.newStudy;

  @override
  StudyFlow get flow => StudyFlow.newFullCycle;

  @override
  List<StudyMode> get modes => const <StudyMode>[
    StudyMode.review,
    StudyMode.match,
    StudyMode.guess,
    StudyMode.recall,
    StudyMode.fill,
  ];

  @override
  bool supportsEntry(StudyEntryType entryType) {
    return entryType == StudyEntryType.deck ||
        entryType == StudyEntryType.folder;
  }

  @override
  Future<List<StudyFlashcardRef>> loadBatch(
    StudyContext context,
    StudyRepo repo,
  ) {
    return repo.loadNewCards(context);
  }
}

final class SrsReviewStrategy extends StudyStrategy {
  const SrsReviewStrategy();

  @override
  StudyType get handleType => StudyType.srsReview;

  @override
  StudyFlow get flow => StudyFlow.srsFillReview;

  @override
  List<StudyMode> get modes => const <StudyMode>[StudyMode.fill];

  @override
  bool supportsEntry(StudyEntryType entryType) {
    return entryType == StudyEntryType.deck ||
        entryType == StudyEntryType.folder ||
        entryType == StudyEntryType.today;
  }

  @override
  Future<List<StudyFlashcardRef>> loadBatch(
    StudyContext context,
    StudyRepo repo,
  ) {
    return repo.loadDueCards(context);
  }
}
