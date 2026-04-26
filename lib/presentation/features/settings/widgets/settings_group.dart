import 'package:flutter/widgets.dart';

import '../../../shared/layouts/mx_section.dart';
import '../../../shared/widgets/mx_card.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MxCard(
      variant: MxCardVariant.outlined,
      child: MxSection(title: title, subtitle: subtitle, child: child),
    );
  }
}
