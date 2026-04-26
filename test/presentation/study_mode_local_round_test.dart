import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/presentation/features/study/widgets/study_session/study_mode_local_round.dart';

void main() {
  test('DT1 onInsert: pendingModeRoundItems falls back to current item', () {
    final snapshot = _snapshot(
      currentItem: _item(id: 'item-1', queuePosition: 1),
    );

    final items = pendingModeRoundItems(snapshot);

    expect(items.map((item) => item.id), <String>['item-1']);
    expect(initialModeRoundIndex(snapshot: snapshot, items: items), 0);
    expect(modeRoundKey(snapshot, items), 'session-1:3:1:item-1');
    expect(overallStudyProgress(snapshot: snapshot, localCorrectCount: 1), 0.1);
  });

  test('DT1 onUpdate: SRS review progress uses single-mode denominator', () {
    final snapshot = _snapshot(
      studyType: StudyType.srsReview,
      studyFlow: StudyFlow.srsFillReview,
      currentItem: _item(id: 'item-1', queuePosition: 1),
    );

    final progress = overallStudyProgress(
      snapshot: snapshot,
      localCorrectCount: 1,
    );

    expect(progress, 0.5);
  });

  test(
    'DT1 onSearchFilterSort: pendingModeRoundItems keeps pending items in queue order',
    () {
      final current = _item(id: 'item-2', queuePosition: 2);
      final snapshot = _snapshot(
        currentItem: current,
        currentRoundItems: [
          _item(
            id: 'item-3',
            queuePosition: 3,
            status: SessionItemStatus.completed,
          ),
          current,
          _item(id: 'item-1', queuePosition: 1),
        ],
      );

      final items = pendingModeRoundItems(snapshot);

      expect(items.map((item) => item.id), <String>['item-1', 'item-2']);
      expect(initialModeRoundIndex(snapshot: snapshot, items: items), 1);
      expect(modeRoundKey(snapshot, items), 'session-1:3:1:item-1:item-2');
    },
  );

  test(
    'DT2 onUpdate: progress ignores incorrect local and persisted attempts',
    () {
      final snapshot = _snapshot(
        currentItem: _item(id: 'item-1', queuePosition: 1),
        summary: const StudySummary(
          totalCards: 2,
          totalModeCount: 5,
          completedAttempts: 4,
          correctAttempts: 2,
          incorrectAttempts: 2,
          increasedBoxCount: 0,
          decreasedBoxCount: 0,
          remainingCount: 2,
        ),
      );

      final progress = overallStudyProgress(
        snapshot: snapshot,
        localCorrectCount: localCorrectGradeCount(const <String, AttemptGrade>{
          'item-1': AttemptGrade.correct,
          'item-2': AttemptGrade.incorrect,
        }),
      );

      expect(progress, 0.3);
    },
  );
}

StudySessionSnapshot _snapshot({
  required StudySessionItem currentItem,
  StudyType studyType = StudyType.newStudy,
  StudyFlow studyFlow = StudyFlow.newFullCycle,
  List<StudySessionItem> currentRoundItems = const <StudySessionItem>[],
  StudySummary? summary,
}) {
  return StudySessionSnapshot(
    session: StudySession(
      id: 'session-1',
      entryType: StudyEntryType.deck,
      entryRefId: 'deck-1',
      studyType: studyType,
      studyFlow: studyFlow,
      settings: const StudySettingsSnapshot(
        batchSize: 2,
        shuffleFlashcards: false,
        shuffleAnswers: false,
        prioritizeOverdue: true,
      ),
      status: SessionStatus.inProgress,
      startedAt: 0,
      endedAt: null,
      restartedFromSessionId: null,
    ),
    currentItem: currentItem,
    currentRoundItems: currentRoundItems,
    sessionFlashcards: const <StudyFlashcardRef>[],
    summary:
        summary ??
        StudySummary(
          totalCards: 2,
          completedAttempts: 0,
          correctAttempts: 0,
          incorrectAttempts: 0,
          increasedBoxCount: 0,
          decreasedBoxCount: 0,
          remainingCount: 2,
          totalModeCount: studyType == StudyType.newStudy ? 5 : 1,
        ),
    canFinalize: false,
  );
}

StudySessionItem _item({
  required String id,
  required int queuePosition,
  SessionItemStatus status = SessionItemStatus.pending,
}) {
  return StudySessionItem(
    id: id,
    sessionId: 'session-1',
    flashcard: StudyFlashcardRef(
      id: 'card-$id',
      deckId: 'deck-1',
      front: 'front $id',
      back: 'back $id',
      sourcePool: SessionItemSourcePool.newCards,
    ),
    studyMode: StudyMode.guess,
    modeOrder: 3,
    roundIndex: 1,
    queuePosition: queuePosition,
    sourcePool: SessionItemSourcePool.newCards,
    status: status,
    completedAt: status == SessionItemStatus.completed ? 1 : null,
  );
}
