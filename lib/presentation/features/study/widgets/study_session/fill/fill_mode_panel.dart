import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../../core/utils/string_utils.dart';
import '../../../../../../domain/enums/study_enums.dart';
import '../../../../../../domain/study/entities/study_models.dart';
import '../../../../../shared/widgets/mx_primary_button.dart';
import '../../../../../shared/widgets/mx_text_field.dart';
import '../prompt_card.dart';
import '../study_answer_models.dart';

class FillModePanel extends StatefulWidget {
  const FillModePanel({
    required this.item,
    required this.isSubmitting,
    required this.onAnswer,
    this.feedback,
    this.onContinue,
    this.onMarkCorrect,
    super.key,
  });

  final StudySessionItem item;
  final bool isSubmitting;
  final StudyAnswerFeedback? feedback;
  final ValueChanged<StudyAnswerSubmission> onAnswer;
  final VoidCallback? onContinue;
  final ValueChanged<StudyAnswerFeedback>? onMarkCorrect;

  @override
  State<FillModePanel> createState() => _FillModePanelState();
}

class _FillModePanelState extends State<FillModePanel> {
  late final TextEditingController _controller;
  bool _showEmptyError = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant FillModePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _controller.clear();
      _showEmptyError = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final answer = StringUtils.trimmed(_controller.text);
    final inputDisabled = widget.isSubmitting || widget.feedback != null;
    return PromptCard(
      title: l10n.studyModeFill,
      front: widget.item.flashcard.front,
      back: l10n.studyTypeMatchingAnswer,
      feedback: widget.feedback,
      isSubmitting: widget.isSubmitting,
      onContinue: widget.onContinue,
      onMarkCorrect: widget.onMarkCorrect,
      content: MxTextField(
        label: l10n.studyAnswerLabel,
        controller: _controller,
        enabled: !inputDisabled,
        errorText: _showEmptyError ? l10n.studyEmptyAnswerMessage : null,
        minLines: 2,
        maxLines: 4,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        onChanged: (_) => setState(() {
          _showEmptyError = false;
        }),
      ),
      actions: [
        MxPrimaryButton(
          label: l10n.studySubmitAnswer,
          leadingIcon: Icons.check_rounded,
          isLoading: widget.isSubmitting,
          onPressed: inputDisabled || answer.isEmpty ? null : _submit,
        ),
      ],
    );
  }

  void _submit() {
    final answer = StringUtils.trimmed(_controller.text);
    if (answer.isEmpty) {
      setState(() {
        _showEmptyError = true;
      });
      return;
    }
    widget.onAnswer(
      StudyAnswerSubmission(
        grade: StringUtils.equalsNormalized(answer, widget.item.flashcard.back)
            ? AttemptGrade.correct
            : AttemptGrade.incorrect,
        submittedAnswer: answer,
      ),
    );
  }
}
