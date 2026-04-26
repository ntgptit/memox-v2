import '../../enums/study_enums.dart';
import '../entities/study_models.dart';
import '../ports/study_repo.dart';

typedef StudyStrategy = StudyFlowStrategy;

final class StudyFlowPlan {
  const StudyFlowPlan({
    required this.studyType,
    required this.flow,
    required this.modes,
  });

  final StudyType studyType;
  final StudyFlow flow;
  final List<StudyMode> modes;

  int get totalModeCount => modes.length;
}

abstract interface class StudyFlowStrategy {
  StudyType get handleType;

  StudyFlowPlan get flowPlan;

  StudyFlow get flow;

  List<StudyMode> get modes;

  StudyFinalizePolicy get finalizePolicy;

  bool supportsEntry(StudyEntryType entryType);

  bool isPassingGrade(AttemptGrade grade);

  bool isFailingGrade(AttemptGrade grade);

  bool isFinalMode(StudyMode mode);

  int modeOrder(StudyMode mode);

  StudyMode modeForOrder(int order);

  Future<List<StudyFlashcardRef>> loadBatch(
    StudyContext context,
    StudyRepo repo,
  );
}

abstract class AbstractStudyFlowStrategy implements StudyFlowStrategy {
  const AbstractStudyFlowStrategy();

  @override
  StudyFlowPlan get flowPlan => StudyFlowPlan(
    studyType: handleType,
    flow: buildFlow(),
    modes: buildModes(),
  );

  @override
  StudyFlow get flow => flowPlan.flow;

  @override
  List<StudyMode> get modes => flowPlan.modes;

  @override
  StudyFinalizePolicy get finalizePolicy => buildFinalizePolicy();

  StudyFlow buildFlow();

  List<StudyMode> buildModes();

  StudyFinalizePolicy buildFinalizePolicy();

  @override
  bool isPassingGrade(AttemptGrade grade) => grade.isPassing;

  @override
  bool isFailingGrade(AttemptGrade grade) => !isPassingGrade(grade);

  @override
  bool isFinalMode(StudyMode mode) => modes.last == mode;

  @override
  int modeOrder(StudyMode mode) {
    final index = modes.indexOf(mode);
    if (index < 0) {
      throw StateError('Mode $mode is not part of $handleType.');
    }
    return index + 1;
  }

  @override
  StudyMode modeForOrder(int order) {
    if (order < 1 || order > modes.length) {
      throw StateError('Mode order $order is not part of $handleType.');
    }
    return modes[order - 1];
  }
}

final class NewStudyStrategy extends AbstractStudyFlowStrategy {
  const NewStudyStrategy();

  @override
  StudyType get handleType => StudyType.newStudy;

  @override
  StudyFlow buildFlow() => StudyFlow.newFullCycle;

  @override
  List<StudyMode> buildModes() => const <StudyMode>[
    StudyMode.review,
    StudyMode.match,
    StudyMode.guess,
    StudyMode.recall,
    StudyMode.fill,
  ];

  @override
  StudyFinalizePolicy buildFinalizePolicy() => StudyFinalizePolicy.newStudy;

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

final class SrsReviewStrategy extends AbstractStudyFlowStrategy {
  const SrsReviewStrategy();

  @override
  StudyType get handleType => StudyType.srsReview;

  @override
  StudyFlow buildFlow() => StudyFlow.srsFillReview;

  @override
  List<StudyMode> buildModes() => const <StudyMode>[StudyMode.fill];

  @override
  StudyFinalizePolicy buildFinalizePolicy() => StudyFinalizePolicy.srsReview;

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
