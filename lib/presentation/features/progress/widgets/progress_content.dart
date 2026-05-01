import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../providers/progress_session_notifier.dart';
import 'active_session_section.dart';
import 'progress_header_section.dart';
import 'progress_overview_section.dart';
import 'study_session_card.dart';

class ProgressContent extends ConsumerWidget {
  const ProgressContent({required this.state, super.key});

  final ProgressOverviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(progressSessionActionControllerProvider);
    final sessions = state.sessions;
    return ListView.builder(
      key: const ValueKey('progress_session_list'),
      itemCount: sessions.isEmpty ? 4 : sessions.length + 4,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const ProgressHeader();
        }
        if (index == 1) {
          return LearningOverview(state: state);
        }
        if (index == 2) {
          return const ActiveSessionsHeader();
        }
        if (index == 3) {
          if (sessions.isEmpty) {
            return const ActiveSessionsEmptyState();
          }
          return SessionRecoveryOverview(state: state);
        }
        final session = sessions[index - 4];
        return Column(
          children: [
            StudySessionCard(
              snapshot: session,
              isActionLoading: actionState.isLoading,
            ),
            const MxGap(MxSpace.lg),
          ],
        );
      },
    );
  }
}
