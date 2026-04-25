import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../shared/layouts/mx_gap.dart';
import '../../../../shared/layouts/mx_space.dart';
import '../../../../shared/widgets/mx_card.dart';
import '../../../../shared/widgets/mx_text.dart';

class ReadyToFinalizePanel extends StatelessWidget {
  const ReadyToFinalizePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MxText(l10n.studyReadyToFinalizeTitle, role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.sm),
          MxText(
            l10n.studyReadyToFinalizeMessage,
            role: MxTextRole.contentBody,
          ),
        ],
      ),
    );
  }
}
