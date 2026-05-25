import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memox/core/config/google_oauth_config.dart';
import 'package:memox/core/constants/app_constants.dart';
import 'package:memox/core/logging/app_logger.dart';
import 'package:memox/core/services/clock.dart';
import 'package:memox/core/services/id_generator.dart';
import 'package:memox/data/repositories/google_drive_sync_repository.dart';
import 'package:memox/data/sync/app_settings_snapshot_store.dart';
import 'package:memox/data/sync/drive_sync_json.dart';
import 'package:memox/data/sync/drive_sync_metadata_store.dart';
import 'package:memox/data/sync/drive_sync_snapshot_codec.dart';
import 'package:memox/data/sync/google_drive_app_data_client.dart';
import 'package:memox/data/sync/local_database_snapshot_gateway_contract.dart';
import 'package:memox/domain/entities/cloud_account_link.dart';
import 'package:memox/domain/entities/drive_sync_models.dart';
import 'package:memox/domain/repositories/cloud_account_repository.dart';
import 'package:memox/domain/services/google_account_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  group('backup (uploadLocalSnapshot)', () {
    test('success: first upload creates manifest + snapshot', () async {
      final harness = await _RepositoryHarness.create();

      final result = await harness.repository.uploadLocalSnapshot();

      expect(result.kind, DriveSyncActionKind.uploadedLocal);
      expect(result.status.kind, DriveSyncStatusKind.synced);
      expect(harness.drive.createCount, 2);
      expect(harness.drive.snapshotBytes, isNotNull);
      expect(harness.metadata.loadForAccount(_account.subjectId), isNotNull);
    });

    test('success: subsequent identical upload is a no-op', () async {
      final harness = await _RepositoryHarness.create();
      await harness.repository.uploadLocalSnapshot();

      final result = await harness.repository.uploadLocalSnapshot();

      expect(result.kind, DriveSyncActionKind.noChanges);
      expect(harness.drive.updateCount, 0);
    });

    test('success: local change overwrites remote snapshot', () async {
      final harness = await _RepositoryHarness.create();
      await harness.repository.uploadLocalSnapshot();
      harness.database.databaseBytes = Uint8List.fromList(<int>[9, 9, 9]);

      final result = await harness.repository.uploadLocalSnapshot();

      expect(result.kind, DriveSyncActionKind.uploadedLocal);
      expect(harness.drive.updateCount, 2);
    });

    test('failure: no signed-in user returns signed-out status', () async {
      final harness = await _RepositoryHarness.create(account: null);

      final result = await harness.repository.uploadLocalSnapshot();

      expect(result.kind, DriveSyncActionKind.noChanges);
      expect(result.status.kind, DriveSyncStatusKind.signedOut);
      expect(harness.drive.createCount, 0);
    });

    test('failure: no DB file surfaces failure result', () async {
      final harness = await _RepositoryHarness.create(missingDatabase: true);

      final result = await harness.repository.uploadLocalSnapshot();

      expect(result.kind, DriveSyncActionKind.failed);
      expect(result.status.kind, DriveSyncStatusKind.failure);
      expect(harness.drive.createCount, 0);
    });

    test('failure: Drive upload error returns failed result', () async {
      final harness = await _RepositoryHarness.create(
        driveFailure: const GoogleDriveAppDataException(
          'Internal Server Error',
          statusCode: 500,
        ),
      );

      final result = await harness.repository.uploadLocalSnapshot();

      expect(result.kind, DriveSyncActionKind.failed);
      expect(result.status.kind, DriveSyncStatusKind.failure);
    });

    test('failure: 401 maps to needs-authorization status', () async {
      final harness = await _RepositoryHarness.create(
        driveFailure: const GoogleDriveAppDataException(
          'access token expired',
          statusCode: 401,
        ),
      );

      final result = await harness.repository.uploadLocalSnapshot();

      expect(result.kind, DriveSyncActionKind.failed);
      expect(result.status.kind, DriveSyncStatusKind.needsDriveAuthorization);
    });
  });

  group('restore (restoreDriveSnapshot)', () {
    test('success: downloads remote and replaces local DB', () async {
      final harness = await _RepositoryHarness.create();
      await harness.repository.uploadLocalSnapshot();
      harness.database.databaseBytes = Uint8List.fromList(<int>[4, 5, 6]);
      final remote = _snapshotFor(
        databaseBytes: Uint8List.fromList(<int>[8, 8, 8]),
        settings: const <String, Object?>{
          AppConstants.sharedPrefsLocaleKey: 'vi',
        },
      );
      harness.drive.replaceRemoteSnapshot(remote);

      final result = await harness.repository.restoreDriveSnapshot();

      expect(result.kind, DriveSyncActionKind.restoredRemote);
      expect(
        result.restoreEffect,
        DriveSyncRestoreEffect.refreshDatabaseProvider,
      );
      expect(
        harness.database.restoredBytes,
        Uint8List.fromList(<int>[8, 8, 8]),
      );
      expect(
        harness.preferences.getString(AppConstants.sharedPrefsLocaleKey),
        'vi',
      );
    });

    test('failure: no backup found leaves local data untouched', () async {
      final harness = await _RepositoryHarness.create();

      final result = await harness.repository.restoreDriveSnapshot();

      expect(result.kind, DriveSyncActionKind.noChanges);
      expect(result.status.kind, DriveSyncStatusKind.noRemoteSnapshot);
      expect(harness.database.restoredBytes, isNull);
    });

    test('failure: no signed-in user returns signed-out status', () async {
      final harness = await _RepositoryHarness.create(account: null);

      final result = await harness.repository.restoreDriveSnapshot();

      expect(result.kind, DriveSyncActionKind.noChanges);
      expect(result.status.kind, DriveSyncStatusKind.signedOut);
      expect(harness.database.restoredBytes, isNull);
    });

    test(
      'failure: invalid backup ZIP keeps local DB intact (safety)',
      () async {
        final harness = await _RepositoryHarness.create();
        await harness.repository.uploadLocalSnapshot();
        final remote = _snapshotFor(
          databaseBytes: Uint8List.fromList(<int>[8, 8, 8]),
          settings: const <String, Object?>{},
        );
        harness.drive.replaceRemoteSnapshot(
          remote,
          snapshotBytes: Uint8List.fromList(<int>[1, 2, 3]),
        );

        final result = await harness.repository.restoreDriveSnapshot();

        expect(result.kind, DriveSyncActionKind.failed);
        expect(result.message, 'Drive snapshot is invalid.');
        expect(
          harness.database.restoredBytes,
          isNull,
          reason: 'local DB must not be overwritten when validation fails',
        );
      },
    );

    test('failure: newer remote schema rejected before restore', () async {
      final harness = await _RepositoryHarness.create();
      await harness.repository.uploadLocalSnapshot();
      final remote = _snapshotFor(
        databaseBytes: Uint8List.fromList(<int>[8, 8, 8]),
        settings: const <String, Object?>{},
        appDatabaseSchemaVersion: 99,
      );
      harness.drive.replaceRemoteSnapshot(remote);

      final result = await harness.repository.restoreDriveSnapshot();

      expect(result.kind, DriveSyncActionKind.failed);
      expect(result.status.kind, DriveSyncStatusKind.unsupportedSchema);
      expect(harness.database.restoredBytes, isNull);
    });

    test('failure: Drive download error returns failed result', () async {
      final harness = await _RepositoryHarness.create(
        driveFailure: const GoogleDriveAppDataException(
          'service unavailable',
          statusCode: 503,
        ),
      );

      final result = await harness.repository.restoreDriveSnapshot();

      expect(result.kind, DriveSyncActionKind.failed);
      expect(result.status.kind, DriveSyncStatusKind.failure);
      expect(harness.database.restoredBytes, isNull);
    });
  });

  group('loadStatus', () {
    test('signed-out when no account is linked', () async {
      final harness = await _RepositoryHarness.create(account: null);

      final status = await harness.repository.loadStatus();

      expect(status.kind, DriveSyncStatusKind.signedOut);
    });

    test('noRemoteSnapshot when Drive is empty', () async {
      final harness = await _RepositoryHarness.create();

      final status = await harness.repository.loadStatus();

      expect(status.kind, DriveSyncStatusKind.noRemoteSnapshot);
    });

    test('synced after a successful upload', () async {
      final harness = await _RepositoryHarness.create();
      await harness.repository.uploadLocalSnapshot();

      final status = await harness.repository.loadStatus();

      expect(status.kind, DriveSyncStatusKind.synced);
      expect(status.lastSyncedAt, isNotNull);
    });

    test('Drive 401 maps to needs-authorization', () async {
      final harness = await _RepositoryHarness.create(
        driveFailure: const GoogleDriveAppDataException(
          'access token expired',
          statusCode: 401,
        ),
      );

      final status = await harness.repository.loadStatus();

      expect(status.kind, DriveSyncStatusKind.needsDriveAuthorization);
    });

    test('Drive API disabled (403) surfaces as failure with logging', () async {
      final harness = await _RepositoryHarness.create(
        driveFailure: const GoogleDriveAppDataException(
          'Google Drive API has not been used in project.',
          statusCode: 403,
          reason: 'accessNotConfigured',
        ),
      );

      final status = await harness.repository.loadStatus();

      expect(status.kind, DriveSyncStatusKind.failure);
      expect(status.message, contains('Google Drive API'));
      expect(harness.logger.errors, hasLength(1));
    });

    test('null logger does not break failure path', () async {
      final harness = await _RepositoryHarness.create(
        driveFailure: const GoogleDriveAppDataException(
          'Google Drive API has not been used in project.',
          statusCode: 403,
          reason: 'accessNotConfigured',
        ),
        useNullLogger: true,
      );

      final status = await harness.repository.loadStatus();

      expect(status.kind, DriveSyncStatusKind.failure);
      expect(harness.logger.errors, isEmpty);
    });
  });
}

final class _RepositoryHarness {
  const _RepositoryHarness({
    required this.repository,
    required this.drive,
    required this.database,
    required this.metadata,
    required this.preferences,
    required this.logger,
  });

  final GoogleDriveSyncRepository repository;
  final _FakeDriveAppDataClient drive;
  final _FakeLocalDatabaseSnapshotGateway database;
  final DriveSyncMetadataStore metadata;
  final SharedPreferences preferences;
  final _RecordingAppLogger logger;

  static Future<_RepositoryHarness> create({
    DriveAccessTokenResult tokenResult = const DriveAccessTokenResult.success(
      'access-token',
    ),
    GoogleDriveAppDataException? driveFailure,
    bool useNullLogger = false,
    bool missingDatabase = false,
    CloudAccountLink? account = _account,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final drive = _FakeDriveAppDataClient(failure: driveFailure);
    final database = _FakeLocalDatabaseSnapshotGateway(
      databaseBytes: Uint8List.fromList(<int>[1, 2, 3]),
      missing: missingDatabase,
    );
    final metadata = DriveSyncMetadataStore(preferences);
    final logger = _RecordingAppLogger();
    final repository = GoogleDriveSyncRepository(
      accountRepository: _FakeCloudAccountRepository(account),
      authService: _FakeGoogleAccountAuthService(tokenResult),
      googleOAuthConfig: GoogleOAuthConfig.fromValues(
        serverClientId: 'server-client-id.apps.googleusercontent.com',
      ),
      driveClient: drive,
      databaseSnapshotGateway: database,
      settingsSnapshotStore: AppSettingsSnapshotStore(preferences),
      metadataStore: metadata,
      snapshotCodec: const DriveSyncSnapshotCodec(),
      clock: const _FakeClock(100),
      idGenerator: const _FakeIdGenerator('device-id'),
      logger: useNullLogger ? null : logger,
    );

    return _RepositoryHarness(
      repository: repository,
      drive: drive,
      database: database,
      metadata: metadata,
      preferences: preferences,
      logger: logger,
    );
  }
}

final class _RecordingAppLogger implements AppLogger {
  final errors = <_RecordedLogError>[];

  @override
  void error(String message, Object error, StackTrace stackTrace) {
    errors.add(
      _RecordedLogError(message: message, error: error, stackTrace: stackTrace),
    );
  }
}

final class _RecordedLogError {
  const _RecordedLogError({
    required this.message,
    required this.error,
    required this.stackTrace,
  });

  final String message;
  final Object error;
  final StackTrace stackTrace;
}

const _account = CloudAccountLink(
  provider: CloudProvider.google,
  subjectId: 'google-user',
  email: 'user@example.com',
  displayName: 'MemoX User',
  photoUrl: null,
  grantedScopes: <String>{googleDriveAppDataScope},
  driveAuthorizationState: DriveAuthorizationState.authorized,
  linkedAt: 1,
  lastSignedInAt: 1,
);

DriveSyncSnapshot _snapshotFor({
  required Uint8List databaseBytes,
  required Map<String, Object?> settings,
  int appDatabaseSchemaVersion = 6,
}) => const DriveSyncSnapshotCodec().encode(
  databaseBytes: databaseBytes,
  settings: settings,
  appDatabaseSchemaVersion: appDatabaseSchemaVersion,
  createdAt: 100,
  deviceId: 'remote-device',
  deviceLabel: 'Remote device',
);

final class _FakeDriveAppDataClient implements DriveAppDataClient {
  _FakeDriveAppDataClient({this.failure});

  final GoogleDriveAppDataException? failure;

  DriveAppDataFile? manifestFile;
  DriveAppDataFile? snapshotFile;
  Uint8List? manifestBytes;
  Uint8List? snapshotBytes;
  int createCount = 0;
  int updateCount = 0;
  int _version = 1;

  void replaceRemoteSnapshot(
    DriveSyncSnapshot snapshot, {
    Uint8List? snapshotBytes,
  }) {
    snapshotFile = DriveAppDataFile(
      id: 'snapshot-file',
      name: AppConstants.driveSyncSnapshotFileName,
      version: 'remote-${_version++}',
    );
    manifestFile = DriveAppDataFile(
      id: 'manifest-file',
      name: AppConstants.driveSyncManifestFileName,
      version: 'remote-${_version++}',
    );
    this.snapshotBytes = snapshotBytes ?? snapshot.archiveBytes;
    manifestBytes = Uint8List.fromList(
      utf8.encode(
        DriveSyncJson.encodeCanonicalJson(
          DriveSyncJson.encodeManifest(
            snapshot.manifest.copyWith(
              snapshotFileId: snapshotFile!.id,
              snapshotFileVersion: snapshotFile!.version,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Future<DriveAppDataFile?> findFileByName({
    required String accessToken,
    required String name,
  }) async {
    _throwIfFailure();
    return switch (name) {
      AppConstants.driveSyncManifestFileName => manifestFile,
      AppConstants.driveSyncSnapshotFileName => snapshotFile,
      _ => null,
    };
  }

  @override
  Future<DriveAppDataFile> createFile({
    required String accessToken,
    required String name,
    required String mimeType,
    required Uint8List bytes,
    Map<String, String> appProperties = const <String, String>{},
  }) async {
    _throwIfFailure();
    createCount += 1;
    return _upsert(name: name, bytes: bytes);
  }

  @override
  Future<DriveAppDataFile> updateFile({
    required String accessToken,
    required String fileId,
    required String mimeType,
    required Uint8List bytes,
    Map<String, String> appProperties = const <String, String>{},
  }) async {
    _throwIfFailure();
    updateCount += 1;
    final name = fileId == snapshotFile?.id
        ? AppConstants.driveSyncSnapshotFileName
        : AppConstants.driveSyncManifestFileName;
    return _upsert(name: name, bytes: bytes, id: fileId);
  }

  @override
  Future<Uint8List> downloadFile({
    required String accessToken,
    required String fileId,
  }) async {
    _throwIfFailure();
    if (fileId == manifestFile?.id && manifestBytes != null) {
      return manifestBytes!;
    }
    if (fileId == snapshotFile?.id && snapshotBytes != null) {
      return snapshotBytes!;
    }
    throw const GoogleDriveAppDataException('missing test file');
  }

  DriveAppDataFile _upsert({
    required String name,
    required Uint8List bytes,
    String? id,
  }) {
    final file = DriveAppDataFile(
      id:
          id ??
          (name == AppConstants.driveSyncSnapshotFileName
              ? 'snapshot-file'
              : 'manifest-file'),
      name: name,
      version: 'v${_version++}',
    );
    if (name == AppConstants.driveSyncSnapshotFileName) {
      snapshotFile = file;
      snapshotBytes = bytes;
    } else {
      manifestFile = file;
      manifestBytes = bytes;
    }
    return file;
  }

  void _throwIfFailure() {
    final error = failure;
    if (error != null) {
      throw error;
    }
  }
}

final class _FakeLocalDatabaseSnapshotGateway
    implements LocalDatabaseSnapshotGateway {
  _FakeLocalDatabaseSnapshotGateway({
    required this.databaseBytes,
    this.missing = false,
  });

  Uint8List databaseBytes;
  Uint8List? restoredBytes;
  final bool missing;

  @override
  int get currentSchemaVersion => 6;

  @override
  Future<Uint8List> exportDatabase() async {
    if (missing) {
      throw const _MissingDatabaseFileException(
        'Local database file is missing.',
      );
    }
    return databaseBytes;
  }

  @override
  Future<DriveSyncRestoreEffect> restoreDatabase(
    Uint8List databaseBytes,
  ) async {
    restoredBytes = databaseBytes;
    return DriveSyncRestoreEffect.refreshDatabaseProvider;
  }
}

final class _MissingDatabaseFileException implements Exception {
  const _MissingDatabaseFileException(this.message);
  final String message;
  @override
  String toString() => 'MissingDatabaseFileException: $message';
}

final class _FakeCloudAccountRepository implements CloudAccountRepository {
  const _FakeCloudAccountRepository(this.link);

  final CloudAccountLink? link;

  @override
  Future<void> clear() async {}

  @override
  Future<CloudAccountLink?> load() async => link;

  @override
  Future<void> save(CloudAccountLink link) async {}
}

final class _FakeGoogleAccountAuthService implements GoogleAccountAuthService {
  const _FakeGoogleAccountAuthService(this.tokenResult);

  final DriveAccessTokenResult tokenResult;

  @override
  Stream<GoogleAccountAuthResult> get authenticationEvents =>
      const Stream<GoogleAccountAuthResult>.empty();

  @override
  bool get requiresPlatformSignInButton => false;

  @override
  bool get supportsInteractiveSignIn => true;

  @override
  Future<GoogleAccountAuthResult> authorizeDriveAppData(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  ) async => const GoogleAccountAuthResult.signedOut();

  @override
  Future<DriveAccessTokenResult> getDriveAppDataAccessToken(
    GoogleOAuthConfig config,
    CloudAccountLink link,
  ) async => tokenResult;

  @override
  Future<void> initialize(GoogleOAuthConfig config) async {}

  @override
  Future<GoogleAccountAuthResult> restoreLightweightSession(
    GoogleOAuthConfig config,
  ) async => const GoogleAccountAuthResult.signedOut();

  @override
  Future<void> signOutLocal() async {}

  @override
  Future<GoogleAccountAuthResult> signInAndAuthorizeDriveAppData(
    GoogleOAuthConfig config,
  ) async => const GoogleAccountAuthResult.signedOut();
}

final class _FakeClock implements Clock {
  const _FakeClock(this.value);

  final int value;

  @override
  int nowEpochMillis() => value;

  @override
  DateTime nowUtc() => DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
}

final class _FakeIdGenerator implements IdGenerator {
  const _FakeIdGenerator(this.value);

  final String value;

  @override
  String nextId() => value;
}
