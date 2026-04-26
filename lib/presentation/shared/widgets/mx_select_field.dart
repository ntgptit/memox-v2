import 'package:flutter/material.dart';

class MxSelectOption<T> {
  const MxSelectOption({required this.value, required this.label});

  final T value;
  final String label;
}

class MxSelectField<T> extends StatelessWidget {
  const MxSelectField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.helperText,
    this.enabled = true,
    super.key,
  });

  final String label;
  final T value;
  final List<MxSelectOption<T>> options;
  final ValueChanged<T>? onChanged;
  final String? helperText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: options
          .map(
            (option) => DropdownMenuItem<T>(
              value: option.value,
              child: Text(option.label),
            ),
          )
          .toList(growable: false),
      decoration: InputDecoration(labelText: label, helperText: helperText),
      onChanged: enabled ? (value) => _handleChanged(value) : null,
    );
  }

  void _handleChanged(T? value) {
    if (value == null) {
      return;
    }
    onChanged?.call(value);
  }
}
