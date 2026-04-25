import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';
import 'package:memox/presentation/shared/states/mx_loading_state.dart';

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

  testWidgets('DT1 onDisplay: active session renders progress and answer panel', (
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
    await tester.pumpAndSettle();

    expect(find.text('Guess · round 1'), findsOneWidget);
    expect(find.text('front 1'), findsOneWidget);
    expect(find.text('Correct'), findsOneWidget);
    expect(find.text('Skip card'), findsOneWidget);
  });

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
