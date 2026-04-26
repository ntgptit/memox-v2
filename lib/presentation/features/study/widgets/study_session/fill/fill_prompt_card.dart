import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/layouts/mx_space.dart';
import '../../../../../shared/widgets/mx_card.dart';
import '../../../../../shared/widgets/mx_icon_button.dart';
import '../../../../../shared/widgets/mx_text.dart';

class FillPromptCard extends StatelessWidget {
  const FillPromptCard({required this.item, super.key});

  final StudySessionItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      key: const ValueKey<String>('fill-prompt-card'),
      variant: MxCardVariant.outlined,
      padding: const EdgeInsets.all(MxSpace.sm),
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MxSpace.lg),
              child: SingleChildScrollView(
                child: MxText(
                  item.flashcard.back,
                  role: MxTextRole.fillPrompt,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: MxIconButton(
              tooltip: l10n.studyEditCardTooltip,
              icon: Icons.mode_edit_outline,
              onPressed: null,
            ),
          ),
        ],
      ),
    );
  }
}
