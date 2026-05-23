import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/tokens/app_radius.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_text.dart';

class DashboardGreetingHeader extends StatelessWidget {
  const DashboardGreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MxText(
                l10n.dashboardTodayLabel,
                role: MxTextRole.formLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const MxGap(MxSpace.xs),
              MxText(
                l10n.dashboardGreetingTitle,
                role: MxTextRole.pageTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const MxGap(MxSpace.md),
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: AppRadius.borderFull,
          ),
          child: SizedBox.square(
            dimension: 36, // guard:raw-size-reviewed matches mobile kit avatar
            child: Center(
              child: MxText(
                l10n.appName.substring(0, 1),
                role: MxTextRole.badge,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
