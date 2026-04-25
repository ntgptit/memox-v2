import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';
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
    final repo = _CancelOnlyStudyRepo();
    final container = ProviderContainer(
      overrides: [studyRepoProvider.overrideWithValue(repo)],
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

  testWidgets('cancel opens confirm dialog before cancelling session', (
    tester,
  ) async {
    final repo = _CancelOnlyStudyRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: StudySessionScreen(sessionId: 'session-1'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cancel session'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel this session?'), findsOneWidget);
    expect(repo.cancelCount, 0);
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

  testWidgets('answer tap shows feedback before continue', (tester) async {
    final snapshot = _snapshot(
      mode: StudyMode.guess,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [_card(id: 'card-1', front: 'front 1', back: 'back 1')],
      shuffleAnswers: false,
    );
    var continueCount = 0;

    await tester.pumpWidget(
      _InteractiveStudyModeHost(
        snapshot: snapshot,
        onContinue: () => continueCount += 1,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Correct'));
    await tester.pumpAndSettle();

    expect(find.text('Continue'), findsOneWidget);
    expect(find.textContaining('back 1'), findsWidgets);
    expect(continueCount, 0);
  });

  testWidgets('continue calls answer once and disables while loading', (
    tester,
  ) async {
    final snapshot = _snapshot(
      mode: StudyMode.guess,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [_card(id: 'card-1', front: 'front 1', back: 'back 1')],
      shuffleAnswers: false,
    );
    final feedback = StudyAnswerFeedback(
      itemId: snapshot.currentItem!.id,
      selectedGrade: AttemptGrade.correct,
      isCorrect: true,
      correctAnswer: snapshot.currentItem!.flashcard.back,
    );
    var continueCount = 0;

    await tester.pumpWidget(
      _StudyModeHost(
        snapshot: snapshot,
        feedback: feedback,
        onContinue: () => continueCount += 1,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(continueCount, 1);

    await tester.pumpWidget(
      _StudyModeHost(
        snapshot: snapshot,
        feedback: feedback,
        isSubmitting: true,
        onContinue: () => continueCount += 1,
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(ElevatedButton).last);
    await tester.pump();

    expect(continueCount, 1);
  });

  testWidgets('empty fill answer cannot submit', (tester) async {
    final snapshot = _snapshot(
      mode: StudyMode.fill,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [_card(id: 'card-1', front: 'front 1', back: 'back 1')],
      shuffleAnswers: false,
    );
    var answerCount = 0;

    await tester.pumpWidget(
      _StudyModeHost(snapshot: snapshot, onAnswer: (_) => answerCount += 1),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(answerCount, 0);
  });
}

final class _CancelOnlyStudyRepo implements StudyRepo {
  int cancelCount = 0;

  @override
  Future<StudySessionSnapshot> cancelSession(String sessionId) async {
    cancelCount += 1;
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
  Future<StudySessionSnapshot> loadSession(String sessionId) async {
    return _snapshot(
      mode: StudyMode.guess,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [_card(id: 'card-1', front: 'front 1', back: 'back 1')],
      shuffleAnswers: false,
    );
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
  const _StudyModeHost({
    required this.snapshot,
    this.isSubmitting = false,
    this.feedback,
    this.onAnswer,
    this.onContinue,
  });

  final StudySessionSnapshot snapshot;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<AttemptGrade>? onAnswer;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: StudyModePanel(
          snapshot: snapshot,
          answerOptions: studyAnswerOptions(snapshot),
          isSubmitting: isSubmitting,
          feedback: feedback,
          onAnswer: onAnswer ?? (_) {},
          onContinue: onContinue,
        ),
      ),
    );
  }
}

class _InteractiveStudyModeHost extends StatefulWidget {
  const _InteractiveStudyModeHost({
    required this.snapshot,
    required this.onContinue,
  });

  final StudySessionSnapshot snapshot;
  final VoidCallback onContinue;

  @override
  State<_InteractiveStudyModeHost> createState() =>
      _InteractiveStudyModeHostState();
}

class _InteractiveStudyModeHostState extends State<_InteractiveStudyModeHost> {
  StudyAnswerFeedback? _feedback;

  @override
  Widget build(BuildContext context) {
    final item = widget.snapshot.currentItem!;
    return _StudyModeHost(
      snapshot: widget.snapshot,
      feedback: _feedback,
      onAnswer: (grade) => setState(() {
        _feedback = StudyAnswerFeedback(
          itemId: item.id,
          selectedGrade: grade,
          isCorrect:
              grade == AttemptGrade.correct || grade == AttemptGrade.remembered,
          correctAnswer: item.flashcard.back,
        );
      }),
      onContinue: widget.onContinue,
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
