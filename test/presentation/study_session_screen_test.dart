import 'dart:async';

import 'package:flutter/gestures.dart';
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
import 'package:memox/presentation/shared/states/mx_loading_state.dart';
import 'package:memox/presentation/shared/widgets/mx_card.dart';

void main() {
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

  testWidgets(
    'DT1 onDisplay: active session renders progress and answer panel',
    (tester) async {
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
      await tester.pumpAndSettle();

      expect(find.text('Guess · round 1'), findsOneWidget);
      expect(find.text('front 1'), findsOneWidget);
      expect(find.text('Correct'), findsOneWidget);
      expect(find.text('Skip card'), findsOneWidget);
    },
  );

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
      expect(find.byIcon(Icons.volume_up_outlined), findsNWidgets(2));
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
    await tester.pumpAndSettle();

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
    await tester.pumpAndSettle();

    expect(find.text('Match'), findsOneWidget);
    expect(find.byIcon(Icons.text_fields), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text(_alphaBack), findsOneWidget);
    expect(find.text(_betaBack), findsOneWidget);
    expect(find.text(_alphaFront), findsOneWidget);
    expect(find.text(_betaFront), findsOneWidget);
  });

  testWidgets(
    'DT8 onDisplay: match mode keeps long definitions visible and hides skip',
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

      final alphaStyle = tester.widget<Text>(find.text(_alphaFront)).style!;
      final betaStyle = tester.widget<Text>(find.text(_betaFront)).style!;
      expect(find.text(_longMatchBack), findsOneWidget);
      expect(alphaStyle.fontSize, betaStyle.fontSize);
      expect(alphaStyle.fontWeight, betaStyle.fontWeight);
      expect(find.text('Skip card'), findsNothing);
    },
  );

  testWidgets(
    'DT1 onUpdate: single-card review auto-submits after two seconds',
    (tester) async {
      final repo = _BatchAnswerStudyRepo();

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
      expect(repo.lastGrade, AttemptGrade.remembered);
    },
  );

  testWidgets(
    'DT4 onUpdate: match correct pair increments progress without submit',
    (tester) async {
      final repo = _BatchAnswerStudyRepo();

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

      expect(find.text('50%'), findsOneWidget);
      expect(find.byKey(const ValueKey('match-left-item-001')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('match-right-item-001')),
        findsOneWidget,
      );
      expect(repo.matchBatchAnswerCount, 0);
    },
  );

  testWidgets('DT5 onUpdate: match mismatch resets locally without submit', (
    tester,
  ) async {
    final repo = _BatchAnswerStudyRepo();

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
    expect(find.text('0%'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(repo.matchBatchAnswerCount, 0);
    expect(find.text('0%'), findsOneWidget);
  });

  testWidgets(
    'DT6 onUpdate: match board submits mixed grades once after completion',
    (tester) async {
      final repo = _BatchAnswerStudyRepo();

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
      await _tapMatchTile(tester, 'match-left-item-002');
      await tester.pump();
      await _tapMatchTile(tester, 'match-right-item-002');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      expect(repo.matchBatchAnswerCount, 1);
      expect(repo.lastItemGrades, <String, AttemptGrade>{
        'item-001': AttemptGrade.incorrect,
        'item-002': AttemptGrade.correct,
      });
    },
  );

  testWidgets(
    'DT2 onUpdate: web mouse right-to-left drag advances review vocabulary and only the last card can auto-submit',
    (tester) async {
      final repo = _BatchAnswerStudyRepo();

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
      final repo = _BatchAnswerStudyRepo();

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

final _activeSnapshot = StudySessionSnapshot(
  session: _session(SessionStatus.inProgress),
  currentItem: StudySessionItem(
    id: 'item-001',
    sessionId: 'session-001',
    flashcard: _card(id: 'card-001', front: 'front 1', back: 'back 1'),
    studyMode: StudyMode.guess,
    modeOrder: 1,
    roundIndex: 1,
    queuePosition: 1,
    sourcePool: SessionItemSourcePool.due,
    status: SessionItemStatus.pending,
    completedAt: null,
  ),
  sessionFlashcards: [_card(id: 'card-001', front: 'front 1', back: 'back 1')],
  summary: const StudySummary(
    totalCards: 2,
    completedAttempts: 1,
    correctAttempts: 1,
    incorrectAttempts: 0,
    increasedBoxCount: 1,
    decreasedBoxCount: 0,
    remainingCount: 1,
  ),
  canFinalize: false,
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

StudySessionSnapshot _reviewSnapshot(List<StudyFlashcardRef> cards) {
  final current = cards.first;
  return StudySessionSnapshot(
    session: _session(SessionStatus.inProgress),
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
      completedAttempts: cards.length,
      correctAttempts: cards.length,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: cards.length,
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

Future<void> _tapMatchTile(WidgetTester tester, String key) {
  return tester.tap(find.byKey(ValueKey<String>(key)), warnIfMissed: false);
}

final class _BatchAnswerStudyRepo implements StudyRepo {
  int batchAnswerCount = 0;
  int matchBatchAnswerCount = 0;
  AttemptGrade? lastGrade;
  Map<String, AttemptGrade>? lastItemGrades;

  @override
  Future<StudySessionSnapshot> answerCurrentModeBatch({
    required String sessionId,
    required AttemptGrade grade,
    required List<StudyMode> modes,
  }) async {
    batchAnswerCount += 1;
    lastGrade = grade;
    return _activeSnapshot;
  }

  @override
  Future<StudySessionSnapshot> answerCurrentMatchModeBatch({
    required String sessionId,
    required Map<String, AttemptGrade> itemGrades,
    required List<StudyMode> modes,
  }) async {
    matchBatchAnswerCount += 1;
    lastItemGrades = itemGrades;
    return _activeSnapshot;
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

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }
}
