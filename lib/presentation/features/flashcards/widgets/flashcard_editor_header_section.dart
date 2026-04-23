import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_text.dart';

class FlashcardEditorHeaderSection extends StatelessWidget {
  const FlashcardEditorHeaderSection({
    required this.title,
    required this.onBack,
    super.key,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        MxIconButton(
          icon: Icons.arrow_back,
          tooltip: l10n.commonBack,
          onPressed: onBack,
        ),
        const MxGap(MxSpace.sm),
        Expanded(child: MxText(title, role: MxTextRole.pageTitle)),
      ],
    );
  }
}
