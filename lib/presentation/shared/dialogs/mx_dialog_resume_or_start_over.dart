import 'package:flutter/material.dart';

import '../widgets/mx_primary_button.dart';
import '../widgets/mx_secondary_button.dart';
import 'mx_dialog.dart';

/// Typed outcome of the [MxDialogResumeOrStartOver] choice dialog.
///
/// `null` (the dialog `show` return type is nullable) means the user cancelled
/// or dismissed. The caller owns the cancel behavior and must create no session.
enum MxResumeChoice { resume, startOver }

/// Shared "Resume or Start over" dialog shown by the study entry gate when a
/// resumable session matches the requested scope.
///
/// Spec: `docs/wireframes/24-shared-dialogs.md` §resume-or-start-over and
/// `docs/business/resume/resume-session.md`. The caller owns all data and
/// navigation; this dialog only collects the choice.
class MxDialogResumeOrStartOver {
  const MxDialogResumeOrStartOver._();

  /// Returns [MxResumeChoice.resume] / [MxResumeChoice.startOver], or
  /// `null` when the user cancels (system back, Cancel button, or barrier tap).
  static Future<MxResumeChoice?> show({
    required BuildContext context,
    required String title,
    required String message,
    required String resumeLabel,
    required String startOverLabel,
  }) {
    final localizations = MaterialLocalizations.of(context);
    return MxDialog.show<MxResumeChoice>(
      context: context,
      title: title,
      icon: Icons.history_rounded,
      child: Text(message),
      actions: [
        Builder(
          builder: (ctx) => MxSecondaryButton(
            label: startOverLabel,
            variant: MxSecondaryVariant.text,
            onPressed: () => Navigator.of(ctx).pop(MxResumeChoice.startOver),
          ),
        ),
        Builder(
          builder: (ctx) => MxSecondaryButton(
            label: localizations.cancelButtonLabel,
            variant: MxSecondaryVariant.text,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ),
        Builder(
          builder: (ctx) => MxPrimaryButton(
            label: resumeLabel,
            onPressed: () => Navigator.of(ctx).pop(MxResumeChoice.resume),
          ),
        ),
      ],
    );
  }
}
