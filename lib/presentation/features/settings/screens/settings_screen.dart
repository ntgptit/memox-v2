import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/theme/responsive/app_layout.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_content_shell.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_scaffold.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/widgets/mx_card.dart';
import '../../../shared/widgets/mx_segmented_control.dart';
import '../../../shared/widgets/mx_text.dart';
import '../providers/locale_notifier.dart';
import '../providers/theme_mode_notifier.dart';

enum _LocaleChoice { system, english, vietnamese }

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MxScaffold(
      title: l10n.settingsTitle,
      body: MxContentShell(
        width: MxContentWidth.reading,
        applyVerticalPadding: true,
        child: ListView(
          key: const ValueKey('settings_content'),
          children: [
            MxText(l10n.settingsTitle, role: MxTextRole.pageTitle),
            const MxGap(MxSpace.xl),
            _SettingsCard(
              title: l10n.settingsAppearanceTitle,
              label: l10n.settingsThemeModeLabel,
              child: MxSegmentedControl<ThemeMode>(
                adaptive: true,
                segments: [
                  MxSegment(
                    value: ThemeMode.system,
                    label: l10n.settingsThemeSystem,
                    icon: Icons.brightness_auto_outlined,
                  ),
                  MxSegment(
                    value: ThemeMode.light,
                    label: l10n.settingsThemeLight,
                    icon: Icons.light_mode_outlined,
                  ),
                  MxSegment(
                    value: ThemeMode.dark,
                    label: l10n.settingsThemeDark,
                    icon: Icons.dark_mode_outlined,
                  ),
                ],
                selected: {themeMode},
                onChanged: (selection) {
                  final nextMode = selection.first;
                  ref.read(themeModeProvider.notifier).set(nextMode);
                  MxSnackbar.success(context, l10n.settingsUpdatedMessage);
                },
              ),
            ),
            const MxGap(MxSpace.lg),
            _SettingsCard(
              title: l10n.settingsLanguageTitle,
              label: l10n.settingsLocaleLabel,
              child: MxSegmentedControl<_LocaleChoice>(
                adaptive: true,
                segments: [
                  MxSegment(
                    value: _LocaleChoice.system,
                    label: l10n.settingsLocaleSystem,
                    icon: Icons.language_outlined,
                  ),
                  MxSegment(
                    value: _LocaleChoice.english,
                    label: l10n.settingsLocaleEnglish,
                  ),
                  MxSegment(
                    value: _LocaleChoice.vietnamese,
                    label: l10n.settingsLocaleVietnamese,
                  ),
                ],
                selected: {_localeChoiceOf(locale)},
                onChanged: (selection) {
                  final nextChoice = selection.first;
                  final notifier = ref.read(localeProvider.notifier);
                  switch (nextChoice) {
                    case _LocaleChoice.system:
                      notifier.clear();
                      break;
                    case _LocaleChoice.english:
                      notifier.set(const Locale('en'));
                      break;
                    case _LocaleChoice.vietnamese:
                      notifier.set(const Locale('vi'));
                      break;
                  }
                  MxSnackbar.success(context, l10n.settingsUpdatedMessage);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.label,
    required this.child,
  });

  final String title;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MxCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MxText(title, role: MxTextRole.sectionTitle),
          const MxGap(MxSpace.sm),
          MxText(label, role: MxTextRole.formLabel),
          const MxGap(MxSpace.md),
          child,
        ],
      ),
    );
  }
}

_LocaleChoice _localeChoiceOf(Locale? locale) {
  return switch (locale?.languageCode) {
    'en' => _LocaleChoice.english,
    'vi' => _LocaleChoice.vietnamese,
    _ => _LocaleChoice.system,
  };
}
