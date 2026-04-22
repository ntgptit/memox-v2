import '../../core/errors/result.dart';
import '../entities/folder_entity.dart';
import '../repositories/folder_repository.dart';

final class CreateFolderUseCase {
  const CreateFolderUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<FolderEntity>> createRoot(String name) {
    return _repository.createRootFolder(name);
  }

  Future<Result<FolderEntity>> createSubfolder({
    required String parentFolderId,
    required String name,
  }) {
    return _repository.createSubfolder(
      parentFolderId: parentFolderId,
      name: name,
    );
  }
}

final class UpdateFolderUseCase {
  const UpdateFolderUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<FolderEntity>> execute({
    required String folderId,
    required String name,
  }) {
    return _repository.updateFolder(folderId: folderId, name: name);
  }
}

final class DeleteFolderUseCase {
  const DeleteFolderUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<void>> execute(String folderId) {
    return _repository.deleteFolder(folderId);
  }
}

final class MoveFolderUseCase {
  const MoveFolderUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<void>> execute({
    required String folderId,
    required String? targetParentId,
  }) {
    return _repository.moveFolder(
      folderId: folderId,
      targetParentId: targetParentId,
    );
  }
}

final class ReorderFoldersUseCase {
  const ReorderFoldersUseCase(this._repository);

  final FolderRepository _repository;

  Future<Result<void>> execute({
    required String? parentFolderId,
    required List<String> orderedFolderIds,
  }) {
    return _repository.reorderFolders(
      parentFolderId: parentFolderId,
      orderedFolderIds: orderedFolderIds,
    );
  }
}
