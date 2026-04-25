import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/router/app_router.dart';
import 'package:memox/app/router/route_guards.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_entry_notifier.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_entry_screen.dart';
import 'package:memox/presentation/features/study/screens/study_session_screen.dart';

void main() {
  testWidgets('DT1 onNavigate: study session path resolves to session screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouteGuardsProvider.overrideWith(
            (ref) => const AppRouteGuards(
              initialLocation: '/library/study/session/session-001',
            ),
          ),
          studySessionStateProvider(
            'session-001',
          ).overrideWith((ref) => Future.value(_activeSnapshot)),
          studyEntryStateProvider(
            'session',
            'session-001',
          ).overrideWith((ref) => Future.value(_unexpectedEntryState)),
        ],
        child: const _RouterApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudySessionScreen), findsOneWidget);
    expect(find.byType(StudyEntryScreen), findsNothing);
  });
}

class _RouterApp extends ConsumerWidget {
  const _RouterApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
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
    totalCards: 1,
    completedAttempts: 0,
    correctAttempts: 0,
    incorrectAttempts: 0,
    increasedBoxCount: 0,
    decreasedBoxCount: 0,
    remainingCount: 1,
  ),
  canFinalize: false,
);

const _unexpectedEntryState = StudyEntryState(
  entryType: StudyEntryType.deck,
  entryRefId: 'deck-001',
  newStudyDefaults: _settings,
  reviewDefaults: _settings,
  resumeCandidate: null,
);

const _settings = StudySettingsSnapshot(
  batchSize: 10,
  shuffleFlashcards: false,
  shuffleAnswers: false,
  prioritizeOverdue: true,
);

StudySession _session(SessionStatus status) {
  return StudySession(
    id: 'session-001',
    entryType: StudyEntryType.deck,
    entryRefId: 'deck-001',
    studyType: StudyType.srsReview,
    studyFlow: StudyFlow.srsFillReview,
    settings: _settings,
    status: status,
    startedAt: 0,
    endedAt: null,
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
