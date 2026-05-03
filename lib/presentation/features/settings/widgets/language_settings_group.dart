import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/widgets/mx_segmented_control.dart';
import '../providers/locale_notifier.dart';
import 'settings_group.dart';

enum _LocaleChoice { system, english, vietnamese }

class LanguageSettingsGroup extends ConsumerWidget {
  const LanguageSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    return SettingsGroup(
      title: l10n.settingsLanguageTitle,
      subtitle: l10n.settingsLocaleLabel,
      child: MxSegmentedControl<_LocaleChoice>(
        adaptive: true,
        density: MxSegmentedControlDensity.compact,
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
            case _LocaleChoice.english:
              notifier.set(const Locale('en'));
            case _LocaleChoice.vietnamese:
              notifier.set(const Locale('vi'));
          }
          MxSnackbar.success(context, l10n.settingsUpdatedMessage);
        },
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
