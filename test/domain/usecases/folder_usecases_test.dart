import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/errors/app_exception.dart';
import 'package:memox/core/errors/failures.dart';
import 'package:memox/domain/enums/folder_content_mode.dart';
import 'package:memox/domain/repositories/folder_repository.dart';
import 'package:memox/domain/services/folder_structure_service.dart';
import 'package:memox/domain/usecases/folder_usecases.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';

void main() {
  group('FolderStructureService', () {
    const service = FolderStructureService();

    test(
      'F4 onInsert: folder containing decks rejects subfolder creation with typed code',
      () {
        expect(
          () =>
              service.resolveModeAfterAddingSubfolder(FolderContentMode.decks),
          throwsA(
            isA<ValidationException>()
                .having(
                  (error) => error.code,
                  'code',
                  FailureCodes.folderContainsDecks,
                )
                .having(
                  (error) => error.message,
                  'message',
                  'The target folder is locked for decks.',
                ),
          ),
        );
      },
    );

    test(
      'F6 onInsert: folder containing subfolders rejects deck creation with typed code',
      () {
        expect(
          () =>
              service.resolveModeAfterAddingDeck(FolderContentMode.subfolders),
          throwsA(
            isA<ValidationException>()
                .having(
                  (error) => error.code,
                  'code',
                  FailureCodes.folderContainsSubfolders,
                )
                .having(
                  (error) => error.message,
                  'message',
                  'The target folder is locked for subfolders.',
                ),
          ),
        );
      },
    );

    test(
      'F3 onInsert: empty folder allows first subfolder and first deck mode paths independently',
      () {
        expect(
          service.resolveModeAfterAddingSubfolder(FolderContentMode.unlocked),
          FolderContentMode.subfolders,
        );
        expect(
          service.resolveModeAfterAddingDeck(FolderContentMode.unlocked),
          FolderContentMode.decks,
        );
      },
    );
  });

  group('ListAllFoldersUseCase', () {
    test('returns all folders, including nested folders', () async {
      const options = <FolderScopeOption>[
        FolderScopeOption(
          id: 'root',
          name: 'Languages',
          breadcrumb: <String>['Languages'],
        ),
        FolderScopeOption(
          id: 'child',
          name: 'Japanese',
          breadcrumb: <String>['Languages', 'Japanese'],
        ),
        FolderScopeOption(
          id: 'leaf',
          name: 'N5',
          breadcrumb: <String>['Languages', 'Japanese', 'N5'],
        ),
      ];
      final useCase = ListAllFoldersUseCase(_StubFolderRepository(options));

      final result = await useCase.execute();

      expect(result.map((option) => option.id), <String>[
        'root',
        'child',
        'leaf',
      ]);
      // The nested leaf is present with its full root → child → leaf breadcrumb.
      expect(result.last.breadcrumb, <String>['Languages', 'Japanese', 'N5']);
    });

    test('delegates straight to the repository scope-option list', () async {
      final stub = _StubFolderRepository(const <FolderScopeOption>[]);
      final useCase = ListAllFoldersUseCase(stub);

      final result = await useCase.execute();

      expect(result, isEmpty);
      expect(stub.listAllFoldersCallCount, 1);
    });
  });

  group('FolderScopeOption.parentBreadcrumb', () {
    test('excludes the current folder (drops the last segment)', () {
      const option = FolderScopeOption(
        id: 'leaf',
        name: 'N5',
        breadcrumb: <String>['Languages', 'Japanese', 'N5'],
      );

      expect(option.parentBreadcrumb, <String>['Languages', 'Japanese']);
    });

    test('is empty for a root folder breadcrumb of one segment', () {
      const option = FolderScopeOption(
        id: 'root',
        name: 'Languages',
        breadcrumb: <String>['Languages'],
      );

      expect(option.parentBreadcrumb, isEmpty);
    });

    test('is empty when the breadcrumb is empty', () {
      const option = FolderScopeOption(
        id: 'orphan',
        name: 'Orphan',
        breadcrumb: <String>[],
      );

      expect(option.parentBreadcrumb, isEmpty);
    });

    test('disambiguates duplicate folder names by parent breadcrumb', () {
      const first = FolderScopeOption(
        id: 'jp-languages',
        name: 'Japanese',
        breadcrumb: <String>['Languages', 'Japanese'],
      );
      const second = FolderScopeOption(
        id: 'jp-travel',
        name: 'Japanese',
        breadcrumb: <String>['Travel', 'Japanese'],
      );

      // Same display name, but the parent breadcrumb distinguishes them.
      expect(first.name, second.name);
      expect(first.parentBreadcrumb, isNot(second.parentBreadcrumb));
      expect(first.parentBreadcrumb, <String>['Languages']);
      expect(second.parentBreadcrumb, <String>['Travel']);
    });
  });
}

/// Minimal [FolderRepository] stub exposing only [listAllFolders]; all other
/// members are unused by [ListAllFoldersUseCase] and routed to [noSuchMethod].
class _StubFolderRepository implements FolderRepository {
  _StubFolderRepository(this._options);

  final List<FolderScopeOption> _options;
  int listAllFoldersCallCount = 0;

  @override
  Future<List<FolderScopeOption>> listAllFolders() async {
    listAllFoldersCallCount++;
    return _options;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
