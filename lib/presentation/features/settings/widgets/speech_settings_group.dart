import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../../domain/services/tts_service.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/states/mx_loading_state.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_inline_toggle.dart';
import '../../../shared/widgets/mx_secondary_button.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_select_field.dart';
import '../../../shared/widgets/mx_segmented_control.dart';
import '../../../shared/widgets/mx_slider.dart';
import '../../../shared/widgets/mx_text.dart';
import '../../../shared/widgets/mx_text_field.dart';
import '../../tts/providers/tts_controller_notifier.dart';
import '../../tts/providers/tts_settings_notifier.dart';
import 'settings_group.dart';

const _speechPreviewButtonKey = ValueKey<String>(
  'settings-speech-preview-button',
);
const _speechVoiceOptionsButtonKey = ValueKey<String>(
  'settings-speech-voice-options-button',
);

class SpeechSettingsGroup extends ConsumerWidget {
  const SpeechSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ttsSettings = ref.watch(ttsSettingsProvider);

    return ttsSettings.when(
      data: (settings) => _SpeechSettingsContent(settings: settings),
      loading: () => SettingsGroup(
        title: l10n.settingsSpeechTitle,
        subtitle: l10n.settingsSpeechLoading,
        child: const MxLoadingState(),
      ),
      error: (_, _) => SettingsGroup(
        title: l10n.settingsSpeechTitle,
        subtitle: l10n.sharedErrorTitle,
        child: MxText(l10n.errorUnexpected, role: MxTextRole.formHelper),
      ),
    );
  }
}

class _SpeechSettingsContent extends ConsumerStatefulWidget {
  const _SpeechSettingsContent({required this.settings});

  static const String systemVoiceValue = 'system';

  final TtsSettings settings;

  @override
  ConsumerState<_SpeechSettingsContent> createState() =>
      _SpeechSettingsContentState();
}

class _SpeechSettingsContentState
    extends ConsumerState<_SpeechSettingsContent> {
  bool _showVoiceOptions = false;
  late final TextEditingController _previewTextController =
      TextEditingController();

  @override
  void dispose() {
    _previewTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settings = widget.settings;
    ref.watch(ttsControllerProvider);
    final voices = _showVoiceOptions
        ? ref.watch(ttsVoicesProvider(settings.frontLanguage))
        : const AsyncData<List<TtsVoice>>(<TtsVoice>[]);
    final notifier = ref.read(ttsSettingsProvider.notifier);

    return SettingsGroup(
      title: l10n.settingsSpeechTitle,
      subtitle: l10n.settingsSpeechLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AutoPlayToggle(settings: settings, notifier: notifier),
          const MxGap(MxSpace.md),
          const MxDivider(),
          const MxGap(MxSpace.md),
          _SpeechLanguageControl(
            label: l10n.settingsSpeechFrontLanguageLabel,
            selected: settings.frontLanguage,
            onChanged: (language) {
              unawaited(notifier.setFrontLanguage(language));
              MxSnackbar.success(context, l10n.settingsUpdatedMessage);
            },
          ),
          const MxGap(MxSpace.md),
          const MxDivider(),
          const MxGap(MxSpace.md),
          _SpeechRateSlider(settings: settings, notifier: notifier),
          const MxGap(MxSpace.lg),
          const MxDivider(),
          const MxGap(MxSpace.md),
          _PreviewTextField(
            controller: _previewTextController,
            language: settings.frontLanguage,
          ),
          const MxGap(MxSpace.md),
          _SpeechActionRow(
            previewLabel: l10n.settingsSpeechPreviewSelected,
            voiceOptionsLabel: _showVoiceOptions
                ? l10n.settingsSpeechHideVoiceOptions
                : l10n.settingsSpeechVoiceOptions,
            onPreview: () => _previewSelected(settings, l10n),
            onToggleVoiceOptions: _toggleVoiceOptions,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            child: _showVoiceOptions
                ? _VoiceOptions(
                    key: const ValueKey<String>('speech-voice-options'),
                    settings: settings,
                    voices: voices,
                    onChanged: (value) {
                      unawaited(
                        notifier.setFrontVoiceName(_voiceNameFromValue(value)),
                      );
                      MxSnackbar.success(context, l10n.settingsUpdatedMessage);
                    },
                  )
                : const SizedBox.shrink(
                    key: ValueKey<String>('speech-voice-options-hidden'),
                  ),
          ),
        ],
      ),
    );
  }

  void _toggleVoiceOptions() {
    setState(() {
      _showVoiceOptions = !_showVoiceOptions;
    });
  }

  void _previewSelected(TtsSettings settings, AppLocalizations l10n) {
    final custom = StringUtils.trimmed(_previewTextController.text);
    final text = StringUtils.isBlank(custom)
        ? _previewText(l10n, settings.frontLanguage)
        : custom;
    unawaited(
      ref
          .read(ttsControllerProvider.notifier)
          .speakText(
            text: text,
            language: settings.frontLanguage,
            side: TtsTextSide.front,
          ),
    );
  }

  String? _voiceNameFromValue(String value) {
    if (value == _SpeechSettingsContent.systemVoiceValue) {
      return null;
    }
    return value;
  }
}

class _AutoPlayToggle extends StatelessWidget {
  const _AutoPlayToggle({required this.settings, required this.notifier});

  final TtsSettings settings;
  final TtsSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxInlineToggle(
      label: l10n.settingsSpeechAutoPlayLabel,
      subtitle: l10n.settingsSpeechAutoPlaySubtitle,
      leadingIcon: Icons.volume_up_rounded,
      value: settings.autoPlay,
      onChanged: (value) {
        unawaited(notifier.setAutoPlay(value));
        MxSnackbar.success(context, l10n.settingsUpdatedMessage);
      },
    );
  }
}

class _SpeechRateSlider extends StatelessWidget {
  const _SpeechRateSlider({required this.settings, required this.notifier});

  final TtsSettings settings;
  final TtsSettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return MxSlider(
      label: l10n.settingsSpeechRateLabel,
      value: settings.rate,
      min: TtsSettings.minRate,
      max: TtsSettings.maxRate,
      divisions: 4,
      valueLabel: l10n.settingsSpeechRateValue(
        (settings.rate * 10).round() / 10,
      ),
      onChanged: (value) {
        unawaited(notifier.setRate(value));
      },
    );
  }
}

class _SpeechActionRow extends StatelessWidget {
  const _SpeechActionRow({
    required this.previewLabel,
    required this.voiceOptionsLabel,
    required this.onPreview,
    required this.onToggleVoiceOptions,
  });

  final String previewLabel;
  final String voiceOptionsLabel;
  final VoidCallback onPreview;
  final VoidCallback onToggleVoiceOptions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MxSecondaryButton(
            key: _speechPreviewButtonKey,
            label: previewLabel,
            leadingIcon: Icons.volume_up_rounded,
            variant: MxSecondaryVariant.tonal,
            fullWidth: true,
            onPressed: onPreview,
          ),
        ),
        const MxGap(MxSpace.sm),
        Expanded(
          child: MxSecondaryButton(
            key: _speechVoiceOptionsButtonKey,
            label: voiceOptionsLabel,
            leadingIcon: Icons.tune_rounded,
            variant: MxSecondaryVariant.outlined,
            fullWidth: true,
            onPressed: onToggleVoiceOptions,
          ),
        ),
      ],
    );
  }
}

class _PreviewTextField extends StatefulWidget {
  const _PreviewTextField({required this.controller, required this.language});

  final TextEditingController controller;
  final TtsLanguage language;

  @override
  State<_PreviewTextField> createState() => _PreviewTextFieldState();
}

class _PreviewTextFieldState extends State<_PreviewTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasContent = StringUtils.isNotBlank(widget.controller.text);
    return MxTextField(
      controller: widget.controller,
      label: l10n.settingsSpeechPreviewTextLabel,
      hintText: _previewText(l10n, widget.language),
      helperText: l10n.settingsSpeechPreviewTextHelper,
      minLines: 1,
      maxLines: 3,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.none,
      suffixIcon: hasContent
          ? MxIconButton(
              icon: Icons.close_rounded,
              tooltip: l10n.settingsSpeechPreviewClearTooltip,
              onPressed: () => widget.controller.clear(),
            )
          : null,
    );
  }
}

class _SpeechLanguageControl extends StatelessWidget {
  const _SpeechLanguageControl({
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final TtsLanguage selected;
  final ValueChanged<TtsLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        MxText(label, role: MxTextRole.formLabel),
        const MxGap(MxSpace.sm),
        MxSegmentedControl<TtsLanguage>(
          adaptive: true,
          segments: [
            MxSegment<TtsLanguage>(
              value: TtsLanguage.korean,
              label: l10n.settingsSpeechKorean,
            ),
            MxSegment<TtsLanguage>(
              value: TtsLanguage.english,
              label: l10n.settingsSpeechEnglish,
            ),
          ],
          selected: {selected},
          onChanged: (selection) {
            onChanged(selection.first);
          },
        ),
      ],
    );
  }
}

class _VoiceOptions extends StatelessWidget {
  const _VoiceOptions({
    required this.settings,
    required this.voices,
    required this.onChanged,
    super.key,
  });

  final TtsSettings settings;
  final AsyncValue<List<TtsVoice>> voices;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const MxGap(MxSpace.md),
        _VoiceSelect(
          label: AppLocalizations.of(context).settingsSpeechFrontVoiceLabel,
          language: settings.frontLanguage,
          voices: voices,
          selectedVoiceName: settings.frontVoiceName,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _VoiceSelect extends StatelessWidget {
  const _VoiceSelect({
    required this.label,
    required this.language,
    required this.voices,
    required this.selectedVoiceName,
    required this.onChanged,
  });

  final String label;
  final TtsLanguage language;
  final AsyncValue<List<TtsVoice>> voices;
  final String? selectedVoiceName;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final voiceItems = voices.when(
      data: (items) => items,
      loading: () => const <TtsVoice>[],
      error: (_, _) => const <TtsVoice>[],
    );
    final hasSelectedVoice = voiceItems.any(
      (voice) => voice.name == selectedVoiceName,
    );
    final selectedValue = hasSelectedVoice
        ? selectedVoiceName!
        : _SpeechSettingsContent.systemVoiceValue;
    final helper = voices.when<String?>(
      data: (items) => items.isEmpty
          ? l10n.settingsSpeechNoVoices(_languageLabel(l10n, language))
          : null,
      loading: () => l10n.settingsSpeechLoadingVoices,
      error: (_, _) => l10n.errorUnexpected,
    );
    return MxSelectField<String>(
      label: label,
      value: selectedValue,
      helperText: helper,
      options: [
        MxSelectOption<String>(
          value: _SpeechSettingsContent.systemVoiceValue,
          label: l10n.settingsSpeechSystemVoice,
        ),
        for (final voice in voiceItems)
          MxSelectOption<String>(value: voice.name, label: voice.name),
      ],
      onChanged: onChanged,
    );
  }
}

String _languageLabel(AppLocalizations l10n, TtsLanguage language) {
  return switch (language) {
    TtsLanguage.korean => l10n.settingsSpeechKorean,
    TtsLanguage.english => l10n.settingsSpeechEnglish,
  };
}

String _previewText(AppLocalizations l10n, TtsLanguage language) {
  return switch (language) {
    TtsLanguage.korean => l10n.settingsSpeechKoreanPreviewText,
    TtsLanguage.english => l10n.settingsSpeechEnglishPreviewText,
  };
}
