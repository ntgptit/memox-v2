import 'package:flutter/material.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/widgets/mx_divider.dart';
import 'settings_group.dart';

const _themeRowKey = ValueKey<String>('settings-personalization-theme-row');
const _languageRowKey = ValueKey<String>(
  'settings-personalization-language-row',
);

class PersonalizationSettingsGroup extends StatelessWidget {
  const PersonalizationSettingsGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsGroup(
      title: l10n.settingsAppSectionTitle,
      contentPadding: EdgeInsets.zero,
      style: SettingsGroupStyle.hub,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PersonalizationRow(
            key: _themeRowKey,
            icon: Icons.wb_sunny_outlined,
            title: l10n.settingsAppearanceTitle,
            subtitle: l10n.settingsAppearanceOverviewSubtitle,
          ),
          const MxDivider(),
          _PersonalizationRow(
            key: _languageRowKey,
            icon: Icons.language_rounded,
            title: l10n.settingsLanguageTitle,
            subtitle: l10n.settingsLanguageOverviewSubtitle,
          ),
        ],
      ),
    );
  }
}

class _PersonalizationRow extends StatelessWidget {
  const _PersonalizationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SettingsRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      value: l10n.settingsSoonChip,
      showChevron: false,
      enabled: false,
      style: SettingsRowStyle.hub,
      preserveSubtitleOnCompact: true,
    );
  }
}
