import '../entities/deck_entity.dart';
import '../entities/flashcard_entity.dart';
import '../entities/folder_entity.dart';
import '../enums/folder_content_mode.dart';

final class BreadcrumbSegmentReadModel {
  const BreadcrumbSegmentReadModel({required this.label, this.folderId});

  final String label;
  final String? folderId;
}

final class LibraryFolderReadModel {
  const LibraryFolderReadModel({
    required this.folder,
    required this.breadcrumb,
    required this.subfolderCount,
    required this.deckCount,
    required this.itemCount,
    required this.dueCardCount,
    required this.newCardCount,
    required this.masteryPercent,
    required this.lastStudiedAt,
  });

  final FolderEntity folder;
  final List<String> breadcrumb;
  final int subfolderCount;
  final int deckCount;
  final int itemCount;
  final int dueCardCount;
  final int newCardCount;
  final int masteryPercent;
  final int? lastStudiedAt;
}

final class LibraryOverviewReadModel {
  const LibraryOverviewReadModel({
    required this.overdueCount,
    required this.dueTodayCount,
    required this.newCardCount,
    required this.totalFolderCount,
    required this.folders,
  });

  final int overdueCount;
  final int dueTodayCount;
  final int newCardCount;
  final int totalFolderCount;
  final List<LibraryFolderReadModel> folders;

  int get deckCount =>
      folders.fold<int>(0, (sum, folder) => sum + folder.deckCount);

  int get cardCount =>
      folders.fold<int>(0, (sum, folder) => sum + folder.itemCount);

  int get masteryPercent {
    final totalCardCount = cardCount;
    if (totalCardCount == 0) {
      return 0;
    }
    final weightedMasteryTotal = folders.fold<int>(
      0,
      (sum, folder) => sum + folder.itemCount * folder.masteryPercent,
    );
    return (weightedMasteryTotal / totalCardCount).round();
  }
}

/// Lightweight folder option used by scope pickers (e.g. Dashboard "Start new
/// learning" → Folder scope). Pure read model: identifies a folder by [id] and
/// [name] plus the ancestor [breadcrumb] (root → leaf, including the folder
/// itself as the last segment) so duplicate names can be disambiguated.
final class FolderScopeOption {
  const FolderScopeOption({
    required this.id,
    required this.name,
    required this.breadcrumb,
  });

  final String id;
  final String name;
  final List<String> breadcrumb;

  /// Ancestor names without the folder itself, for showing parent context.
  List<String> get parentBreadcrumb =>
      breadcrumb.isEmpty ? const <String>[] : breadcrumb.sublist(0, breadcrumb.length - 1);
}

final class FolderDeckReadModel {
  const FolderDeckReadModel({
    required this.deck,
    required this.cardCount,
    required this.dueTodayCount,
    required this.masteryPercent,
    required this.lastStudiedAt,
  });

  final DeckEntity deck;
  final int cardCount;
  final int dueTodayCount;
  final int masteryPercent;
  final int? lastStudiedAt;
}

final class DeckHighlightReadModel {
  const DeckHighlightReadModel({
    required this.deck,
    required this.cardCount,
    required this.dueTodayCount,
    required this.masteryPercent,
    required this.lastStudiedAt,
  });

  final DeckEntity deck;
  final int cardCount;
  final int dueTodayCount;
  final int masteryPercent;
  final int? lastStudiedAt;
}

final class FolderSubfolderReadModel {
  const FolderSubfolderReadModel({
    required this.folder,
    required this.subfolderCount,
    required this.deckCount,
    required this.itemCount,
    required this.dueCardCount,
    required int? masteryPercent,
  }) : _masteryPercent = masteryPercent;

  final FolderEntity folder;
  final int subfolderCount;
  final int deckCount;
  final int itemCount;
  final int dueCardCount;
  final int? _masteryPercent;

  int get masteryPercent => _masteryPercent ?? 0;
}

final class FolderDetailReadModel {
  const FolderDetailReadModel({
    required this.folder,
    required this.breadcrumb,
    required this.subfolders,
    required this.decks,
    required this.hasUnfilteredChildren,
  });

  final FolderEntity folder;
  final List<FolderSubfolderReadModel> subfolders;
  final List<FolderDeckReadModel> decks;
  final List<BreadcrumbSegmentReadModel> breadcrumb;

  /// Whether this folder has any direct child (subfolder or deck) ignoring the
  /// active search filter. Lets the UI tell a genuinely empty folder apart from
  /// a search that filtered every row out (true empty vs search no-results).
  final bool hasUnfilteredChildren;

  FolderContentMode get effectiveContentMode {
    if (folder.contentMode != FolderContentMode.unlocked) {
      return folder.contentMode;
    }
    if (subfolders.isNotEmpty) {
      return FolderContentMode.subfolders;
    }
    if (decks.isNotEmpty) {
      return FolderContentMode.decks;
    }
    return FolderContentMode.unlocked;
  }
}

final class DeckActionContextReadModel {
  const DeckActionContextReadModel({
    required this.deck,
    required this.breadcrumb,
  });

  final DeckEntity deck;
  final List<BreadcrumbSegmentReadModel> breadcrumb;
}

final class FlashcardListItemReadModel {
  const FlashcardListItemReadModel({
    required this.flashcard,
    required this.lastStudiedAt,
  });

  final FlashcardEntity flashcard;
  final int? lastStudiedAt;
}

final class FlashcardDeckProgressReadModel {
  const FlashcardDeckProgressReadModel({
    required this.newCount,
    required this.learningCount,
    required this.masteredCount,
    required this.masteryPercent,
  });

  final int newCount;
  final int learningCount;
  final int masteredCount;
  final int masteryPercent;
}

final class FlashcardListReadModel {
  const FlashcardListReadModel({
    required this.deck,
    required this.breadcrumb,
    required this.progress,
    required this.items,
  });

  final DeckEntity deck;
  final List<BreadcrumbSegmentReadModel> breadcrumb;
  final FlashcardDeckProgressReadModel progress;
  final List<FlashcardListItemReadModel> items;
}
