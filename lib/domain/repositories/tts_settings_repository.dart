import '../services/tts_service.dart';

abstract interface class TtsSettingsRepository {
  Future<TtsSettings> load();
  Future<void> save(TtsSettings settings);
}
