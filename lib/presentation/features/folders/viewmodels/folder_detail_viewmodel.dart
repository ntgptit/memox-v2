import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'folder_detail_viewmodel.g.dart';

/// Which mode the folder-detail screen is rendering.
///
/// A folder may contain *either* subfolders or decks, never both — the
/// business rule "only the deepest folder level can contain decks". The
/// [FolderDetailMode] toggle is demo-only scaffolding: in production the mode
/// is derived from the folder entity and is not user-selectable.
enum FolderDetailMode { subfolders, decks }

@immutable
class FolderDetailHeader {
  const FolderDetailHeader({
    required this.name,
    required this.breadcrumb,
  });

  final String name;
  final List<String> breadcrumb;
}

@immutable
class FolderSubfolderItem {
  const FolderSubfolderItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.caption,
  });

  final String id;
  final String name;
  final IconData icon;
  final String caption;
}

@immutable
class FolderDeckItem {
  const FolderDeckItem({
    required this.id,
    required this.name,
    required this.cardCount,
    required this.dueToday,
    required this.masteryPercent,
    required this.tags,
  });

  final String id;
  final String name;
  final int cardCount;
  final int dueToday;

  /// Mastery in `[0, 100]`.
  final int masteryPercent;
  final List<String> tags;
}

@immutable
class FolderDetailState {
  const FolderDetailState({
    required this.header,
    required this.mode,
    required this.subfolders,
    required this.decks,
  });

  final FolderDetailHeader header;
  final FolderDetailMode mode;
  final List<FolderSubfolderItem> subfolders;
  final List<FolderDeckItem> decks;

  bool get isSubfolderMode => mode == FolderDetailMode.subfolders;
  bool get isDeckMode => mode == FolderDetailMode.decks;

  int get subfolderCount => subfolders.length;
  int get deckCount => decks.length;
  int get totalCardCount =>
      decks.fold(0, (sum, deck) => sum + deck.cardCount);

  FolderDetailState copyWith({FolderDetailMode? mode}) {
    return FolderDetailState(
      header: header,
      mode: mode ?? this.mode,
      subfolders: subfolders,
      decks: decks,
    );
  }
}

/// Demo-only viewmodel for the folder-detail screen.
///
/// Exposes a synchronous [FolderDetailState] with mock data so the screen
/// can render both "contains subfolders" and "contains decks" variants via
/// a demo toggle. Swap for an `AsyncNotifier` backed by the folder
/// repository when the domain lands.
@riverpod
class FolderDetailViewModel extends _$FolderDetailViewModel {
  @override
  FolderDetailState build(String folderId) {
    return _sampleFolderDetails[folderId] ?? _fallbackFolderDetail(folderId);
  }

  void setMode(FolderDetailMode mode) {
    if (state.mode == mode) return;
    state = state.copyWith(mode: mode);
  }

  void createSubfolder(String name) {
    // TODO(folders): wire to CreateSubfolderUseCase when the domain lands.
  }

  void createDeck() {
    // TODO(folders): push a create-deck flow when it exists.
  }

  void openDeck(String id) {
    // TODO(decks): push deck-detail route.
  }

  void editFolder() {
    // TODO(folders): open edit-folder flow.
  }

  void deleteFolder() {
    // TODO(folders): confirm + delete.
  }

  void reorderChildren() {
    // TODO(folders): enter reorder mode.
  }
}

const List<FolderSubfolderItem> _sampleJapaneseN5Subfolders = [
  FolderSubfolderItem(
    id: 'vocab',
    name: 'Vocabulary',
    icon: Icons.auto_stories_outlined,
    caption: '4 decks · 180 cards',
  ),
  FolderSubfolderItem(
    id: 'grammar',
    name: 'Grammar',
    icon: Icons.menu_book_outlined,
    caption: '3 decks · 96 cards',
  ),
  FolderSubfolderItem(
    id: 'kanji',
    name: 'Kanji',
    icon: Icons.draw_outlined,
    caption: '5 decks · 220 cards',
  ),
];

const List<FolderDeckItem> _sampleVocabularyDecks = [
  FolderDeckItem(
    id: 'n5-core',
    name: 'N5 Core Vocabulary',
    cardCount: 42,
    dueToday: 8,
    masteryPercent: 72,
    tags: ['core', 'beginner'],
  ),
  FolderDeckItem(
    id: 'katakana',
    name: 'Katakana Loanwords',
    cardCount: 68,
    dueToday: 12,
    masteryPercent: 54,
    tags: ['katakana'],
  ),
  FolderDeckItem(
    id: 'verbs',
    name: 'Common Verbs',
    cardCount: 56,
    dueToday: 5,
    masteryPercent: 31,
    tags: ['verbs', 'grammar'],
  ),
  FolderDeckItem(
    id: 'adjectives',
    name: 'i-Adjectives',
    cardCount: 34,
    dueToday: 0,
    masteryPercent: 88,
    tags: ['adjectives'],
  ),
];

const Map<String, FolderDetailState> _sampleFolderDetails = {
  'n5': FolderDetailState(
    header: FolderDetailHeader(
      name: 'Japanese N5',
      breadcrumb: ['My Folders', 'Japanese N5'],
    ),
    mode: FolderDetailMode.subfolders,
    subfolders: _sampleJapaneseN5Subfolders,
    decks: _sampleVocabularyDecks,
  ),
  'vocab': FolderDetailState(
    header: FolderDetailHeader(
      name: 'Vocabulary',
      breadcrumb: ['My Folders', 'Japanese N5', 'Vocabulary'],
    ),
    mode: FolderDetailMode.decks,
    subfolders: [],
    decks: _sampleVocabularyDecks,
  ),
  'grammar': FolderDetailState(
    header: FolderDetailHeader(
      name: 'Grammar',
      breadcrumb: ['My Folders', 'Japanese N5', 'Grammar'],
    ),
    mode: FolderDetailMode.decks,
    subfolders: [],
    decks: _sampleVocabularyDecks,
  ),
  'kanji': FolderDetailState(
    header: FolderDetailHeader(
      name: 'Kanji',
      breadcrumb: ['My Folders', 'Japanese N5', 'Kanji'],
    ),
    mode: FolderDetailMode.decks,
    subfolders: [],
    decks: _sampleVocabularyDecks,
  ),
  'daily': FolderDetailState(
    header: FolderDetailHeader(
      name: 'Daily Vocabulary',
      breadcrumb: ['My Folders', 'Daily Vocabulary'],
    ),
    mode: FolderDetailMode.decks,
    subfolders: [],
    decks: _sampleVocabularyDecks,
  ),
};

FolderDetailState _fallbackFolderDetail(String folderId) {
  return FolderDetailState(
    header: FolderDetailHeader(
      name: folderId,
      breadcrumb: ['My Folders', folderId],
    ),
    mode: FolderDetailMode.decks,
    subfolders: const [],
    decks: _sampleVocabularyDecks,
  );
}
