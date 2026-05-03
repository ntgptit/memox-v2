import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/core/services/id_generator.dart';
import 'package:memox/data/sync/drive_sync_metadata_store.dart';
import 'package:memox/domain/entities/drive_sync_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test(
    'DT1 metadataStore: load returns null when no metadata is stored',
    () async {
      final store = DriveSyncMetadataStore(
        await SharedPreferences.getInstance(),
      );

      expect(store.loadForAccount('google-user'), isNull);
    },
  );

  test(
    'DT2 metadataStore: save, load, and clear metadata for account',
    () async {
      final store = DriveSyncMetadataStore(
        await SharedPreferences.getInstance(),
      );
      const metadata = DriveSyncMetadata(
        accountSubjectId: 'google-user',
        manifestFileId: 'manifest-file',
        snapshotFileId: 'snapshot-file',
        remoteFingerprint: 'remote',
        localFingerprint: 'local',
        remoteManifestVersion: 'manifest-version',
        remoteSnapshotVersion: 'snapshot-version',
        lastSyncedAt: 123,
      );

      await store.save(metadata);

      expect(store.loadForAccount('google-user')?.remoteFingerprint, 'remote');
      expect(store.loadForAccount('other-user'), isNull);

      await store.clear();

      expect(store.loadForAccount('google-user'), isNull);
    },
  );

  test('DT3 metadataStore: invalid JSON falls back safely', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      AppConstants.sharedPrefsDriveSyncMetadataKey,
      '{bad json',
    );
    final store = DriveSyncMetadataStore(preferences);

    expect(store.loadForAccount('google-user'), isNull);
  });

  test('DT4 metadataStore: old or incomplete JSON falls back safely', () async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      AppConstants.sharedPrefsDriveSyncMetadataKey,
      '{"accountSubjectId":"google-user"}',
    );
    final store = DriveSyncMetadataStore(preferences);

    expect(store.loadForAccount('google-user'), isNull);
  });

  test(
    'DT5 metadataStore: device id is created once and then reused',
    () async {
      final preferences = await SharedPreferences.getInstance();
      final store = DriveSyncMetadataStore(preferences);
      final idGenerator = _FakeIdGenerator('device-1');

      final first = await store.loadOrCreateDeviceId(idGenerator);
      final second = await store.loadOrCreateDeviceId(
        _FakeIdGenerator('device-2'),
      );

      expect(first, 'device-1');
      expect(second, 'device-1');
    },
  );
}

final class _FakeIdGenerator implements IdGenerator {
  const _FakeIdGenerator(this.value);

  final String value;

  @override
  String nextId() => value;
}
