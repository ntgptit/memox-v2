import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/flutter_tts_service.dart';
import '../../data/settings/tts_settings_store.dart';
import '../../domain/services/tts_service.dart';
import '../../domain/usecases/tts_usecases.dart';

part 'tts_providers.g.dart';

@Riverpod(keepAlive: true)
Future<SharedPreferences> ttsSharedPreferences(Ref ref) {
  return SharedPreferences.getInstance();
}

@Riverpod(keepAlive: true)
Future<TtsSettingsStore> ttsSettingsStore(Ref ref) async {
  return TtsSettingsStore(await ref.watch(ttsSharedPreferencesProvider.future));
}

@Riverpod(keepAlive: true)
TtsService ttsService(Ref ref) {
  final service = FlutterTtsService();
  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
}

@Riverpod(keepAlive: true)
SpeakFlashcardUseCase speakFlashcardUseCase(Ref ref) {
  return SpeakFlashcardUseCase(ref.watch(ttsServiceProvider));
}
