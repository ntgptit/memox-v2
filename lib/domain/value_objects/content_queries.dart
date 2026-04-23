import '../enums/content_sort_mode.dart';

final class ContentQuery {
  const ContentQuery({
    this.searchTerm = '',
    this.sortMode = ContentSortMode.manual,
  });

  final String searchTerm;
  final ContentSortMode sortMode;

  String get normalizedSearchTerm => searchTerm.trim();
  bool get hasSearchTerm => normalizedSearchTerm.isNotEmpty;
}
