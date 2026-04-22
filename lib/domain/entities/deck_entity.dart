import 'base_entity.dart';

final class DeckEntity extends BaseEntity {
  const DeckEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.folderId,
    required this.name,
    required this.sortOrder,
  });

  final String folderId;
  final String name;
  final int sortOrder;
}
