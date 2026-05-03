import 'package:flutter/widgets.dart';

/// View-layer model for a folder shown in the library overview.
///
/// UI-facing only: carries pre-resolved `IconData`, counts already formatted
/// from the domain, and a normalized mastery ratio. The feature viewmodel is
/// responsible for translating domain entities into this shape so the widget
/// can stay dumb.
@immutable
class LibraryFolder {
  const LibraryFolder({
    required this.id,
    required this.name,
    required this.icon,
    required int? subfolderCount,
    required this.deckCount,
    required this.itemCount,
    required this.dueCardCount,
    required this.newCardCount,
    required this.masteryPercent,
    required this.canImportFlashcards,
  }) : _subfolderCount = subfolderCount;

  final String id;
  final String name;
  final IconData icon;
  final int? _subfolderCount;
  final int deckCount;
  final int itemCount;
  final int dueCardCount;
  final int newCardCount;
  final bool canImportFlashcards;

  int get subfolderCount => _subfolderCount ?? 0;

  /// Mastery in `[0, 100]`.
  final int masteryPercent;
}
