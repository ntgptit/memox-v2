import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../domain/study/usecases/deck_study_entry_usecase.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_action_button.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_card_actions.dart';
import '../../../shared/widgets/mx_text.dart';

/// Deck-level study-entry banners for the Flashcard List, shown above the deck
/// summary. Mirrors the Folder Detail ownership pattern: this section never
/// starts a session itself.
///
/// Renders, in priority order (spec `docs/wireframes/06-flashcard-list.md`):
///   1. Resume banner  — when a paused deck-scoped session exists.
///   2. Today CTA       — when the deck has due cards (> 0).
///   3. Study deck CTA  — when the deck has any card (> 0).
///
/// Today / Study-deck route into the Study Entry Gate, and Resume opens the
/// existing session. When the deck has no cards and no resumable session, it
/// collapses to nothing.
class FlashcardStudyEntrySection extends StatelessWidget {
  const FlashcardStudyEntrySection({
    required this.entry,
    required this.onResume,
    required this.onDiscard,
    required this.onStudyToday,
    required this.onStudyDeck,
    super.key,
  });

  final DeckStudyEntry entry;

  /// Opens the existing resumable session ([DeckStudyEntry.resumeSessionId]).
  final ValueChanged<String> onResume;

  /// Discards the existing resumable session ([DeckStudyEntry.resumeSessionId])
  /// after confirmation. Never starts a session.
  final ValueChanged<String> onDiscard;

  /// Enters the Study Entry Gate for a deck-scoped SRS review (due cards).
  final VoidCallback onStudyToday;

  /// Enters the Study Entry Gate for a deck-scoped new study (all cards).
  final VoidCallback onStudyDeck;

  @override
  Widget build(BuildContext context) {
    final hasResume = entry.hasResume;
    final hasCards = entry.hasCards;
    if (!hasResume && !hasCards) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final children = <Widget>[];

    if (hasResume) {
      children.add(
        _ResumeBanner(
          sessionId: entry.resumeSessionId!,
          onResume: onResume,
          onDiscard: onDiscard,
        ),
      );
    }

    if (hasCards) {
      if (children.isNotEmpty) {
        children.add(const MxGap(MxSpace.sm));
      }
      children.add(
        _StudyCard(
          accent: !hasResume,
          subtitle: entry.hasDue
              ? l10n.deckStudyDueCount(entry.dueCount)
              : l10n.deckStudyCardCount(entry.totalCardCount),
          actions: MxCardActions(
            primary: entry.hasDue
                ? MxActionButton(
                    key: const ValueKey('deck_study_today_action'),
                    intent: MxActionIntent.cardPrimary,
                    label: l10n.deckStudyTodayAction,
                    leadingIcon: Icons.bolt_outlined,
                    onPressed: onStudyToday,
                  )
                : MxActionButton(
                    key: const ValueKey('deck_study_deck_action'),
                    intent: MxActionIntent.cardPrimary,
                    label: l10n.deckStudyDeckAction,
                    leadingIcon: Icons.play_arrow_rounded,
                    onPressed: onStudyDeck,
                  ),
            secondary: entry.hasDue
                ? MxActionButton(
                    key: const ValueKey('deck_study_deck_action'),
                    intent: MxActionIntent.cardSecondary,
                    label: l10n.deckStudyDeckAction,
                    leadingIcon: Icons.play_arrow_rounded,
                    onPressed: onStudyDeck,
                  )
                : null,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class _ResumeBanner extends StatelessWidget {
  const _ResumeBanner({
    required this.sessionId,
    required this.onResume,
    required this.onDiscard,
  });

  final String sessionId;
  final ValueChanged<String> onResume;
  final ValueChanged<String> onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxCard(
      key: const ValueKey('deck_resume_banner'),
      accent: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(l10n.studyResumeTitle, role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.xs),
          MxText(l10n.deckResumeMessage, role: MxTextRole.tileMeta),
          const MxGap(MxSpace.md),
          MxCardActions(
            primary: MxActionButton(
              key: const ValueKey('deck_resume_action'),
              intent: MxActionIntent.cardPrimary,
              label: l10n.studyResumeChoiceResumeAction,
              leadingIcon: Icons.play_arrow_rounded,
              onPressed: () => onResume(sessionId),
            ),
            secondary: MxActionButton(
              key: const ValueKey('deck_resume_discard_action'),
              intent: MxActionIntent.cardSecondary,
              label: l10n.dashboardDiscardAction,
              leadingIcon: Icons.delete_outline_rounded,
              isDestructive: true,
              onPressed: () => onDiscard(sessionId),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudyCard extends StatelessWidget {
  const _StudyCard({
    required this.accent,
    required this.subtitle,
    required this.actions,
  });

  final bool accent;
  final String subtitle;
  final MxCardActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxCard(
      key: const ValueKey('deck_study_card'),
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(l10n.deckStudyEntryTitle, role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.xs),
          MxText(subtitle, role: MxTextRole.tileMeta),
          const MxGap(MxSpace.md),
          actions,
        ],
      ),
    );
  }
}
