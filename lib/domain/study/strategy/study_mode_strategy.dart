import '../../../core/errors/app_exception.dart';
import '../../enums/study_enums.dart';

enum StudyModeUiResult {
  viewed,
  correct,
  incorrect,
  remembered,
  forgot,
  timeout,
  help,
}

final class StudyModeSubmissionPlan {
  const StudyModeSubmissionPlan({
    required this.mode,
    required this.label,
    required this.itemGrades,
    required this.acceptedGrades,
    required this.retryIncorrect,
  });

  final StudyMode mode;
  final String label;
  final Map<String, AttemptGrade> itemGrades;
  final Set<AttemptGrade> acceptedGrades;
  final bool retryIncorrect;

  bool shouldRetry(AttemptGrade grade) {
    return retryIncorrect && grade.isFailing;
  }
}

abstract interface class StudyModeStrategy {
  StudyMode get handleType;

  String get label;

  Set<AttemptGrade> get acceptedGrades;

  int? get batchSize;

  Duration get modeCompletionDelay;

  AttemptGrade normalizeUiResult(StudyModeUiResult result);

  bool shouldRetry(AttemptGrade grade);

  StudyModeSubmissionPlan buildSubmission({
    required Iterable<String> pendingItemIds,
    required Map<String, AttemptGrade> itemGrades,
  });
}

abstract class AbstractStudyModeStrategy implements StudyModeStrategy {
  const AbstractStudyModeStrategy();

  @override
  String get label => handleType.name;

  @override
  Set<AttemptGrade> get acceptedGrades => const <AttemptGrade>{
    AttemptGrade.correct,
    AttemptGrade.incorrect,
  };

  @override
  int? get batchSize => null;

  @override
  Duration get modeCompletionDelay => Duration.zero;

  @override
  bool shouldRetry(AttemptGrade grade) => grade.isFailing;

  @override
  AttemptGrade normalizeUiResult(StudyModeUiResult result) {
    return switch (result) {
      StudyModeUiResult.correct ||
      StudyModeUiResult.remembered ||
      StudyModeUiResult.viewed => AttemptGrade.correct,
      StudyModeUiResult.incorrect ||
      StudyModeUiResult.forgot ||
      StudyModeUiResult.timeout ||
      StudyModeUiResult.help => AttemptGrade.incorrect,
    };
  }

  @override
  StudyModeSubmissionPlan buildSubmission({
    required Iterable<String> pendingItemIds,
    required Map<String, AttemptGrade> itemGrades,
  }) {
    final expectedIds = pendingItemIds.toSet();
    final submittedIds = itemGrades.keys.toSet();
    if (expectedIds.length != submittedIds.length ||
        !expectedIds.containsAll(submittedIds)) {
      throw ValidationException(
        message: '$label batch must include every pending item exactly once.',
      );
    }
    if (itemGrades.values.any((grade) => !acceptedGrades.contains(grade))) {
      throw ValidationException(
        message: '$label batch only accepts ${_acceptedGradeLabel()} grades.',
      );
    }
    return StudyModeSubmissionPlan(
      mode: handleType,
      label: label,
      itemGrades: Map.unmodifiable(itemGrades),
      acceptedGrades: acceptedGrades,
      retryIncorrect: true,
    );
  }

  String _acceptedGradeLabel() {
    return acceptedGrades.map((grade) => grade.storageValue).join(' or ');
  }
}

final class ReviewModeStrategy extends AbstractStudyModeStrategy {
  const ReviewModeStrategy();

  @override
  StudyMode get handleType => StudyMode.review;

  @override
  String get label => 'Review';

  @override
  Duration get modeCompletionDelay => const Duration(seconds: 2);

  @override
  AttemptGrade normalizeUiResult(StudyModeUiResult result) {
    return AttemptGrade.correct;
  }

  @override
  bool shouldRetry(AttemptGrade grade) => false;

  @override
  StudyModeSubmissionPlan buildSubmission({
    required Iterable<String> pendingItemIds,
    required Map<String, AttemptGrade> itemGrades,
  }) {
    final plan = super.buildSubmission(
      pendingItemIds: pendingItemIds,
      itemGrades: itemGrades,
    );
    return StudyModeSubmissionPlan(
      mode: plan.mode,
      label: plan.label,
      itemGrades: plan.itemGrades,
      acceptedGrades: plan.acceptedGrades,
      retryIncorrect: false,
    );
  }
}

final class MatchModeStrategy extends AbstractStudyModeStrategy {
  const MatchModeStrategy();

  @override
  StudyMode get handleType => StudyMode.match;

  @override
  String get label => 'Match';

  @override
  int get batchSize => 5;

  @override
  Duration get modeCompletionDelay => const Duration(milliseconds: 650);
}

final class GuessModeStrategy extends AbstractStudyModeStrategy {
  const GuessModeStrategy();

  @override
  StudyMode get handleType => StudyMode.guess;

  @override
  String get label => 'Guess';

  @override
  Duration get modeCompletionDelay => const Duration(milliseconds: 650);
}

final class RecallModeStrategy extends AbstractStudyModeStrategy {
  const RecallModeStrategy();

  @override
  StudyMode get handleType => StudyMode.recall;

  @override
  String get label => 'Recall';
}

final class FillModeStrategy extends AbstractStudyModeStrategy {
  const FillModeStrategy();

  @override
  StudyMode get handleType => StudyMode.fill;

  @override
  String get label => 'Fill';
}

final class StudyModeStrategyFactory {
  StudyModeStrategyFactory(Iterable<StudyModeStrategy> strategies)
    : _byMode = _buildMap(strategies);

  final Map<StudyMode, StudyModeStrategy> _byMode;

  StudyModeStrategy of(StudyMode mode) {
    final strategy = _byMode[mode];
    if (strategy == null) {
      throw StateError('No StudyModeStrategy registered for $mode.');
    }
    return strategy;
  }

  static Map<StudyMode, StudyModeStrategy> _buildMap(
    Iterable<StudyModeStrategy> strategies,
  ) {
    final byMode = <StudyMode, StudyModeStrategy>{};
    for (final strategy in strategies) {
      final previous = byMode[strategy.handleType];
      if (previous != null) {
        throw StateError(
          'Duplicate StudyModeStrategy for ${strategy.handleType}.',
        );
      }
      byMode[strategy.handleType] = strategy;
    }
    final missingModes = StudyMode.values.where(
      (mode) => !byMode.containsKey(mode),
    );
    if (missingModes.isNotEmpty) {
      throw StateError(
        'Missing StudyModeStrategy for ${missingModes.join(', ')}.',
      );
    }
    return Map.unmodifiable(byMode);
  }
}
