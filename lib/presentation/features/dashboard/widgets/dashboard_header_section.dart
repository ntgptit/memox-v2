import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_text.dart';

class DashboardGreetingHeader extends StatelessWidget {
  const DashboardGreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(l10n.dashboardGreetingTitle, role: MxTextRole.pageTitle),
        const MxGap(MxSpace.xs),
        MxText(l10n.dashboardGreetingSubtitle, role: MxTextRole.pageGreeting),
      ],
    );
  }
}

class DashboardFocusHeader extends StatelessWidget {
  const DashboardFocusHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(l10n.dashboardHeading, role: MxTextRole.sectionTitle),
        const MxGap(MxSpace.xs),
        MxText(l10n.dashboardSubtitle, role: MxTextRole.sectionSubtitle),
      ],
    );
  }
}
