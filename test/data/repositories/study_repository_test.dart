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
import 'package:memox/domain/study/strategy/study_mode_strategy.dart';
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
            grade: AttemptGrade.correct,
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
      'DT1 onInsert: starting New Study saves full session and initial queue rows',
      () async {
        await harness.seedDeckWithCards(cardCount: 2);

        final snapshot = await harness.start.execute(
          const StudyContext(
            entryType: StudyEntryType.deck,
            entryRefId: 'deck-1',
            studyType: StudyType.newStudy,
            settings: StudySettingsSnapshot(
              batchSize: 2,
              shuffleFlashcards: false,
              shuffleAnswers: true,
              prioritizeOverdue: false,
            ),
          ),
        );

        expect(snapshot.session.id, 'id-0000');
        await _expectSessionRow(
          harness,
          id: 'id-0000',
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.newStudy,
          studyFlow: StudyFlow.newFullCycle,
          batchSize: 2,
          shuffleFlashcards: false,
          shuffleAnswers: true,
          prioritizeOverdue: false,
          status: SessionStatus.inProgress,
          startedAt: _studyNow,
          endedAt: null,
          restartedFromSessionId: null,
        );
        await _expectItemRow(
          harness,
          id: 'id-0001',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.review,
          modeOrder: 1,
          roundIndex: 1,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.pending,
          completedAt: null,
        );
        await _expectItemRow(
          harness,
          id: 'id-0002',
          sessionId: 'id-0000',
          flashcardId: 'card-2',
          studyMode: StudyMode.review,
          modeOrder: 1,
          roundIndex: 1,
          queuePosition: 2,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.pending,
          completedAt: null,
        );
        await _expectAttemptCount(harness, 0);
        await _expectProgressRow(
          harness,
          flashcardId: 'card-1',
          currentBox: 1,
          reviewCount: 0,
          lapseCount: 0,
          lastResult: null,
          lastStudiedAt: null,
          dueAt: null,
          createdAt: _studyNow,
          updatedAt: _studyNow,
        );
      },
    );

    test(
      'DT2 onInsert: batch Review submit saves attempts item updates and Match queue rows',
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

        await harness.answerBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
        );

        await _expectSessionRow(
          harness,
          id: 'id-0000',
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.newStudy,
          studyFlow: StudyFlow.newFullCycle,
          batchSize: 2,
          shuffleFlashcards: false,
          shuffleAnswers: false,
          prioritizeOverdue: true,
          status: SessionStatus.inProgress,
          startedAt: _studyNow,
          endedAt: null,
          restartedFromSessionId: null,
        );
        await _expectItemRow(
          harness,
          id: 'id-0001',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.review,
          modeOrder: 1,
          roundIndex: 1,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.completed,
          completedAt: _studyNow,
        );
        await _expectItemRow(
          harness,
          id: 'id-0002',
          sessionId: 'id-0000',
          flashcardId: 'card-2',
          studyMode: StudyMode.review,
          modeOrder: 1,
          roundIndex: 1,
          queuePosition: 2,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.completed,
          completedAt: _studyNow,
        );
        await _expectAttemptRow(
          harness,
          id: 'id-0003',
          sessionId: 'id-0000',
          sessionItemId: 'id-0001',
          flashcardId: 'card-1',
          attemptNumber: 1,
          result: AttemptGrade.correct,
          oldBox: null,
          newBox: null,
          nextDueAt: null,
          answeredAt: _studyNow,
        );
        await _expectAttemptRow(
          harness,
          id: 'id-0004',
          sessionId: 'id-0000',
          sessionItemId: 'id-0002',
          flashcardId: 'card-2',
          attemptNumber: 1,
          result: AttemptGrade.correct,
          oldBox: null,
          newBox: null,
          nextDueAt: null,
          answeredAt: _studyNow,
        );
        await _expectItemRow(
          harness,
          id: 'id-0005',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.match,
          modeOrder: 2,
          roundIndex: 1,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.pending,
          completedAt: null,
        );
        await _expectItemRow(
          harness,
          id: 'id-0006',
          sessionId: 'id-0000',
          flashcardId: 'card-2',
          studyMode: StudyMode.match,
          modeOrder: 2,
          roundIndex: 1,
          queuePosition: 2,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.pending,
          completedAt: null,
        );
        await _expectProgressRow(
          harness,
          flashcardId: 'card-1',
          currentBox: 1,
          reviewCount: 0,
          lapseCount: 0,
          lastResult: null,
          lastStudiedAt: null,
          dueAt: null,
          createdAt: _studyNow,
          updatedAt: _studyNow,
        );
      },
    );

    test(
      'DT3 onInsert: batch Match submit saves item grades and failed retry rows',
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
        await harness.answerBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
        );

        await harness.answerMatchBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0005': AttemptGrade.incorrect,
            'id-0006': AttemptGrade.correct,
          },
        );

        await _expectSessionRow(
          harness,
          id: 'id-0000',
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.newStudy,
          studyFlow: StudyFlow.newFullCycle,
          batchSize: 2,
          shuffleFlashcards: false,
          shuffleAnswers: false,
          prioritizeOverdue: true,
          status: SessionStatus.inProgress,
          startedAt: _studyNow,
          endedAt: null,
          restartedFromSessionId: null,
        );
        await _expectItemRow(
          harness,
          id: 'id-0005',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.match,
          modeOrder: 2,
          roundIndex: 1,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.completed,
          completedAt: _studyNow,
        );
        await _expectItemRow(
          harness,
          id: 'id-0006',
          sessionId: 'id-0000',
          flashcardId: 'card-2',
          studyMode: StudyMode.match,
          modeOrder: 2,
          roundIndex: 1,
          queuePosition: 2,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.completed,
          completedAt: _studyNow,
        );
        await _expectAttemptRow(
          harness,
          id: 'id-0007',
          sessionId: 'id-0000',
          sessionItemId: 'id-0005',
          flashcardId: 'card-1',
          attemptNumber: 2,
          result: AttemptGrade.incorrect,
          oldBox: null,
          newBox: null,
          nextDueAt: null,
          answeredAt: _studyNow,
        );
        await _expectAttemptRow(
          harness,
          id: 'id-0008',
          sessionId: 'id-0000',
          sessionItemId: 'id-0006',
          flashcardId: 'card-2',
          attemptNumber: 2,
          result: AttemptGrade.correct,
          oldBox: null,
          newBox: null,
          nextDueAt: null,
          answeredAt: _studyNow,
        );
        await _expectItemRow(
          harness,
          id: 'id-0009',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.match,
          modeOrder: 2,
          roundIndex: 2,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.retry,
          status: SessionItemStatus.pending,
          completedAt: null,
        );
        await _expectProgressRow(
          harness,
          flashcardId: 'card-1',
          currentBox: 1,
          reviewCount: 0,
          lapseCount: 0,
          lastResult: null,
          lastStudiedAt: null,
          dueAt: null,
          createdAt: _studyNow,
          updatedAt: _studyNow,
        );
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
      'DT4 repositoryFlow: batch review submit inserts correct attempt per pending item',
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
          everyElement(AttemptGrade.correct.storageValue),
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
        );

        expect(afterReview.currentItem?.studyMode, StudyMode.match);
        await expectLater(
          () => harness.answerBatch.execute(
            sessionId: started.session.id,
            studyType: started.session.studyType,
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
        );
        while (snapshot.currentItem != null) {
          snapshot = await harness.answer.execute(
            sessionId: snapshot.session.id,
            studyType: snapshot.session.studyType,
            grade: AttemptGrade.correct,
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
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'DT8 repositoryFlow: all-correct Match batch advances to Guess',
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
        await harness.answerBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
        );

        final answered = await harness.answerMatchBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0005': AttemptGrade.correct,
            'id-0006': AttemptGrade.correct,
          },
        );

        expect(answered.session.status, SessionStatus.inProgress);
        expect(answered.currentItem?.studyMode, StudyMode.guess);
        expect(answered.currentItem?.modeOrder, 3);
        expect(answered.currentItem?.roundIndex, 1);
      },
    );

    test(
      'DT9 repositoryFlow: mixed Match batch creates retry for incorrect item only',
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
        await harness.answerBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
        );

        final answered = await harness.answerMatchBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0005': AttemptGrade.incorrect,
            'id-0006': AttemptGrade.correct,
          },
        );

        expect(answered.currentItem?.studyMode, StudyMode.match);
        expect(answered.currentItem?.roundIndex, 2);
        expect(answered.currentRoundItems.map((item) => item.flashcard.id), [
          'card-1',
        ]);
      },
    );

    test(
      'DT10 repositoryFlow: Match batch fails fast outside Match mode',
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

        await expectLater(
          () => harness.answerMatchBatch.execute(
            sessionId: started.session.id,
            studyType: started.session.studyType,
            itemGrades: const <String, AttemptGrade>{
              'id-0001': AttemptGrade.correct,
              'id-0002': AttemptGrade.correct,
            },
          ),
          throwsA(isA<ValidationException>()),
        );
        await _expectAttemptCount(harness, 0);
      },
    );

    test('DT11 repositoryFlow: Match batch rejects extra item ids', () async {
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
      await harness.answerBatch.execute(
        sessionId: started.session.id,
        studyType: started.session.studyType,
      );

      await expectLater(
        () => harness.answerMatchBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0005': AttemptGrade.correct,
            'extra-item': AttemptGrade.correct,
          },
        ),
        throwsA(isA<ValidationException>()),
      );
      await _expectItemRow(
        harness,
        id: 'id-0005',
        sessionId: 'id-0000',
        flashcardId: 'card-1',
        studyMode: StudyMode.match,
        modeOrder: 2,
        roundIndex: 1,
        queuePosition: 1,
        sourcePool: SessionItemSourcePool.newCards,
        status: SessionItemStatus.pending,
        completedAt: null,
      );
      await _expectAttemptCount(harness, 2);
    });

    test(
      'DT12 repositoryFlow: Match batch accepts normalized correct grades',
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
        await harness.answerBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
        );

        final answered = await harness.answerMatchBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0005': AttemptGrade.correct,
            'id-0006': AttemptGrade.correct,
          },
        );
        expect(answered.currentItem?.studyMode, StudyMode.guess);
        await _expectAttemptCount(harness, 4);
      },
    );

    test(
      'DT13 repositoryFlow: Guess mode item batch saves attempts and failed retry rows',
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
        await harness.answerBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
        );
        await harness.answerMatchBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0005': AttemptGrade.correct,
            'id-0006': AttemptGrade.correct,
          },
        );

        final answered = await harness.answerModeItemBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0009': AttemptGrade.incorrect,
            'id-0010': AttemptGrade.correct,
          },
        );

        expect(answered.currentItem?.studyMode, StudyMode.guess);
        expect(answered.currentItem?.roundIndex, 2);
        await _expectItemRow(
          harness,
          id: 'id-0009',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.guess,
          modeOrder: 3,
          roundIndex: 1,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.completed,
          completedAt: _studyNow,
        );
        await _expectItemRow(
          harness,
          id: 'id-0010',
          sessionId: 'id-0000',
          flashcardId: 'card-2',
          studyMode: StudyMode.guess,
          modeOrder: 3,
          roundIndex: 1,
          queuePosition: 2,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.completed,
          completedAt: _studyNow,
        );
        await _expectAttemptRow(
          harness,
          id: 'id-0011',
          sessionId: 'id-0000',
          sessionItemId: 'id-0009',
          flashcardId: 'card-1',
          attemptNumber: 3,
          result: AttemptGrade.incorrect,
          oldBox: null,
          newBox: null,
          nextDueAt: null,
          answeredAt: _studyNow,
        );
        await _expectAttemptRow(
          harness,
          id: 'id-0012',
          sessionId: 'id-0000',
          sessionItemId: 'id-0010',
          flashcardId: 'card-2',
          attemptNumber: 3,
          result: AttemptGrade.correct,
          oldBox: null,
          newBox: null,
          nextDueAt: null,
          answeredAt: _studyNow,
        );
        await _expectItemRow(
          harness,
          id: 'id-0013',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.guess,
          modeOrder: 3,
          roundIndex: 2,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.retry,
          status: SessionItemStatus.pending,
          completedAt: null,
        );
        await _expectProgressRow(
          harness,
          flashcardId: 'card-1',
          currentBox: 1,
          reviewCount: 0,
          lapseCount: 0,
          lastResult: null,
          lastStudiedAt: null,
          dueAt: null,
          createdAt: _studyNow,
          updatedAt: _studyNow,
        );
      },
    );

    test(
      'DT14 repositoryFlow: Recall mode item batch saves correct and incorrect fields',
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
        await harness.answerBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
        );
        await harness.answerMatchBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0005': AttemptGrade.correct,
            'id-0006': AttemptGrade.correct,
          },
        );
        await harness.answerModeItemBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0009': AttemptGrade.correct,
            'id-0010': AttemptGrade.correct,
          },
        );

        final answered = await harness.answerModeItemBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0013': AttemptGrade.incorrect,
            'id-0014': AttemptGrade.correct,
          },
        );

        expect(answered.currentItem?.studyMode, StudyMode.recall);
        expect(answered.currentItem?.roundIndex, 2);
        await _expectAttemptRow(
          harness,
          id: 'id-0015',
          sessionId: 'id-0000',
          sessionItemId: 'id-0013',
          flashcardId: 'card-1',
          attemptNumber: 4,
          result: AttemptGrade.incorrect,
          oldBox: null,
          newBox: null,
          nextDueAt: null,
          answeredAt: _studyNow,
        );
        await _expectAttemptRow(
          harness,
          id: 'id-0016',
          sessionId: 'id-0000',
          sessionItemId: 'id-0014',
          flashcardId: 'card-2',
          attemptNumber: 4,
          result: AttemptGrade.correct,
          oldBox: null,
          newBox: null,
          nextDueAt: null,
          answeredAt: _studyNow,
        );
        await _expectItemRow(
          harness,
          id: 'id-0017',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.recall,
          modeOrder: 4,
          roundIndex: 2,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.retry,
          status: SessionItemStatus.pending,
          completedAt: null,
        );
      },
    );

    test(
      'DT15 repositoryFlow: Fill mode item batch completes final mode as ready to finalize',
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
        await harness.answerBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
        );
        await harness.answerMatchBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0005': AttemptGrade.correct,
            'id-0006': AttemptGrade.correct,
          },
        );
        await harness.answerModeItemBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0009': AttemptGrade.correct,
            'id-0010': AttemptGrade.correct,
          },
        );
        await harness.answerModeItemBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0013': AttemptGrade.correct,
            'id-0014': AttemptGrade.correct,
          },
        );

        final answered = await harness.answerModeItemBatch.execute(
          sessionId: started.session.id,
          studyType: started.session.studyType,
          itemGrades: const <String, AttemptGrade>{
            'id-0017': AttemptGrade.correct,
            'id-0018': AttemptGrade.correct,
          },
        );

        expect(answered.session.status, SessionStatus.readyToFinalize);
        expect(answered.session.endedAt, _studyNow);
        await _expectItemRow(
          harness,
          id: 'id-0017',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.fill,
          modeOrder: 5,
          roundIndex: 1,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.completed,
          completedAt: _studyNow,
        );
        await _expectAttemptRow(
          harness,
          id: 'id-0019',
          sessionId: 'id-0000',
          sessionItemId: 'id-0017',
          flashcardId: 'card-1',
          attemptNumber: 5,
          result: AttemptGrade.correct,
          oldBox: null,
          newBox: null,
          nextDueAt: null,
          answeredAt: _studyNow,
        );
      },
    );

    test(
      'DT1 listActiveSessions: returns only active sessions ordered newest first',
      () async {
        await harness.seedDeckWithCards(cardCount: 1);

        final completed = await harness.startOneCardNewStudy();
        harness.clock.advance(const Duration(minutes: 1));
        final cancelled = await harness.startOneCardNewStudy();
        harness.clock.advance(const Duration(minutes: 1));
        final inProgress = await harness.startOneCardNewStudy();
        harness.clock.advance(const Duration(minutes: 1));
        final ready = await harness.startOneCardNewStudy();
        harness.clock.advance(const Duration(minutes: 1));
        final failed = await harness.startOneCardNewStudy();

        await harness.setSessionStatus(
          sessionId: completed.session.id,
          status: SessionStatus.completed,
        );
        await harness.setSessionStatus(
          sessionId: cancelled.session.id,
          status: SessionStatus.cancelled,
        );
        await harness.setSessionStatus(
          sessionId: ready.session.id,
          status: SessionStatus.readyToFinalize,
        );
        await harness.setSessionStatus(
          sessionId: failed.session.id,
          status: SessionStatus.failedToFinalize,
        );

        final active = await harness.resume.listActiveSessions();

        expect(active.map((snapshot) => snapshot.session.id), <String>[
          failed.session.id,
          ready.session.id,
          inProgress.session.id,
        ]);
        expect(
          active.map((snapshot) => snapshot.session.status),
          <SessionStatus>[
            SessionStatus.failedToFinalize,
            SessionStatus.readyToFinalize,
            SessionStatus.inProgress,
          ],
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
            grade: AttemptGrade.correct,
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
          grade: AttemptGrade.correct,
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
        await _expectSessionRow(
          harness,
          id: 'id-0000',
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.newStudy,
          studyFlow: StudyFlow.newFullCycle,
          batchSize: 1,
          shuffleFlashcards: false,
          shuffleAnswers: false,
          prioritizeOverdue: true,
          status: SessionStatus.cancelled,
          startedAt: _studyNow,
          endedAt: _studyNow,
          restartedFromSessionId: null,
        );
        await _expectItemRow(
          harness,
          id: 'id-0001',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.review,
          modeOrder: 1,
          roundIndex: 1,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.abandoned,
          completedAt: null,
        );
        await _expectSessionRow(
          harness,
          id: 'id-0002',
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.newStudy,
          studyFlow: StudyFlow.newFullCycle,
          batchSize: 1,
          shuffleFlashcards: false,
          shuffleAnswers: false,
          prioritizeOverdue: true,
          status: SessionStatus.inProgress,
          startedAt: _studyNow,
          endedAt: null,
          restartedFromSessionId: 'id-0000',
        );
        await _expectItemRow(
          harness,
          id: 'id-0003',
          sessionId: 'id-0002',
          flashcardId: 'card-1',
          studyMode: StudyMode.review,
          modeOrder: 1,
          roundIndex: 1,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.pending,
          completedAt: null,
        );
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
        await _expectSessionRow(
          harness,
          id: 'id-0000',
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.srsReview,
          studyFlow: StudyFlow.srsFillReview,
          batchSize: 1,
          shuffleFlashcards: false,
          shuffleAnswers: false,
          prioritizeOverdue: true,
          status: SessionStatus.completed,
          startedAt: _studyNow,
          endedAt: _studyNow,
          restartedFromSessionId: null,
        );
        await _expectItemRow(
          harness,
          id: 'id-0001',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.fill,
          modeOrder: 1,
          roundIndex: 1,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.overdue,
          status: SessionItemStatus.completed,
          completedAt: _studyNow,
        );
        await _expectAttemptRow(
          harness,
          id: 'id-0002',
          sessionId: 'id-0000',
          sessionItemId: 'id-0001',
          flashcardId: 'card-1',
          attemptNumber: 1,
          result: AttemptGrade.correct,
          oldBox: 4,
          newBox: 5,
          nextDueAt: expectedDueAt,
          answeredAt: _studyNow,
        );
        await _expectProgressRow(
          harness,
          flashcardId: 'card-1',
          currentBox: 5,
          reviewCount: 1,
          lapseCount: 0,
          lastResult: ReviewResult.perfect,
          lastStudiedAt: _studyNow,
          dueAt: expectedDueAt,
          createdAt: _studyNow,
          updatedAt: _studyNow,
        );
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
        await _expectSessionRow(
          harness,
          id: 'id-0000',
          entryType: StudyEntryType.deck,
          entryRefId: 'deck-1',
          studyType: StudyType.newStudy,
          studyFlow: StudyFlow.newFullCycle,
          batchSize: 2,
          shuffleFlashcards: false,
          shuffleAnswers: false,
          prioritizeOverdue: true,
          status: SessionStatus.cancelled,
          startedAt: _studyNow,
          endedAt: _studyNow,
          restartedFromSessionId: null,
        );
        await _expectItemRow(
          harness,
          id: 'id-0001',
          sessionId: 'id-0000',
          flashcardId: 'card-1',
          studyMode: StudyMode.review,
          modeOrder: 1,
          roundIndex: 1,
          queuePosition: 1,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.abandoned,
          completedAt: null,
        );
        await _expectItemRow(
          harness,
          id: 'id-0002',
          sessionId: 'id-0000',
          flashcardId: 'card-2',
          studyMode: StudyMode.review,
          modeOrder: 1,
          roundIndex: 1,
          queuePosition: 2,
          sourcePool: SessionItemSourcePool.newCards,
          status: SessionItemStatus.abandoned,
          completedAt: null,
        );
      },
    );

    test(
      'DT1 onRefreshRetry: SRS Review treats incorrect as retry and finalizes recovered review',
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
        expect(progress.currentBox, 3);
        expect(progress.lastResult, ReviewResult.recovered.storageValue);
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

final _studyNow = DateTime.utc(2026, 4, 24, 9).millisecondsSinceEpoch;

Future<void> _expectSessionRow(
  _StudyHarness harness, {
  required String id,
  required StudyEntryType entryType,
  required String? entryRefId,
  required StudyType studyType,
  required StudyFlow studyFlow,
  required int batchSize,
  required bool shuffleFlashcards,
  required bool shuffleAnswers,
  required bool prioritizeOverdue,
  required SessionStatus status,
  required int startedAt,
  required int? endedAt,
  required String? restartedFromSessionId,
}) async {
  final row = await (harness.database.select(
    harness.database.studySessions,
  )..where((table) => table.id.equals(id))).getSingle();

  expect(row.id, id);
  expect(row.entryType, entryType.storageValue);
  expect(row.entryRefId, entryRefId);
  expect(row.studyType, studyType.storageValue);
  expect(row.studyFlow, studyFlow.storageValue);
  expect(row.batchSize, batchSize);
  expect(row.shuffleFlashcards, shuffleFlashcards ? 1 : 0);
  expect(row.shuffleAnswers, shuffleAnswers ? 1 : 0);
  expect(row.prioritizeOverdue, prioritizeOverdue ? 1 : 0);
  expect(row.status, status.storageValue);
  expect(row.startedAt, startedAt);
  expect(row.endedAt, endedAt);
  expect(row.restartedFromSessionId, restartedFromSessionId);
}

Future<void> _expectItemRow(
  _StudyHarness harness, {
  required String id,
  required String sessionId,
  required String flashcardId,
  required StudyMode studyMode,
  required int modeOrder,
  required int roundIndex,
  required int queuePosition,
  required SessionItemSourcePool sourcePool,
  required SessionItemStatus status,
  required int? completedAt,
}) async {
  final row = await (harness.database.select(
    harness.database.studySessionItems,
  )..where((table) => table.id.equals(id))).getSingle();

  expect(row.id, id);
  expect(row.sessionId, sessionId);
  expect(row.flashcardId, flashcardId);
  expect(row.studyMode, studyMode.storageValue);
  expect(row.modeOrder, modeOrder);
  expect(row.roundIndex, roundIndex);
  expect(row.queuePosition, queuePosition);
  expect(row.sourcePool, sourcePool.storageValue);
  expect(row.status, status.storageValue);
  expect(row.completedAt, completedAt);
}

Future<void> _expectAttemptRow(
  _StudyHarness harness, {
  required String id,
  required String sessionId,
  required String sessionItemId,
  required String flashcardId,
  required int attemptNumber,
  required AttemptGrade result,
  required int? oldBox,
  required int? newBox,
  required int? nextDueAt,
  required int answeredAt,
}) async {
  final row = await (harness.database.select(
    harness.database.studyAttempts,
  )..where((table) => table.id.equals(id))).getSingle();

  expect(row.id, id);
  expect(row.sessionId, sessionId);
  expect(row.sessionItemId, sessionItemId);
  expect(row.flashcardId, flashcardId);
  expect(row.attemptNumber, attemptNumber);
  expect(row.result, result.storageValue);
  expect(row.oldBox, oldBox);
  expect(row.newBox, newBox);
  expect(row.nextDueAt, nextDueAt);
  expect(row.answeredAt, answeredAt);
}

Future<void> _expectProgressRow(
  _StudyHarness harness, {
  required String flashcardId,
  required int currentBox,
  required int reviewCount,
  required int lapseCount,
  required ReviewResult? lastResult,
  required int? lastStudiedAt,
  required int? dueAt,
  required int createdAt,
  required int updatedAt,
}) async {
  final row = await (harness.database.select(
    harness.database.flashcardProgress,
  )..where((table) => table.flashcardId.equals(flashcardId))).getSingle();

  expect(row.flashcardId, flashcardId);
  expect(row.currentBox, currentBox);
  expect(row.reviewCount, reviewCount);
  expect(row.lapseCount, lapseCount);
  expect(row.lastResult, lastResult?.storageValue);
  expect(row.lastStudiedAt, lastStudiedAt);
  expect(row.dueAt, dueAt);
  expect(row.createdAt, createdAt);
  expect(row.updatedAt, updatedAt);
}

Future<void> _expectAttemptCount(_StudyHarness harness, int expected) async {
  final rows = await harness.database
      .select(harness.database.studyAttempts)
      .get();
  expect(rows, hasLength(expected));
}

final class _StudyHarness {
  _StudyHarness._({
    required this.database,
    required this.clock,
    required this.start,
    required this.resume,
    required this.answer,
    required this.answerBatch,
    required this.answerModeItemBatch,
    required this.answerMatchBatch,
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
    final modeFactory = StudyModeStrategyFactory(const <StudyModeStrategy>[
      ReviewModeStrategy(),
      MatchModeStrategy(),
      GuessModeStrategy(),
      RecallModeStrategy(),
      FillModeStrategy(),
    ]);
    return _StudyHarness._(
      database: database,
      clock: clock,
      start: StartStudySessionUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
      resume: ResumeStudySessionUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
      answer: AnswerFlashcardUseCase(
        repository: repo,
        strategyFactory: factory,
      ),
      answerBatch: AnswerCurrentModeBatchUseCase(
        repository: repo,
        flowStrategyFactory: factory,
        modeStrategyFactory: modeFactory,
      ),
      answerModeItemBatch: AnswerCurrentModeItemGradesBatchUseCase(
        repository: repo,
        flowStrategyFactory: factory,
        modeStrategyFactory: modeFactory,
      ),
      answerMatchBatch: AnswerCurrentMatchModeBatchUseCase(
        repository: repo,
        flowStrategyFactory: factory,
        modeStrategyFactory: modeFactory,
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
  final TestClock clock;
  final StartStudySessionUseCase start;
  final ResumeStudySessionUseCase resume;
  final AnswerFlashcardUseCase answer;
  final AnswerCurrentModeBatchUseCase answerBatch;
  final AnswerCurrentModeItemGradesBatchUseCase answerModeItemBatch;
  final AnswerCurrentMatchModeBatchUseCase answerMatchBatch;
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

  Future<StudySessionSnapshot> startOneCardNewStudy() {
    return start.execute(
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
  }

  Future<void> setSessionStatus({
    required String sessionId,
    required SessionStatus status,
  }) {
    return (database.update(
      database.studySessions,
    )..where((table) => table.id.equals(sessionId))).write(
      StudySessionsCompanion(
        status: Value(status.storageValue),
        endedAt: Value(clock.nowEpochMillis()),
      ),
    );
  }

  Future<void> dispose() => database.close();
}
