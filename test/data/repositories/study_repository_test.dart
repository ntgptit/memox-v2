import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/errors/app_exception.dart';
import 'package:memox/data/datasources/local/app_database.dart';
import 'package:memox/data/datasources/local/daos/folder_dao.dart';
import 'package:memox/data/datasources/local/daos/study_attempt_dao.dart';
import 'package:memox/data/datasources/local/daos/study_session_dao.dart';
import 'package:memox/data/datasources/local/daos/study_session_item_dao.dart';
import 'package:memox/data/datasources/local/local_transaction_runner.dart';
import 'package:memox/data/repositories/study_repo_impl.dart';
import 'package:memox/domain/enums/study_enums.dart';
import 'package:memox/domain/study/entities/study_models.dart';
import 'package:memox/domain/study/strategy/study_strategy.dart';
import 'package:memox/domain/study/strategy/study_strategy_factory.dart';
import 'package:memox/domain/study/usecases/study_usecases.dart';

import '../../support/content_repository_harness.dart';

void main() {
  group('StudyRepository', () {
    late _StudyHarness harness;

    setUp(() {
      harness = _StudyHarness.create();
    });

    tearDown(() async {
      await harness.dispose();
    });

    test(
      'DT1 onNavigate: runs New Study through five modes and finalizes to box 2',
      () async {
        await harness.seedDeckWithCards(cardCount: 2);

        var snapshot = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 2,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        while (snapshot.currentItem != null) {
          snapshot = await harness.answer.execute(
            sessionId: snapshot.session.id,
            studyType: snapshot.session.studyType,
            grade: AttemptGrade.remembered,
          );
        }

        expect(snapshot.session.status, SessionStatus.readyToFinalize);

        snapshot = await harness.finalize.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
        );

        expect(snapshot.session.status, SessionStatus.completed);
        final progressRows = await harness.database
            .select(harness.database.flashcardProgress)
            .get();
        expect(progressRows.map((row) => row.currentBox), everyElement(2));
        expect(progressRows.map((row) => row.dueAt), everyElement(isNotNull));
      },
    );

    test(
      'DT2 onNavigate: rejects New Study from the today entry point',
      () async {
        await harness.seedDeckWithCards(cardCount: 1, due: true);

        await expectLater(
          () => harness.start.execute(
            const StudyContext(
              entryType: StudyEntryType.today,
              entryRefId: null,
              studyType: StudyType.newStudy,
              settings: StudySettingsSnapshot(
                batchSize: 1,
                shuffleFlashcards: false,
                shuffleAnswers: false,
                prioritizeOverdue: true,
              ),
            ),
          ),
          throwsA(isA<ValidationException>()),
        );

        final sessions = await harness.database
            .select(harness.database.studySessions)
            .get();
        expect(sessions, isEmpty);
      },
    );

    test(
      'DT3 onNavigate: starts SRS Review from today with only due and overdue cards',
      () async {
        await harness.seedDeckWithCards(cardCount: 3);
        final now = DateTime.utc(2026, 4, 24, 9).millisecondsSinceEpoch;
        await (harness.database.update(harness.database.flashcardProgress)
              ..where((table) => table.flashcardId.equals('card-2')))
            .write(FlashcardProgressCompanion(dueAt: Value(now)));
        await (harness.database.update(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals('card-3'))).write(
          FlashcardProgressCompanion(
            dueAt: Value(now - Duration.millisecondsPerDay),
          ),
        );

        final snapshot = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.today,
            entryRefId: null,
            studyType: StudyType.srsReview,
            settings: StudySettingsSnapshot(
              batchSize: 3,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        expect(snapshot.sessionFlashcards.map((card) => card.id), <String>[
          'card-3',
          'card-2',
        ]);
        expect(
          snapshot.sessionFlashcards.map((card) => card.sourcePool),
          <SessionItemSourcePool>[
            SessionItemSourcePool.overdue,
            SessionItemSourcePool.due,
          ],
        );
      },
    );

    test(
      'DT4 onNavigate: starts New Study from cards in a nested folder deck',
      () async {
        final now = DateTime.utc(2026, 4, 24, 9).millisecondsSinceEpoch;
        await harness.database
            .into(harness.database.folders)
            .insert(
              FoldersCompanion.insert(
                id: 'folder-root',
                name: 'Root',
                contentMode: 'subfolders',
                sortOrder: 0,
                createdAt: now,
                updatedAt: now,
              ),
            );
        await harness.database
            .into(harness.database.folders)
            .insert(
              FoldersCompanion.insert(
                id: 'folder-child',
                parentId: const Value('folder-root'),
                name: 'Child',
                contentMode: 'decks',
                sortOrder: 0,
                createdAt: now,
                updatedAt: now,
              ),
            );
        await harness.database
            .into(harness.database.decks)
            .insert(
              DecksCompanion.insert(
                id: 'deck-child',
                folderId: 'folder-child',
                name: 'Nested Deck',
                sortOrder: 0,
                createdAt: now,
                updatedAt: now,
              ),
            );
        await harness.database
            .into(harness.database.flashcards)
            .insert(
              FlashcardsCompanion.insert(
                id: 'nested-card',
                deckId: 'deck-child',
                front: 'front',
                back: 'back',
                sortOrder: 0,
                createdAt: now,
                updatedAt: now,
              ),
            );
        await harness.database
            .into(harness.database.flashcardProgress)
            .insert(
              FlashcardProgressCompanion.insert(
                flashcardId: 'nested-card',
                currentBox: 1,
                reviewCount: 0,
                lapseCount: 0,
                createdAt: now,
                updatedAt: now,
              ),
            );

        final snapshot = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.folder,
            entryRefId: 'folder-root',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 5,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        expect(snapshot.sessionFlashcards.map((card) => card.id), <String>[
          'nested-card',
        ]);
        expect(snapshot.currentItem?.flashcard.deckId, 'deck-child');
      },
    );

    test(
      'DT1 repositoryFlow: skip requeues without passing the item',
      () async {
        await harness.seedDeckWithCards(cardCount: 1);

        final started = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );
        final skipped = await harness.skip.execute(started.session.id);

        expect(skipped.session.status, SessionStatus.inProgress);
        expect(
          skipped.currentItem?.flashcard.id,
          started.currentItem?.flashcard.id,
        );
        expect(skipped.summary.completedAttempts, 0);
      },
    );

    test(
      'DT2 repositoryFlow: incorrect New Study answer requeues the same mode without SRS commit',
      () async {
        await harness.seedDeckWithCards(cardCount: 1);

        final started = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        final answered = await harness.answer.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          grade: AttemptGrade.incorrect,
        );

        final progress = await (harness.database.select(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals('card-1'))).getSingle();

        expect(answered.session.status, SessionStatus.inProgress);
        expect(answered.currentItem?.flashcard.id, 'card-1');
        expect(answered.currentItem?.studyMode, StudyMode.review);
        expect(answered.currentItem?.roundIndex, 2);
        expect(answered.summary.completedAttempts, 1);
        expect(progress.currentBox, 1);
        expect(progress.reviewCount, 0);
        expect(progress.dueAt, isNull);
      },
    );

    test(
      'DT4 repositoryFlow: batch review submit inserts remembered attempt per pending item',
      () async {
        await harness.seedDeckWithCards(cardCount: 2);

        final started = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 2,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        final answered = await harness.answerBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          grade: AttemptGrade.remembered,
        );

        final attempts = await harness.database
            .select(harness.database.studyAttempts)
            .get();
        final reviewItems =
            await (harness.database.select(harness.database.studySessionItems)
                  ..where((table) => table.sessionId.equals(started.session.id))
                  ..where(
                    (table) =>
                        table.studyMode.equals(StudyMode.review.storageValue),
                  ))
                .get();

        expect(answered.summary.completedAttempts, 2);
        expect(attempts, hasLength(2));
        expect(
          attempts.map((attempt) => attempt.result),
          everyElement(AttemptGrade.remembered.storageValue),
        );
        expect(
          reviewItems.map((item) => item.status),
          everyElement(SessionItemStatus.completed.storageValue),
        );
      },
    );

    test(
      'DT5 repositoryFlow: batch review submit advances from Review to Match',
      () async {
        await harness.seedDeckWithCards(cardCount: 1);

        final started = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        final answered = await harness.answerBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          grade: AttemptGrade.remembered,
        );

        expect(answered.session.status, SessionStatus.inProgress);
        expect(answered.currentItem?.studyMode, StudyMode.match);
        expect(answered.currentItem?.modeOrder, 2);
      },
    );

    test(
      'DT6 repositoryFlow: batch review submit fails fast outside Review mode',
      () async {
        await harness.seedDeckWithCards(cardCount: 1);

        final started = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );
        final afterReview = await harness.answerBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          grade: AttemptGrade.remembered,
        );

        expect(afterReview.currentItem?.studyMode, StudyMode.match);
        await expectLater(
          () => harness.answerBatch.execute(
            sessionId: started.session.id,
            studyType: started.session.studyType,
            grade: AttemptGrade.remembered,
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'DT7 repositoryFlow: batch review submit fails fast for terminal session',
      () async {
        await harness.seedDeckWithCards(cardCount: 1);

        var snapshot = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        snapshot = await harness.answerBatch.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
          grade: AttemptGrade.remembered,
        );
        while (snapshot.currentItem != null) {
          snapshot = await harness.answer.execute(
            sessionId: snapshot.session.id,
            studyType: snapshot.session.studyType,
            grade: AttemptGrade.remembered,
          );
        }
        snapshot = await harness.finalize.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
        );

        expect(snapshot.session.status, SessionStatus.completed);
        await expectLater(
          () => harness.answerBatch.execute(
            sessionId: snapshot.session.id,
            studyType: snapshot.session.studyType,
            grade: AttemptGrade.remembered,
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'DT3 repositoryFlow: recovered SRS Review decreases box once after retry pass',
      () async {
        await harness.seedDeckWithCards(cardCount: 1, due: true, currentBox: 4);

        var snapshot = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.srsReview,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        snapshot = await harness.answer.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
          grade: AttemptGrade.incorrect,
        );
        expect(snapshot.currentItem?.roundIndex, 2);

        snapshot = await harness.answer.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
          grade: AttemptGrade.correct,
        );
        expect(snapshot.session.status, SessionStatus.readyToFinalize);

        await harness.finalize.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
        );

        final progress = await (harness.database.select(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals('card-1'))).getSingle();

        expect(progress.currentBox, 3);
        expect(progress.lastResult, ReviewResult.recovered.storageValue);
        expect(progress.lapseCount, 1);
      },
    );

    test(
      'DT1 onUpdate: does not mark completed session failed on stale finalize',
      () async {
        await harness.seedDeckWithCards(cardCount: 1);

        var snapshot = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        while (snapshot.currentItem != null) {
          snapshot = await harness.answer.execute(
            sessionId: snapshot.session.id,
            studyType: snapshot.session.studyType,
            grade: AttemptGrade.remembered,
          );
        }

        snapshot = await harness.finalize.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
        );
        expect(snapshot.session.status, SessionStatus.completed);

        await expectLater(
          () => harness.finalize.execute(
            sessionId: snapshot.session.id,
            studyType: snapshot.session.studyType,
          ),
          throwsA(isA<ValidationException>()),
        );

        final persistedSession = await (harness.database.select(
          harness.database.studySessions,
        )..where((table) => table.id.equals(snapshot.session.id))).getSingle();
        expect(persistedSession.status, SessionStatus.completed.storageValue);
      },
    );

    test('DT2 onUpdate: does not cancel a completed session', () async {
      await harness.seedDeckWithCards(cardCount: 1);

      var snapshot = await harness.start.execute(
        const StudyContext(
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.newStudy,
          settings: StudySettingsSnapshot(
            batchSize: 1,
            shuffleFlashcards: false,
            shuffleAnswers: false,
            prioritizeOverdue: true,
          ),
        ),
      );

      while (snapshot.currentItem != null) {
        snapshot = await harness.answer.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
          grade: AttemptGrade.remembered,
        );
      }

      snapshot = await harness.finalize.execute(
        sessionId: snapshot.session.id,
        studyType: snapshot.session.studyType,
      );

      await expectLater(
        () => harness.cancel.execute(snapshot.session.id),
        throwsA(isA<ValidationException>()),
      );

      final persistedSession = await (harness.database.select(
        harness.database.studySessions,
      )..where((table) => table.id.equals(snapshot.session.id))).getSingle();
      expect(persistedSession.status, SessionStatus.completed.storageValue);
    });

    test(
      'DT3 onUpdate: restart cancels the previous session and links the new one',
      () async {
        await harness.seedDeckWithCards(cardCount: 2);

        final first = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        final restarted = await harness.restart.execute(
          sessionId: first.session.id,
          context: const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        final previous = await (harness.database.select(
          harness.database.studySessions,
        )..where((table) => table.id.equals(first.session.id))).getSingle();

        expect(previous.status, SessionStatus.cancelled.storageValue);
        expect(restarted.session.status, SessionStatus.inProgress);
        expect(restarted.session.restartedFromSessionId, first.session.id);
      },
    );

    test(
      'DT4 onUpdate: perfect SRS Review increases box and schedules the next interval',
      () async {
        await harness.seedDeckWithCards(cardCount: 1, due: true, currentBox: 4);

        var snapshot = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.srsReview,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        snapshot = await harness.answer.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
          grade: AttemptGrade.correct,
        );

        await harness.finalize.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
        );

        final progress = await (harness.database.select(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals('card-1'))).getSingle();
        final expectedDueAt = DateTime.utc(
          2026,
          4,
          24,
          9,
        ).add(const Duration(days: 14)).millisecondsSinceEpoch;

        expect(progress.currentBox, 5);
        expect(progress.lastResult, ReviewResult.perfect.storageValue);
        expect(progress.dueAt, expectedDueAt);
      },
    );

    test(
      'DT5 onUpdate: overdue priority chooses overdue card before due card when batch is limited',
      () async {
        await harness.seedDeckWithCards(cardCount: 2);
        final now = DateTime.utc(2026, 4, 24, 9).millisecondsSinceEpoch;
        await (harness.database.update(harness.database.flashcardProgress)
              ..where((table) => table.flashcardId.equals('card-1')))
            .write(FlashcardProgressCompanion(dueAt: Value(now)));
        await (harness.database.update(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals('card-2'))).write(
          FlashcardProgressCompanion(
            dueAt: Value(now - Duration.millisecondsPerDay),
          ),
        );

        final snapshot = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.srsReview,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        expect(snapshot.sessionFlashcards.map((card) => card.id), <String>[
          'card-2',
        ]);
        expect(
          snapshot.sessionFlashcards.single.sourcePool,
          SessionItemSourcePool.overdue,
        );
      },
    );

    test(
      'DT6 onUpdate: cancelling an in-progress session abandons pending items',
      () async {
        await harness.seedDeckWithCards(cardCount: 2);

        final started = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 2,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        final cancelled = await harness.cancel.execute(started.session.id);

        final items = await (harness.database.select(
          harness.database.studySessionItems,
        )..where((table) => table.sessionId.equals(started.session.id))).get();

        expect(cancelled.session.status, SessionStatus.cancelled);
        expect(cancelled.currentItem, isNull);
        expect(items.map((item) => item.status), everyElement('abandoned'));
      },
    );

    test(
      'DT1 onRefreshRetry: SRS Review treats forgot as retry and finalizes to box 1',
      () async {
        await harness.seedDeckWithCards(cardCount: 1, due: true, currentBox: 4);

        var snapshot = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.srsReview,
            settings: StudySettingsSnapshot(
              batchSize: 1,
              shuffleFlashcards: false,
              shuffleAnswers: false,
              prioritizeOverdue: true,
            ),
          ),
        );

        snapshot = await harness.answer.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
          grade: AttemptGrade.forgot,
        );
        expect(snapshot.currentItem, isNotNull);
        expect(snapshot.session.status, SessionStatus.inProgress);

        snapshot = await harness.answer.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
          grade: AttemptGrade.correct,
        );
        expect(snapshot.session.status, SessionStatus.readyToFinalize);

        await harness.finalize.execute(
          sessionId: snapshot.session.id,
          studyType: snapshot.session.studyType,
        );

        final progress = await (harness.database.select(
          harness.database.flashcardProgress,
        )..where((table) => table.flashcardId.equals('card-1'))).getSingle();
        expect(progress.currentBox, 1);
        expect(progress.lastResult, ReviewResult.forgot.storageValue);
      },
    );

    test(
      'DT2 onRefreshRetry: New Study with no eligible new cards creates no session',
      () async {
        await harness.seedDeckWithCards(cardCount: 1, due: true);

        await expectLater(
          () => harness.start.execute(
            const StudyContext(
              entryType: StudyEntryType.deck,
              entryRefId: 'deck-1',
              studyType: StudyType.newStudy,
              settings: StudySettingsSnapshot(
                batchSize: 1,
                shuffleFlashcards: false,
                shuffleAnswers: false,
                prioritizeOverdue: true,
              ),
            ),
          ),
          throwsA(isA<ValidationException>()),
        );

        final sessions = await harness.database
            .select(harness.database.studySessions)
            .get();
        expect(sessions, isEmpty);
      },
    );

    test(
      'DT3 onRefreshRetry: missing deck entry reference fails before creating a session',
      () async {
        await expectLater(
          () => harness.start.execute(
            const StudyContext(
              entryType: StudyEntryType.deck,
              entryRefId: null,
              studyType: StudyType.newStudy,
              settings: StudySettingsSnapshot(
                batchSize: 1,
                shuffleFlashcards: false,
                shuffleAnswers: false,
                prioritizeOverdue: true,
              ),
            ),
          ),
          throwsA(isA<ValidationException>()),
        );

        final sessions = await harness.database
            .select(harness.database.studySessions)
            .get();
        expect(sessions, isEmpty);
      },
    );
  });
}

final class _StudyHarness {
  _StudyHarness._({
    required this.database,
    required this.start,
    required this.answer,
    required this.answerBatch,
    required this.skip,
    required this.cancel,
    required this.restart,
    required this.finalize,
  });

  factory _StudyHarness.create() {
    final database = AppDatabase(executor: NativeDatabase.memory());
    final clock = TestClock(DateTime.utc(2026, 4, 24, 9));
    final idGenerator = SequenceIdGenerator();
    final transactionRunner = LocalTransactionRunner(database);
    final repo = StudyRepoImpl(
      database: database,
      studySessionDao: StudySessionDao(database),
      studySessionItemDao: StudySessionItemDao(database),
      studyAttemptDao: StudyAttemptDao(database),
      folderDao: FolderDao(database),
      transactionRunner: transactionRunner,
      clock: clock,
      idGenerator: idGenerator,
    );
    final factory = StudyStrategyFactory(const <StudyStrategy>[
      NewStudyStrategy(),
      SrsReviewStrategy(),
    ]);
    return _StudyHarness._(
      database: database,
      start: StartStudySessionUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
      answer: AnswerFlashcardUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
      answerBatch: AnswerCurrentModeBatchUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
      skip: SkipFlashcardUseCase(repo),
      cancel: CancelStudySessionUseCase(repo),
      restart: RestartStudySessionUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
      finalize: FinalizeStudySessionUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
    );
  }

  final AppDatabase database;
  final StartStudySessionUseCase start;
  final AnswerFlashcardUseCase answer;
  final AnswerCurrentModeBatchUseCase answerBatch;
  final SkipFlashcardUseCase skip;
  final CancelStudySessionUseCase cancel;
  final RestartStudySessionUseCase restart;
  final FinalizeStudySessionUseCase finalize;

  Future<void> seedDeckWithCards({
    required int cardCount,
    bool due = false,
    int currentBox = 1,
  }) async {
    final now = DateTime.utc(2026, 4, 24, 9).millisecondsSinceEpoch;
    await database
        .into(database.folders)
        .insert(
          FoldersCompanion.insert(
            id: 'folder-1',
            name: 'Study',
            contentMode: 'decks',
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await database
        .into(database.decks)
        .insert(
          DecksCompanion.insert(
            id: 'deck-1',
            folderId: 'folder-1',
            name: 'Deck',
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );
    for (var index = 0; index < cardCount; index++) {
      final cardId = 'card-${index + 1}';
      await database
          .into(database.flashcards)
          .insert(
            FlashcardsCompanion.insert(
              id: cardId,
              deckId: 'deck-1',
              front: 'front $index',
              back: 'back $index',
              sortOrder: index,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await database
          .into(database.flashcardProgress)
          .insert(
            FlashcardProgressCompanion.insert(
              flashcardId: cardId,
              currentBox: currentBox,
              reviewCount: 0,
              lapseCount: 0,
              dueAt: Value(due ? now - Duration.millisecondsPerDay : null),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  Future<void> dispose() => database.close();
}
