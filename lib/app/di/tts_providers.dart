import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/datasources/local/daos/tts_settings_dao.dart';
import '../../data/repositories/tts_settings_repository_impl.dart';
import '../../data/services/flutter_tts_service.dart';
import '../../domain/repositories/tts_settings_repository.dart';
import '../../domain/services/tts_playback_policy.dart';
import '../../domain/services/tts_service.dart';
import '../../domain/usecases/tts_usecases.dart';
import 'providers.dart';

part 'tts_providers.g.dart';

@riverpod
TtsPlaybackPolicy ttsPlaybackPolicy(Ref ref) => const TtsPlaybackPolicy();

@riverpod
Future<TtsSettingsRepository> ttsSettingsRepository(Ref ref) async =>
    TtsSettingsRepositoryImpl(TtsSettingsDao(ref.watch(appDatabaseProvider)));

@Riverpod(keepAlive: true)
TtsService ttsService(Ref ref) {
  final service = FlutterTtsService();
  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
}

@riverpod
SpeakFlashcardUseCase speakFlashcardUseCase(Ref ref) => SpeakFlashcardUseCase(
  ref.watch(ttsServiceProvider),
  playbackPolicy: ref.watch(ttsPlaybackPolicyProvider),
);
