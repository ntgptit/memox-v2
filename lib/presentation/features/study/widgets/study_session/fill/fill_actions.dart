import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import 'package:memox/presentation/shared/layouts/mx_gap.dart';
import 'package:memox/presentation/shared/layouts/mx_space.dart';
import 'package:memox/presentation/shared/widgets/mx_primary_button.dart';
import 'package:memox/presentation/shared/widgets/mx_secondary_button.dart';

class FillInputActions extends StatelessWidget {
  const FillInputActions({
    required this.canCheck,
    required this.isSubmitting,
    required this.onHelp,
    required this.onCheck,
    super.key,
  });

  final bool canCheck;
  final bool isSubmitting;
  final VoidCallback onHelp;
  final VoidCallback onCheck;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: MxSecondaryButton(
            key: const ValueKey<String>('fill-help-action'),
            label: l10n.studyHintAction,
            fullWidth: true,
            onPressed: isSubmitting ? null : onHelp,
          ),
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: MxPrimaryButton(
            key: const ValueKey<String>('fill-check-action'),
            label: l10n.studyCheckAnswerAction,
            shape: MxPrimaryButtonShape.pill,
            fullWidth: true,
            onPressed: canCheck ? onCheck : null,
          ),
        ),
      ],
    );
  }
}

class FillResultActions extends StatelessWidget {
  const FillResultActions({
    required this.isSubmitting,
    required this.onMarkCorrect,
    required this.onTryAgain,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onMarkCorrect;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: MxSecondaryButton(
            key: const ValueKey<String>('fill-mark-correct-action'),
            label: l10n.studyMarkCorrectAction,
            fullWidth: true,
            onPressed: isSubmitting ? null : onMarkCorrect,
          ),
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: MxPrimaryButton(
            key: const ValueKey<String>('fill-try-again-action'),
            label: l10n.studyTryAgainAction,
            shape: MxPrimaryButtonShape.pill,
            fullWidth: true,
            onPressed: isSubmitting ? null : onTryAgain,
          ),
        ),
      ],
    );
  }
}
