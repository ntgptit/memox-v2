import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../app/di/tts_providers.dart';
import '../../../../domain/services/tts_service.dart';

part 'tts_settings_notifier.g.dart';

@riverpod
class TtsSettingsNotifier extends _$TtsSettingsNotifier {
  @override
  Future<TtsSettings> build() async {
    final store = await ref.watch(ttsSettingsStoreProvider.future);
    return store.load();
  }

  // guard:retry-reviewed
  Future<void> setAutoPlay(bool value) =>
      _update((settings) => settings.copyWith(autoPlay: value));

  // guard:retry-reviewed
  Future<void> setFrontLanguage(TtsLanguage language) => _update(
        (settings) =>
            settings.copyWith(frontLanguage: language, clearFrontVoice: true),
      );

  // guard:retry-reviewed
  Future<void> setRate(double value) => _update(
        (settings) => settings.copyWith(rate: TtsSettings.normalizeRate(value)),
      );

  // guard:retry-reviewed
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
    final store = await ref.read(ttsSettingsStoreProvider.future);
    if (!ref.mounted) {
      return;
    }
    await store.save(next);
    if (!ref.mounted) {
      return;
    }
    state = AsyncData<TtsSettings>(next);
  }
}
