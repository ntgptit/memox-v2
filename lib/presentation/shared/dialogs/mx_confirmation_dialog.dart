import 'package:flutter/material.dart';

import '../widgets/mx_primary_button.dart';
import '../widgets/mx_secondary_button.dart';
import 'mx_dialog.dart';

enum MxConfirmationTone { neutral, primary, danger }

/// Simple yes/no confirmation dialog with tone-aware primary button.
class MxConfirmationDialog {
  const MxConfirmationDialog._();

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    IconData? icon,
    MxConfirmationTone tone = MxConfirmationTone.primary,
  }) async {
    final localizations = MaterialLocalizations.of(context);
    final result = await MxDialog.show<bool>(
      context: context,
      title: title,
      icon: icon,
      child: Text(message),
      actions: [
        Builder(
          builder: (ctx) => MxSecondaryButton(
            label: cancelLabel ?? localizations.cancelButtonLabel,
            variant: MxSecondaryVariant.text,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
        ),
        Builder(
          builder: (ctx) => MxPrimaryButton(
            label: confirmLabel ?? localizations.okButtonLabel,
            tone: tone == MxConfirmationTone.danger
                ? MxPrimaryButtonTone.danger
                : MxPrimaryButtonTone.primary,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ),
      ],
    );
    return result ?? false;
  }
}
