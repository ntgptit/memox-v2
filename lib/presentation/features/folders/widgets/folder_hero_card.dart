import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_action_button.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_card_actions.dart';
import '../../../shared/widgets/mx_progress_ring.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/folder_detail_viewmodel.dart';

/// Decks-mode hero for Folder Detail, per Design System mobile UI kit
/// "04 · Folder detail / decks". Combines the folder mastery ring, the
/// deck/card summary line, and the folder-scoped Start study CTA into a single
/// soft gradient hero card (`MxCard.heroGradient`) so the decks state matches
/// the mock surface (subtle primary→secondary wash, quiet border, light shadow
/// — not a saturated accent fill).
///
/// Mirrors the established Deck Detail mastery hero (`MxProgressRingSize.hero`)
/// and reuses the shared card-action hierarchy (`MxCardActions`) rather than a
/// raw full-width button — the action-hierarchy contract owns CTA layout.
///
/// The card never starts a session itself: [onStartStudyDue] /
/// [onStartStudyFolder] route into the Study Entry Gate (the gate owns
/// empty-scope validation, resume conflict, and session creation).
///
/// `{n} new` from the mock stays out: there is no read model backing a folder
/// "new" count, so it must not be rendered with a placeholder value.
class FolderHeroCard extends StatelessWidget {
  const FolderHeroCard({
    required this.deckCount,
    required this.cardCount,
    required this.masteryPercent,
    required this.dueCount,
    required this.onStartStudyDue,
    required this.onStartStudyFolder,
    super.key,
  });

  /// Builds the hero from the decks-mode read model, deriving the deck count,
  /// total cards, and average mastery from [decks]. [dueCount] comes from the
  /// recursive folder study-entry scope so it stays consistent with the gate.
  factory FolderHeroCard.fromDecks({
    required List<FolderDeckItem> decks,
    required int dueCount,
    required VoidCallback onStartStudyDue,
    required VoidCallback onStartStudyFolder,
    Key? key,
  }) {
    final cardCount = decks.fold<int>(0, (sum, item) => sum + item.cardCount);
    final masteryPercent = decks.isEmpty
        ? 0
        : (decks.fold<int>(0, (sum, item) => sum + item.masteryPercent) /
                  decks.length)
              .round();
    return FolderHeroCard(
      key: key,
      deckCount: decks.length,
      cardCount: cardCount,
      masteryPercent: masteryPercent,
      dueCount: dueCount,
      onStartStudyDue: onStartStudyDue,
      onStartStudyFolder: onStartStudyFolder,
    );
  }

  /// Number of direct decks in the folder.
  final int deckCount;

  /// Total flashcards across the folder's decks.
  final int cardCount;

  /// Average mastery across the folder's decks, in `[0, 100]`.
  final int masteryPercent;

  /// Recursive due-card count for the folder scope. Drives the CTA: `> 0`
  /// surfaces the due-review primary, `0` surfaces a plain Start study.
  final int dueCount;

  /// Enters the Study Entry Gate for a folder-scoped SRS review (due cards).
  final VoidCallback onStartStudyDue;

  /// Enters the Study Entry Gate for a folder-scoped new study (all cards).
  final VoidCallback onStartStudyFolder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasDue = dueCount > 0;

    return MxCard(
      key: const ValueKey('folder_study_card'),
      variant: MxCardVariant.heroGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MxProgressRing(
                value: masteryPercent / 100,
                size: MxProgressRingSize.hero,
              ),
              const MxGap(MxSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MxText(
                      StringUtils.upperCaseToEmpty(
                        l10n.folderDetailMasteryOverline,
                      ),
                      role: MxTextRole.overline,
                    ),
                    const MxGap(MxSpace.xs),
                    MxText(
                      l10n.folderDetailDeckCountAndCards(deckCount, cardCount),
                      role: MxTextRole.tileTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const MxGap(MxSpace.xxs),
                    MxText(
                      hasDue
                          ? l10n.folderDetailDueCount(dueCount)
                          : l10n.libraryDeckAllCaughtUp,
                      role: MxTextRole.tileMeta,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const MxGap(MxSpace.md),
          MxCardActions(
            primary: hasDue
                ? MxActionButton(
                    key: const ValueKey('folder_study_today_action'),
                    intent: MxActionIntent.cardPrimary,
                    label: l10n.folderDetailStartStudyDueAction(dueCount),
                    leadingIcon: Icons.play_arrow_rounded,
                    onPressed: onStartStudyDue,
                  )
                : MxActionButton(
                    key: const ValueKey('folder_study_folder_action'),
                    intent: MxActionIntent.cardPrimary,
                    label: l10n.folderDetailStartStudyAction,
                    leadingIcon: Icons.play_arrow_rounded,
                    onPressed: onStartStudyFolder,
                  ),
            secondary: hasDue
                ? MxActionButton(
                    key: const ValueKey('folder_study_folder_action'),
                    intent: MxActionIntent.cardSecondary,
                    label: l10n.folderStudyFolderAction,
                    leadingIcon: Icons.folder_outlined,
                    onPressed: onStartStudyFolder,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
