import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/states/mx_empty_state.dart';

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
