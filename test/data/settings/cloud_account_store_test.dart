import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/data/settings/cloud_account_store.dart';
import 'package:memox/domain/entities/cloud_account_link.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('DT1 load: returns null when no account is saved', () async {
    final store = CloudAccountStore(await SharedPreferences.getInstance());

    expect(await store.load(), isNull);
  });

  test('DT2 load: restores current schema Google account metadata', () async {
    final store = CloudAccountStore(await SharedPreferences.getInstance());

    await store.save(_accountLink);
    final loaded = await store.load();

    expect(loaded?.subjectId, 'google-user-001');
    expect(loaded?.email, 'user@example.com');
    expect(loaded?.grantedScopes, contains(googleDriveAppDataScope));
    expect(loaded?.driveAuthorizationState, DriveAuthorizationState.authorized);
  });

  test('DT3 load: ignores malformed or legacy account JSON', () async {
    final preferences = await SharedPreferences.getInstance();
    final store = CloudAccountStore(preferences);

    await preferences.setString(
      AppConstants.sharedPrefsCloudAccountLinkKey,
      '{"schemaVersion":0,"provider":"google"}',
    );

    expect(await store.load(), isNull);

    await preferences.setString(
      AppConstants.sharedPrefsCloudAccountLinkKey,
      '{not-json',
    );

    expect(await store.load(), isNull);
  });

  test(
    'DT1 saveClear: persists no token material and clears account',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final store = CloudAccountStore(preferences);

      await store.save(_accountLink);
      final rawValue = preferences.getString(
        AppConstants.sharedPrefsCloudAccountLinkKey,
      );
      await store.clear();

      expect(rawValue, isNot(contains('accessToken')));
      expect(rawValue, isNot(contains('refreshToken')));
      expect(rawValue, isNot(contains('idToken')));
      expect(await store.load(), isNull);
    },
  );
}

const _accountLink = CloudAccountLink(
  provider: CloudProvider.google,
  subjectId: 'google-user-001',
  email: 'user@example.com',
  displayName: 'MemoX User',
  photoUrl: 'https://example.com/avatar.png',
  grantedScopes: <String>{googleDriveAppDataScope},
  driveAuthorizationState: DriveAuthorizationState.authorized,
  linkedAt: 1,
  lastSignedInAt: 2,
);
