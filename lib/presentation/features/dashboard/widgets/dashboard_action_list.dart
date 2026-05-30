import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_action_button.dart';
import '../../../shared/widgets/mx_due_summary_card.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';
import 'dashboard_scope_picker_sheet.dart';

const _dashboardSecondsPerReviewCard = 20;
const _secondsPerMinute = 60;

class DashboardActionList extends StatelessWidget {
  const DashboardActionList({required this.state, super.key});

  final DashboardOverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = state.hasReviewCards
        ? l10n.dashboardDueNowLabel
        : l10n.dashboardAllCaughtUpTitle;
    final summary = state.hasReviewCards
        ? l10n.dashboardDueNowSummary(state.reviewCount, state.deckCount)
        : l10n.dashboardNoDueTitle;
    final supportingCopy = state.hasReviewCards
        ? l10n.dashboardReviewTimeEstimate(_estimatedMinutes(state.reviewCount))
        : l10n.dashboardNoDueMessage;

    return MxDueSummaryCard(
      key: const ValueKey('dashboard_due_now_card'),
      label: title,
      title: summary,
      message: supportingCopy,
      action: _DashboardDueAction(state: state),
    );
  }

  int _estimatedMinutes(int cardCount) {
    final seconds = cardCount * _dashboardSecondsPerReviewCard;
    final minutes = (seconds / _secondsPerMinute).ceil();
    if (minutes < 1) return 1;
    return minutes;
  }
}

/// Card-level actions for the due-now summary card. Density follows the action
/// hierarchy contract: compact card actions, exactly one dominant primary,
/// never full-width (`docs/ui-ux/action-hierarchy-contract.md`).
class _DashboardDueAction extends ConsumerWidget {
  const _DashboardDueAction({required this.state});

  final DashboardOverviewState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final startNewLearning = MxActionButton(
      key: const ValueKey('dashboard_start_new_study_action'),
      intent: state.hasReviewCards
          ? MxActionIntent.cardSecondary
          : MxActionIntent.cardPrimary,
      label: l10n.dashboardStartNewLearningAction,
      leadingIcon: Icons.tune_rounded,
      onPressed: () => showDashboardScopePicker(
        context,
        ref,
        reviewCount: state.reviewCount,
      ),
    );

    if (!state.hasReviewCards) {
      // No review cards: "Start new learning" is the single primary; library
      // is the lighter companion action.
      return _stackedActions(
        primary: startNewLearning,
        secondary: MxActionButton(
          key: const ValueKey('dashboard_open_library_action'),
          intent: MxActionIntent.cardSecondary,
          label: l10n.dashboardOpenLibraryAction,
          leadingIcon: Icons.folder_open_outlined,
          onPressed: () => context.goLibrary(),
        ),
      );
    }

    // Has review cards: "Start review" is the dominant primary; "Start new
    // learning" is the lighter companion.
    return _stackedActions(
      primary: MxActionButton(
        key: const ValueKey('dashboard_review_now_action'),
        intent: MxActionIntent.cardPrimary,
        label: l10n.dashboardStartReviewAction,
        trailingIcon: Icons.arrow_forward_rounded,
        onPressed: () => context.goStudyToday(),
      ),
      secondary: startNewLearning,
    );
  }

  /// Stacks two compact card actions vertically, trailing-aligned, primary on
  /// top. Avoids a row that would overflow with long CTA labels at narrow
  /// widths / large text while keeping both actions compact (not full-width).
  Widget _stackedActions({
    required MxActionButton primary,
    required MxActionButton secondary,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [primary, const MxGap(MxSpace.sm), secondary],
  );
}
