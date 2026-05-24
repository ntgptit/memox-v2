import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../domain/services/tts_service.dart';
import '../../../shared/widgets/mx_slider.dart';
import '../../tts/providers/tts_settings_notifier.dart';

class SpeechPitchSlider extends StatelessWidget {
  const SpeechPitchSlider({
    required this.settings,
    required this.notifier,
    super.key,
  });

  final TtsSettings settings;
  final TtsSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxSlider(
      label: l10n.settingsSpeechPitchLabel,
      value: settings.pitch,
      min: TtsSettings.minPitch,
      max: TtsSettings.maxPitch,
      divisions: 8,
      valueLabel: l10n.settingsSpeechPitchValue(
        (settings.pitch * 10).round() / 10,
      ),
      onChanged: (value) {
        unawaited(notifier.setPitch(value));
      },
    );
  }
}

class SpeechVolumeSlider extends StatelessWidget {
  const SpeechVolumeSlider({
    required this.settings,
    required this.notifier,
    super.key,
  });

  final TtsSettings settings;
  final TtsSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxSlider(
      label: l10n.settingsSpeechVolumeLabel,
      value: settings.volume,
      min: TtsSettings.minVolume,
      max: TtsSettings.maxVolume,
      divisions: 10,
      valueLabel: l10n.settingsSpeechVolumeValue(
        (settings.volume * 100).round(),
      ),
      onChanged: (value) {
        unawaited(notifier.setVolume(value));
      },
    );
  }
}
