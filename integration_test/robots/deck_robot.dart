import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/dialogs/mx_destination_picker_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_deck_card.dart';
import 'package:memox/presentation/shared/widgets/mx_study_set_tile.dart';

import 'memox_robot.dart';

final class DeckRobot extends MemoxRobot {
  const DeckRobot(super.tester);

  static const double _deckTileBodyTapInset = 72;

  Future<void> openCreateDeckDialog() async {
    await _openCreateDeck();
    await waitUntilVisible(find.text('Create deck'));
    await waitUntilVisible(find.text('Deck name'));
  }

  Future<void> enterDeckName(String name) async {
    await enterText(find.byType(TextField).last, name);
  }

  Future<void> confirmDeckCreation({String? expectedName}) async {
    await tapVisible(find.text('Create').last);
    await waitUntilAbsent(find.text('Create deck'));
    if (expectedName != null) {
      await waitUntilVisible(find.text(expectedName));
    }
  }

  Future<void> createDeck(String name) async {
    await openCreateDeckDialog();
    await enterDeckName(name);
    await confirmDeckCreation(expectedName: name.trim());
  }

  Future<void> cancelDeckCreation(String name) async {
    await openCreateDeckDialog();
    await enterDeckName(name);
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Create deck'));
    await waitUntilAbsent(find.text(name));
  }

  Future<void> expectCreateDeckConfirmDisabled() async {
    final confirmButton = find.ancestor(
      of: find.text('Create').last,
      matching: find.byType(ElevatedButton),
    );
    await waitUntilVisible(confirmButton);
    expect(tester.widget<ElevatedButton>(confirmButton).onPressed, isNull);
  }

  Future<void> expectDeckVisible(String name) async {
    await waitUntilVisible(find.text(name));
  }

  Future<void> expectDeckAbsent(String name) async {
    await waitUntilAbsent(find.text(name));
  }

  Future<void> expectDeckRowBasics({
    required String name,
    required int cardCount,
  }) async {
    await expectDeckVisible(name);
    await waitUntilVisible(find.text(_cardCountLabel(cardCount)));
  }

  Future<void> expectDeckActionsAvailable(String name) async {
    await _openVisibleDeckActions(name);
    await waitUntilVisible(find.text('Edit'));
    await waitUntilVisible(find.text('Move'));
    await waitUntilVisible(find.text('Duplicate'));
    await waitUntilVisible(find.text('Delete'));
  }

  Future<void> expectDecksInOrder(List<String> names) async {
    for (final name in names) {
      await waitUntilVisible(find.text(name));
    }

    final positions = [
      for (final name in names) tester.getTopLeft(find.text(name).first).dy,
    ];
    final sortedPositions = [...positions]..sort();
    expect(positions, sortedPositions);
  }

  Future<void> openDeck(String name) async {
    await _tapDeckTileBody(name);
    await waitUntilVisible(find.byTooltip('Add flashcard'));
  }

  Future<void> openDeckWithFlashcard({
    required String deckName,
    required String flashcardFront,
  }) async {
    await _tapDeckTileBody(deckName);
    await waitUntilVisible(find.text(deckName));
    await waitUntilVisible(find.text(flashcardFront));
  }

  Future<void> tapBackToFolder(String folderName) async {
    await tapVisible(find.byTooltip('Back'));
    await waitUntilVisible(find.text(folderName));
    await waitUntilVisible(find.byTooltip('More actions'));
  }

  Future<void> openVisibleDeckRenameDialog(String name) async {
    await _openVisibleDeckActions(name);
    await tapVisible(find.text('Edit'));
    await waitUntilVisible(find.text('Rename deck'));
    await waitUntilVisible(find.text('Deck name'));
  }

  Future<void> renameVisibleDeck({
    required String from,
    required String to,
  }) async {
    await openVisibleDeckRenameDialog(from);
    await enterDeckName(to);
    await tapVisible(find.text('Save').last);
    await waitUntilAbsent(find.text('Rename deck'));
    await waitUntilVisible(find.text(to));
    expect(find.text(from), findsNothing);
  }

  Future<void> cancelRenameVisibleDeck({
    required String from,
    required String attemptedName,
  }) async {
    await openVisibleDeckRenameDialog(from);
    await enterDeckName(attemptedName);
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Rename deck'));
    await waitUntilVisible(find.text(from));
    expect(find.text(attemptedName), findsNothing);
  }

  Future<void> expectRenameConfirmDisabled() async {
    final confirmButton = find.ancestor(
      of: find.text('Save').last,
      matching: find.byType(ElevatedButton),
    );
    await waitUntilVisible(confirmButton);
    expect(tester.widget<ElevatedButton>(confirmButton).onPressed, isNull);
  }

  Future<void> renameCurrentDeck({
    required String from,
    required String to,
  }) async {
    await tapVisible(find.byTooltip('More actions').last);
    await waitUntilVisible(find.text('Deck actions'));
    await tapVisible(find.text('Edit'));
    await waitUntilVisible(find.text('Rename deck'));
    await enterText(find.byType(TextField).last, to);
    await tapVisible(find.text('Save').last);
    await waitUntilAbsent(find.text('Rename deck'));
    await waitUntilVisible(find.text(to));
    expect(find.text(from), findsNothing);
  }

  Future<void> cancelRenameCurrentDeck({
    required String from,
    required String attemptedName,
  }) async {
    await tapVisible(find.byTooltip('More actions').last);
    await waitUntilVisible(find.text('Deck actions'));
    await tapVisible(find.text('Edit'));
    await waitUntilVisible(find.text('Rename deck'));
    await enterText(find.byType(TextField).last, attemptedName);
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Rename deck'));
    await waitUntilVisible(find.text(from));
    expect(find.text(attemptedName), findsNothing);
  }

  Future<void> duplicateVisibleDeckToCurrentFolder({
    required String sourceName,
    required String duplicatedName,
  }) async {
    await duplicateVisibleDeckToDestination(
      sourceName: sourceName,
      destinationName: 'Current folder',
      duplicatedName: duplicatedName,
    );
  }

  Future<void> duplicateVisibleDeckToDestination({
    required String sourceName,
    required String destinationName,
    required String duplicatedName,
  }) async {
    await _openVisibleDeckActions(sourceName);
    await tapVisible(find.text('Duplicate'));
    await waitUntilVisible(find.text('Duplicate deck'));
    await waitUntilVisible(_destinationPicker());
    await tapVisible(_moveDestinationText(destinationName).last);
    await waitUntilAbsent(find.text('Duplicate deck'));
    await waitUntilVisible(find.text(duplicatedName));
  }

  Future<void> duplicateCurrentDeckToCurrentFolder({
    required String sourceName,
    required String duplicatedName,
  }) async {
    await tapVisible(find.byTooltip('More actions').last);
    await waitUntilVisible(find.text('Deck actions'));
    await tapVisible(find.text('Duplicate deck'));
    await waitUntilVisible(find.text('Duplicate deck'));
    await tapVisible(find.text('Current folder'));
    await waitUntilAbsent(find.text('Duplicate deck'));
    await waitUntilVisible(find.text(duplicatedName));
    expect(find.text(sourceName), findsNothing);
  }

  Future<void> deleteVisibleDeck(String name) async {
    await _openVisibleDeckDeleteDialog(name);
    await tapVisible(find.text('Delete').last);
    await waitUntilAbsent(find.text('Delete deck'));
    await waitUntilAbsent(find.text(name));
  }

  Future<void> cancelDeleteVisibleDeck(String name) async {
    await _openVisibleDeckDeleteDialog(name);
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Delete deck'));
    await waitUntilVisible(find.text(name));
  }

  Future<void> deleteCurrentDeck(String name) async {
    await tapVisible(find.byTooltip('More actions').last);
    await waitUntilVisible(find.text('Deck actions'));
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete deck'));
    await tapVisible(find.text('Delete').last);
    await waitUntilAbsent(find.text('Delete deck'));
    await waitUntilAbsent(find.text(name));
  }

  Future<void> cancelDeleteCurrentDeck(String name) async {
    await tapVisible(find.byTooltip('More actions').last);
    await waitUntilVisible(find.text('Deck actions'));
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete deck'));
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Delete deck'));
    await waitUntilVisible(find.text(name));
  }

  Future<void> openCurrentFolderReorderMode() async {
    await tapVisible(find.byTooltip('More actions').first);
    await waitUntilVisible(find.text('Folder actions'));
    await tapVisible(find.text('Reorder'));
    await waitUntilVisible(find.text('Save order'));
  }

  Future<void> dragDeckToTop(String name) async {
    final tile = _deckTile(name);
    await waitUntilVisible(tile);
    await tester.ensureVisible(tile);
    await tester.pump(const Duration(milliseconds: 100));
    await waitUntilVisible(find.byType(ReorderableListView));

    final tileRect = tester.getRect(tile);
    final listRect = tester.getRect(find.byType(ReorderableListView).last);
    final start = _dragHandleCenterFor(tileRect);
    final endY = listRect.top - tileRect.height;
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

  Future<void> openVisibleDeckMoveDialog(String name) async {
    await _openVisibleDeckActions(name);
    await tapVisible(find.text('Move'));
    await waitUntilVisible(find.text('Move deck'));
    await waitUntilVisible(_destinationPicker());
  }

  Future<void> moveVisibleDeckTo({
    required String deckName,
    required String destinationName,
  }) async {
    await openVisibleDeckMoveDialog(deckName);
    await selectMoveDestination(destinationName);
    await waitUntilAbsent(find.text('Move deck'));
  }

  Future<void> expectMoveDestinationVisible(String name) async {
    await waitUntilVisible(_moveDestinationText(name));
  }

  Future<void> expectMoveDestinationAbsent(String name) async {
    expect(_moveDestinationText(name), findsNothing);
  }

  Future<void> expectNoValidMoveDestinationFound() async {
    await waitUntilVisible(find.text('No valid destination found.'));
  }

  Future<void> selectMoveDestination(String name) async {
    await tapVisible(_moveDestinationText(name).last);
  }

  Future<void> tapVisibleDeckStudyAction(String deckId) async {
    final action = find.byKey(ValueKey<String>('deck_study_$deckId'));
    await waitUntilVisible(action);
    final tappable = find.descendant(
      of: action,
      matching: find.byType(InkWell),
    );
    await tapVisible(tappable);
    await waitUntilVisible(find.text('Start a study session'));
  }

  Future<void> startStudyFromDeckDetail() async {
    await tapVisible(find.text('Study this deck'));
    await waitUntilVisible(find.text('Start a study session'));
  }

  Future<void> searchDecks(String text) => searchFor(text);

  Future<void> clearDeckSearch() => clearSearch();

  Future<void> _openVisibleDeckActions(String name) async {
    await longPressVisible(_deckTile(name));
    await waitUntilVisible(find.text('Deck actions'));
  }

  Future<void> _openVisibleDeckDeleteDialog(String name) async {
    await _openVisibleDeckActions(name);
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete deck'));
  }

  Future<void> _openCreateDeck() async {
    final textButton = find.text('New deck');
    if (textButton.evaluate().isNotEmpty) {
      await tapVisible(textButton.last);
      return;
    }

    await tapFloatingActionButton();
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Create deck').evaluate().isNotEmpty) {
        return;
      }
      final createChoice = find.text('New deck');
      if (createChoice.evaluate().isNotEmpty) {
        await tapVisible(createChoice.last);
        return;
      }
    }
    fail('Timed out opening deck creation');
  }

  Finder _deckTile(String name) => find.ancestor(
      of: find.text(name),
      matching: find.byWidgetPredicate(
        (widget) => widget is MxDeckCard || widget is MxStudySetTile,
      ),
    );

  Finder _destinationPicker() => find.byWidgetPredicate(
      (widget) => widget is MxDestinationPickerSheet<Object?>,
    );

  Finder _moveDestinationText(String name) => find.descendant(of: _destinationPicker(), matching: find.text(name));

  String _cardCountLabel(int count) {
    if (count == 1) {
      return '1 card';
    }
    return '$count cards';
  }

  Offset _dragHandleCenterFor(Rect tileRect) {
    final handles = find.byIcon(Icons.drag_handle);
    for (var index = 0; index < handles.evaluate().length; index++) {
      final handle = handles.at(index);
      final handleRect = tester.getRect(handle);
      final isSameRow =
          (handleRect.center.dy - tileRect.center.dy).abs() <
          tileRect.height / 2;
      if (isSameRow) {
        return handleRect.center;
      }
    }
    return Offset(tileRect.right - 24, tileRect.center.dy);
  }

  Future<void> _tapDeckTileBody(String name) async {
    final tile = _deckTile(name);
    await waitUntilVisible(tile);
    await tester.ensureVisible(tile);
    await tester.pump(const Duration(milliseconds: 100));
    final target = await _waitUntilTappable(tile);
    final rect = tester.getRect(target);
    final bodyX = rect.width > _deckTileBodyTapInset
        ? rect.left + _deckTileBodyTapInset
        : rect.center.dx;
    await tester.tapAt(Offset(bodyX, rect.center.dy));
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<Finder> _waitUntilTappable(Finder finder, {int maxPumps = 60}) async {
    for (var attempt = 0; attempt < maxPumps; attempt++) {
      final target = finder.hitTestable();
      if (target.evaluate().isNotEmpty) {
        return target.first;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
    fail('Timed out waiting for tappable $finder');
  }
}
