import 'package:flutter/widgets.dart';

import '../../../shared/layouts/mx_section.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';

const double _settingsGroupVerticalPadding = 10;
const double _settingsGroupRadius = 12;

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.title,
    required this.child,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MxCard(
      variant: MxCardVariant.outlined,
      padding: const EdgeInsets.symmetric(
        horizontal: MxSpace.md,
        vertical: _settingsGroupVerticalPadding,
      ),
      borderRadius: const BorderRadius.all(
        Radius.circular(_settingsGroupRadius),
      ),
      child: MxSection(
        title: title,
        subtitle: subtitle,
        spacing: MxSpace.sm,
        child: child,
      ),
    );
  }
}
