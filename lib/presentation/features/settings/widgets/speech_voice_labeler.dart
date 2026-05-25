import 'package:memox/l10n/generated/app_localizations.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../../domain/services/tts_service.dart';

final class SpeechVoiceLabeler {
  SpeechVoiceLabeler(List<TtsVoice> voices)
    : _voiceFamilyIndex = _buildVoiceFamilyIndex(voices);

  final Map<String, int> _voiceFamilyIndex;

  String labelFor(AppLocalizations l10n, TtsVoice voice) {
    final familyIndex = _voiceFamilyIndex[_voiceFamilyKey(voice.name)] ?? 1;
    final parts = <String>[
      _voiceBaseLabel(l10n, voice.language, familyIndex),
    ];
    final source = _voiceSourceLabel(l10n, voice.name);
    if (source != null) {
      parts.add(source);
    }
    final gender = _voiceGenderLabel(l10n, voice.gender);
    if (gender != null) {
      parts.add(gender);
    }
    return parts.join(' · ');
  }

  static Map<String, int> _buildVoiceFamilyIndex(List<TtsVoice> voices) {
    final indexes = <String, int>{};
    for (final voice in voices) {
      final key = _voiceFamilyKey(voice.name);
      indexes.putIfAbsent(key, () => indexes.length + 1);
    }
    return indexes;
  }
}

String _voiceBaseLabel(
  AppLocalizations l10n,
  TtsLanguage language,
  int index,
) =>
    switch (language) {
      TtsLanguage.korean => l10n.settingsSpeechKoreanVoiceLabel(index),
      TtsLanguage.english => l10n.settingsSpeechEnglishVoiceLabel(index),
    };

String? _voiceSourceLabel(AppLocalizations l10n, String voiceName) =>
    switch (_voiceSource(voiceName)) {
      _VoiceSource.device => l10n.settingsSpeechVoiceDeviceSource,
      _VoiceSource.online => l10n.settingsSpeechVoiceOnlineSource,
      null => null,
    };

String? _voiceGenderLabel(AppLocalizations l10n, String? gender) =>
    switch (gender) {
      'male' => l10n.settingsSpeechVoiceMale,
      'female' => l10n.settingsSpeechVoiceFemale,
      _ => null,
    };

enum _VoiceSource { device, online }

_VoiceSource? _voiceSource(String voiceName) {
  final tokens = _voiceNameTokens(voiceName);
  if (tokens.isEmpty) {
    return null;
  }
  return switch (tokens.last) {
    'local' => _VoiceSource.device,
    'network' => _VoiceSource.online,
    _ => null,
  };
}

String _voiceFamilyKey(String voiceName) {
  final tokens = _voiceNameTokens(voiceName);
  if (tokens.isEmpty) {
    return StringUtils.normalizedForComparison(voiceName);
  }
  final familyTokens = switch (tokens.last) {
    'local' || 'network' => tokens.take(tokens.length - 1),
    _ => tokens,
  };
  return familyTokens.join('-');
}

List<String> _voiceNameTokens(String voiceName) => StringUtils
    .normalizedForComparison(voiceName)
    .split(RegExp(r'[-_\s]+'))
    .where(StringUtils.isNotBlank)
    .toList(growable: false);
