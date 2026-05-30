import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/widgets/study_session/fill/fill_answer_cards.dart';
import 'package:memox/presentation/features/study/widgets/study_session/fill/fill_mode_session_view.dart';

/// Widget-level coverage for Fill mode strict matcher and hint reveal policy.
/// Spec: `docs/wireframes/17-study-session-fill.md`.
void main() {
  StudyFlashcardRef card(String id, String front) => StudyFlashcardRef(
    id: id,
    deckId: 'deck-1',
    front: front,
    back: 'back $id',
    sourcePool: SessionItemSourcePool.due,
  );

  StudySessionItem item(String id, String front) => StudySessionItem(
    id: 'item-$id',
    sessionId: 'session-1',
    flashcard: card(id, front),
    studyMode: StudyMode.fill,
    modeOrder: 1,
    roundIndex: 1,
    queuePosition: 1,
    sourcePool: SessionItemSourcePool.due,
    status: SessionItemStatus.pending,
    completedAt: null,
  );

  StudySessionSnapshot snapshotFor(String front, {String secondFront = 'xyzab'}) {
    final i1 = item('c1', front);
    final i2 = item('c2', secondFront);
    return StudySessionSnapshot(
      session: const StudySession(
        id: 'session-1',
        entryType: StudyEntryType.deck,
        entryRefId: 'deck-1',
        studyType: StudyType.newStudy,
        studyFlow: StudyFlow.newFullCycle,
        settings: StudySettingsSnapshot(
          batchSize: 20,
          shuffleFlashcards: false,
          shuffleAnswers: false,
          prioritizeOverdue: false,
        ),
        status: SessionStatus.inProgress,
        startedAt: 0,
        endedAt: null,
        restartedFromSessionId: null,
      ),
      currentItem: i1,
      currentRoundItems: <StudySessionItem>[i1, i2],
      sessionFlashcards: <StudyFlashcardRef>[i1.flashcard, i2.flashcard],
      summary: const StudySummary(
        totalCards: 2,
        completedAttempts: 0,
        correctAttempts: 0,
        incorrectAttempts: 0,
        increasedBoxCount: 0,
        decreasedBoxCount: 0,
        remainingCount: 2,
      ),
      canFinalize: false,
    );
  }

  Future<List<Map<String, AttemptGrade>>> pump(
    WidgetTester tester,
    StudySessionSnapshot snapshot,
  ) async {
    final submissions = <Map<String, AttemptGrade>>[];
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [ttsServiceProvider.overrideWithValue(_NoopTts())],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: FillModeSessionView(
            snapshot: snapshot,
            isSubmitting: false,
            canCancel: true,
            onSubmit: (grades) async {
              submissions.add(Map<String, AttemptGrade>.from(grades));
              return true;
            },
            onCancel: () {},
            onBack: () {},
          ),
        ),
      ),
    );
    await tester.pump();
    return submissions;
  }

  Finder inputField() => find.byKey(const ValueKey<String>('fill-answer-input'));
  Finder checkButton() => find.byKey(const ValueKey<String>('fill-check-action'));
  Finder hintButton() => find.byKey(const ValueKey<String>('fill-help-action'));
  Finder tryAgainButton() =>
      find.byKey(const ValueKey<String>('fill-try-again-action'));

  group('Fill matcher (strict)', () {
    testWidgets('case difference is treated as wrong', (tester) async {
      await pump(tester, snapshotFor('abc'));
      await tester.enterText(inputField(), 'ABC');
      await tester.pump();
      await tester.tap(checkButton());
      await tester.pump();
      // Wrong feedback card appears.
      expect(find.byType(FillIncorrectCard), findsOneWidget);
      // Drain TTS auto-speak timers spawned by the wrong-feedback card.
      await tester.pump(const Duration(seconds: 21));
    });

    testWidgets('trim-only difference still passes', (tester) async {
      final submissions = await pump(tester, snapshotFor('웃기다'));
      await tester.enterText(inputField(), '  웃기다  ');
      await tester.pump();
      await tester.tap(checkButton());
      await tester.pump();
      // No wrong feedback — advanced to next card.
      expect(find.byType(FillIncorrectCard), findsNothing);
      // First card pass does NOT submit yet (not last item) but staged grade exists.
      expect(submissions, isEmpty);
    });
  });

  group('Fill hint reveal', () {
    testWidgets('hint reveals one character per tap', (tester) async {
      await pump(tester, snapshotFor('abcde'));
      await tester.tap(hintButton());
      await tester.pump();
      expect(
        tester.widget<TextField>(find.descendant(
          of: inputField(),
          matching: find.byType(TextField),
        )).controller!.text,
        'a',
      );
      await tester.tap(hintButton());
      await tester.pump();
      expect(
        tester.widget<TextField>(find.descendant(
          of: inputField(),
          matching: find.byType(TextField),
        )).controller!.text,
        'ab',
      );
    });

    testWidgets('hint tap does not show wrong feedback', (tester) async {
      await pump(tester, snapshotFor('abcde'));
      await tester.tap(hintButton());
      await tester.pump();
      expect(find.byType(FillIncorrectCard), findsNothing);
    });

    testWidgets('hint stops revealing at cap (floor(len/2))', (tester) async {
      await pump(tester, snapshotFor('abcde'));
      await tester.tap(hintButton());
      await tester.pump();
      await tester.tap(hintButton());
      await tester.pump();
      // Cap reached (2 for length 5). Further taps must not extend reveal.
      await tester.tap(hintButton(), warnIfMissed: false);
      await tester.pump();
      expect(
        tester.widget<TextField>(find.descendant(
          of: inputField(),
          matching: find.byType(TextField),
        )).controller!.text,
        'ab',
      );
    });

    testWidgets(
      'try again clears input but keeps hint reveal count for same card',
      (tester) async {
        await pump(tester, snapshotFor('abcde'));
        // Reveal one char.
        await tester.tap(hintButton());
        await tester.pump();
        // Type a wrong guess and check.
        await tester.enterText(inputField(), 'zz');
        await tester.pump();
        await tester.tap(checkButton());
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(FillIncorrectCard), findsOneWidget);
        // Try again → back to input, controller cleared. Invoke the callback
        // directly to avoid hit-test flake from in-flight AnimatedSwitcher
        // transition layers in widget-test mode.
        final tryAgain = tester.widget(tryAgainButton());
        // ignore: avoid_dynamic_calls
        (tryAgain as dynamic).onPressed.call();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(FillIncorrectCard), findsNothing);
        final textField = tester.widget<TextField>(
          find.descendant(of: inputField(), matching: find.byType(TextField)),
        );
        expect(textField.controller!.text, '');
        // Tap Hint again — reveal count is retained, so this is the SECOND reveal,
        // producing 'ab' (not 'a').
        await tester.tap(hintButton());
        await tester.pump();
        expect(
          tester.widget<TextField>(find.descendant(
            of: inputField(),
            matching: find.byType(TextField),
          )).controller!.text,
          'ab',
        );
        // Drain TTS auto-speak timers from the brief wrong-feedback state.
        await tester.pump(const Duration(seconds: 21));
      },
    );
  });
}

final class _NoopTts implements TtsService {
  @override
  Stream<TtsState> get state => const Stream<TtsState>.empty();

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguage language) async =>
      const <TtsVoice>[];

  @override
  Future<void> speak(
    String text, {
    required TtsLanguage language,
    required double rate,
    required double pitch,
    required double volume,
    String? voiceName,
  }) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
