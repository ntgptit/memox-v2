import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/tts_providers.dart';
import '../../../../domain/services/tts_service.dart';

part 'tts_settings_notifier.g.dart';

@riverpod
class TtsSettingsNotifier extends _$TtsSettingsNotifier {
  @override
  Future<TtsSettings> build() async {
    final repository = await ref.watch(ttsSettingsRepositoryProvider.future);
    return repository.load();
  }

  Future<void> setAutoPlay(bool value) =>
      _update((settings) => settings.copyWith(autoPlay: value));

  Future<void> setFrontLanguage(TtsLanguage language) => _update(
    (settings) =>
        settings.copyWith(frontLanguage: language, clearFrontVoice: true),
  );

  Future<void> setRate(double value) => _update(
    (settings) => settings.copyWith(rate: TtsSettings.normalizeRate(value)),
  );

  Future<void> setPitch(double value) => _update(
    (settings) => settings.copyWith(pitch: TtsSettings.normalizePitch(value)),
  );

  Future<void> setVolume(double value) => _update(
    (settings) => settings.copyWith(volume: TtsSettings.normalizeVolume(value)),
  );

  Future<void> setFrontVoiceName(String? voiceName) => _update(
    (settings) => settings.copyWith(
      frontVoiceName: voiceName,
      clearFrontVoice: voiceName == null,
    ),
  );

  Future<void> _update(
    TtsSettings Function(TtsSettings settings) transform,
  ) async {
    final current = state.when<TtsSettings>(
      data: (settings) => settings,
      loading: () => TtsSettings.defaults,
      error: (_, _) => TtsSettings.defaults,
    );
    final next = transform(current);
    final repository = await ref.read(ttsSettingsRepositoryProvider.future);
    if (!ref.mounted) {
      return;
    }
    await repository.save(next);
    if (!ref.mounted) {
      return;
    }
    state = AsyncData<TtsSettings>(next);
  }
}
