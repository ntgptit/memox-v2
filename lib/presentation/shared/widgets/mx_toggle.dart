import 'package:flutter/material.dart';

/// Shared binary setting row backed by Material switch styling.
class MxToggle extends StatelessWidget {
  const MxToggle({
    required this.label,
    required this.value,
    required this.onChanged,
    this.subtitle,
    super.key,
  });

  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(label),
      subtitle: subtitle == null ? null : Text(subtitle!),
    );
  }
}
