import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memox/core/utils/string_utils.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/l10n/generated/app_localizations.dart';
import 'package:memox/presentation/features/tts/providers/tts_controller_notifier.dart';
import 'package:memox/presentation/shared/widgets/mx_speak_button.dart';

class StudySpeakButton extends ConsumerWidget {
  const StudySpeakButton({
    required this.text,
    required this.side,
    this.tooltip,
    super.key,
  });

  final String text;
  final TtsTextSide side;
  final String? tooltip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ttsControllerProvider);
    final isEnabled = StringUtils.isNotBlank(text);
    final isSpeaking = state == TtsState.speaking;
    return MxSpeakButton(
      tooltip: isSpeaking
          ? AppLocalizations.of(context).studyStopAudioTooltip
          : tooltip ?? AppLocalizations.of(context).studyCardAudioTooltip,
      isSpeaking: isSpeaking,
      onPressed: isEnabled
          ? () {
              final controller = ref.read(ttsControllerProvider.notifier);
              if (isSpeaking) {
                unawaited(controller.stop());
                return;
              }
              unawaited(controller.speakTextSide(text: text, side: side));
            }
          : null,
    );
  }
}

class StudyAutoSpeakEffect extends ConsumerStatefulWidget {
  const StudyAutoSpeakEffect({
    required this.triggerKey,
    required this.text,
    required this.side,
    this.enabled = true,
    super.key,
  });

  final Object? triggerKey;
  final String text;
  final TtsTextSide side;
  final bool enabled;

  @override
  ConsumerState<StudyAutoSpeakEffect> createState() =>
      _StudyAutoSpeakEffectState();
}

class _StudyAutoSpeakEffectState extends ConsumerState<StudyAutoSpeakEffect> {
  Object? _lastTriggerKey;

  @override
  void initState() {
    super.initState();
    _lastTriggerKey = widget.triggerKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.enabled) return;
      _speakCurrentText();
    });
  }

  @override
  void didUpdateWidget(covariant StudyAutoSpeakEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled || widget.triggerKey == _lastTriggerKey) {
      return;
    }
    _lastTriggerKey = widget.triggerKey;
    _speakCurrentText();
  }

  void _speakCurrentText() {
    unawaited(
      ref
          .read(ttsControllerProvider.notifier)
          .autoPlayTextSide(text: widget.text, side: widget.side),
    );
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
