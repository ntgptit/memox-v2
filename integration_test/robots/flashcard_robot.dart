import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'memox_robot.dart';

final class FlashcardRobot extends MemoxRobot {
  const FlashcardRobot(super.tester);

  Future<void> expectEmptyDeck() async {
    await waitUntilVisible(find.text('No flashcards yet'));
  }

  Future<void> createFlashcard({
    required String front,
    required String back,
  }) async {
    await tapVisible(find.byTooltip('Add flashcard'));
    await waitUntilVisible(find.text('New flashcard'));
    await enterText(find.byType(TextField).at(0), front);
    await enterText(find.byType(TextField).at(1), back);
    await tapVisible(find.text('Save flashcard'));
    await waitUntilVisible(find.text(front));
    await waitUntilVisible(find.text(back));
  }

  Future<void> saveAndAddNext({
    required String front,
    required String back,
  }) async {
    await tapVisible(find.byTooltip('Add flashcard'));
    await waitUntilVisible(find.text('New flashcard'));
    await enterText(find.byType(TextField).at(0), front);
    await enterText(find.byType(TextField).at(1), back);
    await tapVisible(find.text('Save & add next'));
    await waitUntilVisible(find.text('New flashcard'));
    await waitUntilEditorFieldsCleared();
    expect(find.text(front), findsNothing);
  }

  Future<void> saveCurrentNewFlashcard({
    required String front,
    required String back,
  }) async {
    await waitUntilVisible(find.text('New flashcard'));
    await enterText(find.byType(TextField).at(0), front);
    await enterText(find.byType(TextField).at(1), back);
    await tapVisible(find.text('Save flashcard'));
    await waitUntilAbsent(find.text('New flashcard'));
    await waitUntilVisible(find.text(front));
    await waitUntilVisible(find.text(back));
  }

  Future<void> waitUntilEditorFieldsCleared({int maxPumps = 40}) async {
    for (var attempt = 0; attempt < maxPumps; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      final front = _textFieldTextAt(0);
      final back = _textFieldTextAt(1);
      if (front.isEmpty && back.isEmpty) {
        return;
      }
    }
    fail('Timed out waiting for flashcard editor fields to clear');
  }

  Future<void> attemptBlankCreate() async {
    await tapVisible(find.byTooltip('Add flashcard'));
    await waitUntilVisible(find.text('New flashcard'));
    await tapVisible(find.text('Save flashcard'));
    await waitUntilVisible(find.text('front and back are required.'));
    await waitUntilVisible(find.text('New flashcard'));
  }

  Future<void> openFlashcardForEdit(String front) async {
    await tapVisible(find.text(front));
    await waitUntilVisible(find.text('Edit flashcard'));
  }

  Future<void> updateCurrentFlashcard({
    required String fromFront,
    required String toFront,
    required String toBack,
  }) async {
    await waitUntilVisible(find.text('Edit flashcard'));
    await enterText(find.byType(TextField).at(0), toFront);
    await enterText(find.byType(TextField).at(1), toBack);
    await tapVisible(find.text('Save changes'));
    await waitUntilAbsent(find.text('Edit flashcard'));
    await waitUntilVisible(find.text(toFront));
    await waitUntilVisible(find.text(toBack));
    expect(find.text(fromFront), findsNothing);
  }

  Future<void> deleteFlashcard(String front) async {
    await longPressVisible(find.text(front));
    await waitUntilVisible(find.text('Flashcard actions'));
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete flashcards'));
    await tapVisible(find.text('Delete').last);
    await waitUntilAbsent(find.text('Delete flashcards'));
    await waitUntilAbsent(find.text(front));
    await waitUntilVisible(find.text('No flashcards yet'));
  }

  Future<void> cancelDeleteFlashcard(String front) async {
    await longPressVisible(find.text(front));
    await waitUntilVisible(find.text('Flashcard actions'));
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete flashcards'));
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Delete flashcards'));
    await waitUntilVisible(find.text(front));
  }

  Future<void> selectFlashcard(String front) async {
    await longPressVisible(find.text(front));
    await waitUntilVisible(find.text('Flashcard actions'));
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

  String _textFieldTextAt(int index) {
    final field = tester.widget<TextField>(find.byType(TextField).at(index));
    return field.controller?.text ?? '';
  }
}
