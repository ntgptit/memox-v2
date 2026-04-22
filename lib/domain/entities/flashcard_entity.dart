import 'base_entity.dart';

final class FlashcardEntity extends BaseEntity {
  const FlashcardEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.deckId,
    required this.title,
    required this.front,
    required this.back,
    required this.note,
    required this.sortOrder,
  });

  final String deckId;
  final String? title;
  final String front;
  final String back;
  final String? note;
  final int sortOrder;

  String get displayName {
    final trimmedTitle = title?.trim();
    if (trimmedTitle != null && trimmedTitle.isNotEmpty) {
      return trimmedTitle;
    }

    return front;
  }
}
