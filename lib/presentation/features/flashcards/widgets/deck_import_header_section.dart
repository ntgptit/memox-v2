import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_text.dart';

class DeckImportHeaderSection extends StatelessWidget {
  const DeckImportHeaderSection({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        MxIconButton(
          icon: Icons.arrow_back,
          tooltip: l10n.commonBack,
          onPressed: () =>
              context.popRoute(fallback: () => context.goDeckDetail(deckId)),
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: MxText(l10n.flashcardsImportTitle, role: MxTextRole.pageTitle),
        ),
      ],
    );
  }
}
