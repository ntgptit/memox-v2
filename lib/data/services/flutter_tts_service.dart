import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../core/utils/string_utils.dart';
import '../../domain/services/tts_service.dart';

final class FlutterTtsService implements TtsService {
  FlutterTtsService({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts() {
    _configureHandlers();
    _initFuture = _configurePlatform();
  }

  final FlutterTts _flutterTts;
  final StreamController<TtsState> _stateController =
      StreamController<TtsState>.broadcast();
  late final Future<void> _initFuture;
  TtsState _currentState = TtsState.idle;

  @override
  Stream<TtsState> get state => _stateController.stream;

  @override
  Future<List<TtsVoice>> availableVoices(TtsLanguage language) async {
    final rawVoices = await _flutterTts.getVoices;
    if (rawVoices is! List) {
      return const <TtsVoice>[];
    }
    final voices = <TtsVoice>[];
    for (final rawVoice in rawVoices) {
      if (rawVoice is! Map) {
        continue;
      }
      final rawName = rawVoice['name'];
      final rawLocale = rawVoice['locale'];
      if (rawName is! String || rawLocale is! String) {
        continue;
      }
      if (!StringUtils.equalsNormalized(rawLocale, language.localeTag)) {
        continue;
      }
      final rawGender = rawVoice['gender'];
      voices.add(
        TtsVoice(
          name: rawName,
          language: language,
          gender: rawGender is String ? rawGender : null,
        ),
      );
    }
    voices.sort(
      (left, right) => StringUtils.compareNormalized(left.name, right.name),
    );
    return voices;
  }

  @override
  Future<void> speak(
    String text, {
    required TtsLanguage language,
    required double rate,
    String? voiceName,
  }) async {
    if (StringUtils.isBlank(text)) {
      return;
    }
    await _initFuture;
    await stop();
    await _runOnEngine(
      () => _flutterTts.setLanguage(language.localeTag),
      label: 'setLanguage',
    );
    await _runOnEngine(
      () => _flutterTts.setSpeechRate(TtsSettings.normalizeRate(rate)),
      label: 'setSpeechRate',
    );
    await _runOnEngine(
      () => _flutterTts.setVolume(1.0),
      label: 'setVolume',
    );
    await _runOnEngine(
      () => _flutterTts.setPitch(1.0),
      label: 'setPitch',
    );
    if (StringUtils.isNotBlank(voiceName)) {
      await _runOnEngine(
        () => _flutterTts.setVoice(<String, String>{
          'name': StringUtils.trimmed(voiceName),
          'locale': language.localeTag,
        }),
        label: 'setVoice',
      );
    }
    _emit(TtsState.speaking);
    await _flutterTts.speak(StringUtils.trimmed(text));
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
    _emit(TtsState.idle);
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _stateController.close();
  }

  void _configureHandlers() {
    _flutterTts.setStartHandler(() => _emit(TtsState.speaking));
    _flutterTts.setCompletionHandler(() => _emit(TtsState.idle));
    _flutterTts.setCancelHandler(() => _emit(TtsState.idle));
    _flutterTts.setPauseHandler(() => _emit(TtsState.paused));
    _flutterTts.setContinueHandler(() => _emit(TtsState.speaking));
    _flutterTts.setErrorHandler((_) => _emit(TtsState.error));
  }

  Future<void> _configurePlatform() async {
    await _runOnEngine(
      () => _flutterTts.awaitSpeakCompletion(false),
      label: 'awaitSpeakCompletion',
    );
    if (!kIsWeb && Platform.isIOS) {
      await _runOnEngine(
        () => _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          const <IosTextToSpeechAudioCategoryOptions>[
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.spokenAudio,
        ),
        label: 'setIosAudioCategory',
      );
    }
  }

  Future<void> _runOnEngine(
    Future<dynamic> Function() action, {
    required String label,
  }) async {
    try {
      await action();
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'FlutterTtsService',
          context: ErrorDescription('while invoking $label'),
          silent: true,
        ),
      );
    }
  }

  void _emit(TtsState nextState) {
    if (_stateController.isClosed || _currentState == nextState) {
      return;
    }
    _currentState = nextState;
    _stateController.add(nextState);
  }
}
