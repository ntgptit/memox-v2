import 'package:flutter/widgets.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../widgets/personalization_settings_group.dart';
import '../widgets/settings_overview_groups.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MxScaffold(
      title: l10n.settingsTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: ListView(
          key: const ValueKey<String>('settings_content'),
          children: const [
            AccountSettingsOverviewGroup(),
            MxGap(MxSpace.xxl),
            PersonalizationSettingsGroup(),
            MxGap(MxSpace.xxl),
            LearningSettingsOverviewGroup(),
            MxGap(MxSpace.xxl),
            AudioSpeechSettingsOverviewGroup(),
          ],
        ),
      ),
    );
  }
}
