import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../../domain/study/entities/empty_scope_reason.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/widgets/mx_empty_state.dart';

/// Dedicated empty-state screen rendered when [EmptyScopeException] aborts a
/// study-session start. Spec: `docs/business/study/study-flow.md` §Empty
/// scope matrix. Implements all six Tier 1 (P0-1) cases.
///
/// The screen owns CTA wiring — each [EmptyScopeReason] maps to one navigation
/// intent. Tier 2 (`tag`) and Tier 3 (`allBuried`/`allSuspended`) reasons are
/// not yet part of [EmptyScopeReason]; they remain blocked.
class EmptyScopeScreen extends StatelessWidget {
  const EmptyScopeScreen({
    required this.failure,
    required this.entryType,
    required this.entryRefId,
    super.key,
  });

  final EmptyScopeException failure;

  /// Raw entry-type segment forwarded from `study_entry_screen.dart`
  /// (`deck` / `folder` / `today`). Used to re-enter study for the
  /// "Study new instead" CTA.
  final String entryType;

  /// Forwarded from `study_entry_screen.dart`; the `deckId` for deck reasons
  /// or `folderId` for folder reasons. Null for today-scoped reasons.
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
          EmptyScopeReason.deckNoDueCards => _noDueCards(
            context,
            l10n,
            title: l10n.studyEmpty_deck_noDueCards_title,
            ctaLabel: l10n.studyEmpty_deck_noDueCards_cta,
            subtitle: l10n.studyEmpty_deck_noDueCards_subtitle,
          ),
          EmptyScopeReason.folderNoCards => _folderNoCards(context, l10n),
          EmptyScopeReason.folderNoDueCards => _noDueCards(
            context,
            l10n,
            title: l10n.studyEmpty_folder_noDueCards_title,
            ctaLabel: l10n.studyEmpty_folder_noDueCards_cta,
            subtitle: l10n.studyEmpty_folder_noDueCards_subtitle,
          ),
          EmptyScopeReason.todayAllDone => _todayAllDone(context, l10n),
          EmptyScopeReason.todayNoContent => _todayNoContent(context, l10n),
          EmptyScopeReason.allBuried => _allBuried(context, l10n),
          EmptyScopeReason.allSuspended => _allSuspended(context, l10n),
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

  /// Shared layout for `deck_noDueCards` and `folder_noDueCards`. The subtitle
  /// is only rendered when a future due date exists (spec: study-flow.md
  /// §"Next due" calculation — omit the line otherwise).
  Widget _noDueCards(
    BuildContext context,
    AppLocalizations l10n, {
    required String title,
    required String ctaLabel,
    required String Function(String relativeTime) subtitle,
  }) {
    final relativeTime = _relativeNextDue(l10n, failure.nextDueAt);
    return MxEmptyState(
      icon: Icons.check_circle_outline,
      title: title,
      message: relativeTime == null ? null : subtitle(relativeTime),
      actionLabel: ctaLabel,
      actionLeadingIcon: Icons.school_outlined,
      onAction: () => _studyNewInstead(context),
    );
  }

  Widget _folderNoCards(BuildContext context, AppLocalizations l10n) {
    final folderId = entryRefId;
    return MxEmptyState(
      icon: Icons.folder_open_outlined,
      title: l10n.studyEmpty_folder_noCards_title,
      actionLabel: l10n.studyEmpty_folder_noCards_cta,
      actionLeadingIcon: Icons.add,
      onAction: folderId == null ? null : () => context.goFolderDetail(folderId),
    );
  }

  Widget _allBuried(BuildContext context, AppLocalizations l10n) => MxEmptyState(
    icon: Icons.bedtime_outlined,
    title: l10n.studyEmpty_allBuried_title,
    message: l10n.studyEmpty_allBuried_message,
    actionLabel: l10n.studyEmpty_allBuried_cta,
    actionLeadingIcon: Icons.school_outlined,
    onAction: entryRefId == null
        ? () => context.goHome()
        : () => _studyNewInstead(context),
  );

  Widget _allSuspended(BuildContext context, AppLocalizations l10n) =>
      MxEmptyState(
        icon: Icons.pause_circle_outline,
        title: l10n.studyEmpty_allSuspended_title,
        message: l10n.studyEmpty_allSuspended_message,
        actionLabel: l10n.studyEmpty_allSuspended_cta,
        actionLeadingIcon: Icons.style_outlined,
        onAction: () => _viewScope(context),
      );

  /// Navigates to where the user can manage (e.g. unsuspend) the scope's cards.
  void _viewScope(BuildContext context) {
    final refId = entryRefId;
    if (refId == null) {
      context.goLibrary();
      return;
    }
    if (entryType == StudyEntryType.folder.storageValue) {
      context.goFolderDetail(refId);
      return;
    }
    context.goFlashcardList(refId);
  }

  Widget _todayAllDone(BuildContext context, AppLocalizations l10n) =>
      MxEmptyState(
        icon: Icons.task_alt_outlined,
        title: l10n.studyEmpty_today_allDone_title,
        message: l10n.studyEmpty_today_allDone_message,
        actionLabel: l10n.studyEmpty_today_allDone_cta,
        actionLeadingIcon: Icons.home_outlined,
        onAction: () => context.goHome(),
      );

  Widget _todayNoContent(BuildContext context, AppLocalizations l10n) =>
      MxEmptyState(
        icon: Icons.library_books_outlined,
        title: l10n.studyEmpty_today_noContent_title,
        actionLabel: l10n.studyEmpty_today_noContent_cta,
        actionLeadingIcon: Icons.add,
        onAction: () => context.goLibrary(),
      );

  /// Re-enters the study entry for the same scope. Deck and folder entries
  /// default to New Study (see `study_entry_screen.dart` `_defaultStudyType`),
  /// so this switches the flow away from the empty SRS-review queue.
  void _studyNewInstead(BuildContext context) {
    final refId = entryRefId;
    if (refId == null) {
      return;
    }
    context.goStudyEntry(
      entryType: entryType,
      entryRefId: refId,
      preserveStack: false,
    );
  }

  /// Formats [nextDueAt] into a localized relative fragment ("in 3 days",
  /// "in 2 hours", "soon"). Returns null when there is no future due date.
  String? _relativeNextDue(AppLocalizations l10n, DateTime? nextDueAt) {
    if (nextDueAt == null) {
      return null;
    }
    final remaining = nextDueAt.difference(DateTime.now());
    if (remaining.inHours < 1) {
      return l10n.studyEmptyNextDueSoon;
    }
    if (remaining.inHours < 24) {
      return l10n.studyEmptyNextDueInHours(remaining.inHours);
    }
    return l10n.studyEmptyNextDueInDays(remaining.inDays);
  }
}
