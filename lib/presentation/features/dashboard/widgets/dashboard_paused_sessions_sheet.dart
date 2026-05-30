import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_action_button.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_card_actions.dart';
import '../../../shared/widgets/mx_progress_indicator.dart';
import '../../../shared/widgets/mx_text.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';
import 'dashboard_resume_section.dart';

/// Opens the paused-sessions bottom sheet listing every resumable session.
///
/// [context] is the host (Dashboard) context, captured so navigation survives
/// the sheet closing. Used by the Dashboard resume card "+ N more paused
/// sessions" link.
Future<void> showDashboardPausedSessionsSheet(
  BuildContext context,
  WidgetRef ref,
  List<DashboardResumeSessionItem> sessions,
) {
  final l10n = AppLocalizations.of(context);
  return MxBottomSheet.show<void>(
    context: context,
    title: l10n.dashboardPausedSessionsSheetTitle(sessions.length),
    child: DashboardPausedSessionsSheet(
      key: const ValueKey('dashboard_paused_sessions_sheet'),
      initialSessions: sessions,
      onResume: (sheetContext, session) {
        Navigator.of(sheetContext).pop();
        context.goStudySession(session.sessionId);
      },
    ),
  );
}

class DashboardPausedSessionsSheet extends ConsumerWidget {
  const DashboardPausedSessionsSheet({
    required this.initialSessions,
    required this.onResume,
    super.key,
  });

  final List<DashboardResumeSessionItem> initialSessions;
  final void Function(BuildContext sheetContext, DashboardResumeSessionItem session)
  onResume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stay live: reflect discards as the Dashboard overview refreshes.
    final sessions =
        ref.watch(dashboardOverviewProvider).value?.resumeSessions ??
        initialSessions;

    if (sessions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) unawaited(Navigator.of(context).maybePop());
      });
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < sessions.length; index++) ...[
          _PausedSessionRow(
            session: sessions[index],
            onResume: onResume,
          ),
          if (index < sessions.length - 1) const MxGap(MxSpace.sm),
        ],
      ],
    );
  }
}

class _PausedSessionRow extends ConsumerWidget {
  const _PausedSessionRow({required this.session, required this.onResume});

  final DashboardResumeSessionItem session;
  final void Function(BuildContext sheetContext, DashboardResumeSessionItem session)
  onResume;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return MxCard(
      key: ValueKey('dashboard_paused_session_${session.sessionId}'),
      variant: MxCardVariant.outlined,
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
              key: ValueKey('dashboard_paused_resume_${session.sessionId}'),
              intent: MxActionIntent.cardPrimary,
              label: l10n.studyResumeAction,
              leadingIcon: Icons.play_arrow_rounded,
              onPressed: () => onResume(context, session),
            ),
            secondary: MxActionButton(
              key: ValueKey('dashboard_paused_discard_${session.sessionId}'),
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
