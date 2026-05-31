import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/widgets/mx_empty_state.dart';

class FlashcardEmptyStateSection extends StatelessWidget {
  const FlashcardEmptyStateSection({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      title: l10n.flashcardsEmptyTitle,
      message: l10n.flashcardsEmptyMessage,
      icon: Icons.style_outlined,
      actionLabel: l10n.flashcardsAddAction,
      actionLeadingIcon: Icons.add,
      onAction: () => context.pushFlashcardCreate(deckId),
    );
  }
}

/// Shown when the deck has cards but the active search term filters them all
/// out. Distinct from [FlashcardEmptyStateSection] (true empty deck) so the
/// user is offered "Clear search" instead of a create CTA.
class FlashcardNoResultsSection extends StatelessWidget {
  const FlashcardNoResultsSection({required this.onClearSearch, super.key});

  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      key: const ValueKey('flashcard_no_results'),
      title: l10n.flashcardsNoResultsTitle,
      message: l10n.flashcardsNoResultsMessage,
      icon: Icons.search_off_rounded,
      actionLabel: l10n.flashcardsClearSearchAction,
      actionLeadingIcon: Icons.close_rounded,
      onAction: onClearSearch,
    );
  }
}
