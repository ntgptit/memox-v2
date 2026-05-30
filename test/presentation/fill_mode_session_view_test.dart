import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/repositories/tts_settings_repository.dart';
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

  StudySessionSnapshot snapshotFor(
    String front, {
    String secondFront = 'xyzab',
  }) {
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

  Future<_FillHarness> pump(
    WidgetTester tester,
    StudySessionSnapshot snapshot,
  ) async {
    final fakeTts = _RecordingTts();
    final submissions = <Map<String, AttemptGrade>>[];
    await tester.binding.setSurfaceSize(const Size(430, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    addTearDown(fakeTts.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ttsServiceProvider.overrideWithValue(fakeTts),
          ttsSettingsRepositoryProvider.overrideWith(
            (ref) async => _FakeTtsSettingsRepository(
              settings: const TtsSettings(
                autoPlay: true,
                frontLanguage: TtsLanguage.korean,
                rate: TtsSettings.defaultRate,
                pitch: TtsSettings.defaultPitch,
                volume: TtsSettings.defaultVolume,
              ),
            ),
          ),
        ],
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
    return _FillHarness(submissions: submissions, tts: fakeTts);
  }

  Finder inputField() =>
      find.byKey(const ValueKey<String>('fill-answer-input'));
  Finder checkButton() =>
      find.byKey(const ValueKey<String>('fill-check-action'));
  Finder hintButton() => find.byKey(const ValueKey<String>('fill-help-action'));
  Finder tryAgainButton() =>
      find.byKey(const ValueKey<String>('fill-try-again-action'));
  Finder markCorrectButton() =>
      find.byKey(const ValueKey<String>('fill-mark-correct-action'));
  Finder speakButton(String text) =>
      find.byKey(ValueKey<String>('fill-front-speak-$text'));

  group('Fill matcher (strict)', () {
    testWidgets('case difference is treated as wrong', (tester) async {
      await pump(tester, snapshotFor('abc'));
      await tester.enterText(inputField(), 'ABC');
      await tester.pump();
      await tester.tap(checkButton());
      await tester.pump();
      // Wrong feedback card appears.
      expect(find.byType(FillIncorrectCard), findsOneWidget);
    });

    testWidgets('trim-only difference still passes', (tester) async {
      final harness = await pump(tester, snapshotFor('웃기다'));
      await tester.enterText(inputField(), '  웃기다  ');
      await tester.pump();
      await tester.tap(checkButton());
      await tester.pump();
      // No wrong feedback — advanced to next card.
      expect(find.byType(FillIncorrectCard), findsNothing);
      // First card pass does NOT submit yet (not last item) but staged grade exists.
      expect(harness.submissions, isEmpty);
    });
  });

  group('Fill TTS', () {
    testWidgets('DT14 onDisplay: typing state hides the manual speak button', (
      tester,
    ) async {
      await pump(tester, snapshotFor('abcde'));

      expect(speakButton('abcde'), findsNothing);
    });

    testWidgets('DT14 onDisplay: wrong feedback does not auto-play TTS', (
      tester,
    ) async {
      final harness = await pump(tester, snapshotFor('abcde'));
      await tester.enterText(inputField(), 'wrong');
      await tester.pump();
      await tester.tap(checkButton());
      await tester.pumpAndSettle();

      expect(find.byType(FillIncorrectCard), findsOneWidget);
      expect(speakButton('abcde'), findsOneWidget);
      expect(harness.tts.speakCalls, isEmpty);
    });

    testWidgets(
      'DT14 onSelect: manual speak button speaks the correct front after wrong feedback',
      (tester) async {
        final harness = await pump(tester, snapshotFor('abcde'));
        await tester.enterText(inputField(), 'wrong');
        await tester.pump();
        await tester.tap(checkButton());
        await tester.pumpAndSettle();

        expect(speakButton('abcde'), findsOneWidget);
        await tester.tap(speakButton('abcde'));
        await tester.pump();

        expect(harness.tts.speakCalls, hasLength(1));
        expect(harness.tts.speakCalls.single.text, 'abcde');
        expect(harness.tts.speakCalls.single.language, TtsLanguage.korean);
      },
    );
  });

  group('Fill hint reveal', () {
    testWidgets('hint reveals one character per tap', (tester) async {
      await pump(tester, snapshotFor('abcde'));
      await tester.tap(hintButton());
      await tester.pump();
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: inputField(),
                matching: find.byType(TextField),
              ),
            )
            .controller!
            .text,
        'a',
      );
      await tester.tap(hintButton());
      await tester.pump();
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: inputField(),
                matching: find.byType(TextField),
              ),
            )
            .controller!
            .text,
        'ab',
      );
    });

    testWidgets('hint tap does not show wrong feedback', (tester) async {
      await pump(tester, snapshotFor('abcde'));
      await tester.tap(hintButton());
      await tester.pump();
      expect(find.byType(FillIncorrectCard), findsNothing);
    });

    testWidgets('hint tap does not submit an attempt', (tester) async {
      // Wireframe §Components (Hint button): hint only reveals; no attempt is
      // persisted. With a multi-item snapshot, a Hint tap alone must leave
      // submissions empty and keep the input card visible.
      final harness = await pump(tester, snapshotFor('abcde'));
      await tester.tap(hintButton());
      await tester.pump();
      await tester.tap(hintButton());
      await tester.pump();
      expect(harness.submissions, isEmpty);
      expect(
        find.byKey(const ValueKey<String>('fill-input-card')),
        findsOneWidget,
      );
      expect(find.byType(FillIncorrectCard), findsNothing);
    });

    testWidgets('new card resets hint reveal count', (tester) async {
      // First card front: 'abcde'; second card front: 'xyzab'. After tapping
      // Hint once on card 1 and clearing card 1 via a correct exact match, the
      // view advances to card 2 with reveal count back to 0 — the next Hint
      // tap reveals 'x', not 'xy'.
      await pump(tester, snapshotFor('abcde', secondFront: 'xyzab'));
      await tester.tap(hintButton());
      await tester.pump();
      // Overwrite the revealed prefix with the full exact answer for card 1.
      await tester.enterText(inputField(), 'abcde');
      await tester.pump();
      await tester.tap(checkButton());
      await tester.pump();
      // Now on card 2, controller cleared, reveal count reset.
      final inputAfter = tester.widget<TextField>(
        find.descendant(of: inputField(), matching: find.byType(TextField)),
      );
      expect(inputAfter.controller!.text, '');
      await tester.tap(hintButton());
      await tester.pump();
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: inputField(),
                matching: find.byType(TextField),
              ),
            )
            .controller!
            .text,
        'x',
      );
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
        tester
            .widget<TextField>(
              find.descendant(
                of: inputField(),
                matching: find.byType(TextField),
              ),
            )
            .controller!
            .text,
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
          tester
              .widget<TextField>(
                find.descendant(
                  of: inputField(),
                  matching: find.byType(TextField),
                ),
              )
              .controller!
              .text,
          'ab',
        );
      },
    );
  });

  group('Fill Mark correct', () {
    testWidgets(
      'Mark correct on a non-last item advances to the next card without submitting',
      (tester) async {
        // Two-item snapshot: Mark correct on the FIRST card stages the grade
        // locally and advances to card 2; onSubmit is only called when the
        // last item is graded.
        final harness = await pump(
          tester,
          snapshotFor('abcde', secondFront: 'xyzab'),
        );
        await tester.enterText(inputField(), 'wrong');
        await tester.pump();
        await tester.tap(checkButton());
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(FillIncorrectCard), findsOneWidget);
        // Invoke onPressed directly to avoid AnimatedSwitcher hit-test flake.
        final markCorrect = tester.widget(markCorrectButton());
        // ignore: avoid_dynamic_calls
        (markCorrect as dynamic).onPressed.call();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        // Advanced to card 2: input card visible, controller cleared, no
        // onSubmit yet (still not the last item).
        expect(
          find.byKey(const ValueKey<String>('fill-input-card')),
          findsOneWidget,
        );
        final input = tester.widget<TextField>(
          find.descendant(of: inputField(), matching: find.byType(TextField)),
        );
        expect(input.controller!.text, '');
        expect(harness.submissions, isEmpty);
      },
    );

    testWidgets(
      'Mark correct on the LAST item flushes the staged batch via onSubmit',
      (tester) async {
        // Pass card 1 with an exact match, then on card 2 (last) trigger wrong
        // feedback and tap Mark correct. The view must submit both grades as
        // AttemptGrade.correct.
        final harness = await pump(
          tester,
          snapshotFor('abcde', secondFront: 'xyzab'),
        );
        await tester.enterText(inputField(), 'abcde');
        await tester.pump();
        await tester.tap(checkButton());
        await tester.pump();
        // Now on card 2. Wrong guess → wrong feedback.
        await tester.enterText(inputField(), 'nope');
        await tester.pump();
        await tester.tap(checkButton());
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(FillIncorrectCard), findsOneWidget);
        final markCorrect = tester.widget(markCorrectButton());
        // ignore: avoid_dynamic_calls
        (markCorrect as dynamic).onPressed.call();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        expect(harness.submissions, hasLength(1));
        expect(harness.submissions.single, <String, AttemptGrade>{
          'item-c1': AttemptGrade.correct,
          'item-c2': AttemptGrade.correct,
        });
      },
    );
  });
}

final class _FillHarness {
  const _FillHarness({required this.submissions, required this.tts});

  final List<Map<String, AttemptGrade>> submissions;
  final _RecordingTts tts;
}

final class _SpeakCall {
  const _SpeakCall({required this.text, required this.language});

  final String text;
  final TtsLanguage language;
}

final class _FakeTtsSettingsRepository implements TtsSettingsRepository {
  _FakeTtsSettingsRepository({required this.settings});

  TtsSettings settings;

  @override
  Future<TtsSettings> load() async => settings;

  @override
  Future<void> save(TtsSettings settings) async {
    this.settings = settings;
  }
}

final class _RecordingTts implements TtsService {
  final StreamController<TtsState> _states =
      StreamController<TtsState>.broadcast();
  final List<_SpeakCall> speakCalls = <_SpeakCall>[];
  int stopCount = 0;

  @override
  Stream<TtsState> get state => _states.stream;

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
  }) async {
    speakCalls.add(_SpeakCall(text: text, language: language));
    if (!_states.isClosed) {
      _states.add(TtsState.speaking);
    }
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
    if (!_states.isClosed) {
      _states.add(TtsState.idle);
    }
  }

  @override
  Future<void> dispose() async {
    await _states.close();
  }
}
