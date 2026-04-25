import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/progress/providers/progress_session_notifier.dart';
import 'package:memox/presentation/features/study/providers/study_entry_notifier.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';
import 'package:memox/presentation/features/study/widgets/study_session/study_mode_panel.dart';
import 'package:memox/presentation/shared/widgets/mx_answer_option_card.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'DT1 onUpdate: studyAnswerOptions preserves source order when answer shuffle is off',
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

  test(
    'DT2 onUpdate: session action controller cancels without provider error',
    () async {
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
    },
  );

  test(
    'DT15 onUpdate: studyGuessAnswerOptions returns five source-order options',
    () {
      final snapshot = _snapshot(
        mode: StudyMode.guess,
        currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
        cards: [
          _card(id: 'card-1', front: 'front 1', back: 'back 1'),
          _card(id: 'card-2', front: 'front 2', back: 'back 2'),
          _card(id: 'card-3', front: 'front 3', back: 'back 3'),
          _card(id: 'card-4', front: 'front 4', back: 'back 4'),
          _card(id: 'card-5', front: 'front 5', back: 'back 5'),
        ],
        shuffleAnswers: false,
      );

      expect(studyGuessAnswerOptions(snapshot).map((card) => card.id), [
        'card-1',
        'card-2',
        'card-3',
        'card-4',
        'card-5',
      ]);
    },
  );

  test(
    'DT11 onUpdate: review batch controller submits remembered grade without provider error',
    () async {
      final repo = _ReviewBatchStudyRepo();
      final container = ProviderContainer(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final success = await container
          .read(studySessionActionControllerProvider('session-1').notifier)
          .answerCurrentReviewModeAsRemembered();

      expect(success, isTrue);
      expect(repo.batchAnswerCount, 1);
      expect(repo.lastGrade, AttemptGrade.remembered);
      expect(repo.lastModes, <StudyMode>[
        StudyMode.review,
        StudyMode.match,
        StudyMode.guess,
        StudyMode.recall,
        StudyMode.fill,
      ]);
      expect(
        container
            .read(studySessionActionControllerProvider('session-1'))
            .hasError,
        isFalse,
      );
    },
  );

  test(
    'DT14 onUpdate: match batch controller forwards exact item grade map',
    () async {
      final repo = _MatchBatchStudyRepo();
      final container = ProviderContainer(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final itemGrades = <String, AttemptGrade>{
        'item-1': AttemptGrade.correct,
        'item-2': AttemptGrade.incorrect,
      };
      final success = await container
          .read(studySessionActionControllerProvider('session-1').notifier)
          .answerCurrentMatchModeBatch(itemGrades);

      expect(success, isTrue);
      expect(repo.matchBatchAnswerCount, 1);
      expect(repo.lastItemGrades, itemGrades);
      expect(repo.lastModes, <StudyMode>[
        StudyMode.review,
        StudyMode.match,
        StudyMode.guess,
        StudyMode.recall,
        StudyMode.fill,
      ]);
      expect(
        container
            .read(studySessionActionControllerProvider('session-1'))
            .hasError,
        isFalse,
      );
    },
  );

  test(
    'DT12 onUpdate: study session mutation invalidates cached Progress sessions',
    () async {
      final repo = _ReviewBatchStudyRepo();
      final container = ProviderContainer(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      await container.read(progressStudySessionsProvider.future);
      expect(repo.activeSessionLoadCount, 1);

      final success = await container
          .read(studySessionActionControllerProvider('session-1').notifier)
          .answerCurrentReviewModeAsRemembered();
      await container.read(progressStudySessionsProvider.future);

      expect(success, isTrue);
      expect(repo.activeSessionLoadCount, 2);
    },
  );

  test(
    'DT13 onUpdate: terminal study session mutation invalidates cached Study Entry resume state',
    () async {
      SharedPreferences.setMockInitialValues(const <String, Object>{});
      final repo = _ResumeCandidateStudyRepo();
      final container = ProviderContainer(
        overrides: [studyRepoProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final initial = await container.read(
        studyEntryStateProvider('deck', 'deck-1').future,
      );
      expect(initial.resumeCandidate?.session.id, 'session-1');
      expect(repo.resumeCandidateLoadCount, 1);

      final success = await container
          .read(studySessionActionControllerProvider('session-1').notifier)
          .cancel();
      final refreshed = await container.read(
        studyEntryStateProvider('deck', 'deck-1').future,
      );

      expect(success, isTrue);
      expect(repo.resumeCandidateLoadCount, 2);
      expect(refreshed.resumeCandidate, isNull);
    },
  );

  testWidgets(
    'DT3 onUpdate: cancel opens confirm dialog before cancelling session',
    (tester) async {
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
    },
  );

  testWidgets(
    'DT4 onUpdate: Fill mode clears answer text when the item changes',
    (tester) async {
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
    },
  );

  testWidgets('DT5 onUpdate: answer tap shows feedback before continue', (
    tester,
  ) async {
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

  testWidgets(
    'DT6 onUpdate: continue calls answer once and disables while loading',
    (tester) async {
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
    },
  );

  testWidgets('DT7 onUpdate: empty fill answer cannot submit', (tester) async {
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

  testWidgets(
    'DT8 onUpdate: match mode renders answer cards instead of secondary buttons',
    (tester) async {
      final snapshot = _snapshot(
        mode: StudyMode.match,
        currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
        cards: [
          _card(id: 'card-1', front: 'front 1', back: 'back 1'),
          _card(id: 'card-2', front: 'front 2', back: 'back 2'),
          _card(id: 'card-3', front: 'front 3', back: 'back 3'),
        ],
        shuffleAnswers: false,
      );

      await tester.pumpWidget(_StudyModeHost(snapshot: snapshot));
      await tester.pumpAndSettle();

      expect(find.byType(MxAnswerOptionCard), findsNWidgets(3));
      expect(find.widgetWithText(MxSecondaryButton, 'back 1'), findsNothing);
      expect(find.widgetWithText(MxSecondaryButton, 'back 2'), findsNothing);
      expect(find.widgetWithText(MxSecondaryButton, 'back 3'), findsNothing);
    },
  );

  testWidgets('DT1 onSelect: selecting a long match option shows feedback', (
    tester,
  ) async {
    const longWrongAnswer =
        'A very long distractor answer that should remain readable and tappable '
        'when rendered as a match option.';
    final snapshot = _snapshot(
      mode: StudyMode.match,
      currentCard: _card(
        id: 'card-1',
        front: 'front 1',
        back: 'correct answer',
      ),
      cards: [
        _card(id: 'card-1', front: 'front 1', back: 'correct answer'),
        _card(id: 'card-2', front: 'front 2', back: longWrongAnswer),
      ],
      shuffleAnswers: false,
    );

    await tester.pumpWidget(
      _InteractiveStudyModeHost(snapshot: snapshot, onContinue: () {}),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text(longWrongAnswer));
    await tester.tap(find.text(longWrongAnswer));
    await tester.pumpAndSettle();

    expect(find.text('Not quite'), findsOneWidget);
    expect(find.text('Correct answer: correct answer'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets(
    'DT9 onUpdate: incorrect feedback can be marked correct before continuing',
    (tester) async {
      final snapshot = _snapshot(
        mode: StudyMode.fill,
        currentCard: _card(id: 'card-1', front: 'front 1', back: 'answer 1'),
        cards: [_card(id: 'card-1', front: 'front 1', back: 'answer 1')],
        shuffleAnswers: false,
      );
      final feedback = StudyAnswerFeedback(
        itemId: snapshot.currentItem!.id,
        selectedGrade: AttemptGrade.incorrect,
        isCorrect: false,
        correctAnswer: snapshot.currentItem!.flashcard.back,
      );
      StudyAnswerFeedback? correctedFeedback;

      await tester.pumpWidget(
        _StudyModeHost(
          snapshot: snapshot,
          feedback: feedback,
          onMarkCorrect: (value) => correctedFeedback = value,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark correct'));
      await tester.pumpAndSettle();

      expect(correctedFeedback?.selectedGrade, AttemptGrade.correct);
      expect(correctedFeedback?.isCorrect, isTrue);
    },
  );

  testWidgets('DT10 onUpdate: fill feedback shows the submitted answer', (
    tester,
  ) async {
    final snapshot = _snapshot(
      mode: StudyMode.fill,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'answer 1'),
      cards: [_card(id: 'card-1', front: 'front 1', back: 'answer 1')],
      shuffleAnswers: false,
    );
    final feedback = StudyAnswerFeedback(
      itemId: snapshot.currentItem!.id,
      selectedGrade: AttemptGrade.incorrect,
      isCorrect: false,
      correctAnswer: snapshot.currentItem!.flashcard.back,
      submittedAnswer: 'anser 1',
    );

    await tester.pumpWidget(
      _StudyModeHost(snapshot: snapshot, feedback: feedback),
    );
    await tester.pumpAndSettle();

    expect(find.text('Your answer: anser 1'), findsOneWidget);
    expect(find.text('Correct answer: answer 1'), findsOneWidget);
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
  Future<List<StudySessionSnapshot>> listActiveSessions() {
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
      mode: StudyMode.fill,
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
  Future<StudySessionSnapshot> answerCurrentModeBatch({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentMatchModeBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
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

final class _ResumeCandidateStudyRepo implements StudyRepo {
  int cancelCount = 0;
  int resumeCandidateLoadCount = 0;
  bool hasResumeCandidate = true;

  @override
  Future<StudySessionSnapshot?> findResumeCandidate(
    StudyContext context,
  ) async {
    resumeCandidateLoadCount += 1;
    if (!hasResumeCandidate) {
      return null;
    }
    return _activeSnapshot();
  }

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) async {
    return _activeSnapshot();
  }

  @override
  Future<StudySessionSnapshot> cancelSession(String sessionId) async {
    cancelCount += 1;
    hasResumeCandidate = false;
    return _snapshot(
      mode: StudyMode.fill,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [_card(id: 'card-1', front: 'front 1', back: 'back 1')],
      shuffleAnswers: false,
      status: SessionStatus.cancelled,
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
  Future<List<StudySessionSnapshot>> listActiveSessions() {
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
  Future<StudySessionSnapshot> answerCurrentItem({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentModeBatch({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentMatchModeBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
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

  StudySessionSnapshot _activeSnapshot() {
    return _snapshot(
      mode: StudyMode.fill,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [_card(id: 'card-1', front: 'front 1', back: 'back 1')],
      shuffleAnswers: false,
      status: SessionStatus.inProgress,
    );
  }
}

final class _ReviewBatchStudyRepo implements StudyRepo {
  int batchAnswerCount = 0;
  int activeSessionLoadCount = 0;
  AttemptGrade? lastGrade;
  List<StudyMode>? lastModes;

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) async {
    return _snapshot(
      mode: StudyMode.review,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [_card(id: 'card-1', front: 'front 1', back: 'back 1')],
      shuffleAnswers: false,
      studyType: StudyType.newStudy,
    );
  }

  @override
  Future<StudySessionSnapshot> answerCurrentModeBatch({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) async {
    batchAnswerCount += 1;
    lastGrade = grade;
    lastModes = modes;
    return _snapshot(
      mode: StudyMode.match,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [_card(id: 'card-1', front: 'front 1', back: 'back 1')],
      shuffleAnswers: false,
      studyType: StudyType.newStudy,
    );
  }

  @override
  Future<StudySessionSnapshot> answerCurrentMatchModeBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
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
  Future<List<StudySessionSnapshot>> listActiveSessions() async {
    activeSessionLoadCount += 1;
    return [
      _snapshot(
        mode: StudyMode.review,
        currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
        cards: [_card(id: 'card-1', front: 'front 1', back: 'back 1')],
        shuffleAnswers: false,
        studyType: StudyType.newStudy,
      ),
    ];
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
  Future<StudySessionSnapshot> cancelSession(String sessionId) {
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

final class _MatchBatchStudyRepo implements StudyRepo {
  int matchBatchAnswerCount = 0;
  Map<String, AttemptGrade>? lastItemGrades;
  List<StudyMode>? lastModes;

  @override
  Future<StudySessionSnapshot> loadSession(String sessionId) async {
    return _snapshot(
      mode: StudyMode.match,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [
        _card(id: 'card-1', front: 'front 1', back: 'back 1'),
        _card(id: 'card-2', front: 'front 2', back: 'back 2'),
      ],
      shuffleAnswers: false,
      studyType: StudyType.newStudy,
    );
  }

  @override
  Future<StudySessionSnapshot> answerCurrentMatchModeBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
    required List<StudyMode> modes,
  }) async {
    matchBatchAnswerCount += 1;
    lastItemGrades = itemGrades;
    lastModes = modes;
    return _snapshot(
      mode: StudyMode.guess,
      currentCard: _card(id: 'card-1', front: 'front 1', back: 'back 1'),
      cards: [
        _card(id: 'card-1', front: 'front 1', back: 'back 1'),
        _card(id: 'card-2', front: 'front 2', back: 'back 2'),
      ],
      shuffleAnswers: false,
      studyType: StudyType.newStudy,
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
  Future<List<StudySessionSnapshot>> listActiveSessions() {
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
  Future<StudySessionSnapshot> answerCurrentItem({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> answerCurrentModeBatch({
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
  Future<StudySessionSnapshot> cancelSession(String sessionId) {
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
    this.onMarkCorrect,
  });

  final StudySessionSnapshot snapshot;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<StudyAnswerSubmission>? onAnswer;
  final VoidCallback? onContinue;
  final ValueChanged<StudyAnswerFeedback>? onMarkCorrect;

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
          onMarkCorrect: onMarkCorrect,
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
      onAnswer: (submission) => setState(() {
        _feedback = StudyAnswerFeedback(
          itemId: item.id,
          selectedGrade: submission.grade,
          isCorrect:
              submission.grade == AttemptGrade.correct ||
              submission.grade == AttemptGrade.remembered,
          correctAnswer: item.flashcard.back,
          submittedAnswer: submission.submittedAnswer,
          selectedOptionId: submission.selectedOptionId,
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
  StudyType studyType = StudyType.srsReview,
  SessionStatus status = SessionStatus.inProgress,
}) {
  return StudySessionSnapshot(
    session: StudySession(
      id: 'session-1',
      entryType: StudyEntryType.deck,
      entryRefId: 'deck-1',
      studyType: studyType,
      studyFlow: studyType == StudyType.newStudy
          ? StudyFlow.newFullCycle
          : StudyFlow.srsFillReview,
      settings: StudySettingsSnapshot(
        batchSize: cards.length,
        shuffleFlashcards: false,
        shuffleAnswers: shuffleAnswers,
        prioritizeOverdue: true,
      ),
      status: status,
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
