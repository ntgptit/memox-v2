import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../../shared/layouts/mx_gap.dart';
import '../../../../../shared/layouts/mx_space.dart';
import '../../../../../shared/widgets/mx_primary_button.dart';
import '../../../../../shared/widgets/mx_secondary_button.dart';

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
      children: [
        Expanded(
          child: MxSecondaryButton(
            key: const ValueKey<String>('fill-help-action'),
            label: l10n.studyHelpAction,
            leadingIcon: Icons.lightbulb_outline,
            size: MxButtonSize.large,
            fullWidth: true,
            onPressed: isSubmitting ? null : onHelp,
          ),
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: MxPrimaryButton(
            key: const ValueKey<String>('fill-check-action'),
            label: l10n.studyCheckAnswerAction,
            leadingIcon: Icons.check_rounded,
            size: MxButtonSize.large,
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
    required this.onNext,
    super.key,
  });

  final bool isSubmitting;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final nextButton = MxPrimaryButton(
      key: const ValueKey<String>('fill-next-action'),
      label: l10n.studyNextAction,
      trailingIcon: Icons.arrow_forward_rounded,
      size: MxButtonSize.large,
      tone: MxPrimaryButtonTone.danger,
      onPressed: isSubmitting ? null : onNext,
    );

    return Align(alignment: Alignment.centerRight, child: nextButton);
  }
}
