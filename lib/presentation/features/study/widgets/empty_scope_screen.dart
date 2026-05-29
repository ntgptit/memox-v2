import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/study/entities/empty_scope_reason.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/widgets/mx_empty_state.dart';

/// Dedicated empty-state screen rendered when [EmptyScopeException] aborts a
/// study-session start. Spec: `docs/business/study/study-flow.md` §Empty
/// scope matrix. Currently implements `deck_noCards` (Tier 1, P0-1).
///
/// Tier 1 remaining cases (deckNoDueCards, folderNoCards, folderNoDueCards,
/// todayAllDone, todayNoContent) will branch in the switch below in the
/// follow-up PR. The screen owns CTA wiring — each reason maps to one
/// navigation intent.
class EmptyScopeScreen extends StatelessWidget {
  const EmptyScopeScreen({
    required this.failure,
    required this.entryRefId,
    super.key,
  });

  final EmptyScopeException failure;

  /// Forwarded from `study_entry_screen.dart`; for deck-scoped reasons this
  /// is the `deckId`. May be null for non-deck reasons (none yet).
  final String? entryRefId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxScaffold(
      title: l10n.studyEntryTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        child: switch (failure.reason) {
          EmptyScopeReason.deckNoCards => _deckNoCards(context, l10n),
        },
      ),
    );
  }

  Widget _deckNoCards(BuildContext context, AppLocalizations l10n) {
    final deckId = entryRefId;
    return MxEmptyState(
      icon: Icons.style_outlined,
      title: l10n.studyEmpty_deck_noCards_title,
      actionLabel: l10n.studyEmpty_deck_noCards_cta,
      actionLeadingIcon: Icons.add,
      onAction: deckId == null
          ? null
          : () => context.pushFlashcardCreate(deckId),
    );
  }
}
