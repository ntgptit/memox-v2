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
          progressStudySessionsProvider.overrideWith(
            (ref) => Future.value(const <StudySessionSnapshot>[]),
          ),
        ],
        child: const _TestApp(child: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No active study sessions'), findsOneWidget);
    expect(find.text('Open library'), findsOneWidget);
  });

  testWidgets('DT2 onDisplay: active sessions show overview and actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          progressStudySessionsProvider.overrideWith(
            (ref) => Future.value([
              _snapshot(id: 'session-1'),
              _snapshot(id: 'session-2', status: SessionStatus.readyToFinalize),
              _snapshot(
                id: 'session-3',
                status: SessionStatus.failedToFinalize,
              ),
            ]),
          ),
        ],
        child: const _TestApp(child: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Study sessions'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
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
      find.text('Retry finalize'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Finalize failed'), findsWidgets);
    expect(find.text('Retry finalize'), findsOneWidget);
    expect(find.text('Cancel session'), findsWidgets);
  });

  testWidgets('DT1 onSelect: cancel confirms before mutating session', (
    tester,
  ) async {
    final repo = _ProgressScreenStudyRepo();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyRepoProvider.overrideWithValue(repo),
          progressStudySessionsProvider.overrideWith(
            (ref) => Future.value([_snapshot()]),
          ),
        ],
        child: const _TestApp(child: ProgressScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final cancelButton = find.widgetWithText(
      MxSecondaryButton,
      'Cancel session',
    );
    await tester.ensureVisible(cancelButton);
    await tester.pumpAndSettle();
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    expect(find.text('Cancel this study session?'), findsOneWidget);
    expect(repo.cancelCount, 0);

    await tester.tap(find.text('Cancel session').last);
    await tester.pumpAndSettle();

    expect(repo.cancelCount, 1);
  });
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

StudySessionSnapshot _snapshot({
  String id = 'session-1',
  SessionStatus status = SessionStatus.inProgress,
}) {
  final card = _card();
  return StudySessionSnapshot(
    session: StudySession(
      id: id,
      entryType: StudyEntryType.deck,
      entryRefId: 'deck-1',
      studyType: StudyType.srsReview,
      studyFlow: StudyFlow.srsFillReview,
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
    currentItem: status == SessionStatus.inProgress
        ? StudySessionItem(
            id: 'item-1',
            sessionId: id,
            flashcard: card,
            studyMode: StudyMode.fill,
            modeOrder: 1,
            roundIndex: 1,
            queuePosition: 1,
            sourcePool: SessionItemSourcePool.due,
            status: SessionItemStatus.pending,
            completedAt: null,
          )
        : null,
    sessionFlashcards: [card],
    summary: StudySummary(
      totalCards: 1,
      completedAttempts: status == SessionStatus.inProgress ? 0 : 1,
      correctAttempts: status == SessionStatus.inProgress ? 0 : 1,
      incorrectAttempts: 0,
      increasedBoxCount: 0,
      decreasedBoxCount: 0,
      remainingCount: status == SessionStatus.inProgress ? 1 : 0,
    ),
    canFinalize:
        status == SessionStatus.readyToFinalize ||
        status == SessionStatus.failedToFinalize,
  );
}

StudyFlashcardRef _card() {
  return const StudyFlashcardRef(
    id: 'card-1',
    deckId: 'deck-1',
    front: 'front 1',
    back: 'back 1',
    sourcePool: SessionItemSourcePool.due,
  );
}
