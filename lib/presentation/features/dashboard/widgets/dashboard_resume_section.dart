import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../shared/dialogs/mx_confirmation_dialog.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_action_button.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_card_actions.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../progress/providers/progress_session_notifier.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';
import 'dashboard_paused_sessions_sheet.dart';

/// Resume section shown at the top of the Dashboard whenever a resumable
/// (paused) study session exists. Renders the most-recent session as a compact
/// card with Continue / Discard card actions, plus a link to the full
/// paused-sessions sheet when more than one session is paused.
class DashboardResumeSection extends ConsumerWidget {
  const DashboardResumeSection({required this.sessions, super.key});

  final List<DashboardResumeSessionItem> sessions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sessions.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final primary = sessions.first;
    final extraCount = sessions.length - 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MxText(l10n.dashboardResumeSectionTitle, role: MxTextRole.formLabel),
        const MxGap(MxSpace.sm),
        DashboardResumeCard(
          key: const ValueKey('dashboard_resume_card'),
          session: primary,
        ),
        if (extraCount > 0) ...[
          const MxGap(MxSpace.xs),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: MxSecondaryButton(
              key: const ValueKey('dashboard_more_paused_sessions'),
              label: l10n.dashboardMorePausedSessions(extraCount),
              variant: MxSecondaryVariant.text,
              onPressed: () =>
                  showDashboardPausedSessionsSheet(context, ref, sessions),
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact resume card for a single paused session.
class DashboardResumeCard extends ConsumerWidget {
  const DashboardResumeCard({required this.session, super.key});

  final DashboardResumeSessionItem session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(resumeSessionTitle(l10n, session), role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.sm),
          MxLinearProgress(value: session.progress),
          const MxGap(MxSpace.xs),
          MxText(
            l10n.progressSessionCardProgress(
              session.completedSteps,
              session.totalSteps,
              session.remainingCount,
            ),
            role: MxTextRole.tileMeta,
          ),
          const MxGap(MxSpace.md),
          MxCardActions(
            primary: MxActionButton(
              key: const ValueKey('dashboard_resume_continue_action'),
              intent: MxActionIntent.cardPrimary,
              label: l10n.studyResumeAction,
              leadingIcon: Icons.play_arrow_rounded,
              onPressed: () => context.goStudySession(session.sessionId),
            ),
            secondary: MxActionButton(
              key: const ValueKey('dashboard_resume_discard_action'),
              intent: MxActionIntent.cardSecondary,
              label: l10n.dashboardDiscardAction,
              leadingIcon: Icons.delete_outline_rounded,
              isDestructive: true,
              onPressed: () => discardDashboardSession(context, ref, session),
            ),
          ),
        ],
      ),
    );
  }
}

/// Title for a resume session: "{studyType} · {entryType}".
String resumeSessionTitle(
  AppLocalizations l10n,
  DashboardResumeSessionItem session,
) => l10n.progressSessionTitle(
  _studyTypeLabel(l10n, session.studyType),
  _entryTypeLabel(l10n, session.entryType),
);

String _studyTypeLabel(AppLocalizations l10n, StudyType studyType) =>
    switch (studyType) {
      StudyType.newStudy => l10n.studyTypeNew,
      StudyType.srsReview => l10n.studyTypeReview,
    };

String _entryTypeLabel(AppLocalizations l10n, StudyEntryType entryType) =>
    switch (entryType) {
      StudyEntryType.deck => l10n.progressEntryDeck,
      StudyEntryType.folder => l10n.progressEntryFolder,
      StudyEntryType.today => l10n.progressEntryToday,
    };

/// Confirms and discards a paused session through the use-case path
/// ([progressSessionActionControllerProvider] → CancelStudySessionUseCase),
/// which bumps the study-session revision so the Dashboard refreshes.
Future<void> discardDashboardSession(
  BuildContext context,
  WidgetRef ref,
  DashboardResumeSessionItem session,
) async {
  final l10n = AppLocalizations.of(context);
  final confirmed = await MxConfirmationDialog.show(
    context: context,
    title: l10n.dashboardDiscardSessionTitle,
    message: l10n.dashboardDiscardSessionMessage,
    confirmLabel: l10n.dashboardDiscardAction,
    icon: Icons.delete_outline_rounded,
    tone: MxConfirmationTone.danger,
  );
  if (!context.mounted) return;
  if (!confirmed) return;
  final success = await ref
      .read(progressSessionActionControllerProvider.notifier)
      .cancel(session.sessionId);
  if (!context.mounted) return;
  if (!success) {
    MxSnackbar.error(context, l10n.dashboardSessionDiscardFailedMessage);
    return;
  }
  MxSnackbar.success(context, l10n.dashboardSessionDiscardedMessage);
}
