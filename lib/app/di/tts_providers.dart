import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/services/flutter_tts_service.dart';
import '../../data/settings/tts_settings_store.dart';
import '../../domain/services/tts_playback_policy.dart';
import '../../domain/services/tts_service.dart';
import '../../domain/usecases/tts_usecases.dart';
import 'providers.dart';

part 'tts_providers.g.dart';

@riverpod
TtsPlaybackPolicy ttsPlaybackPolicy(Ref ref) {
  return const TtsPlaybackPolicy();
}

@riverpod
Future<TtsSettingsStore> ttsSettingsStore(Ref ref) async {
  return TtsSettingsStore(await ref.watch(sharedPreferencesProvider.future));
}

@Riverpod(keepAlive: true)
TtsService ttsService(Ref ref) {
  final service = FlutterTtsService();
  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
}

@riverpod
SpeakFlashcardUseCase speakFlashcardUseCase(Ref ref) {
  return SpeakFlashcardUseCase(
    ref.watch(ttsServiceProvider),
    playbackPolicy: ref.watch(ttsPlaybackPolicyProvider),
  );
}
