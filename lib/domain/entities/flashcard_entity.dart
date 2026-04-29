import 'base_entity.dart';

final class FlashcardEntity extends BaseEntity {
  const FlashcardEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.deckId,
    required this.front,
    required this.back,
    required this.note,
    required this.sortOrder,
    this.hasLearningProgress = false,
  });

  final String deckId;
  final String front;
  final String back;
  final String? note;
  final int sortOrder;
  final bool hasLearningProgress;

  String get displayName => front;
}
