import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/empty_scope_reason.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/ports/study_repo.dart';
import 'package:memox/domain/study/strategy/study_strategy.dart';
import 'package:memox/domain/study/strategy/study_strategy_factory.dart';
import 'package:memox/domain/study/usecases/study_usecases.dart';

void main() {
  group('P0-1 Tier 1: empty-scope matrix', () {
    StartStudySessionUseCase useCaseFor(StudyRepo repo) => StartStudySessionUseCase(
      repository: repo,
      strategyFactory: StudyFlowStrategyFactory(const <StudyFlowStrategy>[
        NewStudyStrategy(),
        SrsReviewStrategy(),
      ]),
    );

    Matcher throwsEmptyScope(EmptyScopeReason reason) => throwsA(
      isA<EmptyScopeException>().having(
        (error) => error.reason,
        'reason',
        reason,
      ),
    );

    test(
      'S4: deck with zero flashcards throws EmptyScopeException(deckNoCards)',
      () async {
        final repo = _FakeStudyRepo(deckCount: 0);

        await expectLater(
          useCaseFor(repo).execute(
            const StudyContext(
              entryType: StudyEntryType.deck,
              entryRefId: 'deck-empty',
              studyType: StudyType.newStudy,
              settings: _testSettings,
            ),
          ),
          throwsEmptyScope(EmptyScopeReason.deckNoCards),
        );
        expect(repo.deckCountCalls, <String>['deck-empty']);
        expect(repo.startSessionCalled, isFalse);
      },
    );

    test(
      'S4 (negative): deck with cards (new) routes past the empty-scope guard',
      () async {
        final repo = _FakeStudyRepo(deckCount: 3);

        // _rejectEmptyScope passes; downstream loadBatch throws
        // UnimplementedError via noSuchMethod — proves we routed past the guard.
        await expectLater(
          useCaseFor(repo).execute(
            const StudyContext(
              entryType: StudyEntryType.deck,
              entryRefId: 'deck-with-cards',
              studyType: StudyType.newStudy,
              settings: _testSettings,
            ),
          ),
          throwsA(isNot(isA<EmptyScopeException>())),
        );
      },
    );

    test(
      'S4e: deck (srs_review) with cards but none due throws '
      'EmptyScopeException(deckNoDueCards) carrying nextDueAt',
      () async {
        final nextDue = DateTime.utc(2026, 5, 1, 9);
        final repo = _FakeStudyRepo(
          deckCount: 4,
          dueCount: 0,
          next: nextDue,
        );

        await expectLater(
          useCaseFor(repo).execute(
            const StudyContext(
              entryType: StudyEntryType.deck,
              entryRefId: 'deck-no-due',
              studyType: StudyType.srsReview,
              settings: _testSettings,
            ),
          ),
          throwsA(
            isA<EmptyScopeException>()
                .having((e) => e.reason, 'reason', EmptyScopeReason.deckNoDueCards)
                .having((e) => e.nextDueAt, 'nextDueAt', nextDue),
          ),
        );
        expect(repo.startSessionCalled, isFalse);
      },
    );

    test(
      'S4e (negative): deck (srs_review) with due cards routes past the guard',
      () async {
        final repo = _FakeStudyRepo(deckCount: 4, dueCount: 2);

        await expectLater(
          useCaseFor(repo).execute(
            const StudyContext(
              entryType: StudyEntryType.deck,
              entryRefId: 'deck-due',
              studyType: StudyType.srsReview,
              settings: _testSettings,
            ),
          ),
          throwsA(isNot(isA<EmptyScopeException>())),
        );
      },
    );

    test(
      'S4b: folder whose subtree has zero cards throws '
      'EmptyScopeException(folderNoCards)',
      () async {
        final repo = _FakeStudyRepo(scopeCount: 0);

        await expectLater(
          useCaseFor(repo).execute(
            const StudyContext(
              entryType: StudyEntryType.folder,
              entryRefId: 'folder-empty',
              studyType: StudyType.newStudy,
              settings: _testSettings,
            ),
          ),
          throwsEmptyScope(EmptyScopeReason.folderNoCards),
        );
        expect(repo.startSessionCalled, isFalse);
      },
    );

    test(
      'S4j: folder (srs_review) with cards but none due throws '
      'EmptyScopeException(folderNoDueCards) carrying nextDueAt',
      () async {
        final nextDue = DateTime.utc(2026, 5, 2, 9);
        final repo = _FakeStudyRepo(
          scopeCount: 6,
          dueCount: 0,
          next: nextDue,
        );

        await expectLater(
          useCaseFor(repo).execute(
            const StudyContext(
              entryType: StudyEntryType.folder,
              entryRefId: 'folder-no-due',
              studyType: StudyType.srsReview,
              settings: _testSettings,
            ),
          ),
          throwsA(
            isA<EmptyScopeException>()
                .having(
                  (e) => e.reason,
                  'reason',
                  EmptyScopeReason.folderNoDueCards,
                )
                .having((e) => e.nextDueAt, 'nextDueAt', nextDue),
          ),
        );
      },
    );

    test(
      'S4c: today (srs_review) with cards but none due throws '
      'EmptyScopeException(todayAllDone)',
      () async {
        final repo = _FakeStudyRepo(scopeCount: 9, dueCount: 0);

        await expectLater(
          useCaseFor(repo).execute(
            const StudyContext(
              entryType: StudyEntryType.today,
              entryRefId: null,
              studyType: StudyType.srsReview,
              settings: _testSettings,
            ),
          ),
          throwsEmptyScope(EmptyScopeReason.todayAllDone),
        );
        expect(repo.startSessionCalled, isFalse);
      },
    );

    test(
      'S4d: today (srs_review) with zero cards anywhere throws '
      'EmptyScopeException(todayNoContent)',
      () async {
        final repo = _FakeStudyRepo(scopeCount: 0);

        await expectLater(
          useCaseFor(repo).execute(
            const StudyContext(
              entryType: StudyEntryType.today,
              entryRefId: null,
              studyType: StudyType.srsReview,
              settings: _testSettings,
            ),
          ),
          throwsEmptyScope(EmptyScopeReason.todayNoContent),
        );
        expect(repo.startSessionCalled, isFalse);
      },
    );

    test(
      'S4f: deck whose every card is buried throws '
      'EmptyScopeException(allBuried)',
      () async {
        final repo = _FakeStudyRepo(deckCount: 3, activeBuriedCount: 3);

        await expectLater(
          useCaseFor(repo).execute(
            const StudyContext(
              entryType: StudyEntryType.deck,
              entryRefId: 'deck-buried',
              studyType: StudyType.srsReview,
              settings: _testSettings,
            ),
          ),
          throwsEmptyScope(EmptyScopeReason.allBuried),
        );
        expect(repo.startSessionCalled, isFalse);
      },
    );

    test(
      'S4g: deck whose every card is suspended throws '
      'EmptyScopeException(allSuspended)',
      () async {
        final repo = _FakeStudyRepo(deckCount: 3, suspendedCount: 3);

        await expectLater(
          useCaseFor(repo).execute(
            const StudyContext(
              entryType: StudyEntryType.deck,
              entryRefId: 'deck-suspended',
              studyType: StudyType.srsReview,
              settings: _testSettings,
            ),
          ),
          throwsEmptyScope(EmptyScopeReason.allSuspended),
        );
        expect(repo.startSessionCalled, isFalse);
      },
    );

    test(
      'allSuspended takes precedence over allBuried when some cards are buried '
      'and the rest suspended',
      () async {
        // 1 suspended + 2 buried of 3 → not all suspended, but all hidden.
        final repo = _FakeStudyRepo(
          deckCount: 3,
          suspendedCount: 1,
          activeBuriedCount: 2,
        );

        await expectLater(
          useCaseFor(repo).execute(
            const StudyContext(
              entryType: StudyEntryType.deck,
              entryRefId: 'deck-mixed',
              studyType: StudyType.srsReview,
              settings: _testSettings,
            ),
          ),
          throwsEmptyScope(EmptyScopeReason.allBuried),
        );
      },
    );
  });
}

const _testSettings = StudySettingsSnapshot(
  batchSize: 20,
  shuffleFlashcards: false,
  shuffleAnswers: false,
  prioritizeOverdue: false,
);

class _FakeStudyRepo implements StudyRepo {
  _FakeStudyRepo({
    this.deckCount = 0,
    this.scopeCount = 0,
    this.dueCount = 0,
    this.suspendedCount = 0,
    this.activeBuriedCount = 0,
    this.next,
  });

  final int deckCount;
  final int scopeCount;
  final int dueCount;
  final int suspendedCount;
  final int activeBuriedCount;
  final DateTime? next;

  final List<String> deckCountCalls = <String>[];
  bool startSessionCalled = false;

  @override
  Future<int> countFlashcardsInDeck(String deckId) async {
    deckCountCalls.add(deckId);
    return deckCount;
  }

  @override
  Future<int> countFlashcardsInScope(StudyContext context) async => scopeCount;

  @override
  Future<int> countDueCardsInScope(StudyContext context) async => dueCount;

  @override
  Future<int> countSuspendedInScope(StudyContext context) async =>
      suspendedCount;

  @override
  Future<int> countActiveBuriedInScope(StudyContext context) async =>
      activeBuriedCount;

  @override
  Future<DateTime?> nextDueAt(StudyContext context) async => next;

  @override
  Future<StudySessionSnapshot> startSession({
    required StudyContext context,
    required StudyFlow flow,
    required List<StudyMode> modes,
    required List<StudyFlashcardRef> batch,
  }) {
    startSessionCalled = true;
    throw UnimplementedError();
  }

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
