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
    test(
      'S4: StartStudySessionUseCase throws EmptyScopeException(deckNoCards) '
      'when entry deck has 0 flashcards',
      () async {
        final repo = _FakeStudyRepo(deckCount: 0);
        final useCase = StartStudySessionUseCase(
          repository: repo,
          strategyFactory: StudyFlowStrategyFactory(const <StudyFlowStrategy>[
            NewStudyStrategy(),
            SrsReviewStrategy(),
          ]),
        );

        await expectLater(
          useCase.execute(
            const StudyContext(
              entryType: StudyEntryType.deck,
              entryRefId: 'deck-empty',
              studyType: StudyType.newStudy,
              settings: _testSettings,
            ),
          ),
          throwsA(
            isA<EmptyScopeException>().having(
              (error) => error.reason,
              'reason',
              EmptyScopeReason.deckNoCards,
            ),
          ),
        );
        expect(repo.countCalls, <String>['deck-empty']);
        expect(repo.startSessionCalled, isFalse);
      },
    );

    test(
      'S4 (negative): does not throw EmptyScopeException when deck has cards',
      () async {
        final repo = _FakeStudyRepo(deckCount: 3);
        final useCase = StartStudySessionUseCase(
          repository: repo,
          strategyFactory: StudyFlowStrategyFactory(const <StudyFlowStrategy>[
            NewStudyStrategy(),
            SrsReviewStrategy(),
          ]),
        );

        // _rejectEmptyScope passes; downstream loadBatch is _FakeStudyRepo's
        // UnimplementedError — proves we routed past the empty-scope guard.
        await expectLater(
          useCase.execute(
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
  });
}

const _testSettings = StudySettingsSnapshot(
  batchSize: 20,
  shuffleFlashcards: false,
  shuffleAnswers: false,
  prioritizeOverdue: false,
);

class _FakeStudyRepo implements StudyRepo {
  _FakeStudyRepo({required this.deckCount});

  final int deckCount;
  final List<String> countCalls = <String>[];
  bool startSessionCalled = false;

  @override
  Future<int> countFlashcardsInDeck(String deckId) async {
    countCalls.add(deckId);
    return deckCount;
  }

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
