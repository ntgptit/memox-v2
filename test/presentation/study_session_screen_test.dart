import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';
import 'package:memox/presentation/features/study/widgets/study_session/guess/guess_motion.dart';
import 'package:memox/presentation/features/study/widgets/study_session/fill/fill_motion.dart';
import 'package:memox/presentation/features/study/widgets/study_session/recall/recall_motion.dart';
import 'package:memox/presentation/features/study/widgets/study_session/study_speak_button.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';
import 'package:memox/presentation/shared/widgets/mx_text.dart';
import 'package:memox/presentation/shared/widgets/mx_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('DT1 onOpen: shows loading state while session loads', (
    tester,
  ) async {
    final completer = Completer<StudySessionSnapshot>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(_activeSnapshot);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => completer.future),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(MxLoadingState), findsOneWidget);
  });

  testWidgets('DT1 onDisplay: guess mode renders trắc nghiệm layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_activeSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    expect(find.text('Guess'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.text_fields), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('front 1'), findsOneWidget);
    expect(find.text('back 1'), findsOneWidget);
    expect(find.text('back 2'), findsOneWidget);
    expect(find.text('back 3'), findsOneWidget);
    expect(find.text('back 4'), findsOneWidget);
    expect(find.text('back 5'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is MxText &&
            widget.data == 'front 1' &&
            widget.role == MxTextRole.guessPrompt,
      ),
      findsOneWidget,
    );
    final promptStyle = tester.widget<Text>(find.text('front 1')).style!;
    final promptTheme = Theme.of(tester.element(find.text('front 1')));
    expect(
      promptStyle.fontSize,
      lessThan(promptTheme.textTheme.displayMedium!.fontSize!),
    );
    final termCardHeight = tester
        .getSize(find.byKey(const ValueKey<String>('guess-target-card')))
        .height;
    final answerOptionHeight = _cardHeightForKey(
      tester,
      'guess-option-card-001',
    );
    expect(termCardHeight, greaterThan(answerOptionHeight * 2.2));
    expect(find.text('Correct'), findsNothing);
    expect(find.text('Incorrect'), findsNothing);
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Skip card'), findsNothing);
  });

  testWidgets(
    'DT3 onDisplay: review mode renders title actions progress and two cards',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_singleReviewSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Review'), findsOneWidget);
      expect(find.byIcon(Icons.text_fields), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
      expect(find.byIcon(Icons.mode_edit_outline), findsOneWidget);
      expect(find.text('front 1'), findsOneWidget);
      expect(find.text('back 1'), findsOneWidget);
    },
  );

  testWidgets(
    'DT4 onDisplay: review mode initial progress row uses larger synchronized sizing',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_singleReviewSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final progress = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final progressLabelStyle = tester.widget<Text>(find.text('0%')).style!;
      expect(find.text('0%'), findsOneWidget);
      expect(progress.minHeight, 8);
      expect(progressLabelStyle.fontSize, greaterThanOrEqualTo(14));
      expect(progressLabelStyle.fontWeight, FontWeight.w600);
    },
  );

  testWidgets('DT5 onDisplay: review mode hides grading and skip controls', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_singleReviewSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    expect(find.text('Forgot'), findsNothing);
    expect(find.text('Remembered'), findsNothing);
    expect(find.text('Skip card'), findsNothing);
  });

  testWidgets(
    'DT6 onDisplay: review faces use fixed larger non-heavy typography',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_mixedLengthReviewSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final frontStyle = tester.widget<Text>(find.text('front 1')).style!;
      final shortAnswerStyle = tester.widget<Text>(find.text('back 1')).style!;
      expect(frontStyle.fontSize, greaterThan(shortAnswerStyle.fontSize!));
      expect(frontStyle.fontWeight, FontWeight.w500);
      expect(shortAnswerStyle.fontWeight, FontWeight.w400);

      await tester.dragFrom(const Offset(700, 400), const Offset(-500, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final longAnswerStyle = tester
          .widget<Text>(find.text(_longReviewBack))
          .style!;
      expect(longAnswerStyle.fontSize, shortAnswerStyle.fontSize);
      expect(longAnswerStyle.fontWeight, FontWeight.w400);
      expect(shortAnswerStyle.fontWeight, longAnswerStyle.fontWeight);
      expect(shortAnswerStyle.color, longAnswerStyle.color);
    },
  );

  testWidgets('DT7 onDisplay: match mode renders full two-column board', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_matchSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    expect(find.text('Match'), findsOneWidget);
    expect(find.byIcon(Icons.text_fields), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.text('20%'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('match-front-speak-item-001')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('match-front-speak-item-002')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('match-left-item-001')),
        matching: find.text(_alphaFront),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('match-right-item-001')),
        matching: find.text(_alphaBack),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('match-left-item-002')),
        matching: find.text(_betaFront),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('match-right-item-002')),
        matching: find.text(_betaBack),
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'DT8 onDisplay: match mode keeps meaning text fixed and ellipsized',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_matchLongTextSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final longMeaning = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('match-right-item-001')),
          matching: find.text(_longMatchBack),
        ),
      );
      final shortMeaning = tester.widget<Text>(
        find.descendant(
          of: find.byKey(const ValueKey('match-right-item-002')),
          matching: find.text(_betaBack),
        ),
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('match-left-item-001')),
          matching: find.text(_alphaFront),
        ),
        findsOneWidget,
      );
      expect(longMeaning.style!.fontSize, shortMeaning.style!.fontSize);
      expect(longMeaning.style!.fontWeight, shortMeaning.style!.fontWeight);
      expect(longMeaning.maxLines, 4);
      expect(longMeaning.overflow, TextOverflow.ellipsis);
      expect(find.text('Skip card'), findsNothing);
    },
  );

  testWidgets('DT9 onDisplay: match mode shows only first display batch', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_largeMatchSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (var index = 1; index <= 5; index++) {
      expect(find.text(_matchFront(index)), findsOneWidget);
      expect(find.text(_matchBack(index)), findsOneWidget);
    }
    expect(find.text(_matchFront(6)), findsNothing);
    expect(find.text(_matchBack(6)), findsNothing);
    expect(find.text(_matchFront(7)), findsNothing);
    expect(find.text(_matchBack(7)), findsNothing);
    expect(find.byKey(const ValueKey('match-left-item-006')), findsNothing);
    expect(find.byKey(const ValueKey('match-right-item-006')), findsNothing);
    expect(find.byKey(const ValueKey('match-left-item-007')), findsNothing);
    expect(find.byKey(const ValueKey('match-right-item-007')), findsNothing);
  });

  testWidgets(
    'DT10 onDisplay: match mode uses five-pair slot height for sparse batch',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_matchSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sparseTileHeight = _matchTileHeight(tester, 'match-left-item-001');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_fivePairMatchSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fivePairTileHeight = _matchTileHeight(
        tester,
        'match-left-item-001',
      );

      expect(sparseTileHeight, closeTo(fivePairTileHeight, 0.1));
    },
  );

  testWidgets('DT11 onDisplay: guess mode keeps long option scrollable', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_longGuessOptionSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final longOption = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('guess-option-card-002')),
        matching: find.text(_longGuessBack),
      ),
    );
    final optionHeights = [
      for (var index = 1; index <= 5; index++)
        _cardHeightForKey(tester, 'guess-option-card-00$index'),
    ];
    final firstOptionHeight = optionHeights.first;
    final listBottom = tester
        .getBottomLeft(find.byKey(const ValueKey('guess-options-list')))
        .dy;
    final lastCardBottom = tester
        .getBottomLeft(_cardFinderForKey('guess-option-card-005'))
        .dy;

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text(_longGuessBack), findsOneWidget);
    for (final height in optionHeights) {
      expect(height, closeTo(firstOptionHeight, 0.1));
    }
    expect(lastCardBottom, closeTo(listBottom, 0.1));
    expect(longOption.maxLines, 2);
    expect(longOption.overflow, TextOverflow.ellipsis);
    expect(longOption.textAlign, TextAlign.center);
  });

  testWidgets('DT12 onDisplay: recall mode renders hidden answer layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_recallSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    final questionHeight = tester.getSize(
      find.byKey(const ValueKey<String>('recall-question-card')),
    );
    final answerHeight = tester.getSize(
      find.byKey(const ValueKey<String>('recall-answer-card')),
    );
    final frontText = tester.widget<MxText>(
      find.byWidgetPredicate(
        (widget) =>
            widget is MxText &&
            widget.data == 'front 1' &&
            widget.role == MxTextRole.recallFront,
      ),
    );

    expect(find.text('Recall'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.text_fields), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.byIcon(Icons.mode_edit_outline), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
    expect(frontText.textAlign, TextAlign.center);
    expect(
      find.byKey(const ValueKey<String>('recall-answer-hidden')),
      findsOneWidget,
    );
    expect(find.byType(ImageFiltered), findsOneWidget);
    expect(find.text('Show (20s)'), findsOneWidget);
    expect(find.text('Forgot'), findsNothing);
    expect(find.text('Remembered'), findsNothing);
    expect(find.text('Correct'), findsNothing);
    expect(find.text('Incorrect'), findsNothing);
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Skip card'), findsNothing);
    expect(questionHeight.height, closeTo(answerHeight.height, 0.1));
  });

  testWidgets('DT13 onDisplay: fill mode renders input layout', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_fillSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    final checkButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Check'),
    );
    final inputTextField = tester.widget<TextField>(find.byType(TextField));

    expect(find.text('Fill'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.text_fields), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.byIcon(Icons.mode_edit_outline), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('back 1'), findsOneWidget);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(checkButton.onPressed, isNull);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is MxTextField &&
            widget.variant == MxTextFieldVariant.borderless &&
            widget.textRole == MxTextRole.fillInput &&
            widget.textAlign == TextAlign.center &&
            widget.expands,
      ),
      findsOneWidget,
    );
    expect(inputTextField.expands, isTrue);
    expect(inputTextField.maxLines, isNull);
    expect(inputTextField.minLines, isNull);
    expect(find.text('Continue'), findsNothing);
    expect(find.text('Skip card'), findsNothing);
  });

  testWidgets(
    'DT14 onDisplay: fill mode avoids keyboard overflow in short viewport',
    (tester) async {
      tester.view.physicalSize = const Size(390, 620);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 260);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.view.resetViewInsets();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_fillSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await _pumpStudyScreenData(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('80%'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('fill-prompt-card')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey<String>('fill-input-card')),
        findsOneWidget,
      );
      expect(find.text('Help'), findsOneWidget);
      expect(find.text('Check'), findsOneWidget);
    },
  );

  testWidgets(
    'DT1 onSelect: active mode cancel opens confirmation before mutation',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_fillSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await _pumpStudyScreenData(tester);

      expect(find.text('Fill'), findsOneWidget);
      expect(find.byTooltip('Cancel session'), findsOneWidget);

      await tester.tap(find.byTooltip('Cancel session'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel this session?'), findsOneWidget);
      expect(
        find.text(
          'Your current study session will stop and you will be taken to '
          'the result screen.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'DT1 onUpdate: single-card review auto-submits after two seconds',
    (tester) async {
      final repo = _BatchAnswerStudyRepo(_singleReviewSnapshot);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_singleReviewSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(repo.batchAnswerCount, 0);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(repo.batchAnswerCount, 1);
      expect(repo.lastGrade, AttemptGrade.correct);
    },
  );

  testWidgets('DT4 onUpdate: match correct pair holds success before fade', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo(_matchSnapshot);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_matchSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapMatchTile(tester, 'match-left-item-001');
    await tester.pump();
    await _tapMatchTile(tester, 'match-right-item-001');
    await tester.pump();

    final successCard = tester.widget<MxCard>(
      find.descendant(
        of: find.byKey(const ValueKey('match-left-item-001')),
        matching: find.byType(MxCard),
      ),
    );
    expect(find.text('30%'), findsOneWidget);
    expect(successCard.backgroundColor, isNotNull);
    expect(_matchTileOpacity(tester, 'match-left-item-001'), 1);
    expect(find.byKey(const ValueKey('match-left-item-001')), findsOneWidget);
    expect(find.byKey(const ValueKey('match-right-item-001')), findsOneWidget);
    expect(repo.matchBatchAnswerCount, 0);

    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump();

    expect(_matchTileOpacity(tester, 'match-left-item-001'), 0);
    expect(repo.matchBatchAnswerCount, 0);
  });

  testWidgets('DT5 onUpdate: match mismatch resets locally without submit', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo(_matchSnapshot);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_matchSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapMatchTile(tester, 'match-left-item-001');
    await tester.pump();
    await _tapMatchTile(tester, 'match-right-item-002');
    await tester.pump();

    final errorCard = tester.widget<MxCard>(
      find.descendant(
        of: find.byKey(const ValueKey('match-left-item-001')),
        matching: find.byType(MxCard),
      ),
    );
    expect(errorCard.backgroundColor, isNotNull);
    expect(repo.matchBatchAnswerCount, 0);
    expect(find.text('20%'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(repo.matchBatchAnswerCount, 0);
    expect(find.text('20%'), findsOneWidget);
  });

  testWidgets(
    'DT6 onUpdate: match board submits mixed grades once after completion',
    (tester) async {
      final repo = _BatchAnswerStudyRepo(_matchSnapshot);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_matchSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tapMatchTile(tester, 'match-left-item-001');
      await tester.pump();
      await _tapMatchTile(tester, 'match-right-item-002');
      await tester.pump(const Duration(milliseconds: 500));

      await _tapMatchTile(tester, 'match-left-item-001');
      await tester.pump();
      await _tapMatchTile(tester, 'match-right-item-001');
      await tester.pump();
      expect(find.text('20%'), findsOneWidget);
      await _tapMatchTile(tester, 'match-left-item-002');
      await tester.pump();
      await _tapMatchTile(tester, 'match-right-item-002');
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();

      expect(repo.matchBatchAnswerCount, 1);
      expect(repo.lastItemGrades, <String, AttemptGrade>{
        'item-001': AttemptGrade.incorrect,
        'item-002': AttemptGrade.correct,
      });
    },
  );

  testWidgets(
    'DT7 onUpdate: match display batch advances before final submit',
    (tester) async {
      final repo = _BatchAnswerStudyRepo(_largeMatchSnapshot);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_largeMatchSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (var index = 1; index <= 5; index++) {
        await _completeMatchPair(tester, index);
      }
      expect(repo.matchBatchAnswerCount, 0);

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();

      expect(find.text('34%'), findsOneWidget);
      expect(find.text(_matchFront(6)), findsOneWidget);
      expect(find.text(_matchBack(6)), findsOneWidget);
      expect(find.text(_matchFront(7)), findsOneWidget);
      expect(find.text(_matchBack(7)), findsOneWidget);
      expect(repo.matchBatchAnswerCount, 0);

      await _completeMatchPair(tester, 6);
      await tester.pump();
      expect(repo.matchBatchAnswerCount, 0);

      await _completeMatchPair(tester, 7);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump();

      expect(repo.matchBatchAnswerCount, 1);
      expect(repo.lastItemGrades, <String, AttemptGrade>{
        for (var index = 1; index <= 7; index++)
          _matchItemId(index): AttemptGrade.correct,
      });
    },
  );

  testWidgets(
    'DT8 onUpdate: guess correct option submits correct after feedback',
    (tester) async {
      final repo = _BatchAnswerStudyRepo(_activeSnapshot);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_activeSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tapGuessOption(tester, 'card-001');
      await tester.pump();
      await tester.pump(guessColorTransitionDuration);

      final selectedCard = _cardForKey(tester, 'guess-option-card-001');
      final idleCard = _cardForKey(tester, 'guess-option-card-002');
      expect(selectedCard.backgroundColor, isNot(idleCard.backgroundColor));
      expect(repo.itemAnswerCount, 0);

      await tester.pump(guessFeedbackDelay - guessColorTransitionDuration);
      await tester.pump();

      expect(repo.itemAnswerCount, 0);
      expect(repo.modeItemBatchAnswerCount, 1);
      expect(repo.lastModeItemGrades, <String, AttemptGrade>{
        'item-001': AttemptGrade.correct,
      });
    },
  );

  testWidgets(
    'DT9 onUpdate: guess incorrect option submits incorrect after feedback',
    (tester) async {
      final repo = _BatchAnswerStudyRepo();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_activeSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tapGuessOption(tester, 'card-002');
      await tester.pump();
      await tester.pump(guessColorTransitionDuration);

      final wrongCard = _cardForKey(tester, 'guess-option-card-002');
      final correctCard = _cardForKey(tester, 'guess-option-card-001');
      final idleCard = _cardForKey(tester, 'guess-option-card-003');
      expect(wrongCard.backgroundColor, isNot(idleCard.backgroundColor));
      expect(correctCard.backgroundColor, isNot(idleCard.backgroundColor));
      expect(wrongCard.backgroundColor, isNot(correctCard.backgroundColor));
      expect(find.text('40%'), findsOneWidget);
      expect(repo.itemAnswerCount, 0);

      await tester.pump(guessFeedbackDelay - guessColorTransitionDuration);
      await tester.pump();

      expect(repo.itemAnswerCount, 0);
      expect(repo.modeItemBatchAnswerCount, 1);
      expect(find.text('40%'), findsOneWidget);
      expect(repo.lastModeItemGrades, <String, AttemptGrade>{
        'item-001': AttemptGrade.incorrect,
      });
    },
  );

  testWidgets('DT10 onUpdate: guess ignores taps while resolving', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo(_activeSnapshot);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_activeSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await _tapGuessOption(tester, 'card-002');
    await tester.pump();
    await _tapGuessOption(tester, 'card-001');
    await tester.pump();

    await tester.pump(guessFeedbackDelay);
    await tester.pump();

    expect(repo.itemAnswerCount, 0);
    expect(repo.modeItemBatchAnswerCount, 1);
    expect(repo.lastModeItemGrades, <String, AttemptGrade>{
      'item-001': AttemptGrade.incorrect,
    });
  });

  testWidgets(
    'DT27 onUpdate: guess stages local answers until the last mode item',
    (tester) async {
      final repo = _BatchAnswerStudyRepo(_twoItemGuessSnapshot);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_twoItemGuessSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await _tapGuessOption(tester, 'card-001');
      await tester.pump(guessFeedbackDelay);
      await tester.pump();

      expect(find.text('front 2'), findsOneWidget);
      expect(repo.modeItemBatchAnswerCount, 0);

      await _tapGuessOption(tester, 'card-001');
      await tester.pump(guessFeedbackDelay);
      await tester.pump();

      expect(repo.modeItemBatchAnswerCount, 1);
      expect(repo.lastModeItemGrades, <String, AttemptGrade>{
        'item-001': AttemptGrade.correct,
        'item-002': AttemptGrade.incorrect,
      });
    },
  );

  testWidgets('DT11 onUpdate: recall show reveals answer without submit', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo(_recallSnapshot);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_recallSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    await tester.tap(find.text('Show (20s)'));
    await _pumpRecallRevealTransition(tester);

    final answerText = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('recall-answer-revealed')),
        matching: find.text(_longRecallBack),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('recall-answer-revealed')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('recall-answer-revealed')),
        matching: find.byType(SingleChildScrollView),
      ),
      findsOneWidget,
    );
    expect(find.text('Forgot'), findsOneWidget);
    expect(find.text('Remembered'), findsOneWidget);
    expect(find.text('Show (20s)'), findsNothing);
    expect(answerText.maxLines, isNull);
    expect(repo.itemAnswerCount, 0);
  });

  testWidgets('DT12 onUpdate: recall Forgot submits incorrect batch grade', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo(_recallSnapshot);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_recallSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    await tester.tap(find.text('Show (20s)'));
    await _pumpRecallRevealTransition(tester);
    await tester.tap(find.text('Forgot'));
    await tester.pump();

    expect(find.text('60%'), findsOneWidget);
    expect(repo.itemAnswerCount, 0);
    expect(repo.modeItemBatchAnswerCount, 1);
    expect(repo.lastModeItemGrades, <String, AttemptGrade>{
      'item-001': AttemptGrade.incorrect,
    });
  });

  testWidgets('DT13 onUpdate: recall Remembered submits correct batch grade', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo(_recallSnapshot);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_recallSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    await tester.tap(find.text('Show (20s)'));
    await _pumpRecallRevealTransition(tester);
    await tester.tap(find.text('Remembered'));
    await tester.pump();

    expect(repo.itemAnswerCount, 0);
    expect(repo.modeItemBatchAnswerCount, 1);
    expect(repo.lastModeItemGrades, <String, AttemptGrade>{
      'item-001': AttemptGrade.correct,
    });
  });

  testWidgets('DT14 onUpdate: recall item change resets hidden answer', (
    tester,
  ) async {
    var currentSnapshot = _recallSnapshot;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => currentSnapshot),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    await tester.tap(find.text('Show (20s)'));
    await _pumpRecallRevealTransition(tester);
    expect(find.text('Forgot'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(StudySessionScreen)),
    );
    currentSnapshot = _secondRecallSnapshot;
    container.invalidate(studySessionStateProvider('session-001'));
    await tester.pump();
    await _pumpStudyScreenData(tester);
    await _pumpRecallRevealTransition(tester);

    expect(find.text('front 2'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('recall-answer-hidden')),
      findsAtLeastNWidgets(1),
    );
    expect(find.text('Show (20s)'), findsOneWidget);
    expect(find.text('Forgot'), findsNothing);
    expect(find.text('Remembered'), findsNothing);
  });

  testWidgets('DT15 onUpdate: recall ignores taps while submitting', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo(_recallSnapshot)
      ..modeItemBatchCompleter = Completer<StudySessionSnapshot>();
    addTearDown(() {
      final completer = repo.modeItemBatchCompleter;
      if (completer != null && !completer.isCompleted) {
        completer.complete(_recallSnapshot);
      }
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_recallSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    await tester.tap(find.text('Show (20s)'));
    await _pumpRecallRevealTransition(tester);
    await tester.tap(find.text('Remembered'));
    await tester.pump();
    await tester.tap(find.text('Forgot'), warnIfMissed: false);
    await tester.pump();

    expect(repo.itemAnswerCount, 0);
    expect(repo.modeItemBatchAnswerCount, 1);
    expect(repo.lastModeItemGrades, <String, AttemptGrade>{
      'item-001': AttemptGrade.correct,
    });

    repo.modeItemBatchCompleter!.complete(_recallSnapshot);
    await tester.pump();
  });

  testWidgets('DT16 onUpdate: recall timeout reveals answer with next action', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo(_recallSnapshot);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_recallSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    await tester.pump(recallAnswerTimeoutDuration);
    await _pumpRecallRevealTransition(tester);

    expect(
      find.byKey(const ValueKey<String>('recall-answer-revealed')),
      findsOneWidget,
    );
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Forgot'), findsNothing);
    expect(find.text('Remembered'), findsNothing);
    expect(repo.itemAnswerCount, 0);

    final actionRight = tester.getTopRight(
      find.byKey(const ValueKey<String>('recall-next-action')),
    );
    final cardRight = tester
        .getTopRight(find.byKey(const ValueKey<String>('recall-answer-card')))
        .dx;
    expect(actionRight.dx, closeTo(cardRight, 1));
  });

  testWidgets(
    'DT17 onUpdate: recall timeout Next submits incorrect batch grade',
    (tester) async {
      final repo = _BatchAnswerStudyRepo(_recallSnapshot);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_recallSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await _pumpStudyScreenData(tester);

      await tester.pump(recallAnswerTimeoutDuration);
      await _pumpRecallRevealTransition(tester);
      await tester.tap(find.text('Next'));
      await tester.pump();

      expect(find.text('60%'), findsOneWidget);
      expect(repo.itemAnswerCount, 0);
      expect(repo.modeItemBatchAnswerCount, 1);
      expect(repo.lastModeItemGrades, <String, AttemptGrade>{
        'item-001': AttemptGrade.incorrect,
      });
    },
  );

  testWidgets(
    'DT28 onUpdate: recall stages correct and incorrect until mode completes',
    (tester) async {
      final repo = _BatchAnswerStudyRepo(_twoItemRecallSnapshot);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_twoItemRecallSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await _pumpStudyScreenData(tester);

      await tester.tap(find.text('Show (20s)'));
      await _pumpRecallRevealTransition(tester);
      await tester.tap(find.text('Remembered'));
      await tester.pump();

      expect(find.text('front 2'), findsOneWidget);
      expect(repo.modeItemBatchAnswerCount, 0);

      await tester.tap(find.text('Show (20s)'));
      await _pumpRecallRevealTransition(tester);
      await tester.tap(find.text('Forgot'));
      await tester.pump();

      expect(repo.modeItemBatchAnswerCount, 1);
      expect(repo.lastModeItemGrades, <String, AttemptGrade>{
        'item-001': AttemptGrade.correct,
        'item-002': AttemptGrade.incorrect,
      });
    },
  );

  testWidgets('DT18 onUpdate: fill keeps check disabled for blank input', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo();

    await _pumpFillScreen(tester, repo: repo);

    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();

    final checkButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Check'),
    );
    expect(checkButton.onPressed, isNull);
    expect(repo.itemAnswerCount, 0);
  });

  testWidgets(
    'DT19 onUpdate: fill correct input submits mode batch when mode completes',
    (tester) async {
      final repo = _BatchAnswerStudyRepo(_multiReviewSnapshot);

      await _pumpFillScreen(tester, repo: repo);

      await tester.enterText(find.byType(TextField), ' Front 1 ');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('fill-check-action')));
      await tester.pump();

      expect(repo.itemAnswerCount, 0);
      expect(repo.modeItemBatchAnswerCount, 1);
      expect(repo.lastModeItemGrades, <String, AttemptGrade>{
        'item-001': AttemptGrade.correct,
      });
    },
  );

  testWidgets('DT20 onUpdate: fill incorrect input reveals result locally', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo();

    await _pumpFillScreen(tester, repo: repo);

    await _enterWrongFillAnswer(tester);

    expect(find.text('80%'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('fill-result-card')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('fill-result-card')),
        matching: find.text('wrong'),
      ),
      findsOneWidget,
    );
    expect(find.text('front 1'), findsOneWidget);
    expect(find.text('Correct'), findsNothing);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Try again'), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('fill-result-card')),
        matching: find.byIcon(Icons.refresh),
      ),
      findsNothing,
    );
    expect(repo.itemAnswerCount, 0);
  });

  testWidgets('DT21 onUpdate: fill next submits incorrect grade', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo();

    await _pumpFillScreen(tester, repo: repo);
    await _enterWrongFillAnswer(tester);
    _pressFillAction(tester, 'fill-next-action');
    await tester.pump();

    expect(find.text('80%'), findsOneWidget);
    expect(repo.itemAnswerCount, 0);
    expect(repo.modeItemBatchAnswerCount, 1);
    expect(repo.lastModeItemGrades, <String, AttemptGrade>{
      'item-001': AttemptGrade.incorrect,
    });
  });

  testWidgets('DT25 onUpdate: fill help stages incorrect and next flushes', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo();

    await _pumpFillScreen(tester, repo: repo);
    await tester.tap(find.byKey(const ValueKey<String>('fill-help-action')));
    await _pumpFillStateTransition(tester);

    expect(repo.itemAnswerCount, 0);
    expect(repo.modeItemBatchAnswerCount, 0);
    expect(
      find.byKey(const ValueKey<String>('fill-result-card')),
      findsOneWidget,
    );
    expect(find.text('Correct'), findsNothing);
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('80%'), findsOneWidget);

    _pressFillAction(tester, 'fill-next-action');
    await tester.pump();

    expect(repo.itemAnswerCount, 0);
    expect(repo.modeItemBatchAnswerCount, 1);
    expect(repo.lastModeItemGrades, <String, AttemptGrade>{
      'item-001': AttemptGrade.incorrect,
    });
  });

  testWidgets('DT26 onUpdate: fill item change resets input state', (
    tester,
  ) async {
    var currentSnapshot = _fillSnapshot;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => currentSnapshot),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    await _enterWrongFillAnswer(tester);
    expect(find.text('Next'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(StudySessionScreen)),
    );
    currentSnapshot = _secondFillSnapshot;
    container.invalidate(studySessionStateProvider('session-001'));
    await tester.pump();
    await _pumpStudyScreenData(tester);
    await _pumpFillStateTransition(tester);

    final input = tester.widget<TextField>(find.byType(TextField));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('fill-prompt-card')),
        matching: find.text('back 2'),
      ),
      findsOneWidget,
    );
    expect(input.controller?.text, isEmpty);
    expect(find.text('Help'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('Next'), findsNothing);
  });

  testWidgets(
    'DT29 onUpdate: fill stages local answers until the last mode item',
    (tester) async {
      final repo = _BatchAnswerStudyRepo(_multiReviewSnapshot);

      await _pumpFillScreen(tester, repo: repo, snapshot: _twoItemFillSnapshot);

      await tester.enterText(find.byType(TextField), 'Front 1');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('fill-check-action')));
      await tester.pump();

      expect(find.text('back 2'), findsOneWidget);
      expect(repo.modeItemBatchAnswerCount, 0);

      await tester.enterText(find.byType(TextField), 'wrong');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('fill-check-action')));
      await _pumpFillStateTransition(tester);
      _pressFillAction(tester, 'fill-next-action');
      await tester.pump();

      expect(repo.modeItemBatchAnswerCount, 1);
      expect(repo.lastModeItemGrades, <String, AttemptGrade>{
        'item-001': AttemptGrade.correct,
        'item-002': AttemptGrade.incorrect,
      });
    },
  );

  testWidgets('DT30 onUpdate: study speak buttons only bind front TTS side', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_activeSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await _pumpStudyScreenData(tester);

    final frontButton = tester.widget<StudySpeakButton>(
      find.byKey(const ValueKey<String>('guess-front-speak-card-001')),
    );

    expect(frontButton.text, 'front 1');
    expect(frontButton.side, TtsTextSide.front);
    expect(
      find.byKey(const ValueKey<String>('guess-back-speak-card-001')),
      findsNothing,
    );
  });

  testWidgets(
    'DT2 onUpdate: web mouse right-to-left drag advances review vocabulary and only the last card can auto-submit',
    (tester) async {
      final repo = _BatchAnswerStudyRepo(_multiReviewSnapshot);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_multiReviewSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      expect(repo.batchAnswerCount, 0);

      await tester.dragFrom(
        const Offset(700, 400),
        const Offset(-500, 0),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('front 2'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(repo.batchAnswerCount, 0);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(repo.batchAnswerCount, 1);
    },
  );

  testWidgets(
    'DT3 onUpdate: web mouse wheel scroll advances review vocabulary',
    (tester) async {
      final repo = _BatchAnswerStudyRepo(_multiReviewSnapshot);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studyRepoProvider.overrideWithValue(repo),
            studySessionStateProvider(
              'session-001',
            ).overrideWith((ref) => Future.value(_multiReviewSnapshot)),
          ],
          child: const _TestApp(
            child: StudySessionScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      tester.binding.handlePointerEvent(
        const PointerScrollEvent(
          position: Offset(700, 400),
          scrollDelta: Offset(0, 80),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('front 2'), findsOneWidget);
      expect(repo.batchAnswerCount, 0);
    },
  );

  testWidgets('DT2 onDisplay: terminal session shows result handoff', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_terminalSnapshot)),
        ],
        child: const _TestApp(
          child: StudySessionScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('This session has ended.'), findsOneWidget);
    expect(find.text('View result'), findsOneWidget);
  });
}

final _activeSnapshot = _guessSnapshotFor([
  _card(id: 'card-001', front: 'front 1', back: 'back 1'),
  _card(id: 'card-002', front: 'front 2', back: 'back 2'),
  _card(id: 'card-003', front: 'front 3', back: 'back 3'),
  _card(id: 'card-004', front: 'front 4', back: 'back 4'),
  _card(id: 'card-005', front: 'front 5', back: 'back 5'),
]);

const _longGuessBack =
    'Missing person / Người mất tích (Danh từ, người không xác định được '
    'vị trí hiện tại, cần giữ nguyên toàn bộ nội dung trong option card)';

final _longGuessOptionSnapshot = _guessSnapshotFor([
  _card(id: 'card-001', front: 'front 1', back: 'back 1'),
  _card(id: 'card-002', front: 'front 2', back: _longGuessBack),
  _card(id: 'card-003', front: 'front 3', back: 'back 3'),
  _card(id: 'card-004', front: 'front 4', back: 'back 4'),
  _card(id: 'card-005', front: 'front 5', back: 'back 5'),
]);

final _twoItemGuessSnapshot = _modeRoundSnapshotFor(
  mode: StudyMode.guess,
  modeOrder: 3,
  completedAttempts: 4,
  cards: [
    _card(id: 'card-001', front: 'front 1', back: 'back 1'),
    _card(id: 'card-002', front: 'front 2', back: 'back 2'),
  ],
);

const _longRecallBack =
    'Report / Báo cáo, khai báo (Động từ, trình bày lại một sự việc đã xảy ra '
    'hoặc thông tin cần được ghi nhận trong quá trình học)';

final _recallSnapshot = _recallSnapshotFor(
  itemId: 'item-001',
  card: _card(id: 'card-001', front: 'front 1', back: _longRecallBack),
);

final _secondRecallSnapshot = _recallSnapshotFor(
  itemId: 'item-002',
  card: _card(id: 'card-002', front: 'front 2', back: 'back 2'),
);

final _twoItemRecallSnapshot = _modeRoundSnapshotFor(
  mode: StudyMode.recall,
  modeOrder: 4,
  completedAttempts: 6,
  cards: [
    _card(id: 'card-001', front: 'front 1', back: _longRecallBack),
    _card(id: 'card-002', front: 'front 2', back: 'back 2'),
  ],
);

final _fillSnapshot = _fillSnapshotFor(
  itemId: 'item-001',
  card: _card(id: 'card-001', front: 'front 1', back: 'back 1'),
);

final _secondFillSnapshot = _fillSnapshotFor(
  itemId: 'item-002',
  card: _card(id: 'card-002', front: 'front 2', back: 'back 2'),
);

final _twoItemFillSnapshot = _modeRoundSnapshotFor(
  mode: StudyMode.fill,
  modeOrder: 5,
  completedAttempts: 8,
  cards: [
    _card(id: 'card-001', front: 'front 1', back: 'back 1'),
    _card(id: 'card-002', front: 'front 2', back: 'back 2'),
  ],
);

final _singleReviewSnapshot = _reviewSnapshot([
  _card(id: 'card-001', front: 'front 1', back: 'back 1'),
]);

final _multiReviewSnapshot = _reviewSnapshot([
  _card(id: 'card-001', front: 'front 1', back: 'back 1'),
  _card(id: 'card-002', front: 'front 2', back: 'back 2'),
]);

const _longReviewBack =
    'Welfare / Phúc lợi (Danh từ, chế độ đảm bảo đời sống xã hội, '
    'âm Hán Việt: Phúc chỉ; Phúc: phúc lợi, Chỉ: hưởng đến lợi ích)';

final _mixedLengthReviewSnapshot = _reviewSnapshot([
  _card(id: 'card-001', front: 'front 1', back: 'back 1'),
  _card(id: 'card-002', front: '복지', back: _longReviewBack),
]);

const _alphaFront = 'Alpha';
const _alphaBack = 'Alpha definition';
const _betaFront = 'Beta';
const _betaBack = 'Beta definition';
const _longMatchBack =
    'A long definition that should stay readable inside the Match board tile '
    'without pushing adjacent controls outside the available card area.';

final _matchSnapshot = _matchSnapshotFor([
  _card(id: 'card-001', front: _alphaFront, back: _alphaBack),
  _card(id: 'card-002', front: _betaFront, back: _betaBack),
]);

final _matchLongTextSnapshot = _matchSnapshotFor([
  _card(id: 'card-001', front: _alphaFront, back: _longMatchBack),
  _card(id: 'card-002', front: _betaFront, back: _betaBack),
]);

final _largeMatchSnapshot = _matchSnapshotFor([
  for (var index = 1; index <= 7; index++)
    _card(
      id: 'card-${index.toString().padLeft(3, '0')}',
      front: _matchFront(index),
      back: _matchBack(index),
    ),
]);

final _fivePairMatchSnapshot = _matchSnapshotFor([
  for (var index = 1; index <= 5; index++)
    _card(
      id: 'card-${index.toString().padLeft(3, '0')}',
      front: _matchFront(index),
      back: _matchBack(index),
    ),
]);

final _terminalSnapshot = StudySessionSnapshot(
  session: _session(SessionStatus.completed),
  currentItem: null,
  sessionFlashcards: const <StudyFlashcardRef>[],
  summary: const StudySummary(
    totalCards: 1,
    completedAttempts: 1,
    correctAttempts: 1,
    incorrectAttempts: 0,
    increasedBoxCount: 1,
    decreasedBoxCount: 0,
    remainingCount: 0,
  ),
  canFinalize: false,
);

StudySession _session(SessionStatus status) {
  return StudySession(
    id: 'session-001',
    entryType: StudyEntryType.deck,
    entryRefId: 'deck-001',
    studyType: StudyType.srsReview,
    studyFlow: StudyFlow.srsFillReview,
    settings: const StudySettingsSnapshot(
      batchSize: 2,
      shuffleFlashcards: false,
      shuffleAnswers: false,
      prioritizeOverdue: true,
    ),
    status: status,
    startedAt: 0,
    endedAt: status == SessionStatus.inProgress ? null : 1,
    restartedFromSessionId: null,
  );
}

StudySession _newStudySession(SessionStatus status) {
  return StudySession(
    id: 'session-001',
    entryType: StudyEntryType.deck,
    entryRefId: 'deck-001',
    studyType: StudyType.newStudy,
    studyFlow: StudyFlow.newFullCycle,
    settings: const StudySettingsSnapshot(
      batchSize: 2,
      shuffleFlashcards: false,
      shuffleAnswers: false,
      prioritizeOverdue: true,
    ),
    status: status,
    startedAt: 0,
    endedAt: status == SessionStatus.inProgress ? null : 1,
    restartedFromSessionId: null,
  );
}

StudySessionSnapshot _guessSnapshotFor(List<StudyFlashcardRef> cards) {
  final current = cards.first;
  final completedAttempts = cards.length * 2;
  final remainingCount = cards.length * 3;
  return StudySessionSnapshot(
    session: _newStudySession(SessionStatus.inProgress),
    currentItem: StudySessionItem(
      id: 'item-001',
      sessionId: 'session-001',
      flashcard: current,
      studyMode: StudyMode.guess,
      modeOrder: 3,
      roundIndex: 1,
      queuePosition: 1,
      sourcePool: SessionItemSourcePool.newCards,
      status: SessionItemStatus.pending,
      completedAt: null,
    ),
    sessionFlashcards: cards,
    summary: StudySummary(
      totalCards: cards.length,
      totalModeCount: 5,
      completedAttempts: completedAttempts,
      correctAttempts: completedAttempts,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: remainingCount,
    ),
    canFinalize: false,
  );
}

StudySessionSnapshot _reviewSnapshot(List<StudyFlashcardRef> cards) {
  final current = cards.first;
  return StudySessionSnapshot(
    session: _newStudySession(SessionStatus.inProgress),
    currentItem: StudySessionItem(
      id: 'item-001',
      sessionId: 'session-001',
      flashcard: current,
      studyMode: StudyMode.review,
      modeOrder: 1,
      roundIndex: 1,
      queuePosition: 1,
      sourcePool: SessionItemSourcePool.due,
      status: SessionItemStatus.pending,
      completedAt: null,
    ),
    sessionFlashcards: cards,
    summary: StudySummary(
      totalCards: cards.length,
      totalModeCount: 5,
      completedAttempts: 0,
      correctAttempts: 0,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: cards.length,
    ),
    canFinalize: false,
  );
}

StudySessionSnapshot _recallSnapshotFor({
  required String itemId,
  required StudyFlashcardRef card,
}) {
  const completedAttempts = 3;
  const remainingCount = 2;
  return StudySessionSnapshot(
    session: _newStudySession(SessionStatus.inProgress),
    currentItem: StudySessionItem(
      id: itemId,
      sessionId: 'session-001',
      flashcard: card,
      studyMode: StudyMode.recall,
      modeOrder: 4,
      roundIndex: 1,
      queuePosition: 1,
      sourcePool: SessionItemSourcePool.newCards,
      status: SessionItemStatus.pending,
      completedAt: null,
    ),
    sessionFlashcards: [card],
    summary: const StudySummary(
      totalCards: 1,
      totalModeCount: 5,
      completedAttempts: completedAttempts,
      correctAttempts: completedAttempts,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: remainingCount,
    ),
    canFinalize: false,
  );
}

StudySessionSnapshot _fillSnapshotFor({
  required String itemId,
  required StudyFlashcardRef card,
}) {
  const completedAttempts = 4;
  const remainingCount = 1;
  return StudySessionSnapshot(
    session: _newStudySession(SessionStatus.inProgress),
    currentItem: StudySessionItem(
      id: itemId,
      sessionId: 'session-001',
      flashcard: card,
      studyMode: StudyMode.fill,
      modeOrder: 5,
      roundIndex: 1,
      queuePosition: 1,
      sourcePool: SessionItemSourcePool.newCards,
      status: SessionItemStatus.pending,
      completedAt: null,
    ),
    sessionFlashcards: [card],
    summary: const StudySummary(
      totalCards: 1,
      totalModeCount: 5,
      completedAttempts: completedAttempts,
      correctAttempts: completedAttempts,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: remainingCount,
    ),
    canFinalize: false,
  );
}

StudySessionSnapshot _modeRoundSnapshotFor({
  required StudyMode mode,
  required int modeOrder,
  required int completedAttempts,
  required List<StudyFlashcardRef> cards,
}) {
  final items = [
    for (var index = 0; index < cards.length; index++)
      StudySessionItem(
        id: 'item-${(index + 1).toString().padLeft(3, '0')}',
        sessionId: 'session-001',
        flashcard: cards[index],
        studyMode: mode,
        modeOrder: modeOrder,
        roundIndex: 1,
        queuePosition: index + 1,
        sourcePool: SessionItemSourcePool.newCards,
        status: SessionItemStatus.pending,
        completedAt: null,
      ),
  ];
  return StudySessionSnapshot(
    session: _newStudySession(SessionStatus.inProgress),
    currentItem: items.first,
    currentRoundItems: items,
    sessionFlashcards: cards,
    summary: StudySummary(
      totalCards: cards.length,
      totalModeCount: 5,
      completedAttempts: completedAttempts,
      correctAttempts: completedAttempts,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: (cards.length * 5) - completedAttempts,
    ),
    canFinalize: false,
  );
}

StudySessionSnapshot _matchSnapshotFor(List<StudyFlashcardRef> cards) {
  final items = [
    for (var index = 0; index < cards.length; index++)
      StudySessionItem(
        id: 'item-${(index + 1).toString().padLeft(3, '0')}',
        sessionId: 'session-001',
        flashcard: cards[index],
        studyMode: StudyMode.match,
        modeOrder: 2,
        roundIndex: 1,
        queuePosition: index + 1,
        sourcePool: SessionItemSourcePool.newCards,
        status: SessionItemStatus.pending,
        completedAt: null,
      ),
  ];
  return StudySessionSnapshot(
    session: _newStudySession(SessionStatus.inProgress),
    currentItem: items.first,
    currentRoundItems: items,
    sessionFlashcards: cards,
    summary: StudySummary(
      totalCards: cards.length,
      totalModeCount: 5,
      completedAttempts: cards.length,
      correctAttempts: cards.length,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: cards.length * 4,
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
    deckId: 'deck-001',
    front: front,
    back: back,
    sourcePool: SessionItemSourcePool.due,
  );
}

Future<void> _pumpStudyScreenData(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
}

Future<void> _pumpRecallRevealTransition(WidgetTester tester) async {
  await tester.pump(recallRevealTransitionDuration);
  await tester.pump();
}

Future<void> _pumpFillStateTransition(WidgetTester tester) async {
  await tester.pump(
    fillStateTransitionDuration + const Duration(milliseconds: 50),
  );
  await tester.pump();
}

Future<void> _pumpFillScreen(
  WidgetTester tester, {
  required _BatchAnswerStudyRepo repo,
  StudySessionSnapshot? snapshot,
}) async {
  repo.sessionSnapshot = snapshot ?? _fillSnapshot;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        studyRepoProvider.overrideWithValue(repo),
        studySessionStateProvider(
          'session-001',
        ).overrideWith((ref) => Future.value(snapshot ?? _fillSnapshot)),
      ],
      child: const _TestApp(
        child: StudySessionScreen(sessionId: 'session-001'),
      ),
    ),
  );
  await _pumpStudyScreenData(tester);
}

Future<void> _enterWrongFillAnswer(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), 'wrong');
  await tester.pump();
  await tester.tap(find.byKey(const ValueKey<String>('fill-check-action')));
  await _pumpFillStateTransition(tester);
}

void _pressFillAction(WidgetTester tester, String key) {
  final root = find.byKey(ValueKey<String>(key));
  final primary = find.descendant(
    of: root,
    matching: find.byType(ElevatedButton),
  );
  if (primary.evaluate().isNotEmpty) {
    tester.widget<ElevatedButton>(primary).onPressed!();
    return;
  }
  final outlined = find.descendant(
    of: root,
    matching: find.byType(OutlinedButton),
  );
  if (outlined.evaluate().isNotEmpty) {
    tester.widget<OutlinedButton>(outlined).onPressed!();
    return;
  }
  final tonal = find.descendant(of: root, matching: find.byType(FilledButton));
  tester.widget<FilledButton>(tonal).onPressed!();
}

Future<void> _tapGuessOption(WidgetTester tester, String cardId) {
  return tester.tap(
    find.byKey(ValueKey<String>('guess-option-$cardId')),
    warnIfMissed: false,
  );
}

Future<void> _tapMatchTile(WidgetTester tester, String key) {
  return tester.tap(find.byKey(ValueKey<String>(key)), warnIfMissed: false);
}

MxCard _cardForKey(WidgetTester tester, String key) {
  return tester.widget<MxCard>(_cardFinderForKey(key));
}

double _cardHeightForKey(WidgetTester tester, String key) {
  return tester.getSize(_cardFinderForKey(key)).height;
}

Finder _cardFinderForKey(String key) {
  return find.descendant(
    of: find.byKey(ValueKey<String>(key)),
    matching: find.byType(MxCard),
  );
}

double _matchTileOpacity(WidgetTester tester, String key) {
  return tester
      .widget<AnimatedOpacity>(
        find.descendant(
          of: find.byKey(ValueKey<String>(key)),
          matching: find.byType(AnimatedOpacity),
        ),
      )
      .opacity;
}

double _matchTileHeight(WidgetTester tester, String key) {
  return tester
      .getSize(
        find.descendant(
          of: find.byKey(ValueKey<String>(key)),
          matching: find.byType(MxCard),
        ),
      )
      .height;
}

Future<void> _completeMatchPair(WidgetTester tester, int index) async {
  final itemId = _matchItemId(index);
  await _tapMatchTile(tester, 'match-left-$itemId');
  await tester.pump();
  await _tapMatchTile(tester, 'match-right-$itemId');
  await tester.pump();
}

String _matchItemId(int index) => 'item-${index.toString().padLeft(3, '0')}';

String _matchFront(int index) => 'Match front $index';

String _matchBack(int index) => 'Match definition $index';

final class _BatchAnswerStudyRepo implements StudyRepo {
  _BatchAnswerStudyRepo([StudySessionSnapshot? sessionSnapshot])
    : sessionSnapshot = sessionSnapshot ?? _activeSnapshot;

  StudySessionSnapshot sessionSnapshot;
  int itemAnswerCount = 0;
  int batchAnswerCount = 0;
  int modeItemBatchAnswerCount = 0;
  int matchBatchAnswerCount = 0;
  AttemptGrade? lastGrade;
  Map<String, AttemptGrade>? lastModeItemGrades;
  Map<String, AttemptGrade>? lastItemGrades;
  Completer<StudySessionSnapshot>? itemAnswerCompleter;
  Completer<StudySessionSnapshot>? modeItemBatchCompleter;

  @override
  Future<StudySessionSnapshot> answerCurrentModeItemGradesBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
    required List<StudyMode> modes,
  }) async {
    final currentMode = sessionSnapshot.currentItem?.studyMode;
    if (currentMode == StudyMode.review) {
      batchAnswerCount += 1;
      lastGrade = itemGrades.values.single;
      return sessionSnapshot;
    }
    if (currentMode == StudyMode.match) {
      matchBatchAnswerCount += 1;
      lastItemGrades = itemGrades;
      return sessionSnapshot;
    }
    modeItemBatchAnswerCount += 1;
    lastModeItemGrades = itemGrades;
    final completer = modeItemBatchCompleter;
    if (completer != null) {
      return completer.future;
    }
    return sessionSnapshot;
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
  Future<StudySessionSnapshot> loadSession(String sessionId) {
    return Future.value(sessionSnapshot);
  }

  @override
  Future<StudySessionSnapshot> answerCurrentItem({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) {
    itemAnswerCount += 1;
    lastGrade = grade;
    final completer = itemAnswerCompleter;
    if (completer != null) {
      return completer.future;
    }
    return Future.value(sessionSnapshot);
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
    required StudyFinalizePolicy finalizePolicy,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<StudySessionSnapshot> retryFinalize({
    required String sessionId,
    required StudyType studyType,
    required StudyFinalizePolicy finalizePolicy,
  }) {
    throw UnimplementedError();
  }
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  static final TtsService _defaultTtsService = _NoopStudyTtsService();

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ProviderScope(
        overrides: [ttsServiceProvider.overrideWithValue(_defaultTtsService)],
        child: child,
      ),
    );
  }
}

final class _NoopStudyTtsService implements TtsService {
  @override
  Stream<TtsState> get state => const Stream<TtsState>.empty();

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguage language) async {
    return const <TtsVoice>[];
  }

  @override
  Future<void> speak(
    String text, {
    required TtsLanguage language,
    required double rate,
    String? voiceName,
  }) async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}
