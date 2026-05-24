import '../../core/utils/string_utils.dart';
import '../services/tts_playback_policy.dart';
import '../services/tts_service.dart';
import '../study/entities/study_models.dart';

final class SpeakFlashcardUseCase {
  const SpeakFlashcardUseCase(
    this._ttsService, {
    TtsPlaybackPolicy playbackPolicy = const TtsPlaybackPolicy(),
  }) : _playbackPolicy = playbackPolicy;

  final TtsService _ttsService;
  final TtsPlaybackPolicy _playbackPolicy;

  Future<void> speakText({
    required String text,
    required TtsLanguage language,
    required TtsSettings settings,
    String? voiceName,
  }) async {
    if (StringUtils.isBlank(text)) {
      return;
    }
    await _ttsService.speak(
      StringUtils.trimmed(text),
      language: language,
      rate: settings.rate,
      voiceName: voiceName,
    );
  }

  Future<void> speakFlashcardSide({
    required StudyFlashcardRef flashcard,
    required TtsTextSide side,
    required TtsSettings settings,
  }) {
    if (!_playbackPolicy.canSpeakFlashcardSide(side)) {
      return Future<void>.value();
    }
    return speakText(
      text: _textFor(flashcard, side),
      language: settings.languageFor(side),
      settings: settings,
      voiceName: settings.voiceNameFor(side),
    );
  }

  String _textFor(StudyFlashcardRef flashcard, TtsTextSide side) => switch (side) {
      TtsTextSide.front => flashcard.front,
      TtsTextSide.back => flashcard.back,
      TtsTextSide.note => '',
    };
}
