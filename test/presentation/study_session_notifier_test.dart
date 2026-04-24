import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';
import 'package:memox/presentation/features/study/widgets/study_session/study_mode_panel.dart';

void main() {
  test(
    'studyAnswerOptions preserves source order when answer shuffle is off',
    () {
      final snapshot = _snapshot(
        mode: StudyMode.match,
        currentCard: _card(id: 'card-2', front: 'front 2', back: 'back 2'),
        cards: [
          _card(id: 'card-1', front: 'front 1', back: 'back 1'),
          _card(id: 'card-2', front: 'front 2', back: 'back 2'),
          _card(id: 'card-3', front: 'front 3', back: 'back 3'),
          _card(id: 'card-4', front: 'front 4', back: 'back 4'),
        ],
        shuffleAnswers: false,
      );

      expect(studyAnswerOptions(snapshot).map((card) => card.id), [
        'card-1',
        'card-2',
        'card-3',
        'card-4',
      ]);
    },
  );

  test('session action controller cancels without provider error', () async {
    final container = ProviderContainer(
      overrides: [
        studyRepoProvider.overrideWithValue(const _CancelOnlyStudyRepo()),
      ],
    );
    addTearDown(container.dispose);

    final success = await container
        .read(studySessionActionControllerProvider('session-1').notifier)
        .cancel();

    expect(success, isTrue);
    expect(
      container
          .read(studySessionActionControllerProvider('session-1'))
          .hasError,
      isFalse,
    );
  });

  testWidgets('Fill mode clears answer text when the item changes', (
    tester,
  ) async {
    final first = _snapshot(
      mode: StudyMode.fill,
      itemId: 'item-1',
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [
        _card(id: 'card-1', front: 'front 1', back: 'back 1'),
        _card(id: 'card-2', front: 'front 2', back: 'back 2'),
      ],
      shuffleAnswers: false,
    );
    final second = _snapshot(
      mode: StudyMode.fill,
      itemId: 'item-2',
      currentCard: _card(id: 'card-2', front: 'front 2', back: 'back 2'),
      cards: [
        _card(id: 'card-1', front: 'front 1', back: 'back 1'),
        _card(id: 'card-2', front: 'front 2', back: 'back 2'),
      ],
      shuffleAnswers: false,
    );

    await tester.pumpWidget(_StudyModeHost(snapshot: first));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'stale answer');
    expect(_editableText(tester).controller.text, 'stale answer');

    await tester.pumpWidget(_StudyModeHost(snapshot: second));
    await tester.pump();

    expect(_editableText(tester).controller.text, isEmpty);
  });
}

final class _CancelOnlyStudyRepo implements StudyRepo {
  const _CancelOnlyStudyRepo();

  @override
  Future<StudySessionSnapshot> cancelSession(String sessionId) async {
    return _snapshot(
      mode: StudyMode.fill,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [_card(id: 'card-1', front: 'front 1', back: 'back 1')],
      shuffleAnswers: false,
    );
  }

  @override
  Future<List<StudyFlashcardRef>> loadNewCards(StudyContext context) {
    throw UnimplementedError();
  }

  @override
  Future<List<StudyFlashcardRef>> loadDueCards(StudyContext context) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot?> findResumeCandidate(StudyContext context) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> startSession({
    required StudyContext context,
    required StudyFlow flow,
    required List<StudyMode> modes,
    required List<StudyFlashcardRef> batch,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentItem({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> skipCurrentItem(String sessionId) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> finalizeSession({
    required String sessionId,
    required StudyType studyType,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> retryFinalize({
    required String sessionId,
    required StudyType studyType,
  }) {
    throw UnimplementedError();
  }
}

class _StudyModeHost extends StatelessWidget {
  const _StudyModeHost({required this.snapshot});

  final StudySessionSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: StudyModePanel(
          snapshot: snapshot,
          answerOptions: studyAnswerOptions(snapshot),
          onAnswer: (_) {},
        ),
      ),
    );
  }
}

EditableText _editableText(WidgetTester tester) {
  return tester.widget<EditableText>(find.byType(EditableText));
}

StudySessionSnapshot _snapshot({
  required StudyMode mode,
  required StudyFlashcardRef currentCard,
  required List<StudyFlashcardRef> cards,
  required bool shuffleAnswers,
  String itemId = 'item-1',
}) {
  return StudySessionSnapshot(
    session: StudySession(
      id: 'session-1',
      entryType: StudyEntryType.deck,
      entryRefId: 'deck-1',
      studyType: StudyType.srsReview,
      studyFlow: StudyFlow.srsFillReview,
      settings: StudySettingsSnapshot(
        batchSize: cards.length,
        shuffleFlashcards: false,
        shuffleAnswers: shuffleAnswers,
        prioritizeOverdue: true,
      ),
      status: SessionStatus.inProgress,
      startedAt: 0,
      endedAt: null,
      restartedFromSessionId: null,
    ),
    currentItem: StudySessionItem(
      id: itemId,
      sessionId: 'session-1',
      flashcard: currentCard,
      studyMode: mode,
      modeOrder: 1,
      roundIndex: 1,
      queuePosition: 1,
      sourcePool: SessionItemSourcePool.due,
      status: SessionItemStatus.pending,
      completedAt: null,
    ),
    sessionFlashcards: cards,
    summary: const StudySummary(
      totalCards: 0,
      completedAttempts: 0,
      correctAttempts: 0,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: 0,
    ),
    canFinalize: false,
  );
}

StudyFlashcardRef _card({
  required String id,
  required String front,
  required String back,
}) {
  return StudyFlashcardRef(
    id: id,
    deckId: 'deck-1',
    front: front,
    back: back,
    sourcePool: SessionItemSourcePool.due,
  );
}
