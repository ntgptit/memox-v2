import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'memox_robot.dart';

final class FolderRobot extends MemoxRobot {
  const FolderRobot(super.tester);

  Future<void> expectEmptyLibrary() async {
    await waitUntilVisible(find.text('No folders yet'));
  }

  Future<void> createRootFolder(String name) async {
    await _openCreateFolder();
    await waitUntilVisible(find.text('Folder name'));
    await enterText(find.byType(TextField).last, name);
    await tapVisible(find.text('Create').last);
    await waitUntilAbsent(find.text('Folder name'));
    await waitUntilVisible(find.text(name));
  }

  Future<void> cancelRootFolderCreation(String name) async {
    await _openCreateFolder();
    await waitUntilVisible(find.text('Folder name'));
    await enterText(find.byType(TextField).last, name);
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Folder name'));
    await waitUntilAbsent(find.text(name));
  }

  Future<void> openFolder(String name) async {
    await tapVisible(find.text(name));
    await waitUntilVisible(find.text('This folder is empty'));
  }

  Future<void> createSubfolder(String name) async {
    await tapVisible(find.text('New subfolder'));
    await waitUntilVisible(find.text('Folder name'));
    await enterText(find.byType(TextField).last, name);
    await tapVisible(find.text('Create').last);
    await waitUntilAbsent(find.text('Folder name'));
    await waitUntilVisible(find.text(name));
  }

  Future<void> renameCurrentFolder({
    required String from,
    required String to,
  }) async {
    await tapVisible(find.byTooltip('More actions').first);
    await waitUntilVisible(find.text('Folder actions'));
    await tapVisible(find.text('Edit'));
    await waitUntilVisible(find.text('Rename folder'));
    await enterText(find.byType(TextField).last, to);
    await tapVisible(find.text('Save').last);
    await waitUntilAbsent(find.text('Rename folder'));
    await waitUntilVisible(find.text(to));
    expect(find.text(from), findsNothing);
  }

  Future<void> cancelRenameCurrentFolder({
    required String from,
    required String attemptedName,
  }) async {
    await tapVisible(find.byTooltip('More actions').first);
    await waitUntilVisible(find.text('Folder actions'));
    await tapVisible(find.text('Edit'));
    await waitUntilVisible(find.text('Rename folder'));
    await enterText(find.byType(TextField).last, attemptedName);
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Rename folder'));
    await waitUntilVisible(find.text(from));
    expect(find.text(attemptedName), findsNothing);
  }

  Future<void> deleteCurrentFolder(String name) async {
    await tapVisible(find.byTooltip('More actions').first);
    await waitUntilVisible(find.text('Folder actions'));
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete folder'));
    await tapVisible(find.text('Delete').last);
    await waitUntilAbsent(find.text('Delete folder'));
    await waitUntilAbsent(find.text(name));
  }

  Future<void> cancelDeleteCurrentFolder(String name) async {
    await tapVisible(find.byTooltip('More actions').first);
    await waitUntilVisible(find.text('Folder actions'));
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete folder'));
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Delete folder'));
    await waitUntilVisible(find.text(name));
  }

  Future<void> _openCreateFolder() async {
    final textButton = find.text('Create folder');
    if (textButton.evaluate().isNotEmpty) {
      await tapVisible(textButton);
      return;
    }
    await tapVisible(find.byTooltip('Create folder'));
  }
}
