import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memox/app/di/content/deck_providers.dart';
import 'package:memox/app/di/content/folder_providers.dart';
import 'package:memox/app/router/route_names.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/repositories/deck_repository.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/value_objects/content_actions.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/study/providers/study_session_notifier.dart';
import 'package:memox/presentation/features/study/screens/study_result_screen.dart';
import 'package:memox/presentation/shared/widgets/mx_loading_state.dart';

void main() {
  testWidgets('loading state shows skeleton while session loads', (
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
    'completed result shows accuracy, breakdown, box changes, and CTAs',
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
      expect(find.text('Accuracy'), findsOneWidget);
      expect(find.text('Results'), findsOneWidget);
      expect(find.text('Perfect'), findsOneWidget);
      expect(find.text('Passed'), findsOneWidget);
      expect(find.text('Recovered'), findsOneWidget);
      expect(find.text('Forgot'), findsOneWidget);
      expect(find.text('Box changes'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
      expect(find.text('Stayed'), findsOneWidget);
      expect(find.text('Reset to box 1'), findsOneWidget);
      expect(find.text('Reached box 8'), findsOneWidget);

      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Study more'), findsOneWidget);
      expect(find.text('Cards to review'), findsOneWidget);
      expect(find.text('No cards need extra review.'), findsOneWidget);
      // V1 must NOT surface a separate History/Tough Cards route.
      expect(find.text('View all history'), findsNothing);
      expect(find.text('Tough cards'), findsNothing);
    },
  );

  testWidgets(
    'completed result with recovered/forgot cards shows Cards to review rows',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider('session-001').overrideWith(
              (ref) => Future.value(
                _snapshot(
                  SessionStatus.completed,
                  cardReviewItems: const <StudyResultCardReviewItem>[
                    StudyResultCardReviewItem(
                      flashcardId: 'card-forgot',
                      front: 'forgot-front',
                      back: 'forgot-back',
                      resultType: StudyResultCardReviewType.forgot,
                      attemptCount: 2,
                      lastAnsweredAt: 200,
                      oldBox: 4,
                      newBox: 1,
                      nextDueAt: null,
                    ),
                    StudyResultCardReviewItem(
                      flashcardId: 'card-recovered',
                      front: 'recovered-front',
                      back: 'recovered-back',
                      resultType: StudyResultCardReviewType.recovered,
                      attemptCount: 2,
                      lastAnsweredAt: 100,
                      oldBox: 3,
                      newBox: 3,
                      nextDueAt: null,
                    ),
                  ],
                ),
              ),
            ),
          ],
          child: const _TestApp(
            child: StudyResultScreen(sessionId: 'session-001'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(find.text('Cards to review'), findsOneWidget);
      expect(find.text('forgot-front'), findsOneWidget);
      expect(find.text('forgot-back'), findsOneWidget);
      expect(find.text('Forgot'), findsWidgets);
      expect(find.text('recovered-front'), findsOneWidget);
      expect(find.text('recovered-back'), findsOneWidget);
      expect(find.text('Recovered'), findsWidgets);
      expect(find.text('No cards need extra review.'), findsNothing);
      // No fake navigation to History or filtered Tough Cards screen.
      expect(find.text('View all history'), findsNothing);
      expect(find.text('Tough cards'), findsNothing);
    },
  );

  testWidgets('empty result shows defensive notice and Done', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider('session-001').overrideWith(
            (ref) => Future.value(
              _snapshot(
                SessionStatus.completed,
                breakdown: const StudyResultBreakdown(),
                box: const BoxChangeBreakdown(),
              ),
            ),
          ),
        ],
        child: const _TestApp(
          child: StudyResultScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    expect(find.text('No cards answered'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('failed finalize state shows banner with Retry AND Done', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider('session-001').overrideWith(
            (ref) => Future.value(_snapshot(SessionStatus.failedToFinalize)),
          ),
        ],
        child: const _TestApp(
          child: StudyResultScreen(sessionId: 'session-001'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text("Some data couldn't be saved. Please retry."),
      findsOneWidget,
    );

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('Done for deck-entry uses go and leaves result out of stack', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider('session-001').overrideWith(
            (ref) => Future.value(_snapshot(SessionStatus.completed)),
          ),
        ],
        child: const _RouterTestApp(
          entry: StudyEntryType.deck,
          refId: 'deck-001',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open result'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('FlashcardList deck-001'), findsOneWidget);
    // Back from caller route MUST NOT return to Result.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Session summary'), findsNothing);
  });

  testWidgets('Done for folder-entry goes to folder detail', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider('session-001').overrideWith(
            (ref) => Future.value(
              _snapshot(
                SessionStatus.completed,
                entry: StudyEntryType.folder,
                refId: 'folder-007',
              ),
            ),
          ),
        ],
        child: const _RouterTestApp(
          entry: StudyEntryType.folder,
          refId: 'folder-007',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open result'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('FolderDetail folder-007'), findsOneWidget);
  });

  testWidgets('Done for today-entry goes to Dashboard (Home)', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider('session-001').overrideWith(
            (ref) => Future.value(
              _snapshot(
                SessionStatus.completed,
                entry: StudyEntryType.today,
                refId: null,
              ),
            ),
          ),
        ],
        child: const _RouterTestApp(entry: StudyEntryType.today, refId: null),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open result'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Library'), findsNothing);
    // Back from Dashboard MUST NOT return to Study Result.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Session summary'), findsNothing);
  });

  testWidgets('Study more opens scope picker with Today/Deck/Folder (no Tag)', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studySessionStateProvider('session-001').overrideWith(
            (ref) => Future.value(_snapshot(SessionStatus.completed)),
          ),
          deckRepositoryProvider.overrideWithValue(const _FakeDeckRepository()),
          folderRepositoryProvider.overrideWithValue(
            const _FakeFolderRepository(),
          ),
        ],
        child: const _RouterTestApp(
          entry: StudyEntryType.deck,
          refId: 'deck-001',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open result'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -800));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Study more'));
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Deck'), findsOneWidget);
    expect(find.text('Folder'), findsOneWidget);
    expect(find.text('Tag'), findsNothing);
  });

  testWidgets(
    'Study more → Today routes to Study Today and result is not preserved',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider('session-001').overrideWith(
              (ref) => Future.value(_snapshot(SessionStatus.completed)),
            ),
            deckRepositoryProvider.overrideWithValue(
              const _FakeDeckRepository(),
            ),
            folderRepositoryProvider.overrideWithValue(
              const _FakeFolderRepository(),
            ),
          ],
          child: const _RouterTestApp(
            entry: StudyEntryType.deck,
            refId: 'deck-001',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open result'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Study more'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Today'));
      await tester.pumpAndSettle();

      expect(find.text('Study Today'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Session summary'), findsNothing);
    },
  );

  testWidgets(
    'Study more → Deck routes to Study Entry deck and result is not preserved',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider('session-001').overrideWith(
              (ref) => Future.value(_snapshot(SessionStatus.completed)),
            ),
            deckRepositoryProvider.overrideWithValue(
              const _FakeDeckRepository(
                destinations: [
                  DeckMoveTarget(
                    id: 'deck-zeta',
                    name: 'Zeta deck',
                    breadcrumb: <String>[],
                  ),
                ],
              ),
            ),
            folderRepositoryProvider.overrideWithValue(
              const _FakeFolderRepository(),
            ),
          ],
          child: const _RouterTestApp(
            entry: StudyEntryType.deck,
            refId: 'deck-001',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open result'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Study more'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deck'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Zeta deck'));
      await tester.pumpAndSettle();

      expect(find.text('StudyEntry deck deck-zeta'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Session summary'), findsNothing);
    },
  );

  testWidgets(
    'Study more → Folder routes to Study Entry folder and result is not preserved',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            studySessionStateProvider('session-001').overrideWith(
              (ref) => Future.value(_snapshot(SessionStatus.completed)),
            ),
            deckRepositoryProvider.overrideWithValue(
              const _FakeDeckRepository(),
            ),
            folderRepositoryProvider.overrideWithValue(
              const _FakeFolderRepository(
                folders: [
                  FolderScopeOption(
                    id: 'folder-omega',
                    name: 'Omega folder',
                    breadcrumb: <String>['Omega folder'],
                  ),
                ],
              ),
            ),
          ],
          child: const _RouterTestApp(
            entry: StudyEntryType.deck,
            refId: 'deck-001',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open result'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -800));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Study more'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Folder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Omega folder'));
      await tester.pumpAndSettle();

      expect(find.text('StudyEntry folder folder-omega'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Session summary'), findsNothing);
    },
  );
}

class _FakeDeckRepository implements DeckRepository {
  const _FakeDeckRepository({this.destinations = const <DeckMoveTarget>[]});

  final List<DeckMoveTarget> destinations;

  @override
  Future<List<DeckMoveTarget>> getDeckDestinations() async => destinations;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFolderRepository implements FolderRepository {
  const _FakeFolderRepository({this.folders = const <FolderScopeOption>[]});

  final List<FolderScopeOption> folders;

  @override
  Future<List<FolderScopeOption>> listAllFolders() async => folders;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

StudySessionSnapshot _snapshot(
  SessionStatus status, {
  StudyEntryType entry = StudyEntryType.deck,
  String? refId = 'deck-001',
  StudyResultBreakdown breakdown = const StudyResultBreakdown(
    perfectCount: 3,
    initialPassedCount: 1,
    recoveredCount: 1,
    forgotCount: 0,
  ),
  BoxChangeBreakdown box = const BoxChangeBreakdown(
    advancedCount: 4,
    stayedCount: 0,
    resetCount: 1,
    reachedBox8Count: 0,
  ),
  List<StudyResultCardReviewItem> cardReviewItems =
      const <StudyResultCardReviewItem>[],
}) => StudySessionSnapshot(
  session: StudySession(
    id: 'session-001',
    entryType: entry,
    entryRefId: refId,
    studyType: StudyType.srsReview,
    studyFlow: StudyFlow.srsFillReview,
    settings: const StudySettingsSnapshot(
      batchSize: 5,
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
    totalCards: 5,
    masteredCardCount: 4,
    retryCardCount: 1,
    completedAttempts: 6,
    correctAttempts: 5,
    incorrectAttempts: 1,
    increasedBoxCount: 4,
    decreasedBoxCount: 1,
    remainingCount: 0,
  ),
  canFinalize: false,
  resultBreakdown: breakdown,
  boxChangeBreakdown: box,
  resultCardReviewItems: cardReviewItems,
);

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

class _RouterTestApp extends StatelessWidget {
  const _RouterTestApp({required this.entry, required this.refId});

  final StudyEntryType entry;
  final String? refId;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: '/origin',
      routes: [
        GoRoute(
          path: '/origin',
          builder: (context, state) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () =>
                    context.push('/library/study/session/session-001/result'),
                child: const Text('Open result'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/home',
          name: RouteNames.home,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Home'))),
        ),
        GoRoute(
          path: '/study/:entryType/:entryRefId',
          name: RouteNames.studyEntry,
          builder: (context, state) {
            final entryType = state.pathParameters['entryType'];
            final entryRefId = state.pathParameters['entryRefId'];
            return Scaffold(
              body: Center(child: Text('StudyEntry $entryType $entryRefId')),
            );
          },
        ),
        GoRoute(
          path: '/library',
          name: RouteNames.library,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Library'))),
          routes: [
            GoRoute(
              path: 'folder/:id',
              name: RouteNames.folderDetail,
              builder: (context, state) => Scaffold(
                body: Center(
                  child: Text('FolderDetail ${state.pathParameters['id']}'),
                ),
              ),
            ),
            GoRoute(
              path: 'deck/:deckId/flashcards',
              name: RouteNames.flashcardList,
              builder: (context, state) => Scaffold(
                body: Center(
                  child: Text(
                    'FlashcardList ${state.pathParameters['deckId']}',
                  ),
                ),
              ),
            ),
            GoRoute(
              path: 'study/session/:sessionId/result',
              name: RouteNames.studyResult,
              builder: (context, state) =>
                  const StudyResultScreen(sessionId: 'session-001'),
            ),
            GoRoute(
              path: 'study/today',
              name: RouteNames.studyToday,
              builder: (context, state) =>
                  const Scaffold(body: Center(child: Text('Study Today'))),
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
