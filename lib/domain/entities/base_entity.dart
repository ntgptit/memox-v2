abstract base class BaseEntity {
  const BaseEntity({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final int createdAt;
  final int updatedAt;
}
