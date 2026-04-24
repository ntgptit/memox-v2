import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/theme/mx_gap.dart';
import '../../../../domain/enums/study_enums.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_error_state.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../providers/study_session_notifier.dart';
import '../study_labels.dart';
import '../widgets/study_session/study_mode_panel.dart';

class StudySessionScreen extends ConsumerWidget {
  const StudySessionScreen({required this.sessionId, super.key});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessionState = ref.watch(studySessionStateProvider(sessionId));
    final actionState = ref.watch(
      studySessionActionControllerProvider(sessionId),
    );
    final canCancel =
        sessionState.whenOrNull(
          data: (snapshot) =>
              snapshot.session.status != SessionStatus.completed &&
              snapshot.session.status != SessionStatus.cancelled,
        ) ??
        false;

    ref.listen<AsyncValue<void>>(
      studySessionActionControllerProvider(sessionId),
      (_, next) {
        if (next.hasError) {
          MxSnackbar.error(context, studyErrorMessage(next.error));
        }
      },
    );

    return MxScaffold(
      title: l10n.studySessionTitle,
      actions: [
        if (canCancel)
          MxIconButton(
            tooltip: l10n.studyCancelAction,
            onPressed: actionState.isLoading
                ? null
                : () => _cancel(context, ref, sessionId),
            icon: Icons.close_rounded,
          ),
      ],
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: sessionState.when(
          loading: () => const _StudySessionLoadingView(),
          error: (error, stackTrace) => MxErrorState(
            title: l10n.sharedErrorTitle,
            message: studyErrorMessage(error),
            onRetry: () => ref.invalidate(studySessionStateProvider(sessionId)),
          ),
          data: (snapshot) {
            if (snapshot.session.status == SessionStatus.completed ||
                snapshot.session.status == SessionStatus.cancelled) {
              return _SessionTerminalView(sessionId: sessionId);
            }
            return ListView(
              children: [
                MxText(
                  studyProgressLabel(l10n, snapshot),
                  role: MxTextRole.pageGreeting,
                ),
                const MxGap(MxSpace.md),
                StudyModePanel(
                  snapshot: snapshot,
                  answerOptions: studyAnswerOptions(snapshot),
                  onAnswer: (grade) => ref
                      .read(
                        studySessionActionControllerProvider(
                          sessionId,
                        ).notifier,
                      )
                      .answer(grade),
                ),
                const MxGap(MxSpace.xl),
                if (snapshot.canFinalize)
                  MxPrimaryButton(
                    label: l10n.studyFinalizeAction,
                    leadingIcon: Icons.done_all_rounded,
                    isLoading: actionState.isLoading,
                    fullWidth: true,
                    onPressed: () async {
                      final success = await ref
                          .read(
                            studySessionActionControllerProvider(
                              sessionId,
                            ).notifier,
                          )
                          .finalizeSession();
                      if (context.mounted && success) {
                        context.goStudyResult(sessionId);
                      }
                    },
                  ),
                if (!snapshot.canFinalize)
                  MxSecondaryButton(
                    label: l10n.studySkipAction,
                    leadingIcon: Icons.skip_next_rounded,
                    isLoading: actionState.isLoading,
                    fullWidth: true,
                    onPressed: () => ref
                        .read(
                          studySessionActionControllerProvider(
                            sessionId,
                          ).notifier,
                        )
                        .skip(),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    String sessionId,
  ) async {
    final success = await ref
        .read(studySessionActionControllerProvider(sessionId).notifier)
        .cancel();
    if (!context.mounted || !success) {
      return;
    }
    context.goStudyResult(sessionId);
  }
}

class _StudySessionLoadingView extends StatelessWidget {
  const _StudySessionLoadingView();

  @override
  Widget build(BuildContext context) {
    return const MxLoadingState();
  }
}

class _SessionTerminalView extends StatelessWidget {
  const _SessionTerminalView({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxText(l10n.studySessionEnded, role: MxTextRole.stateTitle),
          const MxGap(MxSpace.lg),
          MxPrimaryButton(
            label: l10n.studyViewResultAction,
            onPressed: () => context.goStudyResult(sessionId),
          ),
        ],
      ),
    );
  }
}
