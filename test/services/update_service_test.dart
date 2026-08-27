import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:my_shelf/models/app_version.dart';
import 'package:my_shelf/services/update_check_exception.dart';
import 'package:my_shelf/services/update_service.dart';

void main() {
  group('UpdateService', () {
    test('hakee GitHubin releases-rajapinnasta uusimman version', () async {
      Uri? requestedUri;
      Map<String, String>? requestedHeaders;

      final service = UpdateService(
        get: (uri, {headers}) async {
          requestedUri = uri;
          requestedHeaders = headers;

          return _jsonResponse([
            _releaseJson(tag: 'v0.13.0-alpha'),
            _releaseJson(tag: 'v0.14.0-alpha'),
            _releaseJson(tag: 'v0.12.1-alpha'),
          ]);
        },
      );

      final result = await service.checkForUpdate(
        AppVersion.parse('0.12.1-alpha'),
      );

      expect(result, isNotNull);
      expect(result!.tagName, 'v0.14.0-alpha');

      expect(requestedUri?.host, 'api.github.com');

      expect(requestedUri?.path, '/repos/Kirjakauppias/my_shelf/releases');

      expect(requestedUri?.queryParameters['per_page'], '20');

      expect(requestedHeaders?['Accept'], 'application/vnd.github+json');

      expect(requestedHeaders?['User-Agent'], 'My-Shelf');
    });

    test('palauttaa null kun uudempaa versiota ei ole', () async {
      final service = UpdateService(
        get: (uri, {headers}) async {
          return _jsonResponse([
            _releaseJson(tag: 'v0.12.1-alpha'),
            _releaseJson(tag: 'v0.12.0-alpha'),
          ]);
        },
      );

      final result = await service.checkForUpdate(
        AppVersion.parse('0.12.1-alpha'),
      );

      expect(result, isNull);
    });

    test('ohittaa draft-julkaisun', () async {
      final service = UpdateService(
        get: (uri, {headers}) async {
          return _jsonResponse([
            _releaseJson(tag: 'v0.99.0-alpha', draft: true),
            _releaseJson(tag: 'v0.13.0-alpha'),
          ]);
        },
      );

      final result = await service.checkForUpdate(
        AppVersion.parse('0.12.1-alpha'),
      );

      expect(result, isNotNull);
      expect(result!.tagName, 'v0.13.0-alpha');
    });

    test('ohittaa virheellisen versionumerotagin', () async {
      final service = UpdateService(
        get: (uri, {headers}) async {
          return _jsonResponse([
            _releaseJson(tag: 'latest-test-build'),
            _releaseJson(tag: 'v0.13.0-alpha'),
          ]);
        },
      );

      final result = await service.checkForUpdate(
        AppVersion.parse('0.12.1-alpha'),
      );

      expect(result, isNotNull);
      expect(result!.tagName, 'v0.13.0-alpha');
    });

    test('vakaa julkaisu tunnistetaan alpha-versiota uudemmaksi', () async {
      final service = UpdateService(
        get: (uri, {headers}) async {
          return _jsonResponse([
            _releaseJson(tag: 'v1.0.0', prerelease: false),
          ]);
        },
      );

      final result = await service.checkForUpdate(
        AppVersion.parse('1.0.0-alpha'),
      );

      expect(result, isNotNull);
      expect(result!.tagName, 'v1.0.0');
    });

    test('HTTP-virhe aiheuttaa UpdateCheckExceptionin', () async {
      final service = UpdateService(
        get: (uri, {headers}) async {
          return http.Response('Server error', 500);
        },
      );

      expect(
        () => service.checkForUpdate(AppVersion.parse('0.12.1-alpha')),
        throwsA(isA<UpdateCheckException>()),
      );
    });

    test('virheellinen JSON aiheuttaa UpdateCheckExceptionin', () async {
      final service = UpdateService(
        get: (uri, {headers}) async {
          return http.Response('{virheellinen json', 200);
        },
      );

      expect(
        () => service.checkForUpdate(AppVersion.parse('0.12.1-alpha')),
        throwsA(isA<UpdateCheckException>()),
      );
    });
  });
}

http.Response _jsonResponse(Object body) {
  return http.Response(
    jsonEncode(body),
    200,
    headers: const {'content-type': 'application/json'},
  );
}

Map<String, dynamic> _releaseJson({
  required String tag,
  bool prerelease = true,
  bool draft = false,
}) {
  return {
    'tag_name': tag,
    'name': 'My Shelf $tag',
    'html_url':
        'https://github.com/'
        'Kirjakauppias/my_shelf/'
        'releases/tag/$tag',
    'prerelease': prerelease,
    'draft': draft,
  };
}
