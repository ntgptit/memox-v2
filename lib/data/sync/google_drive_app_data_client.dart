import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

final class DriveAppDataFile {
  const DriveAppDataFile({
    required this.id,
    required this.name,
    required this.version,
    this.modifiedAt,
    this.size,
    this.appProperties = const <String, String>{},
  });

  final String id;
  final String name;
  final String version;
  final int? modifiedAt;
  final int? size;
  final Map<String, String> appProperties;
}

final class GoogleDriveAppDataException implements Exception {
  const GoogleDriveAppDataException(
    this.message, {
    this.statusCode,
    this.reason,
  });

  final String message;
  final int? statusCode;
  final String? reason;

  @override
  String toString() {
    if (statusCode == null) {
      return 'GoogleDriveAppDataException: $message';
    }
    if (reason == null) {
      return 'GoogleDriveAppDataException($statusCode): $message';
    }
    return 'GoogleDriveAppDataException($statusCode/$reason): $message';
  }
}

abstract interface class DriveAppDataClient {
  Future<DriveAppDataFile?> findFileByName({
    required String accessToken,
    required String name,
  });

  Future<DriveAppDataFile> createFile({
    required String accessToken,
    required String name,
    required String mimeType,
    required Uint8List bytes,
    Map<String, String> appProperties = const <String, String>{},
  });

  Future<DriveAppDataFile> updateFile({
    required String accessToken,
    required String fileId,
    required String mimeType,
    required Uint8List bytes,
    Map<String, String> appProperties = const <String, String>{},
  });

  Future<Uint8List> downloadFile({
    required String accessToken,
    required String fileId,
  });
}

final class GoogleDriveAppDataClient implements DriveAppDataClient {
  const GoogleDriveAppDataClient(this._client);

  static const String _filesFields =
      'files(id,name,version,modifiedTime,size,appProperties)';
  static const String _fileFields =
      'id,name,version,modifiedTime,size,appProperties';

  final http.Client _client;

  @override
  Future<DriveAppDataFile?> findFileByName({
    required String accessToken,
    required String name,
  }) async {
    final query = "name = '${_escapeQueryString(name)}' and trashed = false";
    final uri = Uri.https('www.googleapis.com', '/drive/v3/files', {
      'spaces': 'appDataFolder',
      'pageSize': '10',
      'fields': _filesFields,
      'q': query,
    });
    final response = await _client.get(uri, headers: _headers(accessToken));
    _throwIfUnsuccessful(response);

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const GoogleDriveAppDataException('Invalid Drive list response.');
    }
    final files = decoded['files'];
    if (files is! List || files.isEmpty) {
      return null;
    }
    final first = files.first;
    if (first is! Map<String, dynamic>) {
      throw const GoogleDriveAppDataException('Invalid Drive file metadata.');
    }
    return _decodeFile(first);
  }

  @override
  Future<DriveAppDataFile> createFile({
    required String accessToken,
    required String name,
    required String mimeType,
    required Uint8List bytes,
    Map<String, String> appProperties = const <String, String>{},
  }) async {
    final metadata = <String, Object?>{
      'name': name,
      'parents': <String>['appDataFolder'],
      'mimeType': mimeType,
      if (appProperties.isNotEmpty) 'appProperties': appProperties,
    };
    final uri = Uri.https(
      'www.googleapis.com',
      '/upload/drive/v3/files',
      <String, String>{'uploadType': 'multipart', 'fields': _fileFields},
    );
    return _sendMultipart(
      accessToken: accessToken,
      method: 'POST',
      uri: uri,
      metadata: metadata,
      mimeType: mimeType,
      bytes: bytes,
    );
  }

  @override
  Future<DriveAppDataFile> updateFile({
    required String accessToken,
    required String fileId,
    required String mimeType,
    required Uint8List bytes,
    Map<String, String> appProperties = const <String, String>{},
  }) async {
    final metadata = <String, Object?>{
      'mimeType': mimeType,
      if (appProperties.isNotEmpty) 'appProperties': appProperties,
    };
    final uri = Uri.https(
      'www.googleapis.com',
      '/upload/drive/v3/files/$fileId',
      <String, String>{'uploadType': 'multipart', 'fields': _fileFields},
    );
    return _sendMultipart(
      accessToken: accessToken,
      method: 'PATCH',
      uri: uri,
      metadata: metadata,
      mimeType: mimeType,
      bytes: bytes,
    );
  }

  @override
  Future<Uint8List> downloadFile({
    required String accessToken,
    required String fileId,
  }) async {
    final uri = Uri.https('www.googleapis.com', '/drive/v3/files/$fileId', {
      'alt': 'media',
    });
    final response = await _client.get(uri, headers: _headers(accessToken));
    _throwIfUnsuccessful(response);
    return response.bodyBytes;
  }

  Future<DriveAppDataFile> _sendMultipart({
    required String accessToken,
    required String method,
    required Uri uri,
    required Map<String, Object?> metadata,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    final boundary =
        'memox_drive_sync_${DateTime.now().microsecondsSinceEpoch}';
    final metadataBytes = utf8.encode(jsonEncode(metadata));
    final body = BytesBuilder(copy: false)
      ..add(utf8.encode('--$boundary\r\n'))
      ..add(
        utf8.encode('Content-Type: application/json; charset=UTF-8\r\n\r\n'),
      )
      ..add(metadataBytes)
      ..add(utf8.encode('\r\n--$boundary\r\n'))
      ..add(utf8.encode('Content-Type: $mimeType\r\n\r\n'))
      ..add(bytes)
      ..add(utf8.encode('\r\n--$boundary--\r\n'));

    final request = http.Request(method, uri)
      ..headers.addAll(_headers(accessToken))
      ..headers['Content-Type'] = 'multipart/related; boundary=$boundary'
      ..bodyBytes = body.toBytes();

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    _throwIfUnsuccessful(response);

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const GoogleDriveAppDataException('Invalid Drive upload response.');
    }
    return _decodeFile(decoded);
  }

  Map<String, String> _headers(String accessToken) {
    return <String, String>{'Authorization': 'Bearer $accessToken'};
  }

  void _throwIfUnsuccessful(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    final error = _decodeErrorResponse(response.body);
    throw GoogleDriveAppDataException(
      error.message,
      statusCode: response.statusCode,
      reason: error.reason,
    );
  }

  ({String message, String? reason}) _decodeErrorResponse(String body) {
    if (body.isEmpty) {
      return (message: 'Google Drive request failed.', reason: null);
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) {
        return (message: body, reason: null);
      }
      final error = decoded['error'];
      if (error is! Map<String, dynamic>) {
        return (message: body, reason: null);
      }
      final message = error['message'] is String
          ? error['message'] as String
          : body;
      final errors = error['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map && first['reason'] is String) {
          return (message: message, reason: first['reason'] as String);
        }
      }
      return (message: message, reason: null);
    } on FormatException {
      return (message: body, reason: null);
    }
  }

  DriveAppDataFile _decodeFile(Map<String, dynamic> data) {
    final id = data['id'];
    final name = data['name'];
    if (id is! String || id.isEmpty || name is! String || name.isEmpty) {
      throw const GoogleDriveAppDataException(
        'Drive file metadata is missing.',
      );
    }

    final appProperties = data['appProperties'] is Map
        ? Map<String, String>.from(
            (data['appProperties'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            ),
          )
        : const <String, String>{};

    return DriveAppDataFile(
      id: id,
      name: name,
      version: data['version']?.toString() ?? '',
      modifiedAt: _parseModifiedAt(data['modifiedTime']),
      size: int.tryParse(data['size']?.toString() ?? ''),
      appProperties: appProperties,
    );
  }

  int? _parseModifiedAt(Object? value) {
    if (value is! String) {
      return null;
    }
    return DateTime.tryParse(value)?.toUtc().millisecondsSinceEpoch;
  }

  String _escapeQueryString(String value) {
    return value.replaceAll("'", "\\'");
  }
}
