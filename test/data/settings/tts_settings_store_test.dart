import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/data/settings/tts_settings_store.dart';
import 'package:memox/domain/services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'DT1 load: returns front-only defaults when no values are persisted',
    () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      final store = TtsSettingsStore(preferences);

      final settings = store.load();

      expect(settings.autoPlay, isFalse);
      expect(settings.frontLanguage, TtsLanguage.korean);
      expect(settings.rate, TtsSettings.defaultRate);
      expect(settings.frontVoiceName, isNull);
    },
  );

  test('DT2 load: falls back and clamps invalid persisted values', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.sharedPrefsTtsAutoPlayKey: true,
      AppConstants.sharedPrefsTtsFrontLanguageKey: 'vietnamese',
      AppConstants.sharedPrefsTtsBackLanguageKey: '',
      AppConstants.sharedPrefsTtsRateKey: 9.0,
      AppConstants.sharedPrefsTtsFrontVoiceNameKey: '   ',
      AppConstants.sharedPrefsTtsBackVoiceNameKey: '',
    });
    final preferences = await SharedPreferences.getInstance();
    final store = TtsSettingsStore(preferences);

    final settings = store.load();

    expect(settings.autoPlay, isTrue);
    expect(settings.frontLanguage, TtsLanguage.korean);
    expect(settings.rate, TtsSettings.maxRate);
    expect(settings.frontVoiceName, isNull);
  });

  test('DT1 save: writes front-only speech setting keys exactly', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = TtsSettingsStore(preferences);

    await store.save(
      const TtsSettings(
        autoPlay: true,
        frontLanguage: TtsLanguage.english,
        rate: 0.6,
        frontVoiceName: 'English Voice',
      ),
    );

    expect(preferences.getBool(AppConstants.sharedPrefsTtsAutoPlayKey), isTrue);
    expect(
      preferences.getString(AppConstants.sharedPrefsTtsFrontLanguageKey),
      TtsLanguage.english.storageValue,
    );
    expect(preferences.getDouble(AppConstants.sharedPrefsTtsRateKey), 0.6);
    expect(
      preferences.getString(AppConstants.sharedPrefsTtsFrontVoiceNameKey),
      'English Voice',
    );
    expect(
      preferences.containsKey(AppConstants.sharedPrefsTtsBackLanguageKey),
      isFalse,
    );
    expect(
      preferences.containsKey(AppConstants.sharedPrefsTtsBackVoiceNameKey),
      isFalse,
    );
  });

  test('DT2 save: removes optional voices and clamps low rate', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.sharedPrefsTtsFrontVoiceNameKey: 'old front',
      AppConstants.sharedPrefsTtsBackVoiceNameKey: 'old back',
    });
    final preferences = await SharedPreferences.getInstance();
    final store = TtsSettingsStore(preferences);

    await store.save(
      const TtsSettings(
        autoPlay: false,
        frontLanguage: TtsLanguage.korean,
        rate: 0.1,
      ),
    );

    expect(preferences.getDouble(AppConstants.sharedPrefsTtsRateKey), 0.3);
    expect(
      preferences.containsKey(AppConstants.sharedPrefsTtsFrontVoiceNameKey),
      isFalse,
    );
    expect(
      preferences.containsKey(AppConstants.sharedPrefsTtsBackVoiceNameKey),
      isFalse,
    );
  });
}
