import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/app/di/tts_providers.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:memox/presentation/features/tts/providers/tts_controller_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('DT1 build: follows service state stream updates', () async {
    SharedPreferences.setMockInitialValues({});
    final fake = _FakeTtsService();
    final container = ProviderContainer(
      overrides: [ttsServiceProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    addTearDown(fake.dispose);

    final subscription = container.listen<TtsState>(
      ttsControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    fake.emit(TtsState.speaking);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(ttsControllerProvider), TtsState.speaking);
  });

  test('DT1 speakText: rejects blank text without calling service', () async {
    SharedPreferences.setMockInitialValues({});
    final fake = _FakeTtsService();
    final container = ProviderContainer(
      overrides: [ttsServiceProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    addTearDown(fake.dispose);

    final result = await container
        .read(ttsControllerProvider.notifier)
        .speakText(text: '   ', language: TtsLanguage.korean);

    expect(result, isFalse);
    expect(fake.speakCalls, isEmpty);
  });

  test(
    'DT2 speakText: sends exact text language rate and voice to service',
    () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.sharedPrefsTtsRateKey: 0.6,
        AppConstants.sharedPrefsTtsFrontVoiceNameKey: 'Korean Voice',
      });
      final fake = _FakeTtsService();
      final container = ProviderContainer(
        overrides: [ttsServiceProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);
      addTearDown(fake.dispose);

      final result = await container
          .read(ttsControllerProvider.notifier)
          .speakText(
            text: '안녕하세요',
            language: TtsLanguage.korean,
            side: TtsTextSide.front,
          );

      expect(result, isTrue);
      expect(fake.speakCalls, hasLength(1));
      expect(fake.speakCalls.single.text, '안녕하세요');
      expect(fake.speakCalls.single.language, TtsLanguage.korean);
      expect(fake.speakCalls.single.rate, 0.6);
      expect(fake.speakCalls.single.voiceName, 'Korean Voice');
    },
  );

  test('DT3 speakText: maps service error to controller error state', () async {
    SharedPreferences.setMockInitialValues({});
    final fake = _FakeTtsService(throwOnSpeak: true);
    final container = ProviderContainer(
      overrides: [ttsServiceProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    addTearDown(fake.dispose);

    final result = await container
        .read(ttsControllerProvider.notifier)
        .speakText(text: 'hello', language: TtsLanguage.english);

    expect(result, isFalse);
    expect(container.read(ttsControllerProvider), TtsState.error);
  });

  test(
    'DT4 speakText: rejects non-front side without calling service',
    () async {
      SharedPreferences.setMockInitialValues({});
      final fake = _FakeTtsService();
      final container = ProviderContainer(
        overrides: [ttsServiceProvider.overrideWithValue(fake)],
      );
      addTearDown(container.dispose);
      addTearDown(fake.dispose);

      final result = await container
          .read(ttsControllerProvider.notifier)
          .speakText(
            text: 'meaning',
            language: TtsLanguage.english,
            side: TtsTextSide.back,
          );

      expect(result, isFalse);
      expect(fake.speakCalls, isEmpty);
    },
  );

  test('DT1 stop: stops service and resets state to idle', () async {
    SharedPreferences.setMockInitialValues({});
    final fake = _FakeTtsService();
    final container = ProviderContainer(
      overrides: [ttsServiceProvider.overrideWithValue(fake)],
    );
    addTearDown(container.dispose);
    addTearDown(fake.dispose);

    fake.emit(TtsState.speaking);
    await Future<void>.delayed(Duration.zero);

    final result = await container.read(ttsControllerProvider.notifier).stop();

    expect(result, isTrue);
    expect(fake.stopCount, 1);
    expect(container.read(ttsControllerProvider), TtsState.idle);
  });
}

final class _SpeakCall {
  const _SpeakCall({
    required this.text,
    required this.language,
    required this.rate,
    this.voiceName,
  });

  final String text;
  final TtsLanguage language;
  final double rate;
  final String? voiceName;
}

final class _FakeTtsService implements TtsService {
  _FakeTtsService({this.throwOnSpeak = false});

  final bool throwOnSpeak;
  final StreamController<TtsState> _states =
      StreamController<TtsState>.broadcast();

  final List<_SpeakCall> speakCalls = <_SpeakCall>[];
  int stopCount = 0;

  @override
  Stream<TtsState> get state => _states.stream;

  void emit(TtsState state) {
    if (!_states.isClosed) {
      _states.add(state);
    }
  }

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguage language) async {
    return [TtsVoice(name: '${language.name} voice', language: language)];
  }

  @override
  Future<void> speak(
    String text, {
    required TtsLanguage language,
    required double rate,
    String? voiceName,
  }) async {
    if (throwOnSpeak) {
      throw StateError('TTS unavailable');
    }
    speakCalls.add(
      _SpeakCall(
        text: text,
        language: language,
        rate: rate,
        voiceName: voiceName,
      ),
    );
    emit(TtsState.speaking);
  }

  @override
  Future<void> stop() async {
    stopCount += 1;
    emit(TtsState.idle);
  }

  @override
  Future<void> dispose() async {
    await _states.close();
  }
}
