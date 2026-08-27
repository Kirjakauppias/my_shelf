import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:my_shelf/services/app_update_checker.dart';
import 'package:my_shelf/services/installed_app_version_service.dart';
import 'package:my_shelf/services/update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('AppUpdateChecker', () {
    test('palauttaa päivityksen kun GitHubissa on uudempi versio', () async {
      final installedVersionService = InstalledAppVersionService(
        loadPackageInfo: () async {
          return _packageInfo(version: '0.13.0-alpha', buildNumber: '14');
        },
      );

      final updateService = UpdateService(
        get: (uri, {headers}) async {
          return _jsonResponse([_releaseJson(tag: 'v0.14.0-alpha')]);
        },
      );

      final checker = AppUpdateChecker(
        installedVersionService: installedVersionService,
        updateService: updateService,
      );

      final result = await checker.check();

      expect(result.currentVersion.toString(), '0.13.0-alpha');

      expect(result.updateAvailable, isTrue);

      expect(result.availableRelease, isNotNull);

      expect(result.availableRelease!.tagName, 'v0.14.0-alpha');
    });

    test(
      'palauttaa ettei päivitystä ole kun nykyinen versio on uusin',
      () async {
        final installedVersionService = InstalledAppVersionService(
          loadPackageInfo: () async {
            return _packageInfo(version: '0.13.0-alpha', buildNumber: '14');
          },
        );

        final updateService = UpdateService(
          get: (uri, {headers}) async {
            return _jsonResponse([
              _releaseJson(tag: 'v0.13.0-alpha'),
              _releaseJson(tag: 'v0.12.1-alpha'),
            ]);
          },
        );

        final checker = AppUpdateChecker(
          installedVersionService: installedVersionService,
          updateService: updateService,
        );

        final result = await checker.check();

        expect(result.currentVersion.toString(), '0.13.0-alpha');

        expect(result.updateAvailable, isFalse);

        expect(result.availableRelease, isNull);
      },
    );

    test('käyttää asennetun sovelluksen versiota GitHub-vertailussa', () async {
      final installedVersionService = InstalledAppVersionService(
        loadPackageInfo: () async {
          return _packageInfo(version: '0.12.1-alpha', buildNumber: '13');
        },
      );

      final updateService = UpdateService(
        get: (uri, {headers}) async {
          return _jsonResponse([_releaseJson(tag: 'v0.13.0-alpha')]);
        },
      );

      final checker = AppUpdateChecker(
        installedVersionService: installedVersionService,
        updateService: updateService,
      );

      final result = await checker.check();

      expect(result.currentVersion.toString(), '0.12.1-alpha');

      expect(result.availableRelease?.tagName, 'v0.13.0-alpha');
    });
  });
}

PackageInfo _packageInfo({
  required String version,
  required String buildNumber,
}) {
  return PackageInfo(
    appName: 'My Shelf',
    packageName: 'com.example.my_shelf',
    version: version,
    buildNumber: buildNumber,
    buildSignature: '',
    installerStore: null,
  );
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
