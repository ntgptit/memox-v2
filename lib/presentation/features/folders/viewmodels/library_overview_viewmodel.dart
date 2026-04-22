import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/library_folder.dart';

part 'library_overview_viewmodel.g.dart';

/// Static greeting values used by the library overview until an account /
/// schedule use case is wired in. Grouped as an immutable class so the
/// viewmodel returns a single value object rather than multiple providers.
@immutable
class LibraryOverviewGreeting {
  const LibraryOverviewGreeting({
    required this.salutation,
    required this.userName,
    required this.dueToday,
  });

  final String salutation;
  final String userName;
  final int dueToday;
}

/// UI state for the library overview screen.
@immutable
class LibraryOverviewState {
  const LibraryOverviewState({
    required this.greeting,
    required this.folders,
  });

  final LibraryOverviewGreeting greeting;
  final List<LibraryFolder> folders;

  bool get isEmpty => folders.isEmpty;
}

/// Library-overview viewmodel.
///
/// Exposes a synchronous [LibraryOverviewState]. Sample data lives here
/// (previously inline in the screen) so the widget stays render-only.
/// When the folder repository lands, swap the sync `build()` for an
/// `AsyncNotifier` that watches a repository provider.
@riverpod
class LibraryOverviewViewModel extends _$LibraryOverviewViewModel {
  @override
  LibraryOverviewState build() {
    return const LibraryOverviewState(
      greeting: LibraryOverviewGreeting(
        salutation: 'Good morning',
        userName: 'Alex',
        dueToday: 12,
      ),
      folders: _sampleFolders,
    );
  }

  /// Placeholder for the "create folder" FAB action. Kept here so the FAB
  /// handler in the screen stays a one-liner.
  void createFolder() {
    // TODO(folders): wire to CreateFolderUseCase once the domain exists.
  }

  /// Placeholder for the tile tap handler.
  void openFolder(String folderId) {
    // TODO(folders): push the folder-detail route once it exists.
  }
}

// -----------------------------------------------------------------------------
// Sample data
//
// TODO(folders): replace with a derived provider that maps from the domain
// folder entity list once the folder repository lands. The view contract
// (`List<LibraryFolder>`) stays stable across this swap.
// -----------------------------------------------------------------------------
const List<LibraryFolder> _sampleFolders = [
  LibraryFolder(
    id: 'n5',
    name: 'Japanese N5',
    icon: Icons.language_outlined,
    deckCount: 5,
    itemCount: 128,
    masteryPercent: 72,
  ),
  LibraryFolder(
    id: 'daily',
    name: 'Daily Vocabulary',
    icon: Icons.auto_stories_outlined,
    deckCount: 3,
    itemCount: 86,
    masteryPercent: 45,
  ),
  LibraryFolder(
    id: 'grammar',
    name: 'Grammar Basics',
    icon: Icons.menu_book_outlined,
    deckCount: 4,
    itemCount: 102,
    masteryPercent: 58,
  ),
  LibraryFolder(
    id: 'kanji',
    name: 'Kanji Practice',
    icon: Icons.draw_outlined,
    deckCount: 6,
    itemCount: 240,
    masteryPercent: 31,
  ),
  LibraryFolder(
    id: 'phrases',
    name: 'Conversation Phrases',
    icon: Icons.chat_bubble_outline,
    deckCount: 2,
    itemCount: 54,
    masteryPercent: 88,
  ),
];
