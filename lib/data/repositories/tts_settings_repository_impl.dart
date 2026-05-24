import '../../core/utils/string_utils.dart';
import '../../domain/repositories/tts_settings_repository.dart';
import '../../domain/services/tts_service.dart';
import '../datasources/local/daos/tts_settings_dao.dart';

final class TtsSettingsRepositoryImpl implements TtsSettingsRepository {
  const TtsSettingsRepositoryImpl(this._dao);

  final TtsSettingsDao _dao;

  @override
  Future<TtsSettings> load() async {
    final row = await _dao.load();
    if (row == null) {
      return TtsSettings.defaults;
    }
    return TtsSettings(
      autoPlay: row.autoPlay,
      frontLanguage: TtsLanguage.fromStorage(row.frontLanguage),
      rate: TtsSettings.normalizeRate(row.rate),
      pitch: TtsSettings.normalizePitch(row.pitch),
      volume: TtsSettings.normalizeVolume(row.volume),
      frontVoiceName: StringUtils.trimToNull(row.frontVoiceName),
    );
  }

  @override
  Future<void> save(TtsSettings settings) => _dao.save(settings);
}
