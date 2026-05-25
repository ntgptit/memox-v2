import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/entities/folder_entity.dart';
import 'package:memox/domain/enums/folder_content_mode.dart';
import 'package:memox/domain/value_objects/content_read_models.dart';

void main() {
  test('DT1 calculateMetrics: returns zero mastery for empty library', () {
    const overview = LibraryOverviewReadModel(
      overdueCount: 0,
      dueTodayCount: 0,
      newCardCount: 0,
      totalFolderCount: 0,
      folders: <LibraryFolderReadModel>[],
    );

    expect(overview.deckCount, 0);
    expect(overview.cardCount, 0);
    expect(overview.masteryPercent, 0);
  });

  test(
    'DT2 calculateMetrics: computes weighted mastery from folder card counts',
    () {
      final overview = LibraryOverviewReadModel(
        overdueCount: 0,
        dueTodayCount: 0,
        newCardCount: 0,
        totalFolderCount: 2,
        folders: <LibraryFolderReadModel>[
          _folderReadModel(
            id: 'folder-1',
            deckCount: 1,
            itemCount: 2,
            masteryPercent: 25,
          ),
          _folderReadModel(
            id: 'folder-2',
            deckCount: 3,
            itemCount: 6,
            masteryPercent: 75,
          ),
        ],
      );

      expect(overview.deckCount, 4);
      expect(overview.cardCount, 8);
      expect(overview.masteryPercent, 63);
    },
  );
}

LibraryFolderReadModel _folderReadModel({
  required String id,
  required int deckCount,
  required int itemCount,
  required int masteryPercent,
}) => LibraryFolderReadModel(
  folder: FolderEntity(
    id: id,
    parentId: null,
    name: id,
    contentMode: FolderContentMode.unlocked,
    sortOrder: 0,
    createdAt: 0,
    updatedAt: 0,
  ),
  breadcrumb: <String>[],
  subfolderCount: 0,
  deckCount: deckCount,
  itemCount: itemCount,
  dueCardCount: 0,
  newCardCount: 0,
  masteryPercent: masteryPercent,
  lastStudiedAt: null,
);
