import 'package:flutter_test/flutter_test.dart';

import '../../support/content_repository_harness.dart';

void main() {
  group('FolderRepositoryImpl.listAllFolders (scope read path)', () {
    late ContentRepositoryHarness harness;

    setUp(() {
      harness = ContentRepositoryHarness.create(
        ids: <String>[
          'folder-root-a',
          'folder-child-a',
          'folder-leaf-a',
          'folder-root-b',
          'folder-child-b',
        ],
      );
    });

    tearDown(() async {
      await harness.dispose();
    });

    Future<String> createRoot(String name) async {
      final result = await harness.folderRepository.createRootFolder(name);
      expect(result.isSuccess, isTrue);
      return result.valueOrNull!.id;
    }

    Future<String> createChild(String parentId, String name) async {
      final result = await harness.folderRepository.createSubfolder(
        parentFolderId: parentId,
        name: name,
      );
      expect(result.isSuccess, isTrue);
      return result.valueOrNull!.id;
    }

    test(
      'returns every folder including nested folders as flat scope options',
      () async {
        final rootId = await createRoot('Languages');
        final childId = await createChild(rootId, 'Japanese');
        final leafId = await createChild(childId, 'N5');

        final options = await harness.folderRepository.listAllFolders();

        expect(
          options.map((option) => option.id),
          containsAll(<String>[rootId, childId, leafId]),
        );
        expect(options, hasLength(3));
      },
    );

    test('builds a breadcrumb root → child → leaf for a nested folder', () async {
      final rootId = await createRoot('Languages');
      final childId = await createChild(rootId, 'Japanese');
      final leafId = await createChild(childId, 'N5');

      final options = await harness.folderRepository.listAllFolders();
      final leaf = options.singleWhere((option) => option.id == leafId);

      expect(leaf.name, 'N5');
      expect(leaf.breadcrumb, <String>['Languages', 'Japanese', 'N5']);
    });

    test(
      'parentBreadcrumb excludes the current folder (root → child only)',
      () async {
        final rootId = await createRoot('Languages');
        final childId = await createChild(rootId, 'Japanese');
        final leafId = await createChild(childId, 'N5');

        final options = await harness.folderRepository.listAllFolders();
        final leaf = options.singleWhere((option) => option.id == leafId);

        expect(leaf.breadcrumb.last, 'N5');
        expect(leaf.parentBreadcrumb, <String>['Languages', 'Japanese']);
      },
    );

    test(
      'duplicate folder names can be disambiguated by breadcrumb',
      () async {
        final rootAId = await createRoot('Languages');
        final dupAId = await createChild(rootAId, 'Japanese');
        final rootBId = await createRoot('Travel');
        final dupBId = await createChild(rootBId, 'Japanese');

        final options = await harness.folderRepository.listAllFolders();
        final dupA = options.singleWhere((option) => option.id == dupAId);
        final dupB = options.singleWhere((option) => option.id == dupBId);

        expect(dupA.name, dupB.name);
        expect(dupA.breadcrumb, <String>['Languages', 'Japanese']);
        expect(dupB.breadcrumb, <String>['Travel', 'Japanese']);
        expect(dupA.parentBreadcrumb, isNot(dupB.parentBreadcrumb));
      },
    );

    test(
      'applies no move-target descendant exclusion (self + descendants kept)',
      () async {
        final rootId = await createRoot('Languages');
        final childId = await createChild(rootId, 'Japanese');

        final scopeOptions = await harness.folderRepository.listAllFolders();
        // Move targets exclude the folder itself and all of its descendants.
        final moveTargets = await harness.folderRepository.getFolderMoveTargets(
          rootId,
        );

        // Scope options keep the root and its descendant; move targets drop both.
        expect(
          scopeOptions.map((option) => option.id),
          containsAll(<String>[rootId, childId]),
        );
        final moveTargetIds = moveTargets.map((target) => target.id).toSet();
        expect(moveTargetIds, isNot(contains(rootId)));
        expect(moveTargetIds, isNot(contains(childId)));
      },
    );
  });
}
