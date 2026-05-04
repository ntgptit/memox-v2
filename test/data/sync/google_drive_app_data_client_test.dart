import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:memox/data/sync/google_drive_app_data_client.dart';

void main() {
  test(
    'DT1 request: list searches appDataFolder and decodes first file',
    () async {
      final httpClient = _FakeHttpClient(<_ResponseHandler>[
        (request) {
          expect(request.method, 'GET');
          expect(request.url.host, 'www.googleapis.com');
          expect(request.url.path, '/drive/v3/files');
          expect(request.url.queryParameters['spaces'], 'appDataFolder');
          expect(request.url.queryParameters['q'], contains('memox.sync'));
          expect(request.headers['Authorization'], 'Bearer access-token');
          return http.Response(
            jsonEncode(<String, Object?>{
              'files': <Object?>[
                <String, Object?>{
                  'id': 'file-1',
                  'name': 'memox.sync.manifest.json',
                  'version': '7',
                  'modifiedTime': '2026-05-03T12:00:00.000Z',
                  'size': '42',
                  'appProperties': <String, String>{'kind': 'manifest'},
                },
              ],
            }),
            200,
          );
        },
      ]);
      final client = GoogleDriveAppDataClient(httpClient);

      final file = await client.findFileByName(
        accessToken: 'access-token',
        name: 'memox.sync.manifest.json',
      );

      expect(file?.id, 'file-1');
      expect(file?.version, '7');
      expect(file?.size, 42);
      expect(file?.appProperties['kind'], 'manifest');
    },
  );

  test(
    'DT2 request: list returns null when Drive has no matching file',
    () async {
      final httpClient = _FakeHttpClient(<_ResponseHandler>[
        (_) => http.Response(
          jsonEncode(<String, Object?>{'files': <Object?>[]}),
          200,
        ),
      ]);
      final client = GoogleDriveAppDataClient(httpClient);

      expect(
        await client.findFileByName(accessToken: 'token', name: 'missing'),
        isNull,
      );
    },
  );

  test(
    'DT3 request: create uploads multipart metadata into appDataFolder',
    () async {
      final httpClient = _FakeHttpClient(<_ResponseHandler>[
        (request) {
          expect(request.method, 'POST');
          expect(request.url.path, '/upload/drive/v3/files');
          expect(request.url.queryParameters['uploadType'], 'multipart');
          expect(request.headers['Authorization'], 'Bearer access-token');
          expect(
            request.headers['Content-Type'],
            startsWith('multipart/related;'),
          );
          expect(request, isA<http.Request>());
          final body = utf8.decode((request as http.Request).bodyBytes);
          expect(body, contains('"name":"memox.sync.snapshot.zip"'));
          expect(body, contains('"parents":["appDataFolder"]'));
          expect(body, contains('"kind":"snapshot"'));
          expect(body, contains('Content-Type: application/octet-stream'));
          return http.Response(
            jsonEncode(<String, Object?>{
              'id': 'snapshot-file',
              'name': 'memox.sync.snapshot.zip',
              'version': '11',
            }),
            200,
          );
        },
      ]);
      final client = GoogleDriveAppDataClient(httpClient);

      final file = await client.createFile(
        accessToken: 'access-token',
        name: 'memox.sync.snapshot.zip',
        mimeType: 'application/octet-stream',
        bytes: Uint8List.fromList(<int>[1, 2, 3]),
        appProperties: const <String, String>{'kind': 'snapshot'},
      );

      expect(file.id, 'snapshot-file');
      expect(file.version, '11');
    },
  );

  test('DT4 request: Drive error response throws typed exception', () async {
    final httpClient = _FakeHttpClient(<_ResponseHandler>[
      (_) => http.Response(
        jsonEncode(<String, Object?>{
          'error': <String, Object?>{
            'code': 403,
            'message': 'Google Drive API has not been used in project.',
            'errors': <Object?>[
              <String, Object?>{'reason': 'accessNotConfigured'},
            ],
          },
        }),
        403,
      ),
    ]);
    final client = GoogleDriveAppDataClient(httpClient);

    await expectLater(
      client.downloadFile(accessToken: 'bad-token', fileId: 'snapshot-file'),
      throwsA(
        isA<GoogleDriveAppDataException>()
            .having((error) => error.statusCode, 'statusCode', 403)
            .having((error) => error.reason, 'reason', 'accessNotConfigured'),
      ),
    );
  });
}

typedef _ResponseHandler = http.Response Function(http.BaseRequest request);

final class _FakeHttpClient extends http.BaseClient {
  _FakeHttpClient(List<_ResponseHandler> handlers)
    : _handlers = Queue<_ResponseHandler>.of(handlers);

  final Queue<_ResponseHandler> _handlers;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_handlers.isEmpty) {
      throw StateError('Unexpected request: ${request.method} ${request.url}');
    }
    final response = _handlers.removeFirst()(request);
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
      request: request,
      reasonPhrase: response.reasonPhrase,
    );
  }
}
