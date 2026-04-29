import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/router/route_names.dart';

import '../robots/folder_robot.dart';
import '../robots/memox_robot.dart';
import '../test_app.dart';

void folderFlowTests() {
  group('Folder flow', () {
    testWidgets(
      'DT3 onOpen: renders not-found error for missing folder route',
      (tester) async {
        await pumpTestApp(
          tester,
          initialLocation: '${RoutePaths.library}/folder/e2e-missing-folder',
        );

        await MemoxRobot(tester).expectErrorState(
          title: 'Something went wrong',
          message: 'Folder not found.',
        );

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DT1 onInsert: creates a root folder through the library flow',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.expectEmptyLibrary();
        await folder.createRootFolder('E2E Folder');

        expect(find.text('E2E Folder'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DT2 onInsert: cancels root folder creation without mutating library',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.expectEmptyLibrary();
        await folder.cancelRootFolderCreation('E2E Cancelled Folder');
        await folder.expectEmptyLibrary();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DT3 onInsert: creates a subfolder and locks parent to subfolder mode',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Parent Folder');
        await folder.openFolder('E2E Parent Folder');
        await folder.createSubfolder('E2E Child Folder');

        expect(find.text('E2E Child Folder'), findsOneWidget);
        expect(find.text('New deck'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DT1 onDisplay: opens a root folder detail from the library list',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Read Folder');
        await folder.openFolder('E2E Read Folder');

        expect(find.text('E2E Read Folder'), findsWidgets);
        expect(find.text('This folder is empty'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DT5 onDisplay: opens a subfolder detail from its parent folder',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Display Parent Folder');
        await folder.openFolder('E2E Display Parent Folder');
        await folder.createSubfolder('E2E Display Child Folder');
        await folder.openFolder('E2E Display Child Folder');

        expect(find.text('E2E Display Child Folder'), findsWidgets);
        expect(find.text('This folder is empty'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT1 onUpdate: renames the opened root folder from actions', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Folder Before');
      await folder.openFolder('E2E Folder Before');
      await folder.renameCurrentFolder(
        from: 'E2E Folder Before',
        to: 'E2E Folder After',
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('DT2 onUpdate: cancels folder rename without changing title', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Folder Stable');
      await folder.openFolder('E2E Folder Stable');
      await folder.cancelRenameCurrentFolder(
        from: 'E2E Folder Stable',
        attemptedName: 'E2E Folder Ignored',
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'DT1 onDelete: deletes the opened root folder after confirmation',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Delete Folder');
        await folder.openFolder('E2E Delete Folder');
        await folder.deleteCurrentFolder('E2E Delete Folder');
        await folder.expectEmptyLibrary();

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT2 onDelete: cancels folder deletion and keeps subtree', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Keep Folder');
      await folder.openFolder('E2E Keep Folder');
      await folder.cancelDeleteCurrentFolder('E2E Keep Folder');

      expect(find.text('This folder is empty'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'DT8 onDelete: deletes a parent folder with an existing child folder',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Delete Parent Folder');
        await folder.openFolder('E2E Delete Parent Folder');
        await folder.createSubfolder('E2E Delete Child Folder');
        await folder.deleteCurrentFolder('E2E Delete Parent Folder');
        await folder.expectEmptyLibrary();

        expect(find.text('E2E Delete Child Folder'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('DT1 onSearchFilterSort: filters root folders by name search', (
      tester,
    ) async {
      await pumpTestApp(tester);

      final folder = FolderRobot(tester);
      await folder.createRootFolder('E2E Alpha Folder');
      await folder.createRootFolder('E2E Beta Folder');
      await folder.searchFor('Beta');

      await folder.waitUntilVisible(find.text('E2E Beta Folder'));
      await folder.waitUntilAbsent(find.text('E2E Alpha Folder'));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'DT2 onSearchFilterSort: clears folder search and restores results',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Restore Folder');
        await folder.searchFor('No matching folder');
        await folder.waitUntilAbsent(find.text('E2E Restore Folder'));
        await folder.clearSearch();
        await folder.waitUntilVisible(find.text('E2E Restore Folder'));

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DT5 onSearchFilterSort: shows empty state for unmatched folder search',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Searchable Folder');
        await folder.searchFor('No matching folder');

        await folder.waitUntilVisible(find.text('No matching items'));
        await folder.waitUntilAbsent(find.text('E2E Searchable Folder'));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'DT8 onSearchFilterSort: matches root folder search case-insensitively',
      (tester) async {
        await pumpTestApp(tester);

        final folder = FolderRobot(tester);
        await folder.createRootFolder('E2E Mixed Case Folder');
        await folder.createRootFolder('E2E Other Folder');
        await folder.searchFor('mixed case');

        await folder.waitUntilVisible(find.text('E2E Mixed Case Folder'));
        await folder.waitUntilAbsent(find.text('E2E Other Folder'));
        expect(tester.takeException(), isNull);
      },
    );
  });
}
