import 'tts_service.dart';

final class TtsPlaybackPolicy {
  const TtsPlaybackPolicy();

  bool canSpeakTextSide(TtsTextSide? side) {
    return side == null || side == TtsTextSide.front;
  }

  bool canSpeakFlashcardSide(TtsTextSide side) {
    return side == TtsTextSide.front;
  }
}
