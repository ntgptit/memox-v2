import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_text.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MxText(l10n.progressOverviewHeading, role: MxTextRole.pageTitle),
        const MxGap(MxSpace.sm),
        MxText(l10n.progressOverviewSubtitle, role: MxTextRole.contentBody),
        const MxGap(MxSpace.lg),
      ],
    );
  }
}
