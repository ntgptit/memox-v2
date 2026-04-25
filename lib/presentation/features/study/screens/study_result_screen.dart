import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_error_state.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../providers/study_session_notifier.dart';

class StudyResultScreen extends ConsumerWidget {
  const StudyResultScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessionState = ref.watch(studySessionStateProvider(sessionId));
    final actionState = ref.watch(
      studySessionActionControllerProvider(sessionId),
    );

    return MxScaffold(
      title: l10n.studyResultTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: sessionState.when(
          loading: () => const _StudyResultLoadingView(),
          error: (error, stackTrace) => MxErrorState(
            title: l10n.sharedErrorTitle,
            message: studyErrorMessage(error),
            onRetry: () => ref.invalidate(studySessionStateProvider(sessionId)),
          ),
          data: (snapshot) => ListView(
            children: [
              MxText(l10n.studyResultHeading, role: MxTextRole.pageTitle),
              const MxGap(MxSpace.sm),
              MxText(
                _statusLabel(l10n, snapshot.session.status),
                role: MxTextRole.contentBody,
              ),
              const MxGap(MxSpace.xl),
              MxCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MetricRow(
                      label: l10n.studyResultCards,
                      value: '${snapshot.summary.totalCards}',
                    ),
                    _MetricRow(
                      label: l10n.studyResultAttempts,
                      value: '${snapshot.summary.completedAttempts}',
                    ),
                    _MetricRow(
                      label: l10n.studyResultCorrect,
                      value: '${snapshot.summary.correctAttempts}',
                    ),
                    _MetricRow(
                      label: l10n.studyResultIncorrect,
                      value: '${snapshot.summary.incorrectAttempts}',
                    ),
                    _MetricRow(
                      label: l10n.studyResultBoxUp,
                      value: '${snapshot.summary.increasedBoxCount}',
                    ),
                    _MetricRow(
                      label: l10n.studyResultBoxDown,
                      value: '${snapshot.summary.decreasedBoxCount}',
                    ),
                    _MetricRow(
                      label: l10n.studyResultRemaining,
                      value: '${snapshot.summary.remainingCount}',
                    ),
                  ],
                ),
              ),
              const MxGap(MxSpace.xl),
              if (snapshot.session.status == SessionStatus.failedToFinalize)
                MxPrimaryButton(
                  label: l10n.studyRetryFinalizeAction,
                  leadingIcon: Icons.refresh_rounded,
                  isLoading: actionState.isLoading,
                  onPressed: () => ref
                      .read(
                        studySessionActionControllerProvider(
                          sessionId,
                        ).notifier,
                      )
                      .finalizeSession(),
                ),
              if (snapshot.session.status != SessionStatus.failedToFinalize)
                MxSecondaryButton(
                  label: l10n.commonBack,
                  leadingIcon: Icons.arrow_back_rounded,
                  onPressed: context.goLibrary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, SessionStatus status) {
    return switch (status) {
      SessionStatus.completed => l10n.studyResultCompleted,
      SessionStatus.cancelled => l10n.studyResultCancelled,
      SessionStatus.failedToFinalize => l10n.studyResultFailedFinalize,
      SessionStatus.readyToFinalize => l10n.studyResultReadyFinalize,
      SessionStatus.inProgress => l10n.studyResultInProgress,
      SessionStatus.draft => l10n.studyResultDraft,
    };
  }
}

class _StudyResultLoadingView extends StatelessWidget {
  const _StudyResultLoadingView();

  @override
  Widget build(BuildContext context) {
    return const MxLoadingState();
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MxSpace.xs),
      child: Row(
        children: [
          Expanded(child: MxText(label, role: MxTextRole.contentBody)),
          MxText(value, role: MxTextRole.tileTrailing),
        ],
      ),
    );
  }
}
