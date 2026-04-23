import '../../domain/entities/deck_entity.dart';
import '../../domain/entities/flashcard_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/value_objects/content_read_models.dart';
import '../datasources/local/app_database.dart';
import 'database_enum_codecs.dart';

extension FolderDataMapper on Folder {
  FolderEntity toDomain() {
    return FolderEntity(
      id: id,
      parentId: parentId,
      name: name,
      contentMode: DatabaseEnumCodecs.folderContentModeFromStorage(contentMode),
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension DeckDataMapper on Deck {
  DeckEntity toDomain() {
    return DeckEntity(
      id: id,
      folderId: folderId,
      name: name,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

extension FlashcardDataMapper on Flashcard {
  FlashcardEntity toDomain() {
    return FlashcardEntity(
      id: id,
      deckId: deckId,
      title: title,
      front: front,
      back: back,
      note: note,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

final class FolderDeckAggregateData {
  const FolderDeckAggregateData({
    required this.deck,
    required this.cardCount,
    required this.dueTodayCount,
    required this.masteryPercent,
    required this.lastStudiedAt,
  });

  final Deck deck;
  final int cardCount;
  final int dueTodayCount;
  final int masteryPercent;
  final int? lastStudiedAt;

  FolderDeckReadModel toReadModel() {
    return FolderDeckReadModel(
      deck: deck.toDomain(),
      cardCount: cardCount,
      dueTodayCount: dueTodayCount,
      masteryPercent: masteryPercent,
      lastStudiedAt: lastStudiedAt,
    );
  }
}

final class FlashcardListAggregateData {
  const FlashcardListAggregateData({
    required this.flashcard,
    required this.lastStudiedAt,
  });

  final Flashcard flashcard;
  final int? lastStudiedAt;

  FlashcardListItemReadModel toReadModel() {
    return FlashcardListItemReadModel(
      flashcard: flashcard.toDomain(),
      lastStudiedAt: lastStudiedAt,
    );
  }
}
