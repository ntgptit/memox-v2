import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_result_screen.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';

void main() {
  testWidgets('DT1 onOpen: shows loading state while result loads', (
    tester,
  ) async {
    final completer = Completer<StudySessionSnapshot>();
    addTearDown(() {
      if (!completer.isCompleted) {
        completer.complete(_snapshot(SessionStatus.completed));
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
          child: StudyResultScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(MxLoadingState), findsOneWidget);
  });

  testWidgets(
    'DT1 onDisplay: completed result separates card outcome and attempt accuracy',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider('session-001').overrideWith(
              (ref) => Future.value(_snapshot(SessionStatus.completed)),
            ),
          ],
          child: const _TestApp(
            child: StudyResultScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Session summary'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Cards mastered: 4/4'), findsOneWidget);
      expect(find.text('Attempt accuracy'), findsOneWidget);
      expect(find.text('83%'), findsOneWidget);
      expect(find.text('Retry cards'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('Accuracy'), findsNothing);

      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Study'), findsOneWidget);
    },
  );

  testWidgets('DT2 onDisplay: cancelled result keeps a distinct status label', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider('session-001').overrideWith(
            (ref) => Future.value(_snapshot(SessionStatus.cancelled)),
          ),
        ],
        child: const _TestApp(
          child: StudyResultScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cancelled'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);
  });
}

StudySessionSnapshot _snapshot(SessionStatus status) {
  return StudySessionSnapshot(
    session: StudySession(
      id: 'session-001',
      entryType: StudyEntryType.deck,
      entryRefId: 'deck-001',
      studyType: StudyType.srsReview,
      studyFlow: StudyFlow.srsFillReview,
      settings: const StudySettingsSnapshot(
        batchSize: 4,
        shuffleFlashcards: false,
        shuffleAnswers: false,
        prioritizeOverdue: true,
      ),
      status: status,
      startedAt: 0,
      endedAt: 1,
      restartedFromSessionId: null,
    ),
    currentItem: null,
    sessionFlashcards: const <StudyFlashcardRef>[],
    summary: const StudySummary(
      totalCards: 4,
      masteredCardCount: 4,
      retryCardCount: 2,
      completedAttempts: 6,
      correctAttempts: 5,
      incorrectAttempts: 1,
      increasedBoxCount: 1,
      decreasedBoxCount: 0,
      remainingCount: 0,
    ),
    canFinalize: false,
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
