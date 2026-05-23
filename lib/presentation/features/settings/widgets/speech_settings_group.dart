import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../../domain/services/tts_service.dart';
import '../../../shared/dialogs/mx_bottom_sheet.dart';
import '../../../shared/feedback/mx_snackbar.dart';
import '../../../shared/layouts/mx_gap.dart';
import '../../../shared/layouts/mx_space.dart';
import '../../../shared/motion/mx_motion.dart';
import '../../../shared/widgets/mx_loading_state.dart';
import '../../../shared/widgets/mx_retained_async_state.dart';
import '../../../shared/widgets/mx_divider.dart';
import '../../../shared/widgets/mx_inline_toggle.dart';
import '../../../shared/widgets/mx_icon_button.dart';
import '../../../shared/widgets/mx_list_tile.dart';
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
const _speechTextToSpeechToggleKey = ValueKey<String>(
  'settings-speech-tts-toggle',
);
const _speechVoiceSelectionRowKey = ValueKey<String>(
  'settings-speech-voice-selection-row',
);

class SpeechSettingsGroup extends ConsumerWidget {
  const SpeechSettingsGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ttsSettings = ref.watch(ttsSettingsProvider);

    return MxRetainedAsyncState<TtsSettings>(
      data: ttsSettings.value,
      isLoading: ttsSettings.isLoading,
      error: ttsSettings.hasError ? ttsSettings.error : null,
      stackTrace: ttsSettings.hasError ? ttsSettings.stackTrace : null,
      onRetry: () => ref.invalidate(ttsSettingsProvider),
      skeletonBuilder: (_) => SettingsGroup(
        title: l10n.settingsAudioSpeechTitle,
        subtitle: l10n.settingsSpeechLoading,
        child: const MxLoadingState(),
      ),
      errorBuilder: (_, _, _) => SettingsGroup(
        title: l10n.settingsAudioSpeechTitle,
        subtitle: l10n.sharedErrorTitle,
        child: MxText(l10n.errorUnexpected, role: MxTextRole.formHelper),
      ),
      dataBuilder: (_, settings) => _SpeechSettingsContent(settings: settings),
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
    final notifier = ref.read(ttsSettingsProvider.notifier);

    return SettingsGroup(
      title: l10n.settingsAudioSpeechTitle,
      child: Column(
        children: [
          _AutoPlayToggle(settings: settings, notifier: notifier),
          const MxDivider(),
          _SpeechSettingRow(
            key: _speechVoiceSelectionRowKey,
            icon: Icons.mic_none_rounded,
            title: l10n.settingsSpeechVoiceSelectionLabel,
            value: _voiceSelectionValue(l10n, settings),
            onTap: () => _showVoiceSettingsSheet(context),
          ),
        ],
      ),
    );
  }

  void _showVoiceSettingsSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    unawaited(
      MxBottomSheet.show<void>(
        context: context,
        title: l10n.settingsSpeechVoiceSelectionLabel,
        child: _SpeechDetailsSheet(controller: _previewTextController),
      ),
    );
  }
}

class _SpeechSettingRow extends StatelessWidget {
  const _SpeechSettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MxListTile(
      leading: Icon(icon, color: scheme.onSurfaceVariant, size: MxSpace.xxl),
      title: title,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MxText(
            value,
            role: MxTextRole.tileMeta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const MxGap(MxSpace.sm),
          Icon(
            Icons.chevron_right_rounded,
            size: MxSpace.xxl,
            color: scheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SpeechDetailsSheet extends ConsumerStatefulWidget {
  const _SpeechDetailsSheet({required this.controller});

  final TextEditingController controller;

  @override
  ConsumerState<_SpeechDetailsSheet> createState() =>
      _SpeechDetailsSheetState();
}

class _SpeechDetailsSheetState extends ConsumerState<_SpeechDetailsSheet> {
  bool _showVoiceOptions = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(ttsSettingsProvider);
    final settings = settingsAsync.value;
    if (settingsAsync.hasError) {
      return MxText(l10n.errorUnexpected, role: MxTextRole.formHelper);
    }
    if (settings == null) {
      return const MxLoadingState();
    }

    final notifier = ref.read(ttsSettingsProvider.notifier);
    final voices = _showVoiceOptions
        ? ref.watch(ttsVoicesProvider(settings.frontLanguage))
        : const AsyncData<List<TtsVoice>>(<TtsVoice>[]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SpeechLanguageControl(
          label: l10n.settingsSpeechFrontLanguageLabel,
          selected: settings.frontLanguage,
          onChanged: (language) {
            unawaited(notifier.setFrontLanguage(language));
            MxSnackbar.success(context, l10n.settingsUpdatedMessage);
          },
        ),
        const MxGap(MxSpace.md),
        _SpeechRateSlider(settings: settings, notifier: notifier),
        const MxGap(MxSpace.lg),
        _PreviewTextField(
          controller: widget.controller,
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
          duration: MxDurations.fade,
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
    );
  }

  void _toggleVoiceOptions() {
    setState(() {
      _showVoiceOptions = !_showVoiceOptions;
    });
  }

  void _previewSelected(TtsSettings settings, AppLocalizations l10n) {
    final custom = StringUtils.trimmed(widget.controller.text);
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
      key: _speechTextToSpeechToggleKey,
      label: l10n.settingsSpeechTextToSpeechLabel,
      leadingIcon: Icons.record_voice_over_outlined,
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MxIconButton.compact(
          key: _speechPreviewButtonKey,
          icon: Icons.volume_up_rounded,
          tooltip: previewLabel,
          onPressed: onPreview,
        ),
        const MxGap(MxSpace.xs),
        MxIconButton.compact(
          key: _speechVoiceOptionsButtonKey,
          icon: Icons.tune_rounded,
          tooltip: voiceOptionsLabel,
          onPressed: onToggleVoiceOptions,
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
    final voiceItems = voices.value ?? const <TtsVoice>[];
    final hasSelectedVoice = voiceItems.any(
      (voice) => voice.name == selectedVoiceName,
    );
    final selectedValue = hasSelectedVoice
        ? selectedVoiceName!
        : _SpeechSettingsContent.systemVoiceValue;
    final helper = _voiceSelectHelperText(
      l10n: l10n,
      language: language,
      voices: voices,
      voiceItems: voiceItems,
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

String? _voiceSelectHelperText({
  required AppLocalizations l10n,
  required TtsLanguage language,
  required AsyncValue<List<TtsVoice>> voices,
  required List<TtsVoice> voiceItems,
}) {
  if (voices.isLoading && !voices.hasValue) {
    return l10n.settingsSpeechLoadingVoices;
  }
  if (voices.hasError && !voices.hasValue) {
    return l10n.errorUnexpected;
  }
  if (voiceItems.isEmpty) {
    return l10n.settingsSpeechNoVoices(_languageLabel(l10n, language));
  }
  return null;
}

String _languageLabel(AppLocalizations l10n, TtsLanguage language) {
  return switch (language) {
    TtsLanguage.korean => l10n.settingsSpeechKorean,
    TtsLanguage.english => l10n.settingsSpeechEnglish,
  };
}

String _voiceSelectionValue(AppLocalizations l10n, TtsSettings settings) {
  final voiceName = settings.frontVoiceName;
  if (StringUtils.isNotBlank(voiceName)) {
    return voiceName!;
  }
  return l10n.settingsSpeechSystemVoice;
}

String _previewText(AppLocalizations l10n, TtsLanguage language) {
  return switch (language) {
    TtsLanguage.korean => l10n.settingsSpeechKoreanPreviewText,
    TtsLanguage.english => l10n.settingsSpeechEnglishPreviewText,
  };
}
