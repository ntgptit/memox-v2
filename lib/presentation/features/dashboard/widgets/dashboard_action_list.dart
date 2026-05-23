import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/widgets/mx_button_size.dart';
import '../../../shared/widgets/mx_due_summary_card.dart';
import '../../../shared/widgets/mx_primary_button.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../viewmodels/dashboard_overview_viewmodel.dart';

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

class _DashboardDueAction extends StatelessWidget {
  const _DashboardDueAction({required this.state});

  final DashboardOverviewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!state.hasReviewCards) {
      return MxSecondaryButton(
        key: const ValueKey('dashboard_start_new_study_action'),
        label: l10n.dashboardOpenLibraryAction,
        leadingIcon: Icons.folder_open_outlined,
        size: MxButtonSize.small,
        variant: MxSecondaryVariant.tonal,
        fullWidth: true,
        onPressed: () => context.goLibrary(),
      );
    }

    return MxPrimaryButton(
      key: const ValueKey('dashboard_review_now_action'),
      label: l10n.dashboardStartReviewAction,
      trailingIcon: Icons.arrow_forward_rounded,
      size: MxButtonSize.small,
      fullWidth: true,
      onPressed: () => context.goStudyToday(),
    );
  }
}
