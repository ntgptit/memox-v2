import 'tts_service.dart';

final class TtsPlaybackPolicy {
  const TtsPlaybackPolicy();

  bool canSpeakTextSide(TtsTextSide? side) =>
      side == null || side == TtsTextSide.front;

  bool canSpeakFlashcardSide(TtsTextSide side) => side == TtsTextSide.front;
}
