import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/services/installed_app_version_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  group('InstalledAppVersionService', () {
    test('lukee asennetun sovelluksen version', () async {
      final service = InstalledAppVersionService(
        loadPackageInfo: () async {
          return _packageInfo(version: '0.13.0-alpha', buildNumber: '14');
        },
      );

      final version = await service.getCurrentVersion();

      expect(version.toString(), '0.13.0-alpha');
    });

    test('palauttaa version käyttöliittymän tekstiksi', () async {
      final service = InstalledAppVersionService(
        loadPackageInfo: () async {
          return _packageInfo(version: '0.13.0-alpha', buildNumber: '14');
        },
      );

      expect(await service.getVersionLabel(), '0.13.0-alpha');
    });

    test('palauttaa Androidin build-numeron', () async {
      final service = InstalledAppVersionService(
        loadPackageInfo: () async {
          return _packageInfo(version: '0.13.0-alpha', buildNumber: '14');
        },
      );

      expect(await service.getBuildNumber(), '14');
    });

    test('virheellinen asennettu versio hylätään', () async {
      final service = InstalledAppVersionService(
        loadPackageInfo: () async {
          return _packageInfo(version: 'virheellinen', buildNumber: '14');
        },
      );

      expect(service.getCurrentVersion(), throwsFormatException);
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
