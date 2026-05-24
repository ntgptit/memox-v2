import '../enums/flashcard_starting_status.dart';
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
    this.example,
    this.pronunciation,
    this.hint,
    this.tags = const <String>[],
    this.startingStatus = FlashcardStartingStatus.newCard,
    this.hasLearningProgress = false,
  });

  final String deckId;
  final String front;
  final String back;
  final String? note;
  final int sortOrder;
  final String? example;
  final String? pronunciation;
  final String? hint;
  final List<String> tags;
  final FlashcardStartingStatus startingStatus;
  final bool hasLearningProgress;

  String get displayName => front;
}
