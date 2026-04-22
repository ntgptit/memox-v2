import '../entities/deck_entity.dart';
import '../entities/flashcard_entity.dart';
import '../entities/folder_entity.dart';
import '../enums/folder_content_mode.dart';

final class LibraryFolderReadModel {
  const LibraryFolderReadModel({
    required this.folder,
    required this.breadcrumb,
    required this.deckCount,
    required this.itemCount,
    required this.masteryPercent,
    required this.lastStudiedAt,
  });

  final FolderEntity folder;
  final List<String> breadcrumb;
  final int deckCount;
  final int itemCount;
  final int masteryPercent;
  final int? lastStudiedAt;
}

final class LibraryOverviewReadModel {
  const LibraryOverviewReadModel({
    required this.dueTodayCount,
    required this.folders,
  });

  final int dueTodayCount;
  final List<LibraryFolderReadModel> folders;
}

final class FolderDeckReadModel {
  const FolderDeckReadModel({
    required this.deck,
    required this.cardCount,
    required this.dueTodayCount,
    required this.masteryPercent,
    required this.lastStudiedAt,
  });

  final DeckEntity deck;
  final int cardCount;
  final int dueTodayCount;
  final int masteryPercent;
  final int? lastStudiedAt;
}

final class FolderDetailReadModel {
  const FolderDetailReadModel({
    required this.folder,
    required this.breadcrumb,
    required this.subfolders,
    required this.decks,
  });

  final FolderEntity folder;
  final List<FolderEntity> subfolders;
  final List<FolderDeckReadModel> decks;
  final List<String> breadcrumb;

  FolderContentMode get effectiveContentMode {
    if (folder.contentMode != FolderContentMode.unlocked) {
      return folder.contentMode;
    }
    if (subfolders.isNotEmpty) {
      return FolderContentMode.subfolders;
    }
    if (decks.isNotEmpty) {
      return FolderContentMode.decks;
    }
    return FolderContentMode.unlocked;
  }
}

final class DeckDetailReadModel {
  const DeckDetailReadModel({
    required this.deck,
    required this.breadcrumb,
    required this.cardCount,
    required this.dueTodayCount,
    required this.masteryPercent,
    required this.lastStudiedAt,
  });

  final DeckEntity deck;
  final List<String> breadcrumb;
  final int cardCount;
  final int dueTodayCount;
  final int masteryPercent;
  final int? lastStudiedAt;
}

final class FlashcardListItemReadModel {
  const FlashcardListItemReadModel({
    required this.flashcard,
    required this.lastStudiedAt,
  });

  final FlashcardEntity flashcard;
  final int? lastStudiedAt;
}

final class FlashcardListReadModel {
  const FlashcardListReadModel({
    required this.deck,
    required this.breadcrumb,
    required this.items,
  });

  final DeckEntity deck;
  final List<String> breadcrumb;
  final List<FlashcardListItemReadModel> items;
}
