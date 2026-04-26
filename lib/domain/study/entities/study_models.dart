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
    this.totalModeCount = 1,
  });

  final int totalCards;
  final int completedAttempts;
  final int correctAttempts;
  final int incorrectAttempts;
  final int increasedBoxCount;
  final int decreasedBoxCount;
  final int remainingCount;
  final int totalModeCount;

  StudySummary copyWith({int? totalModeCount}) {
    return StudySummary(
      totalCards: totalCards,
      completedAttempts: completedAttempts,
      correctAttempts: correctAttempts,
      incorrectAttempts: incorrectAttempts,
      increasedBoxCount: increasedBoxCount,
      decreasedBoxCount: decreasedBoxCount,
      remainingCount: remainingCount,
      totalModeCount: totalModeCount ?? this.totalModeCount,
    );
  }
}

final class StudySessionSnapshot {
  const StudySessionSnapshot({
    required this.session,
    required this.currentItem,
    this.currentRoundItems = const <StudySessionItem>[],
    required this.sessionFlashcards,
    required this.summary,
    required this.canFinalize,
  });

  final StudySession session;
  final StudySessionItem? currentItem;
  final List<StudySessionItem> currentRoundItems;
  final List<StudyFlashcardRef> sessionFlashcards;
  final StudySummary summary;
  final bool canFinalize;

  StudySessionSnapshot copyWith({StudySummary? summary}) {
    return StudySessionSnapshot(
      session: session,
      currentItem: currentItem,
      currentRoundItems: currentRoundItems,
      sessionFlashcards: sessionFlashcards,
      summary: summary ?? this.summary,
      canFinalize: canFinalize,
    );
  }
}
