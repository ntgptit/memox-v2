import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_text.dart';
import '../widgets/personalization_settings_group.dart';
import '../widgets/settings_overview_groups.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxScaffold(
      body: MxContentShell(
        width: MxContentWidth.reading,
        padding: const EdgeInsets.symmetric(horizontal: MxSpace.xl),
        child: ListView(
          key: const ValueKey<String>('settings_content'),
          padding: const EdgeInsets.only(top: MxSpace.xl, bottom: MxSpace.xl),
          children: [
            MxText(l10n.settingsTitle, role: MxTextRole.displayLarge),
            const MxGap(MxSpace.lg),
            const AccountSettingsOverviewGroup(),
            const MxGap(MxSpace.lg + MxSpace.xxs),
            const StudySettingsOverviewGroup(),
            const MxGap(MxSpace.lg + MxSpace.xxs),
            const PersonalizationSettingsGroup(),
            const MxGap(MxSpace.lg + MxSpace.xxs),
            const AboutSettingsOverviewGroup(),
            const MxGap(MxSpace.lg),
            const SettingsOverviewFooter(),
          ],
        ),
      ),
    );
  }
}
