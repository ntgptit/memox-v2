import 'package:flutter/material.dart';

import '../widgets/mx_primary_button.dart';
import '../widgets/mx_secondary_button.dart';
import '../widgets/mx_text_field.dart';
import 'mx_dialog.dart';

/// Shared create/rename dialog for short content names such as folders and
/// decks.
class MxNameDialog extends StatefulWidget {
  const MxNameDialog({
    required this.title,
    required this.label,
    required this.hintText,
    required this.confirmLabel,
    this.initialValue,
    super.key,
  });

  final String title;
  final String label;
  final String hintText;
  final String confirmLabel;
  final String? initialValue;

  static Future<String?> show({
    required BuildContext context,
    required String title,
    required String label,
    required String hintText,
    required String confirmLabel,
    String? initialValue,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => MxNameDialog(
        title: title,
        label: label,
        hintText: hintText,
        confirmLabel: confirmLabel,
        initialValue: initialValue,
      ),
    );
  }

  @override
  State<MxNameDialog> createState() => _MxNameDialogState();
}

class _MxNameDialogState extends State<MxNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final initialValue = widget.initialValue ?? '';
    _controller = TextEditingController.fromValue(
      TextEditingValue(
        text: initialValue,
        selection: TextSelection.collapsed(offset: initialValue.length),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmedValue = _controller.text.trim();
    if (trimmedValue.isEmpty) {
      return;
    }
    Navigator.of(context).pop(trimmedValue);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return MxDialog(
      title: widget.title,
      actions: [
        MxSecondaryButton(
          label: localizations.cancelButtonLabel,
          variant: MxSecondaryVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (_, value, child) {
            final canSubmit = value.text.trim().isNotEmpty;
            return MxPrimaryButton(
              label: widget.confirmLabel,
              onPressed: canSubmit ? _submit : null,
            );
          },
        ),
      ],
      child: MxTextField(
        controller: _controller,
        label: widget.label,
        hintText: widget.hintText,
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}
