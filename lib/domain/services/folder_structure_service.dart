import '../../core/errors/app_exception.dart';
import '../enums/folder_content_mode.dart';

final class FolderStructureService {
  const FolderStructureService();

  FolderContentMode resolveModeAfterAddingSubfolder(FolderContentMode current) {
    if (current == FolderContentMode.decks) {
      throw const ValidationException(
        message: 'The target folder is locked for decks.',
      );
    }

    return FolderContentMode.subfolders;
  }

  FolderContentMode resolveModeAfterAddingDeck(FolderContentMode current) {
    if (current == FolderContentMode.subfolders) {
      throw const ValidationException(
        message: 'The target folder is locked for subfolders.',
      );
    }

    return FolderContentMode.decks;
  }

  FolderContentMode resolveModeAfterChildrenChanged({
    required bool hasSubfolders,
    required bool hasDecks,
  }) {
    if (hasSubfolders && hasDecks) {
      throw const ValidationException(
        message: 'A folder cannot contain both subfolders and decks.',
      );
    }

    if (hasSubfolders) {
      return FolderContentMode.subfolders;
    }
    if (hasDecks) {
      return FolderContentMode.decks;
    }
    return FolderContentMode.unlocked;
  }

  void validateFolderMove({
    required String folderId,
    required String? targetParentId,
    required Set<String> descendantIds,
    required FolderContentMode targetParentMode,
  }) {
    if (folderId == targetParentId) {
      throw const ValidationException(
        message: 'A folder cannot be moved into itself.',
      );
    }

    if (targetParentId != null && descendantIds.contains(targetParentId)) {
      throw const ValidationException(
        message: 'A folder cannot be moved into its own descendant.',
      );
    }

    if (targetParentMode == FolderContentMode.decks) {
      throw const ValidationException(
        message: 'The target folder is locked for decks.',
      );
    }
  }

  void validateDeckMove(FolderContentMode targetParentMode) {
    if (targetParentMode == FolderContentMode.subfolders) {
      throw const ValidationException(
        message: 'The target folder is locked for subfolders.',
      );
    }
  }
}
