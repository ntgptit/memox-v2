import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/content/tag_providers.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../domain/value_objects/tag_read_models.dart';

part 'tag_management_notifier.g.dart';

/// Sort orders offered on the tag management screen. "Recently used" from the
/// wireframe is intentionally omitted in V1 — there is no per-tag last-used
/// signal in `flashcard_tags` to sort by.
enum TagSortMode { mostCards, nameAsc, nameDesc }

/// Streams all tags with usage counts (already sorted most-cards-first by the
/// repository). Backs the tag management screen.
@riverpod
Stream<List<TagWithCount>> tagList(Ref ref) =>
    ref.watch(watchAllTagsWithCountUseCaseProvider).call();

@immutable
class TagManagementFilterState {
  const TagManagementFilterState({
    this.searchTerm = '',
    this.sortMode = TagSortMode.mostCards,
  });

  final String searchTerm;
  final TagSortMode sortMode;

  TagManagementFilterState copyWith({
    String? searchTerm,
    TagSortMode? sortMode,
  }) => TagManagementFilterState(
    searchTerm: searchTerm ?? this.searchTerm,
    sortMode: sortMode ?? this.sortMode,
  );
}

/// Local UI state for search + sort. The dataset is small, so filtering and
/// sorting happen in memory.
@riverpod
class TagManagementFilter extends _$TagManagementFilter {
  @override
  TagManagementFilterState build() => const TagManagementFilterState();

  void setSearch(String value) =>
      state = state.copyWith(searchTerm: value);

  void setSort(TagSortMode mode) => state = state.copyWith(sortMode: mode);
}

/// Pure filter + sort applied to the watched tag list.
List<TagWithCount> filterAndSortTags(
  List<TagWithCount> tags,
  TagManagementFilterState filter,
) {
  final term = StringUtils.normalizedForComparison(filter.searchTerm);
  final filtered = term.isEmpty
      ? List<TagWithCount>.of(tags)
      : tags.where((tag) => tag.tag.contains(term)).toList();

  switch (filter.sortMode) {
    case TagSortMode.mostCards:
      filtered.sort((a, b) {
        final byCount = b.cardCount.compareTo(a.cardCount);
        return byCount != 0 ? byCount : a.tag.compareTo(b.tag);
      });
    case TagSortMode.nameAsc:
      filtered.sort((a, b) => a.tag.compareTo(b.tag));
    case TagSortMode.nameDesc:
      filtered.sort((a, b) => b.tag.compareTo(a.tag));
  }
  return filtered;
}
