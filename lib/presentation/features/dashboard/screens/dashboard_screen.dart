import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../folders/viewmodels/library_overview_viewmodel.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final queryState = ref.watch(libraryOverviewQueryProvider);

    return MxScaffold(
      title: l10n.homeTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: MxRetainedAsyncState<LibraryOverviewState>(
          data: queryState.value,
          isLoading: queryState.isLoading,
          error: queryState.hasError ? queryState.error : null,
          stackTrace: queryState.hasError ? queryState.stackTrace : null,
          onRetry: () => ref.invalidate(libraryOverviewQueryProvider),
          dataBuilder: (context, state) => _DashboardContent(state: state),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});

  final LibraryOverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dueToday = state.dueToday;
    final folderCount = state.folders.length;
    final cardCount = state.folders.fold<int>(
      0,
      (sum, folder) => sum + folder.itemCount,
    );
    final hasDueCards = dueToday > 0;

    return ListView(
      key: const ValueKey('dashboard_content'),
      children: [
        MxText(l10n.dashboardHeading, role: MxTextRole.pageTitle),
        const MxGap(MxSpace.sm),
        MxText(l10n.dashboardSubtitle, role: MxTextRole.contentBody),
        const MxGap(MxSpace.xl),
        _DashboardMetricCard(
          icon: Icons.event_available_outlined,
          title: l10n.dashboardDueTodayTitle,
          value: '$dueToday',
          message: hasDueCards
              ? l10n.dashboardDueTodayMessage(dueToday)
              : l10n.dashboardNoDueMessage,
        ),
        const MxGap(MxSpace.lg),
        _DashboardMetricCard(
          icon: Icons.folder_copy_outlined,
          title: l10n.libraryTitle,
          value: '$folderCount',
          message: l10n.dashboardLibrarySummary(folderCount, cardCount),
        ),
        const MxGap(MxSpace.xl),
        MxPrimaryButton(
          key: const ValueKey('dashboard_study_today_action'),
          label: l10n.dashboardStudyTodayAction,
          leadingIcon: Icons.play_arrow_rounded,
          fullWidth: true,
          onPressed: hasDueCards ? () => context.goStudyToday() : null,
        ),
        if (!hasDueCards) ...[
          const MxGap(MxSpace.sm),
          MxText(
            l10n.dashboardNoDueTitle,
            role: MxTextRole.formHelper,
            textAlign: TextAlign.center,
          ),
        ],
        const MxGap(MxSpace.md),
        MxSecondaryButton(
          key: const ValueKey('dashboard_open_library_action'),
          label: l10n.dashboardOpenLibraryAction,
          leadingIcon: Icons.folder_open_outlined,
          fullWidth: true,
          onPressed: () => context.goLibrary(),
        ),
      ],
    );
  }
}

class _DashboardMetricCard extends StatelessWidget {
  const _DashboardMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String value;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MxCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: scheme.primary),
          const MxGap(MxSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MxText(title, role: MxTextRole.sectionTitle),
                const MxGap(MxSpace.xs),
                MxText(value, role: MxTextRole.displayLarge),
                const MxGap(MxSpace.xs),
                MxText(message, role: MxTextRole.contentBody),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
