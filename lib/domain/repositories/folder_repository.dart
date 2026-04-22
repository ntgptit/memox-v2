import '../../core/errors/result.dart';
import '../entities/folder_entity.dart';
import '../value_objects/content_actions.dart';
import '../value_objects/content_queries.dart';
import '../value_objects/content_read_models.dart';

abstract interface class FolderRepository {
  Future<LibraryOverviewReadModel> getLibraryOverview(ContentQuery query);

  Future<FolderDetailReadModel> getFolderDetail(
    String folderId,
    ContentQuery query,
  );

  Future<List<FolderMoveTarget>> getFolderMoveTargets(String folderId);

  Future<Result<FolderEntity>> createRootFolder(String name);

  Future<Result<FolderEntity>> createSubfolder({
    required String parentFolderId,
    required String name,
  });

  Future<Result<FolderEntity>> updateFolder({
    required String folderId,
    required String name,
  });

  Future<Result<void>> deleteFolder(String folderId);

  Future<Result<void>> moveFolder({
    required String folderId,
    required String? targetParentId,
  });

  Future<Result<void>> reorderFolders({
    required String? parentFolderId,
    required List<String> orderedFolderIds,
  });
}
