import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../../domain/services/tts_service.dart';
import '../../../../../shared/layouts/mx_gap.dart';
import '../../../../../shared/layouts/mx_space.dart';
import '../../../../../shared/widgets/mx_card.dart';
import '../../../../../shared/widgets/mx_text.dart';
import '../../../../../shared/widgets/mx_text_field.dart';
import '../study_speak_button.dart';

class FillInputCard extends StatelessWidget {
  const FillInputCard({
    required this.controller,
    required this.focusNode,
    required this.isEnabled,
    required this.canSubmit,
    required this.onSubmit,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isEnabled;
  final bool canSubmit;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      variant: MxCardVariant.outlined,
      child: SizedBox.expand(
        child: MxTextField(
          key: const ValueKey<String>('fill-answer-input'),
          label: l10n.studyAnswerLabel,
          controller: controller,
          focusNode: focusNode,
          enabled: isEnabled,
          autofocus: true,
          variant: MxTextFieldVariant.borderless,
          textRole: MxTextRole.fillInput,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          expands: true,
          textCapitalization: TextCapitalization.none,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (canSubmit) {
              onSubmit();
            }
          },
        ),
      ),
    );
  }
}

class FillIncorrectCard extends StatelessWidget {
  const FillIncorrectCard({
    required this.submittedAnswer,
    required this.correctAnswer,
    super.key,
  });

  final String submittedAnswer;
  final String correctAnswer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxCard(
      variant: MxCardVariant.outlined,
      padding: const EdgeInsets.all(MxSpace.sm),
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MxText(
                    submittedAnswer,
                    role: MxTextRole.fillIncorrectInput,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                  const MxGap(MxSpace.sm),
                  MxText(
                    correctAnswer,
                    role: MxTextRole.fillCorrectAnswer,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ],
              ),
            ),
          ),
          StudyAutoSpeakEffect(
            triggerKey: 'fill-correct-answer:$correctAnswer',
            text: correctAnswer,
            side: TtsTextSide.front,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: StudySpeakButton(
              key: ValueKey<String>('fill-front-speak-$correctAnswer'),
              tooltip: l10n.studyCardAudioTooltip,
              text: correctAnswer,
              side: TtsTextSide.front,
            ),
          ),
        ],
      ),
    );
  }
}
