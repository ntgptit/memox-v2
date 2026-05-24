import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/presentation/shared/dialogs/mx_destination_picker_sheet.dart';
import 'package:memox/presentation/shared/widgets/mx_folder_tile.dart';

import 'memox_robot.dart';

final class FolderRobot extends MemoxRobot {
  const FolderRobot(super.tester);

  static const double _folderTileBodyTapInset = 72;

  Future<void> expectEmptyLibrary() async {
    await waitUntilVisible(find.text('No folders yet'));
  }

  Future<void> expectRootEmptyState() async {
    await waitUntilVisible(find.text('No folders yet'));
    await waitUntilVisible(find.text('Create folder'));
  }

  Future<void> openCreateFolderDialog() async {
    await _openCreateFolder();
    await waitUntilVisible(find.text('Create folder'));
    await waitUntilVisible(find.text('Folder name'));
  }

  Future<void> enterFolderName(String name) async {
    await enterText(find.byType(TextField).last, name);
  }

  Future<void> confirmFolderCreation() async {
    await tapVisible(find.text('Create').last);
  }

  Future<void> expectCreateFolderConfirmDisabled() async {
    final confirmButton = find.ancestor(
      of: find.text('Create').last,
      matching: find.byType(ElevatedButton),
    );
    await waitUntilVisible(confirmButton);
    expect(tester.widget<ElevatedButton>(confirmButton).onPressed, isNull);
  }

  Future<void> expectFolderVisible(String name) async {
    await waitUntilVisible(find.text(name));
  }

  Future<void> expectFolderAbsent(String name) async {
    await waitUntilAbsent(find.text(name));
  }

  Future<void> expectSubfolderCreationAvailableOnly() async {
    await waitUntilVisible(find.byTooltip('New subfolder'));
    expect(find.text('New deck'), findsNothing);
    expect(find.byTooltip('New deck'), findsNothing);
  }

  Future<void> expectDeckCreationAvailableOnly() async {
    await waitUntilVisible(find.byTooltip('New deck'));
    expect(find.text('New subfolder'), findsNothing);
    expect(find.byTooltip('New subfolder'), findsNothing);
  }

  Future<void> expectUnlockedCreateChoicesAvailable() async {
    await tapFloatingActionButton();
    await waitUntilVisible(find.text('What do you want to create?'));
    await waitUntilVisible(find.text('New subfolder'));
    await waitUntilVisible(find.text('New deck'));
  }

  Future<void> expectFoldersInOrder(List<String> names) async {
    for (final name in names) {
      await waitUntilVisible(find.text(name));
    }

    final positions = [
      for (final name in names) tester.getTopLeft(find.text(name).first).dy,
    ];
    final sortedPositions = [...positions]..sort();
    expect(positions, sortedPositions);
  }

  Future<void> openCurrentFolderReorderMode() async {
    await tapVisible(find.byTooltip('More actions').first);
    await waitUntilVisible(find.text('Folder actions'));
    await tapVisible(find.text('Reorder'));
    await waitUntilVisible(find.text('Save order'));
  }

  Future<void> dragFolderToTop(String name) async {
    final tile = _folderTile(name);
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
    await _tapFolderTileBody(name);
    await waitUntilVisible(find.text('This folder is empty'));
  }

  Future<void> openFolderFromLibrary(String name) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      await _tapFolderTileBody(name);
      for (var pump = 0; pump < 10; pump++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.byTooltip('More actions').evaluate().isNotEmpty) {
          return;
        }
      }
    }
    fail('Timed out opening folder "$name" from library');
  }

  Future<void> openVisibleFolder(String name) async {
    await _tapFolderTileBody(name);
    await waitUntilVisible(find.byTooltip('Back'));
    await waitUntilVisible(find.byTooltip('More actions'));
  }

  Future<void> createSubfolder(String name) async {
    await _openCreateSubfolder();
    await waitUntilVisible(find.text('Folder name'));
    await enterText(find.byType(TextField).last, name);
    await tapVisible(find.text('Create').last);
    await waitUntilAbsent(find.text('Folder name'));
    await waitUntilVisible(find.text(name));
  }

  Future<void> renameRootFolder({
    required String from,
    required String to,
  }) async {
    await openRootFolderRenameDialog(from);
    await enterText(find.byType(TextField).last, to);
    await tapVisible(find.text('Save').last);
    await waitUntilAbsent(find.text('Rename folder'));
    await waitUntilVisible(find.text(to));
    expect(find.text(from), findsNothing);
    await tester.pumpAndSettle();
  }

  Future<void> openRootFolderRenameDialog(String name) async {
    await _openRootFolderActions(name);
    await tapVisible(find.text('Edit'));
    await waitUntilVisible(find.text('Rename folder'));
    await waitUntilVisible(find.text('Folder name'));
  }

  Future<void> expectRenameConfirmDisabled() async {
    final confirmButton = find.ancestor(
      of: find.text('Save').last,
      matching: find.byType(ElevatedButton),
    );
    await waitUntilVisible(confirmButton);
    expect(tester.widget<ElevatedButton>(confirmButton).onPressed, isNull);
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

  Future<void> deleteRootFolder(String name) async {
    await _openRootFolderDeleteDialog(name);
    await tapVisible(find.text('Delete').last);
    await waitUntilAbsent(find.text('Delete folder'));
    await waitUntilAbsent(find.text(name));
  }

  Future<void> cancelDeleteRootFolder(String name) async {
    await _openRootFolderDeleteDialog(name);
    await tapVisible(find.text('Cancel'));
    await waitUntilAbsent(find.text('Delete folder'));
    await waitUntilVisible(find.text(name));
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

  Future<void> deleteVisibleFolderRow(String name) async {
    await _openVisibleFolderActions(name);
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete folder'));
    await tapVisible(find.text('Delete').last);
    await waitUntilAbsent(find.text('Delete folder'));
    await waitUntilAbsent(find.text(name));
  }

  Future<void> openRootFolderMoveDialog(String name) async {
    await _openRootFolderActions(name);
    await tapVisible(find.text('Move'));
    await waitUntilVisible(find.text('Move folder'));
    await waitUntilVisible(_destinationPicker());
  }

  Future<void> openVisibleFolderMoveDialog(String name) async {
    await _openVisibleFolderActions(name);
    await tapVisible(find.text('Move'));
    await waitUntilVisible(find.text('Move folder'));
    await waitUntilVisible(_destinationPicker());
  }

  Future<void> moveVisibleFolderTo({
    required String folderName,
    required String destinationName,
  }) async {
    await openVisibleFolderMoveDialog(folderName);
    await selectMoveDestination(destinationName);
    await waitUntilAbsent(find.text('Move folder'));
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

  Future<void> tapBackToFolder(String name) async {
    await tapVisible(find.byTooltip('Back'));
    await waitUntilVisible(find.text(name));
    await waitUntilVisible(find.byTooltip('More actions'));
  }

  Future<void> tapBackToLibrary() async {
    await tapVisible(find.byTooltip('Back'));
    await waitUntilAbsent(find.byTooltip('Back'));
    await waitUntilVisible(find.text('Folders'));
  }

  Future<void> expectCurrentFolder(String name) async {
    await waitUntilVisible(find.byTooltip('Back'));
    await waitUntilVisible(find.byTooltip('More actions'));
    await waitUntilVisible(find.text(name));
  }

  Future<void> tapRootFolderStudyAction(String folderId) => _tapStudyAction(
      ValueKey<String>('library_folder_recursive_study_$folderId'),
    );

  Future<void> tapVisibleFolderStudyAction(String folderId) => _tapStudyAction(
      ValueKey<String>('folder_recursive_study_$folderId'),
    );

  Future<void> _openRootFolderActions(String name) async {
    await longPressVisible(_folderTile(name));
    await waitUntilVisible(find.text('Folder actions'));
  }

  Future<void> _openVisibleFolderActions(String name) async {
    await longPressVisible(_folderTile(name));
    await waitUntilVisible(find.text('Folder actions'));
  }

  Future<void> _openRootFolderDeleteDialog(String name) async {
    await _openRootFolderActions(name);
    await tapVisible(find.text('Delete').last);
    await waitUntilVisible(find.text('Delete folder'));
  }

  Future<void> _openCreateFolder() async {
    final textButton = find.text('Create folder');
    if (textButton.evaluate().isNotEmpty) {
      await tapVisible(textButton);
      return;
    }
    await tapVisible(find.byTooltip('Create folder'));
  }

  Future<void> _openCreateSubfolder() async {
    final textButton = find.text('New subfolder');
    if (textButton.evaluate().isNotEmpty) {
      await tapVisible(textButton.last);
      return;
    }

    await _tapFab();
    for (var attempt = 0; attempt < 20; attempt++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Folder name').evaluate().isNotEmpty) {
        return;
      }
      final createChoice = find.text('New subfolder');
      if (createChoice.evaluate().isNotEmpty) {
        await tapVisible(createChoice.last);
        return;
      }
    }
    fail('Timed out opening subfolder creation');
  }

  Future<void> _tapFab() async {
    await tapFloatingActionButton();
  }

  Finder _folderTile(String name) => find.ancestor(
      of: find.text(name),
      matching: find.byType(MxFolderTile),
    );

  Finder _destinationPicker() => find.byWidgetPredicate(
      (widget) => widget is MxDestinationPickerSheet<Object?>,
    );

  Finder _moveDestinationText(String name) => find.descendant(of: _destinationPicker(), matching: find.text(name));

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

  Future<void> _tapStudyAction(ValueKey<String> key) async {
    final action = find.byKey(key);
    await waitUntilVisible(action);
    final tappable = find.descendant(
      of: action,
      matching: find.byType(InkWell),
    );
    await tapVisible(tappable);
    await waitUntilVisible(find.text('Start a study session'));
  }

  Future<void> _tapFolderTileBody(String name) async {
    final tile = _folderTile(name);
    await waitUntilVisible(tile);
    await tester.ensureVisible(tile);
    await tester.pump(const Duration(milliseconds: 100));
    final target = await _waitUntilTappable(tile);
    final rect = tester.getRect(target);
    final bodyX = rect.width > _folderTileBodyTapInset
        ? rect.left + _folderTileBodyTapInset
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
