import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/study_providers.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/progress/providers/progress_session_notifier.dart';
import 'package:memox/presentation/features/progress/screens/progress_screen.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';

void main() {
  testWidgets('DT1 onDisplay: empty active sessions shows empty state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressOverviewProvider.overrideWith(
            (ref) => Future.value(_overview(sessions: const [])),
          ),
        ],
        child: const _TestApp(child: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Learning overview'), findsOneWidget);
    expect(find.text('Due now'), findsOneWidget);
    expect(find.text('Mastery'), findsOneWidget);
    expect(find.text('Active sessions'), findsOneWidget);
    expect(find.text('No active study sessions'), findsOneWidget);
    expect(find.text('Open'), findsOneWidget);
  });

  testWidgets('DT2 onDisplay: active sessions show overview and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressOverviewProvider.overrideWith(
            (ref) => Future.value(
              _overview(
                sessions: [
                  _snapshot(id: 'session-1'),
                  _snapshot(
                    id: 'session-2',
                    status: SessionStatus.readyToFinalize,
                  ),
                  _snapshot(
                    id: 'session-3',
                    status: SessionStatus.failedToFinalize,
                  ),
                ],
              ),
            ),
          ),
        ],
        child: const _TestApp(child: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Learning overview'), findsOneWidget);
    expect(find.text('Due now'), findsOneWidget);
    expect(find.text('New cards available'), findsOneWidget);
    expect(find.text('Mastery'), findsOneWidget);
    expect(find.text('Active sessions'), findsOneWidget);
    expect(find.text('Active'), findsWidgets);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('Needs retry'), findsOneWidget);
    expect(find.text('SRS Review · Deck'), findsWidgets);
    expect(find.text('In progress'), findsOneWidget);
    expect(find.text('Continue'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Finalize'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Ready to finalize'), findsWidgets);
    expect(find.text('Finalize'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Retry'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Finalize failed'), findsWidgets);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Cancel'), findsWidgets);
  });

  testWidgets('DT3 onDisplay: medium overview metrics share one row', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressOverviewProvider.overrideWith(
            (ref) => Future.value(
              _overview(
                sessions: [
                  _snapshot(id: 'session-1'),
                  _snapshot(
                    id: 'session-2',
                    status: SessionStatus.readyToFinalize,
                  ),
                  _snapshot(
                    id: 'session-3',
                    status: SessionStatus.failedToFinalize,
                  ),
                ],
              ),
            ),
          ),
        ],
        child: const _TestApp(child: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final reviewRect = tester.getRect(
      find.byKey(const ValueKey('progress_metric_review')),
    );
    final newCardsRect = tester.getRect(
      find.byKey(const ValueKey('progress_metric_new_cards')),
    );
    final masteryRect = tester.getRect(
      find.byKey(const ValueKey('progress_metric_mastery')),
    );
    final activeRect = tester.getRect(
      find.byKey(const ValueKey('progress_metric_active')),
    );

    expect(reviewRect.top, moreOrLessEquals(newCardsRect.top));
    expect(reviewRect.top, moreOrLessEquals(masteryRect.top));
    expect(reviewRect.top, moreOrLessEquals(activeRect.top));
    expect(newCardsRect.left, greaterThan(reviewRect.right));
    expect(masteryRect.left, greaterThan(newCardsRect.right));
    expect(activeRect.left, greaterThan(masteryRect.right));
  });

  testWidgets('DT4 onDisplay: new study session progress uses study steps', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressOverviewProvider.overrideWith(
            (ref) => Future.value(
              _overview(
                sessions: [
                  _snapshot(
                    studyType: StudyType.newStudy,
                    studyFlow: StudyFlow.newFullCycle,
                    totalCards: 10,
                    totalModeCount: 5,
                    completedAttempts: 10,
                    remainingCount: 40,
                  ),
                ],
              ),
            ),
          ),
        ],
        child: const _TestApp(child: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('10 of 50 study steps · 40 remaining'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    final progressValues = tester
        .widgetList<LinearProgressIndicator>(
          find.byType(LinearProgressIndicator),
        )
        .map((indicator) => indicator.value)
        .whereType<double>();

    expect(progressValues, contains(moreOrLessEquals(0.2)));
  });

  testWidgets('DT1 onSelect: cancel confirms before mutating session', (
    tester,
  ) async {
    final repo = _ProgressScreenStudyRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          progressOverviewProvider.overrideWith(
            (ref) => Future.value(_overview(sessions: [_snapshot()])),
          ),
        ],
        child: const _TestApp(child: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final cancelButton = find.widgetWithText(MxSecondaryButton, 'Cancel');
    await tester.ensureVisible(cancelButton);
    await tester.pumpAndSettle();
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    expect(find.text('Cancel this study session?'), findsOneWidget);
    expect(repo.cancelCount, 0);

    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();

    expect(repo.cancelCount, 1);
  });
}

ProgressOverviewState _overview({
  required List<StudySessionSnapshot> sessions,
  int overdueCount = 2,
  int dueTodayCount = 5,
  int newCardCount = 4,
  int cardCount = 12,
  int masteryPercent = 48,
}) {
  return ProgressOverviewState(
    sessions: sessions,
    overdueCount: overdueCount,
    dueTodayCount: dueTodayCount,
    newCardCount: newCardCount,
    cardCount: cardCount,
    masteryPercent: masteryPercent,
  );
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

final class _ProgressScreenStudyRepo implements StudyRepo {
  int cancelCount = 0;

  @override
  Future<StudySessionSnapshot> cancelSession(String sessionId) async {
    cancelCount += 1;
    return _snapshot(status: SessionStatus.cancelled);
  }

  @override
  Future<List<StudySessionSnapshot>> listActiveSessions() {
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
  Future<StudySessionSnapshot> answerCurrentModeItemGradesBatch({
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

StudySessionSnapshot _snapshot({
  String id = 'session-1',
  SessionStatus status = SessionStatus.inProgress,
  StudyType studyType = StudyType.srsReview,
  StudyFlow studyFlow = StudyFlow.srsFillReview,
  int totalCards = 1,
  int totalModeCount = 1,
  int? completedAttempts,
  int? remainingCount,
}) {
  final cards = [
    for (var index = 1; index <= totalCards; index++) _card(index),
  ];
  final card = cards.firstOrNull;
  final totalSteps = totalCards * totalModeCount;
  final completed =
      completedAttempts ??
      (status == SessionStatus.inProgress ? 0 : totalSteps);
  final remaining =
      remainingCount ?? (status == SessionStatus.inProgress ? totalSteps : 0);
  return StudySessionSnapshot(
    session: StudySession(
      id: id,
      entryType: StudyEntryType.deck,
      entryRefId: 'deck-1',
      studyType: studyType,
      studyFlow: studyFlow,
      settings: const StudySettingsSnapshot(
        batchSize: 1,
        shuffleFlashcards: false,
        shuffleAnswers: false,
        prioritizeOverdue: true,
      ),
      status: status,
      startedAt: DateTime.utc(2026, 4, 24, 9).millisecondsSinceEpoch,
      endedAt: null,
      restartedFromSessionId: null,
    ),
    currentItem: status == SessionStatus.inProgress && card != null
        ? StudySessionItem(
            id: 'item-1',
            sessionId: id,
            flashcard: card,
            studyMode: studyType == StudyType.newStudy
                ? StudyMode.review
                : StudyMode.fill,
            modeOrder: 1,
            roundIndex: 1,
            queuePosition: 1,
            sourcePool: studyType == StudyType.newStudy
                ? SessionItemSourcePool.newCards
                : SessionItemSourcePool.due,
            status: SessionItemStatus.pending,
            completedAt: null,
          )
        : null,
    sessionFlashcards: cards,
    summary: StudySummary(
      totalCards: totalCards,
      totalModeCount: totalModeCount,
      completedAttempts: completed,
      correctAttempts: completed,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: remaining,
    ),
    canFinalize:
        status == SessionStatus.readyToFinalize ||
        status == SessionStatus.failedToFinalize,
  );
}

StudyFlashcardRef _card([int index = 1]) {
  return StudyFlashcardRef(
    id: 'card-$index',
    deckId: 'deck-1',
    front: 'front $index',
    back: 'back $index',
    sourcePool: SessionItemSourcePool.due,
  );
}
