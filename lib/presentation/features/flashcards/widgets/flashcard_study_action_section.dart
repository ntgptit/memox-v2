import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/mx_primary_button.dart';

class FlashcardStudyActionSection extends StatelessWidget {
  const FlashcardStudyActionSection({
    required this.enabled,
    required this.onStartStudy,
    super.key,
  });

  final bool enabled;
  final VoidCallback onStartStudy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxPrimaryButton(
      label: l10n.flashcardsLearnDeckAction,
      leadingIcon: Icons.play_arrow_rounded,
      size: MxButtonSize.large,
      fullWidth: true,
      onPressed: enabled ? onStartStudy : null,
    );
  }
}
