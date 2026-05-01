import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_empty_state.dart';
import '../../../shared/widgets/mx_text.dart';

class ActiveSessionsHeader extends StatelessWidget {
  const ActiveSessionsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(
          l10n.progressActiveSessionsHeading,
          role: MxTextRole.sectionTitle,
        ),
        const MxGap(MxSpace.xs),
        MxText(
          l10n.progressActiveSessionsSubtitle,
          role: MxTextRole.contentBody,
        ),
        const MxGap(MxSpace.lg),
      ],
    );
  }
}

class ActiveSessionsEmptyState extends StatelessWidget {
  const ActiveSessionsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxEmptyState(
      icon: Icons.insights_outlined,
      title: l10n.progressEmptyTitle,
      message: l10n.progressEmptyMessage,
      actionLabel: l10n.dashboardOpenLibraryAction,
      actionLeadingIcon: Icons.folder_open_outlined,
      onAction: () => context.goLibrary(),
    );
  }
}
