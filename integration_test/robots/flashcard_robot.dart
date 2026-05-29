import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/features/flashcards/widgets/flashcard_detail_card_row.dart';
import 'package:memox/presentation/shared/widgets/mx_term_row.dart';

import 'memox_robot.dart';

final class FlashcardRobot extends MemoxRobot {
  const FlashcardRobot(super.tester);

  static const String _newCardTitle = 'New card';
  static const String _editCardTitle = 'Edit card';
  static const String _saveCardLabel = 'Save card';
  static const String _saveChangesLabel = 'Save changes';

  Future<void> expectEmptyDeck() async {
    await waitUntilVisible(find.text('No flashcards yet'));
    await waitUntilVisible(find.text('Add'));
  }

  Future<void> createFlashcard({
    required String front,
    required String back,
    String? note,
    String? expectedFront,
    String? expectedBack,
    String? expectedNote,
  }) async {
    await openCreateFlashcard();
    await enterCurrentDraft(front: front, back: back, note: note);
    await tapEditorSave();
    await waitUntilAbsent(find.text(_newCardTitle));
    expect(find.text('Flashcard created.'), findsOneWidget);
    await expectFlashcardVisible(expectedFront ?? front.trim());
    await waitUntilVisible(find.text(expectedBack ?? back.trim()));
    if (expectedNote != null) {
      await waitUntilVisible(find.text(expectedNote));
    }
  }

  Future<void> saveAndAddNext({
    required String front,
    required String back,
    String? note,
  }) async {
    await openCreateFlashcard();
    await enterCurrentDraft(front: front, back: back, note: note);
    await tapVisible(find.text('Save + next'));
    await waitUntilVisible(find.text(_newCardTitle));
    await waitUntilEditorFieldsCleared();
    expect(find.text(front), findsNothing);
  }

  Future<void> saveCurrentNewFlashcard({
    required String front,
    required String back,
    String? note,
  }) async {
    await waitUntilVisible(find.text(_newCardTitle));
    await enterCurrentDraft(front: front, back: back, note: note);
    await tapEditorSave();
    await waitUntilAbsent(find.text(_newCardTitle));
    await expectFlashcardVisible(front.trim());
    await waitUntilVisible(find.text(back.trim()));
  }

  Future<void> waitUntilEditorFieldsCleared({int maxPumps = 40}) async {
    for (var attempt = 0; attempt < maxPumps; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      final front = _textFieldTextAt(0);
      final back = _textFieldTextAt(1);
      final note = _textFieldTextAt(2);
      if (front.isEmpty && back.isEmpty && note.isEmpty) {
        return;
      }
    }
    fail('Timed out waiting for flashcard editor fields to clear');
  }

  Future<void> openCreateFlashcard() async {
    await tapVisible(find.byTooltip('Add flashcard'));
    await waitUntilVisible(find.text(_newCardTitle));
  }

  Future<void> enterCurrentDraft({
    required String front,
    required String back,
    String? note,
  }) async {
    await enterText(find.byType(TextField).at(0), front);
    await enterText(find.byType(TextField).at(1), back);
    if (note != null) {
      await enterText(find.byType(TextField).at(2), note);
    }
  }

  Future<void> attemptCreateAndExpectRequiredError({
    required String front,
    required String back,
  }) async {
    await openCreateFlashcard();
    await enterCurrentDraft(front: front, back: back);
    await tapEditorSave();
    await waitUntilVisible(find.text('front and back are required.'));
    await waitUntilVisible(find.text(_newCardTitle));
  }

  Future<void> openFlashcardForEdit(String front) async {
    await scrollToFlashcard(front);
    await tapVisible(_rowText(front).first);
    await waitUntilVisible(find.text(_editCardTitle));
  }

  Future<void> expectCurrentEditorFields({
    required String front,
    required String back,
    String note = '',
  }) async {
    await waitUntilVisible(find.text(_editCardTitle));
    expect(_textFieldTextAt(0), front);
    expect(_textFieldTextAt(1), back);
    expect(_textFieldTextAt(2), note);
  }

  Future<void> updateCurrentFlashcard({
    required String fromFront,
    required String toFront,
    required String toBack,
    String? toNote,
  }) async {
    await waitUntilVisible(find.text(_editCardTitle));
    await enterCurrentDraft(front: toFront, back: toBack, note: toNote);
    await tapEditorSave();
    await waitUntilAbsent(find.text(_editCardTitle));
    await expectFlashcardVisible(toFront.trim());
    await waitUntilVisible(find.text(toBack.trim()));
    if (fromFront != toFront.trim()) {
      expect(find.text(fromFront), findsNothing);
    }
  }

  Future<void> attemptEditAndExpectRequiredError({
    required String front,
    required String back,
    String? note,
  }) async {
    await waitUntilVisible(find.text(_editCardTitle));
    await enterCurrentDraft(front: front, back: back, note: note);
    await tapEditorSave();
    await waitUntilVisible(find.text('front and back are required.'));
    await waitUntilVisible(find.text(_editCardTitle));
  }

  Future<void> cancelCurrentEdit() async {
    await tapVisible(find.byTooltip('Back'));
    await waitUntilAbsent(find.text(_editCardTitle));
  }

  Future<void> deleteFlashcard(
    String front, {
    bool expectEmptyState = false,
  }) async {
    await openFlashcardActions(front);
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete flashcards'));
    await tapVisible(find.text('Delete').last);
    await waitUntilAbsent(find.text('Delete flashcards'));
    await waitUntilAbsent(find.text(front));
    if (expectEmptyState) {
      await expectEmptyDeck();
    }
  }

  Future<void> cancelDeleteFlashcard(String front) async {
    await openFlashcardActions(front);
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete flashcards'));
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Delete flashcards'));
    await expectFlashcardVisible(front);
  }

  Future<void> openFlashcardActions(String front) async {
    await scrollToFlashcard(front);
    await longPressVisible(_rowText(front).first);
    await waitUntilVisible(find.text('Flashcard actions'));
  }

  Future<void> editFlashcardFromActions(String front) async {
    await openFlashcardActions(front);
    await tapVisible(find.text('Edit'));
    await waitUntilVisible(find.text(_editCardTitle));
  }

  Future<void> selectFlashcard(String front) async {
    await openFlashcardActions(front);
    await tapVisible(find.text('Select'));
    await waitUntilVisible(find.text('1 selected'));
  }

  Future<void> bulkDeleteSelected() async {
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete flashcards'));
    await tapVisible(find.text('Delete').last);
    await waitUntilAbsent(find.text('Delete flashcards'));
  }

  Future<void> moveSelectedToDeck(String deckName) async {
    await tapVisible(find.text('Move'));
    await waitUntilVisible(find.text('Move flashcards'));
    await tapVisible(find.text(deckName));
    await waitUntilAbsent(find.text('Move flashcards'));
    await waitUntilVisible(find.text('Flashcards moved.'));
  }

  Future<void> expectFlashcardVisible(String front) async {
    await scrollToFlashcard(front);
    expect(_rowText(front), findsWidgets);
  }

  Future<void> expectFlashcardAbsent(String front) async {
    expect(_rowText(front), findsNothing);
    expect(find.text(front), findsNothing);
  }

  Future<void> expectFlashcardsInOrder(List<String> fronts) async {
    await _scrollToTop();
    await _scrollUntilVisible(_rowText(fronts.first), resetToTop: false);
    for (final front in fronts) {
      await waitUntilVisible(_rowText(front));
    }

    final positions = [
      for (final front in fronts) tester.getTopLeft(_rowText(front).first).dy,
    ];
    final sortedPositions = [...positions]..sort();
    expect(positions, sortedPositions);
  }

  Future<void> openReorderMode() async {
    await _scrollUntilVisible(find.byTooltip('Reorder'));
    await tapVisible(find.byTooltip('Reorder'));
    await waitUntilVisible(find.text('Save order'));
    await waitUntilVisible(find.byType(ReorderableListView));
  }

  Future<void> dragFlashcardToTop(String front) async {
    final row = _termRow(front);
    await waitUntilVisible(row);
    await tester.ensureVisible(row);
    await tester.pump(const Duration(milliseconds: 100));
    await waitUntilVisible(find.byType(ReorderableListView));

    final rowRect = tester.getRect(row);
    final listRect = tester.getRect(find.byType(ReorderableListView).last);
    final start = _dragHandleCenterFor(rowRect);
    final endY = listRect.top - rowRect.height;
    final gesture = await tester.startGesture(start);
    await tester.pump(const Duration(milliseconds: 700));
    await gesture.moveTo(Offset(start.dx, endY));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pumpAndSettle();
  }

  Future<void> saveReorder() async {
    await tapVisible(find.text('Save order'));
    await waitUntilAbsent(find.text('Save order'));
  }

  Future<void> searchFlashcards(String text) => searchFor(text);

  Future<void> clearFlashcardSearch() => clearSearch();

  Future<void> expectStudyUnavailable() async {
    await _scrollUntilVisible(find.text('Study this deck'));
    await waitUntilVisible(
      find.text(
        'Study is available after this deck has at least one flashcard.',
      ),
    );
    final button = find.widgetWithText(ElevatedButton, 'Study this deck');
    await waitUntilVisible(button);
    expect(tester.widget<ElevatedButton>(button).onPressed, isNull);
  }

  Future<void> startStudyThisDeck() async {
    await _scrollUntilVisible(find.text('Study this deck'));
    await tapVisible(find.text('Study this deck'));
    await waitUntilVisible(find.text('Start a study session'));
  }

  Future<void> tapBackToFolder(String folderName) async {
    await _scrollUntilVisible(find.byTooltip('Back'));
    await tapVisible(find.byTooltip('Back'));
    await waitUntilVisible(find.text(folderName));
    await waitUntilVisible(find.byTooltip('More actions'));
  }

  Future<void> importCsv({
    required String csv,
    required int expectedCount,
    required List<String> expectedFronts,
  }) async {
    await openImport();
    await chooseCsvImport();
    await enterText(find.byType(TextField).first, csv);
    await tapVisible(find.text('Preview import'));
    await waitUntilVisible(find.text('$expectedCount valid · 0 issues'));
    await tapVisible(find.text(_importActionLabel(expectedCount)));
    await waitUntilAbsent(find.text('Import flashcards'));
    for (final front in expectedFronts) {
      await expectFlashcardVisible(front);
    }
  }

  Future<void> previewCsvWithIssue(String csv) async {
    await openImport();
    await chooseCsvImport();
    await enterText(find.byType(TextField).first, csv);
    await tapVisible(find.text('Preview import'));
    await waitUntilVisible(find.text('1 valid · 1 issues'));
    await _scrollUntilVisible(find.text('Line 3'));
    await waitUntilVisible(find.text('front and back are required.'));
    expect(find.text('Import 1 card'), findsNothing);
  }

  Future<void> openImport() async {
    await tapVisible(find.byTooltip('Import'));
    await waitUntilVisible(find.text('Import flashcards'));
  }

  Future<void> chooseCsvImport() async {
    await tapVisible(find.text('CSV'));
    await waitUntilVisible(find.text('CSV content'));
  }

  Future<void> tapEditorSave() async {
    final saveCard = find.text(_saveCardLabel);
    if (saveCard.evaluate().isNotEmpty) {
      await tapVisible(saveCard.last);
      return;
    }

    await tapVisible(find.text(_saveChangesLabel).last);
  }

  Future<void> scrollToFlashcard(String front) async {
    await _scrollUntilVisible(_rowText(front));
  }

  Future<void> _scrollUntilVisible(
    Finder finder, {
    int maxDrags = 24,
    bool resetToTop = true,
  }) async {
    if (finder.evaluate().isNotEmpty) {
      await tester.ensureVisible(finder.first);
      await tester.pumpAndSettle();
      return;
    }
    if (resetToTop) {
      await _scrollToTop();
    }
    for (var attempt = 0; attempt < maxDrags; attempt++) {
      if (finder.evaluate().isNotEmpty) {
        await tester.ensureVisible(finder.first);
        await tester.pumpAndSettle();
        return;
      }
      await tester.drag(_verticalScrollable(), const Offset(0, -320));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(finder, findsWidgets);
  }

  Future<void> _scrollToTop() async {
    final scrollable = _verticalScrollable();
    for (var attempt = 0; attempt < 10; attempt++) {
      await tester.drag(scrollable, const Offset(0, 600));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Finder _rowText(String text) => find.descendant(
    of: find.byType(FlashcardDetailCardRow),
    matching: find.text(text),
  );

  Finder _termRow(String term) =>
      find.ancestor(of: find.text(term), matching: find.byType(MxTermRow));

  Finder _verticalScrollable() => find
      .byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      )
      .first;

  Offset _dragHandleCenterFor(Rect rowRect) {
    final handles = find.byIcon(Icons.drag_handle);
    for (var index = 0; index < handles.evaluate().length; index++) {
      final handle = handles.at(index);
      final handleRect = tester.getRect(handle);
      final isSameRow =
          (handleRect.center.dy - rowRect.center.dy).abs() < rowRect.height / 2;
      if (isSameRow) {
        return handleRect.center;
      }
    }
    return Offset(rowRect.right - 24, rowRect.center.dy);
  }

  String _importActionLabel(int count) {
    if (count == 1) {
      return 'Import 1 card';
    }
    return 'Import $count cards';
  }

  String _textFieldTextAt(int index) {
    final field = tester.widget<TextField>(find.byType(TextField).at(index));
    return field.controller?.text ?? '';
  }
}
