import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/drive_sync_models.dart';
import 'drive_sync_json.dart';

final class DriveSyncSnapshotCodec {
  const DriveSyncSnapshotCodec();

  DriveSyncSnapshot encode({
    required Uint8List databaseBytes,
    required Map<String, Object?> settings,
    required int appDatabaseSchemaVersion,
    required int createdAt,
    required String deviceId,
    required String deviceLabel,
  }) {
    final canonicalSettings = DriveSyncJson.encodeCanonicalJson(settings);
    final settingsBytes = Uint8List.fromList(utf8.encode(canonicalSettings));
    final databaseHash = sha256.convert(databaseBytes).toString();
    final settingsHash = sha256.convert(settingsBytes).toString();

    final manifest = DriveSyncManifest(
      manifestVersion: DriveSyncManifest.currentManifestVersion,
      snapshotFormatVersion: DriveSyncManifest.currentSnapshotFormatVersion,
      appId: DriveSyncManifest.currentAppId,
      appDatabaseSchemaVersion: appDatabaseSchemaVersion,
      createdAt: createdAt,
      deviceId: deviceId,
      deviceLabel: deviceLabel,
      databaseSha256: databaseHash,
      settingsSha256: settingsHash,
      snapshotSizeBytes: databaseBytes.length,
    );

    final archive = Archive()
      ..addFile(
        ArchiveFile.string(
          AppConstants.driveSyncManifestEntryName,
          DriveSyncJson.encodeCanonicalJson(
            DriveSyncJson.encodeManifest(manifest),
          ),
        ),
      )
      ..addFile(
        ArchiveFile.bytes(
          AppConstants.driveSyncDatabaseEntryName,
          databaseBytes,
        ),
      )
      ..addFile(
        ArchiveFile.bytes(AppConstants.driveSyncSettingsEntryName, settingsBytes),
      );
    final archiveBytes = ZipEncoder().encodeBytes(archive);

    return DriveSyncSnapshot(
      manifest: manifest,
      archiveBytes: Uint8List.fromList(archiveBytes),
      databaseBytes: databaseBytes,
      settings: settings,
    );
  }

  DriveSyncSnapshot? decode(Uint8List archiveBytes) {
    Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(archiveBytes);
    } on ArchiveException {
      return null;
    } on FormatException {
      return null;
    }

    final manifestText = _archiveText(
      archive,
      AppConstants.driveSyncManifestEntryName,
    );
    final databaseBytes = _archiveBytes(
      archive,
      AppConstants.driveSyncDatabaseEntryName,
    );
    final settingsText = _archiveText(
      archive,
      AppConstants.driveSyncSettingsEntryName,
    );
    if (manifestText == null ||
        databaseBytes == null ||
        settingsText == null) {
      return null;
    }

    final manifest = DriveSyncJson.decodeManifest(
      DriveSyncJson.decodeJsonObject(manifestText),
    );
    final settings = DriveSyncJson.decodeJsonObject(settingsText);
    if (manifest == null || settings == null) {
      return null;
    }

    final databaseHash = sha256.convert(databaseBytes).toString();
    final settingsHash = sha256.convert(utf8.encode(settingsText)).toString();
    if (databaseHash != manifest.databaseSha256 ||
        settingsHash != manifest.settingsSha256 ||
        databaseBytes.length != manifest.snapshotSizeBytes) {
      return null;
    }

    return DriveSyncSnapshot(
      manifest: manifest,
      archiveBytes: archiveBytes,
      databaseBytes: databaseBytes,
      settings: settings,
    );
  }

  Uint8List? _archiveBytes(Archive archive, String path) {
    for (final file in archive.files) {
      if (file.name == path && file.isFile) {
        return file.readBytes();
      }
    }
    return null;
  }

  String? _archiveText(Archive archive, String path) {
    final bytes = _archiveBytes(archive, path);
    if (bytes == null) {
      return null;
    }
    return utf8.decode(bytes);
  }
}
