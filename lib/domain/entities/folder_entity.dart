import '../enums/folder_content_mode.dart';
import 'base_entity.dart';

final class FolderEntity extends BaseEntity {
  const FolderEntity({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required this.parentId,
    required this.name,
    required this.contentMode,
    required this.sortOrder,
  });

  final String? parentId;
  final String name;
  final FolderContentMode contentMode;
  final int sortOrder;

  bool get isRoot => parentId == null;
}
