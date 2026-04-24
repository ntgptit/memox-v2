enum ContentSortMode { manual, name, newest, lastStudied }

extension ContentSortModeX on ContentSortMode {
  bool get allowsManualReorder => this == ContentSortMode.manual;
}
