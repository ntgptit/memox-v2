import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

enum _SnapshotSettingType { string, int, double, bool }

final class AppSettingsSnapshotStore {
  const AppSettingsSnapshotStore(this._preferences);

  static const Map<String, _SnapshotSettingType> _includedKeys =
      <String, _SnapshotSettingType>{
        AppConstants.sharedPrefsThemeModeKey: _SnapshotSettingType.string,
        AppConstants.sharedPrefsLocaleKey: _SnapshotSettingType.string,
        AppConstants.sharedPrefsDefaultNewBatchSizeKey:
            _SnapshotSettingType.int,
        AppConstants.sharedPrefsDefaultReviewBatchSizeKey:
            _SnapshotSettingType.int,
        AppConstants.sharedPrefsShuffleFlashcardsKey:
            _SnapshotSettingType.bool,
        AppConstants.sharedPrefsShuffleAnswersKey: _SnapshotSettingType.bool,
        AppConstants.sharedPrefsPrioritizeOverdueKey: _SnapshotSettingType.bool,
        AppConstants.sharedPrefsTtsAutoPlayKey: _SnapshotSettingType.bool,
        AppConstants.sharedPrefsTtsFrontLanguageKey:
            _SnapshotSettingType.string,
        AppConstants.sharedPrefsTtsRateKey: _SnapshotSettingType.double,
        AppConstants.sharedPrefsTtsFrontVoiceNameKey:
            _SnapshotSettingType.string,
      };

  final SharedPreferences _preferences;

  Map<String, Object?> load() {
    return <String, Object?>{
      for (final entry in _includedKeys.entries)
        if (_preferences.containsKey(entry.key)) entry.key: _preferences.get(entry.key),
    };
  }

  Future<void> restore(Map<String, Object?> settings) async {
    for (final key in _includedKeys.keys) {
      await _preferences.remove(key);
    }

    for (final entry in _includedKeys.entries) {
      final value = settings[entry.key];
      if (value == null) {
        continue;
      }
      switch (entry.value) {
        case _SnapshotSettingType.string:
          if (value is String) {
            await _preferences.setString(entry.key, value);
          }
        case _SnapshotSettingType.int:
          if (value is int) {
            await _preferences.setInt(entry.key, value);
          }
        case _SnapshotSettingType.double:
          if (value is num) {
            await _preferences.setDouble(entry.key, value.toDouble());
          }
        case _SnapshotSettingType.bool:
          if (value is bool) {
            await _preferences.setBool(entry.key, value);
          }
      }
    }
  }
}
