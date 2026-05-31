import '../../enums/study_enums.dart';

final class StudySettingsSnapshot {
  const StudySettingsSnapshot({
    required this.batchSize,
    required this.shuffleFlashcards,
    required this.shuffleAnswers,
    required this.prioritizeOverdue,
  });

  final int batchSize;
  final bool shuffleFlashcards;
  final bool shuffleAnswers;
  final bool prioritizeOverdue;
}

final class StudyContext {
  const StudyContext({
    required this.entryType,
    required this.entryRefId,
    required this.studyType,
    required this.settings,
    this.restartedFromSessionId,
  });

  final StudyEntryType entryType;
  final String? entryRefId;
  final StudyType studyType;
  final StudySettingsSnapshot settings;
  final String? restartedFromSessionId;
}

final class StudyFlashcardRef {
  const StudyFlashcardRef({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    required this.sourcePool,
  });

  final String id;
  final String deckId;
  final String front;
  final String back;
  final SessionItemSourcePool sourcePool;
}

final class StudySession {
  const StudySession({
    required this.id,
    required this.entryType,
    required this.entryRefId,
    required this.studyType,
    required this.studyFlow,
    required this.settings,
    required this.status,
    required this.startedAt,
    required this.endedAt,
    required this.restartedFromSessionId,
  });

  final String id;
  final StudyEntryType entryType;
  final String? entryRefId;
  final StudyType studyType;
  final StudyFlow studyFlow;
  final StudySettingsSnapshot settings;
  final SessionStatus status;
  final int startedAt;
  final int? endedAt;
  final String? restartedFromSessionId;
}

final class StudySessionItem {
  const StudySessionItem({
    required this.id,
    required this.sessionId,
    required this.flashcard,
    required this.studyMode,
    required this.modeOrder,
    required this.roundIndex,
    required this.queuePosition,
    required this.sourcePool,
    required this.status,
    required this.completedAt,
  });

  final String id;
  final String sessionId;
  final StudyFlashcardRef flashcard;
  final StudyMode studyMode;
  final int modeOrder;
  final int roundIndex;
  final int queuePosition;
  final SessionItemSourcePool sourcePool;
  final SessionItemStatus status;
  final int? completedAt;
}

final class StudyAttempt {
  const StudyAttempt({
    required this.id,
    required this.sessionId,
    required this.sessionItemId,
    required this.flashcardId,
    required this.attemptNumber,
    required this.grade,
    required this.answeredAt,
    required this.oldBox,
    required this.newBox,
    required this.nextDueAt,
  });

  final String id;
  final String sessionId;
  final String sessionItemId;
  final String flashcardId;
  final int attemptNumber;
  final AttemptGrade grade;
  final int answeredAt;
  final int? oldBox;
  final int? newBox;
  final int? nextDueAt;
}

final class StudySummary {
  const StudySummary({
    required this.totalCards,
    required this.completedAttempts,
    required this.correctAttempts,
    required this.incorrectAttempts,
    required this.increasedBoxCount,
    required this.decreasedBoxCount,
    required this.remainingCount,
    this.masteredCardCount = 0,
    this.retryCardCount = 0,
    this.totalModeCount = 1,
  });

  final int totalCards;
  final int masteredCardCount;
  final int retryCardCount;
  final int completedAttempts;
  final int correctAttempts;
  final int incorrectAttempts;
  final int increasedBoxCount;
  final int decreasedBoxCount;
  final int remainingCount;
  final int totalModeCount;

  StudySummary copyWith({
    int? masteredCardCount,
    int? retryCardCount,
    int? totalModeCount,
  }) => StudySummary(
    totalCards: totalCards,
    masteredCardCount: masteredCardCount ?? this.masteredCardCount,
    retryCardCount: retryCardCount ?? this.retryCardCount,
    completedAttempts: completedAttempts,
    correctAttempts: correctAttempts,
    incorrectAttempts: incorrectAttempts,
    increasedBoxCount: increasedBoxCount,
    decreasedBoxCount: decreasedBoxCount,
    remainingCount: remainingCount,
    totalModeCount: totalModeCount ?? this.totalModeCount,
  );
}

final class StudyResultBreakdown {
  const StudyResultBreakdown({
    this.perfectCount = 0,
    this.initialPassedCount = 0,
    this.recoveredCount = 0,
    this.forgotCount = 0,
  });

  static const StudyResultBreakdown empty = StudyResultBreakdown();

  final int perfectCount;
  final int initialPassedCount;
  final int recoveredCount;
  final int forgotCount;

  int get totalResultCount =>
      perfectCount + initialPassedCount + recoveredCount + forgotCount;

  int get passedCount => perfectCount + initialPassedCount;
}

final class BoxChangeBreakdown {
  const BoxChangeBreakdown({
    this.advancedCount = 0,
    this.stayedCount = 0,
    this.resetCount = 0,
    this.reachedBox8Count = 0,
  });

  static const BoxChangeBreakdown empty = BoxChangeBreakdown();

  final int advancedCount;
  final int stayedCount;
  final int resetCount;
  final int reachedBox8Count;

  int get totalChangeCount => advancedCount + stayedCount + resetCount;
}

/// Result type for a card surfaced in the Study Result per-card review
/// section (`docs/wireframes/18-study-result.md`). V1 only ever surfaces
/// recovered and forgot cards.
enum StudyResultCardReviewType { recovered, forgot }

final class StudyResultCardReviewItem {
  const StudyResultCardReviewItem({
    required this.flashcardId,
    required this.front,
    required this.back,
    required this.resultType,
    required this.attemptCount,
    required this.lastAnsweredAt,
    required this.oldBox,
    required this.newBox,
    required this.nextDueAt,
  });

  final String flashcardId;
  final String front;
  final String back;
  final StudyResultCardReviewType resultType;
  final int attemptCount;
  final int lastAnsweredAt;
  final int? oldBox;
  final int? newBox;
  final int? nextDueAt;

  bool get isRecovered => resultType == StudyResultCardReviewType.recovered;
  bool get isForgot => resultType == StudyResultCardReviewType.forgot;
}

final class StudySessionSnapshot {
  const StudySessionSnapshot({
    required this.session,
    required this.currentItem,
    this.currentRoundItems = const <StudySessionItem>[],
    required this.sessionFlashcards,
    required this.summary,
    required this.canFinalize,
    this.resultBreakdown = StudyResultBreakdown.empty,
    this.boxChangeBreakdown = BoxChangeBreakdown.empty,
    this.resultCardReviewItems = const <StudyResultCardReviewItem>[],
  });

  final StudySession session;
  final StudySessionItem? currentItem;
  final List<StudySessionItem> currentRoundItems;
  final List<StudyFlashcardRef> sessionFlashcards;
  final StudySummary summary;
  final bool canFinalize;
  final StudyResultBreakdown resultBreakdown;
  final BoxChangeBreakdown boxChangeBreakdown;
  final List<StudyResultCardReviewItem> resultCardReviewItems;

  StudySessionSnapshot copyWith({StudySummary? summary}) =>
      StudySessionSnapshot(
        session: session,
        currentItem: currentItem,
        currentRoundItems: currentRoundItems,
        sessionFlashcards: sessionFlashcards,
        summary: summary ?? this.summary,
        canFinalize: canFinalize,
        resultBreakdown: resultBreakdown,
        boxChangeBreakdown: boxChangeBreakdown,
        resultCardReviewItems: resultCardReviewItems,
      );
}
