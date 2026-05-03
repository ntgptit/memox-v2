import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/data/sync/app_settings_snapshot_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'DT1 settingsSnapshot: load includes syncable settings and excludes account data',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppConstants.sharedPrefsThemeModeKey: 'dark',
        AppConstants.sharedPrefsLocaleKey: 'vi',
        AppConstants.sharedPrefsDefaultNewBatchSizeKey: 12,
        AppConstants.sharedPrefsShuffleFlashcardsKey: false,
        AppConstants.sharedPrefsTtsRateKey: 0.8,
        AppConstants.sharedPrefsCloudAccountLinkKey:
            '{"email":"user@example.com"}',
        AppConstants.sharedPrefsDriveSyncMetadataKey:
            '{"fingerprint":"remote"}',
      });
      final store = AppSettingsSnapshotStore(
        await SharedPreferences.getInstance(),
      );

      final snapshot = store.load();

      expect(snapshot[AppConstants.sharedPrefsThemeModeKey], 'dark');
      expect(snapshot[AppConstants.sharedPrefsLocaleKey], 'vi');
      expect(snapshot[AppConstants.sharedPrefsDefaultNewBatchSizeKey], 12);
      expect(snapshot[AppConstants.sharedPrefsShuffleFlashcardsKey], isFalse);
      expect(snapshot[AppConstants.sharedPrefsTtsRateKey], 0.8);
      expect(
        snapshot,
        isNot(contains(AppConstants.sharedPrefsCloudAccountLinkKey)),
      );
      expect(
        snapshot,
        isNot(contains(AppConstants.sharedPrefsDriveSyncMetadataKey)),
      );
    },
  );

  test(
    'DT2 settingsSnapshot: restore replaces only included settings keys',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        AppConstants.sharedPrefsThemeModeKey: 'dark',
        AppConstants.sharedPrefsDefaultNewBatchSizeKey: 10,
        AppConstants.sharedPrefsCloudAccountLinkKey:
            '{"subjectId":"google-user"}',
      });
      final preferences = await SharedPreferences.getInstance();
      final store = AppSettingsSnapshotStore(preferences);

      await store.restore(<String, Object?>{
        AppConstants.sharedPrefsLocaleKey: 'vi',
        AppConstants.sharedPrefsDefaultReviewBatchSizeKey: 25,
        AppConstants.sharedPrefsShuffleFlashcardsKey: 'invalid',
        AppConstants.sharedPrefsTtsRateKey: 0.75,
        AppConstants.sharedPrefsCloudAccountLinkKey: 'ignored',
      });

      expect(
        preferences.getString(AppConstants.sharedPrefsThemeModeKey),
        isNull,
      );
      expect(
        preferences.getInt(AppConstants.sharedPrefsDefaultNewBatchSizeKey),
        isNull,
      );
      expect(preferences.getString(AppConstants.sharedPrefsLocaleKey), 'vi');
      expect(
        preferences.getInt(AppConstants.sharedPrefsDefaultReviewBatchSizeKey),
        25,
      );
      expect(
        preferences.getBool(AppConstants.sharedPrefsShuffleFlashcardsKey),
        isNull,
      );
      expect(preferences.getDouble(AppConstants.sharedPrefsTtsRateKey), 0.75);
      expect(
        preferences.getString(AppConstants.sharedPrefsCloudAccountLinkKey),
        '{"subjectId":"google-user"}',
      );
    },
  );
}
