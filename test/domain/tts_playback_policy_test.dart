import 'package:flutter_test/flutter_test.dart';
import 'package:memox/domain/services/tts_playback_policy.dart';
import 'package:memox/domain/services/tts_service.dart';

void main() {
  test('DT1 canSpeakTextSide: allows raw text without a card side', () {
    const policy = TtsPlaybackPolicy();

    expect(policy.canSpeakTextSide(null), isTrue);
  });

  test('DT2 canSpeakTextSide: allows front side and rejects back side', () {
    const policy = TtsPlaybackPolicy();

    expect(policy.canSpeakTextSide(TtsTextSide.front), isTrue);
    expect(policy.canSpeakTextSide(TtsTextSide.back), isFalse);
  });

  test('DT1 canSpeakFlashcardSide: allows only front side', () {
    const policy = TtsPlaybackPolicy();

    expect(policy.canSpeakFlashcardSide(TtsTextSide.front), isTrue);
    expect(policy.canSpeakFlashcardSide(TtsTextSide.note), isFalse);
  });
}
