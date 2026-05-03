import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/data/sync/drive_sync_json.dart';
import 'package:memox/data/sync/drive_sync_snapshot_codec.dart';
import 'package:memox/domain/entities/drive_sync_models.dart';

void main() {
  test(
    'DT1 snapshotCodec: encodes and decodes database and settings snapshot',
    () {
      const codec = DriveSyncSnapshotCodec();
      final databaseBytes = Uint8List.fromList(<int>[1, 2, 3]);
      final settings = <String, Object?>{
        'settings.locale': 'vi',
        'settings.study.shuffle_flashcards': true,
      };

      final snapshot = codec.encode(
        databaseBytes: databaseBytes,
        settings: settings,
        appDatabaseSchemaVersion: 6,
        createdAt: 100,
        deviceId: 'device-id',
        deviceLabel: 'MemoX device',
      );
      final decoded = codec.decode(snapshot.archiveBytes);

      expect(decoded, isNotNull);
      expect(decoded!.databaseBytes, databaseBytes);
      expect(decoded.settings, settings);
      expect(decoded.manifest.appId, DriveSyncManifest.currentAppId);
      expect(decoded.manifest.appDatabaseSchemaVersion, 6);
      expect(decoded.manifest.databaseSha256, snapshot.manifest.databaseSha256);
      expect(decoded.manifest.settingsSha256, snapshot.manifest.settingsSha256);
    },
  );

  test(
    'DT2 snapshotCodec: returns null when archived database hash is invalid',
    () {
      const codec = DriveSyncSnapshotCodec();
      final valid = codec.encode(
        databaseBytes: Uint8List.fromList(<int>[1, 2, 3]),
        settings: const <String, Object?>{},
        appDatabaseSchemaVersion: 6,
        createdAt: 100,
        deviceId: 'device-id',
        deviceLabel: 'MemoX device',
      );
      final archive = Archive()
        ..addFile(
          ArchiveFile.string(
            AppConstants.driveSyncManifestEntryName,
            DriveSyncJson.encodeCanonicalJson(
              DriveSyncJson.encodeManifest(valid.manifest),
            ),
          ),
        )
        ..addFile(
          ArchiveFile.bytes(
            AppConstants.driveSyncDatabaseEntryName,
            Uint8List.fromList(<int>[9, 9, 9]),
          ),
        )
        ..addFile(
          ArchiveFile.bytes(
            AppConstants.driveSyncSettingsEntryName,
            Uint8List.fromList(utf8.encode('{}')),
          ),
        );

      final corrupted = Uint8List.fromList(ZipEncoder().encodeBytes(archive));

      expect(codec.decode(corrupted), isNull);
    },
  );

  test('DT3 snapshotCodec: returns null for invalid zip bytes', () {
    const codec = DriveSyncSnapshotCodec();

    expect(codec.decode(Uint8List.fromList(<int>[1, 2])), isNull);
  });
}
