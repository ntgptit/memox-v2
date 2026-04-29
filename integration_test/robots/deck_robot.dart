import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'memox_robot.dart';

final class DeckRobot extends MemoxRobot {
  const DeckRobot(super.tester);

  Future<void> createDeck(String name) async {
    await _openCreateDeck();
    await waitUntilVisible(find.text('Create deck'));
    await enterText(find.byType(TextField).last, name);
    await tapVisible(find.text('Create').last);
    await waitUntilAbsent(find.text('Create deck'));
    await waitUntilVisible(find.text(name));
  }

  Future<void> cancelDeckCreation(String name) async {
    await _openCreateDeck();
    await waitUntilVisible(find.text('Create deck'));
    await enterText(find.byType(TextField).last, name);
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Create deck'));
    await waitUntilAbsent(find.text(name));
  }

  Future<void> openDeck(String name) async {
    await tapVisible(find.text(name));
    await waitUntilVisible(find.text('No flashcards yet'));
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

  Future<void> _openCreateDeck() async {
    final textButton = find.text('New deck');
    if (textButton.evaluate().isNotEmpty) {
      await tapVisible(textButton);
      return;
    }
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    await tester.tapAt(Offset(size.width - 56, size.height - 56));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
