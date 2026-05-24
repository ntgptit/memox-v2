import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../robots/deck_robot.dart';
import '../robots/flashcard_robot.dart';
import '../robots/folder_robot.dart';
import '../robots/study_robot.dart';
import '../test_app.dart';

void registerFlashcardFlowTests() {
  group('Flashcard flow', () {
    testWidgets(
      'DT1 onDisplay: shows empty state for a deck without flashcards',
      (tester) async {
        final h = await _pumpFlashcardFlow(
          tester,
          seedData: (app) => app.seedDeckWithoutFlashcards(
            folderId: 'folder-korean',
            deckId: 'deck-daily',
            folderName: 'Korean',
            deckName: 'Daily Words',
          ),
        );

        await h.folder.openFolderFromLibrary('Korean');
        await h.deck.openDeck('Daily Words');

        await h.flashcards.expectEmptyDeck();
      },
    );

    testWidgets('DT2 onDisplay: shows flashcards in manual order', (
      tester,
    ) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
          _SeedCard(
            id: 'card-school',
            front: '학교',
            back: 'trường học',
            sortOrder: 1,
          ),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');

      await h.flashcards.expectFlashcardsInOrder(['사과', '학교']);
    });

    testWidgets('DT3 onDisplay: shows only flashcards from the opened deck', (
      tester,
    ) async {
      final h = await _pumpFlashcardFlow(
        tester,
        seedData: (app) async {
          await app.seedRootFolder(
            folderId: 'folder-korean',
            folderName: 'Korean',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-korean',
            deckId: 'deck-a',
            deckName: 'A',
          );
          await app.seedDeckInFolder(
            folderId: 'folder-korean',
            deckId: 'deck-b',
            deckName: 'B',
            sortOrder: 1,
          );
          await app.seedFlashcardInDeck(
            deckId: 'deck-a',
            flashcardId: 'card-apple',
            front: '사과',
            back: 'quả táo',
          );
          await app.seedFlashcardInDeck(
            deckId: 'deck-b',
            flashcardId: 'card-school',
            front: '학교',
            back: 'trường học',
          );
        },
      );

      await h.folder.openFolderFromLibrary('Korean');
      await h.deck.openDeckWithFlashcard(deckName: 'A', flashcardFront: '사과');

      await h.flashcards.expectFlashcardVisible('사과');
      await h.flashcards.expectFlashcardAbsent('학교');
    });

    testWidgets('DT1 onInsert: creates a flashcard with front and back', (
      tester,
    ) async {
      final h = await _pumpEmptyDailyDeck(tester);

      await _openEmptyDailyDeck(h);
      await h.flashcards.createFlashcard(front: '사과', back: 'quả táo');

      await h.flashcards.expectFlashcardVisible('사과');
    });

    testWidgets('DT2 onInsert: creates a flashcard with a note', (
      tester,
    ) async {
      final h = await _pumpEmptyDailyDeck(tester);

      await _openEmptyDailyDeck(h);
      await h.flashcards.createFlashcard(
        front: '먹다',
        back: 'ăn',
        note: 'Động từ bất quy tắc không đặc biệt',
      );
      await h.flashcards.openFlashcardForEdit('먹다');

      await h.flashcards.expectCurrentEditorFields(
        front: '먹다',
        back: 'ăn',
        note: 'Động từ bất quy tắc không đặc biệt',
      );
    });

    testWidgets('DT3 onInsert: creates a flashcard without a note', (
      tester,
    ) async {
      final h = await _pumpEmptyDailyDeck(tester);

      await _openEmptyDailyDeck(h);
      await h.flashcards.createFlashcard(front: '학교', back: 'trường học');

      await h.flashcards.expectFlashcardVisible('학교');
    });

    testWidgets('DT4 onInsert: rejects create when front is empty', (
      tester,
    ) async {
      final h = await _pumpEmptyDailyDeck(tester);

      await _openEmptyDailyDeck(h);
      await h.flashcards.attemptCreateAndExpectRequiredError(
        front: '',
        back: 'quả táo',
      );
    });

    testWidgets('DT5 onInsert: rejects create when back is empty', (
      tester,
    ) async {
      final h = await _pumpEmptyDailyDeck(tester);

      await _openEmptyDailyDeck(h);
      await h.flashcards.attemptCreateAndExpectRequiredError(
        front: '사과',
        back: '',
      );
    });

    testWidgets('DT6 onInsert: rejects create when front is whitespace', (
      tester,
    ) async {
      final h = await _pumpEmptyDailyDeck(tester);

      await _openEmptyDailyDeck(h);
      await h.flashcards.attemptCreateAndExpectRequiredError(
        front: '   ',
        back: 'quả táo',
      );
    });

    testWidgets('DT7 onInsert: rejects create when back is whitespace', (
      tester,
    ) async {
      final h = await _pumpEmptyDailyDeck(tester);

      await _openEmptyDailyDeck(h);
      await h.flashcards.attemptCreateAndExpectRequiredError(
        front: '사과',
        back: '   ',
      );
    });

    testWidgets('DT8 onInsert: trims front back and note on create', (
      tester,
    ) async {
      final h = await _pumpEmptyDailyDeck(tester);

      await _openEmptyDailyDeck(h);
      await h.flashcards.createFlashcard(
        front: '  사과  ',
        back: '  quả táo  ',
        note: '  danh từ  ',
        expectedFront: '사과',
        expectedBack: 'quả táo',
        expectedNote: 'danh từ',
      );
      await h.flashcards.openFlashcardForEdit('사과');

      await h.flashcards.expectCurrentEditorFields(
        front: '사과',
        back: 'quả táo',
        note: 'danh từ',
      );
    });

    testWidgets('DT9 onInsert: imports valid CSV flashcards', (tester) async {
      final h = await _pumpEmptyDailyDeck(tester);

      await _openEmptyDailyDeck(h);
      await h.flashcards.importCsv(
        csv: 'front,back\nA,alpha\nB,beta\nC,gamma',
        expectedCount: 3,
        expectedFronts: ['A', 'B', 'C'],
      );
    });

    testWidgets(
      'DT10 onInsert: blocks CSV import while validation issues remain',
      (tester) async {
        final h = await _pumpEmptyDailyDeck(tester);

        await _openEmptyDailyDeck(h);
        await h.flashcards.previewCsvWithIssue('front,back\nA,alpha\nBroken,');
      },
    );

    testWidgets('DT11 onInsert: keeps imported CSV order', (tester) async {
      final h = await _pumpEmptyDailyDeck(tester);

      await _openEmptyDailyDeck(h);
      await h.flashcards.importCsv(
        csv: 'front,back\nA,alpha\nB,beta\nC,gamma',
        expectedCount: 3,
        expectedFronts: ['A', 'B', 'C'],
      );

      await h.flashcards.expectFlashcardsInOrder(['A', 'B', 'C']);
    });

    testWidgets('DT1 onNavigate: opens flashcard edit detail from row tap', (
      tester,
    ) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.openFlashcardForEdit('사과');

      await h.flashcards.expectCurrentEditorFields(
        front: '사과',
        back: 'quả táo',
      );
    });

    testWidgets('DT2 onNavigate: opens flashcard without stale note text', (
      tester,
    ) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.openFlashcardForEdit('사과');

      await h.flashcards.expectCurrentEditorFields(
        front: '사과',
        back: 'quả táo',
      );
      expect(find.text('null'), findsNothing);
      expect(find.text('old note'), findsNothing);
    });

    testWidgets(
      'DT3 onNavigate: opens long flashcard content without overflow',
      (tester) async {
        const longFront = '아주 긴 한국어 문장으로 만든 앞면 내용이 여러 줄로 표시될 수 있습니다';
        const longBack =
            'Một mặt sau rất dài\ncó nhiều dòng\nđể kiểm tra khả năng cuộn.';
        final h = await _pumpDailyDeck(
          tester,
          cards: const [
            _SeedCard(
              id: 'card-long',
              front: longFront,
              back: longBack,
              note: 'Ghi chú dài để kiểm tra vùng nội dung có thể cuộn.',
            ),
          ],
        );

        await _openDailyDeckWithCard(h, longFront);
        await h.flashcards.openFlashcardForEdit(longFront);

        await h.flashcards.expectCurrentEditorFields(
          front: longFront,
          back: longBack,
          note: 'Ghi chú dài để kiểm tra vùng nội dung có thể cuộn.',
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT4 onNavigate: starts study when deck has flashcards', (
      tester,
    ) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.deck.startStudyFromDeckDetail();
      await h.study.startDefaultStudyFromEntry();

      await h.study.expectStudySessionVisible(front: '사과', back: 'quả táo');
    });

    testWidgets('DT5 onNavigate: keeps study disabled for an empty deck', (
      tester,
    ) async {
      final h = await _pumpEmptyDailyDeck(tester, deckName: 'Empty Deck');

      await h.folder.openFolderFromLibrary('Korean');
      await h.deck.openDeck('Empty Deck');

      await h.flashcards.expectStudyUnavailable();
    });

    testWidgets('DT6 onNavigate: studies a newly created flashcard', (
      tester,
    ) async {
      final h = await _pumpEmptyDailyDeck(tester);

      await _openEmptyDailyDeck(h);
      await h.flashcards.createFlashcard(front: '학교', back: 'trường học');
      await h.flashcards.startStudyThisDeck();
      await h.study.startDefaultStudyFromEntry();

      await h.study.expectStudySessionVisible(front: '학교', back: 'trường học');
    });

    testWidgets('DT7 onNavigate: excludes a deleted flashcard from study', (
      tester,
    ) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
          _SeedCard(
            id: 'card-school',
            front: '학교',
            back: 'trường học',
            sortOrder: 1,
          ),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.deleteFlashcard('사과');
      await h.flashcards.startStudyThisDeck();
      await h.study.startDefaultStudyFromEntry();

      await h.study.expectStudySessionVisible(front: '학교', back: 'trường học');
      await h.study.expectStudySessionAbsent('사과');
    });

    testWidgets('DT8 onNavigate: uses edited flashcard content in study', (
      tester,
    ) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.openFlashcardForEdit('사과');
      await h.flashcards.updateCurrentFlashcard(
        fromFront: '사과',
        toFront: '빨간 사과',
        toBack: 'quả táo đỏ',
      );
      await h.flashcards.startStudyThisDeck();
      await h.study.startDefaultStudyFromEntry();

      await h.study.expectStudySessionVisible(
        front: '빨간 사과',
        back: 'quả táo đỏ',
      );
      await h.study.expectStudySessionAbsent('사과');
    });

    testWidgets('DT1 onUpdate: edits flashcard front and back', (tester) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.openFlashcardForEdit('사과');
      await h.flashcards.updateCurrentFlashcard(
        fromFront: '사과',
        toFront: '빨간 사과',
        toBack: 'quả táo đỏ',
      );
      await h.flashcards.openFlashcardForEdit('빨간 사과');

      await h.flashcards.expectCurrentEditorFields(
        front: '빨간 사과',
        back: 'quả táo đỏ',
      );
    });

    testWidgets('DT2 onUpdate: edits flashcard note', (tester) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-eat', front: '먹다', back: 'ăn', note: 'old note'),
        ],
      );

      await _openDailyDeckWithCard(h, '먹다');
      await h.flashcards.openFlashcardForEdit('먹다');
      await h.flashcards.updateCurrentFlashcard(
        fromFront: '먹다',
        toFront: '먹다',
        toBack: 'ăn',
        toNote: 'new note',
      );
      await h.flashcards.openFlashcardForEdit('먹다');

      await h.flashcards.expectCurrentEditorFields(
        front: '먹다',
        back: 'ăn',
        note: 'new note',
      );
    });

    testWidgets('DT3 onUpdate: clears flashcard note', (tester) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(
            id: 'card-eat',
            front: '먹다',
            back: 'ăn',
            note: 'ghi chú cũ',
          ),
        ],
      );

      await _openDailyDeckWithCard(h, '먹다');
      await h.flashcards.openFlashcardForEdit('먹다');
      await h.flashcards.updateCurrentFlashcard(
        fromFront: '먹다',
        toFront: '먹다',
        toBack: 'ăn',
        toNote: '',
      );
      await h.flashcards.openFlashcardForEdit('먹다');

      await h.flashcards.expectCurrentEditorFields(front: '먹다', back: 'ăn');
      expect(find.text('ghi chú cũ'), findsNothing);
    });

    testWidgets('DT4 onUpdate: rejects edit when front is empty', (
      tester,
    ) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.openFlashcardForEdit('사과');

      await h.flashcards.attemptEditAndExpectRequiredError(
        front: '',
        back: 'quả táo',
      );
    });

    testWidgets('DT5 onUpdate: rejects edit when back is empty', (
      tester,
    ) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.openFlashcardForEdit('사과');

      await h.flashcards.attemptEditAndExpectRequiredError(
        front: '사과',
        back: '',
      );
    });

    testWidgets('DT6 onUpdate: cancels edit without changing data', (
      tester,
    ) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.openFlashcardForEdit('사과');
      await h.flashcards.enterCurrentDraft(front: '수박', back: 'quả táo');
      await h.flashcards.cancelCurrentEdit();

      await h.flashcards.expectFlashcardVisible('사과');
      await h.flashcards.expectFlashcardAbsent('수박');
    });

    testWidgets('DT1 onDelete: cancels flashcard deletion', (tester) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.cancelDeleteFlashcard('사과');

      await h.flashcards.expectFlashcardVisible('사과');
    });

    testWidgets('DT2 onDelete: deletes a flashcard after confirmation', (
      tester,
    ) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
          _SeedCard(
            id: 'card-school',
            front: '학교',
            back: 'trường học',
            sortOrder: 1,
          ),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.deleteFlashcard('사과');

      await h.flashcards.expectFlashcardAbsent('사과');
      await h.flashcards.expectFlashcardVisible('학교');
    });

    testWidgets(
      'DT3 onDelete: returns to empty state after deleting last card',
      (tester) async {
        final h = await _pumpDailyDeck(
          tester,
          cards: const [
            _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
          ],
        );

        await _openDailyDeckWithCard(h, '사과');
        await h.flashcards.deleteFlashcard('사과', expectEmptyState: true);
      },
    );

    testWidgets('DT1 onMove: reorders flashcards in the current deck', (
      tester,
    ) async {
      final h = await _pumpOrderedCards(tester);

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.openReorderMode();
      await h.flashcards.dragFlashcardToTop('먹다');
      await h.flashcards.saveReorder();

      await h.flashcards.expectFlashcardsInOrder(['먹다', '사과', '학교']);
    });

    testWidgets(
      'DT2 onMove: keeps reordered flashcards after leaving and reopening',
      (tester) async {
        final h = await _pumpOrderedCards(tester);

        await _openDailyDeckWithCard(h, '사과');
        await h.flashcards.openReorderMode();
        await h.flashcards.dragFlashcardToTop('먹다');
        await h.flashcards.saveReorder();
        await h.flashcards.tapBackToFolder('Korean');
        await h.deck.openDeckWithFlashcard(
          deckName: 'Daily Words',
          flashcardFront: '먹다',
        );

        await h.flashcards.expectFlashcardsInOrder(['먹다', '사과', '학교']);
      },
    );

    testWidgets('DT3 onMove: keeps reordered flashcards after restart', (
      tester,
    ) async {
      final databaseFile = await createIntegrationTestDatabaseFile();
      final h = await _pumpOrderedCards(tester, databaseFile: databaseFile);

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.openReorderMode();
      await h.flashcards.dragFlashcardToTop('먹다');
      await h.flashcards.saveReorder();
      await restartTestApp(
        tester,
        h.app,
        surfaceSize: integrationTestCompactSurfaceSize,
      );
      await h.folder.openFolderFromLibrary('Korean');
      await h.deck.openDeckWithFlashcard(
        deckName: 'Daily Words',
        flashcardFront: '먹다',
      );

      await h.flashcards.expectFlashcardsInOrder(['먹다', '사과', '학교']);
    });

    testWidgets('DT1 onSearchFilterSort: searches flashcards by front', (
      tester,
    ) async {
      final h = await _pumpOrderedCards(tester);

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.searchFlashcards('사과');

      await h.flashcards.expectFlashcardVisible('사과');
      await h.flashcards.expectFlashcardAbsent('학교');
      await h.flashcards.expectFlashcardAbsent('먹다');
    });

    testWidgets('DT2 onSearchFilterSort: searches flashcards by back', (
      tester,
    ) async {
      final h = await _pumpDailyDeck(
        tester,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.searchFlashcards('táo');

      await h.flashcards.expectFlashcardVisible('사과');
    });

    testWidgets(
      'DT3 onSearchFilterSort: shows empty state for no search match',
      (tester) async {
        final h = await _pumpDailyDeck(
          tester,
          cards: const [
            _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
          ],
        );

        await _openDailyDeckWithCard(h, '사과');
        await h.flashcards.searchFlashcards('xyz-not-found');

        await h.flashcards.expectEmptyDeck();
        await h.flashcards.expectFlashcardAbsent('사과');
      },
    );

    testWidgets('DT4 onSearchFilterSort: clears flashcard search', (
      tester,
    ) async {
      final h = await _pumpOrderedCards(tester);

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.searchFlashcards('사과');
      await h.flashcards.expectFlashcardAbsent('학교');
      await h.flashcards.clearFlashcardSearch();

      await h.flashcards.expectFlashcardsInOrder(['사과', '학교', '먹다']);
    });

    testWidgets('DT1 onExternalChange: keeps created flashcard after restart', (
      tester,
    ) async {
      final databaseFile = await createIntegrationTestDatabaseFile();
      final h = await _pumpEmptyDailyDeck(tester, databaseFile: databaseFile);

      await _openEmptyDailyDeck(h);
      await h.flashcards.createFlashcard(front: '사과', back: 'quả táo');
      await restartTestApp(
        tester,
        h.app,
        surfaceSize: integrationTestCompactSurfaceSize,
      );
      await h.folder.openFolderFromLibrary('Korean');
      await h.deck.openDeckWithFlashcard(
        deckName: 'Daily Words',
        flashcardFront: '사과',
      );

      await h.flashcards.expectFlashcardVisible('사과');
    });

    testWidgets('DT2 onExternalChange: keeps edited flashcard after restart', (
      tester,
    ) async {
      final databaseFile = await createIntegrationTestDatabaseFile();
      final h = await _pumpDailyDeck(
        tester,
        databaseFile: databaseFile,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.openFlashcardForEdit('사과');
      await h.flashcards.updateCurrentFlashcard(
        fromFront: '사과',
        toFront: '빨간 사과',
        toBack: 'quả táo đỏ',
      );
      await restartTestApp(
        tester,
        h.app,
        surfaceSize: integrationTestCompactSurfaceSize,
      );
      await h.folder.openFolderFromLibrary('Korean');
      await h.deck.openDeckWithFlashcard(
        deckName: 'Daily Words',
        flashcardFront: '빨간 사과',
      );

      await h.flashcards.expectFlashcardVisible('빨간 사과');
    });

    testWidgets('DT3 onExternalChange: keeps deleted flashcard after restart', (
      tester,
    ) async {
      final databaseFile = await createIntegrationTestDatabaseFile();
      final h = await _pumpDailyDeck(
        tester,
        databaseFile: databaseFile,
        cards: const [
          _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
        ],
      );

      await _openDailyDeckWithCard(h, '사과');
      await h.flashcards.deleteFlashcard('사과', expectEmptyState: true);
      await restartTestApp(
        tester,
        h.app,
        surfaceSize: integrationTestCompactSurfaceSize,
      );
      await h.folder.openFolderFromLibrary('Korean');
      await h.deck.openDeck('Daily Words');

      await h.flashcards.expectFlashcardAbsent('사과');
      await h.flashcards.expectEmptyDeck();
    });
  });
}

Future<_FlashcardFlowHarness> _pumpEmptyDailyDeck(
  WidgetTester tester, {
  String deckName = 'Daily Words',
  File? databaseFile,
}) => _pumpFlashcardFlow(
    tester,
    databaseFile: databaseFile,
    seedData: (app) => app.seedDeckWithoutFlashcards(
      folderId: 'folder-korean',
      deckId: 'deck-daily',
      folderName: 'Korean',
      deckName: deckName,
    ),
  );

Future<_FlashcardFlowHarness> _pumpDailyDeck(
  WidgetTester tester, {
  required List<_SeedCard> cards,
  File? databaseFile,
}) => _pumpFlashcardFlow(
    tester,
    databaseFile: databaseFile,
    seedData: (app) => _seedDailyDeck(app, cards: cards),
  );

Future<_FlashcardFlowHarness> _pumpOrderedCards(
  WidgetTester tester, {
  File? databaseFile,
}) => _pumpDailyDeck(
    tester,
    databaseFile: databaseFile,
    cards: const [
      _SeedCard(id: 'card-apple', front: '사과', back: 'quả táo'),
      _SeedCard(
        id: 'card-school',
        front: '학교',
        back: 'trường học',
        sortOrder: 1,
      ),
      _SeedCard(id: 'card-eat', front: '먹다', back: 'ăn', sortOrder: 2),
    ],
  );

Future<_FlashcardFlowHarness> _pumpFlashcardFlow(
  WidgetTester tester, {
  File? databaseFile,
  Future<void> Function(IntegrationTestAppHandle app)? seedData,
}) async {
  final app = await pumpTestApp(
    tester,
    surfaceSize: integrationTestCompactSurfaceSize,
    databaseFile: databaseFile,
    seedData: seedData,
  );
  return _FlashcardFlowHarness(
    app: app,
    folder: FolderRobot(tester),
    deck: DeckRobot(tester),
    flashcards: FlashcardRobot(tester),
    study: StudyRobot(tester),
  );
}

Future<void> _seedDailyDeck(
  IntegrationTestAppHandle app, {
  required List<_SeedCard> cards,
}) async {
  await app.seedRootFolder(folderId: 'folder-korean', folderName: 'Korean');
  await app.seedDeckInFolder(
    folderId: 'folder-korean',
    deckId: 'deck-daily',
    deckName: 'Daily Words',
  );
  for (final card in cards) {
    await app.seedFlashcardInDeck(
      deckId: 'deck-daily',
      flashcardId: card.id,
      front: card.front,
      back: card.back,
      note: card.note,
      sortOrder: card.sortOrder,
    );
  }
}

Future<void> _openEmptyDailyDeck(_FlashcardFlowHarness h) async {
  await h.folder.openFolderFromLibrary('Korean');
  await h.deck.openDeck('Daily Words');
}

Future<void> _openDailyDeckWithCard(
  _FlashcardFlowHarness h,
  String flashcardFront,
) async {
  await h.folder.openFolderFromLibrary('Korean');
  await h.deck.openDeckWithFlashcard(
    deckName: 'Daily Words',
    flashcardFront: flashcardFront,
  );
}

final class _FlashcardFlowHarness {
  const _FlashcardFlowHarness({
    required this.app,
    required this.folder,
    required this.deck,
    required this.flashcards,
    required this.study,
  });

  final IntegrationTestAppHandle app;
  final FolderRobot folder;
  final DeckRobot deck;
  final FlashcardRobot flashcards;
  final StudyRobot study;
}

final class _SeedCard {
  const _SeedCard({
    required this.id,
    required this.front,
    required this.back,
    this.note,
    this.sortOrder = 0,
  });

  final String id;
  final String front;
  final String back;
  final String? note;
  final int sortOrder;
}
