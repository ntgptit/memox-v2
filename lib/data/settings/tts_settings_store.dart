import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/string_utils.dart';
import '../../domain/services/tts_service.dart';

final class TtsSettingsStore {
  const TtsSettingsStore(this._preferences);

  final SharedPreferences _preferences;

  TtsSettings load() {
    return TtsSettings(
      autoPlay:
          _preferences.getBool(AppConstants.sharedPrefsTtsAutoPlayKey) ??
          TtsSettings.defaults.autoPlay,
      frontLanguage: TtsLanguage.fromStorage(
        _preferences.getString(AppConstants.sharedPrefsTtsFrontLanguageKey),
        fallback: TtsSettings.defaults.frontLanguage,
      ),
      rate: TtsSettings.normalizeRate(
        _preferences.getDouble(AppConstants.sharedPrefsTtsRateKey) ??
            TtsSettings.defaultRate,
      ),
      frontVoiceName: StringUtils.trimToNull(
        _preferences.getString(AppConstants.sharedPrefsTtsFrontVoiceNameKey),
      ),
    );
  }

  Future<void> save(TtsSettings settings) async {
    await _preferences.setBool(
      AppConstants.sharedPrefsTtsAutoPlayKey,
      settings.autoPlay,
    );
    await _preferences.setString(
      AppConstants.sharedPrefsTtsFrontLanguageKey,
      settings.frontLanguage.storageValue,
    );
    await _preferences.setDouble(
      AppConstants.sharedPrefsTtsRateKey,
      TtsSettings.normalizeRate(settings.rate),
    );
    await _writeOptionalString(
      AppConstants.sharedPrefsTtsFrontVoiceNameKey,
      settings.frontVoiceName,
    );
    await _preferences.remove(AppConstants.sharedPrefsTtsBackLanguageKey);
    await _preferences.remove(AppConstants.sharedPrefsTtsBackVoiceNameKey);
  }

  Future<void> _writeOptionalString(String key, String? value) async {
    final normalized = StringUtils.trimToNull(value);
    if (normalized == null) {
      await _preferences.remove(key);
      return;
    }
    await _preferences.setString(key, normalized);
  }
}
