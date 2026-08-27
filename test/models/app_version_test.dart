import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/app_version.dart';

void main() {
  group('AppVersion.parse', () {
    test('lukee tavallisen alpha-version', () {
      final version = AppVersion.parse('0.13.0-alpha');

      expect(version.major, 0);
      expect(version.minor, 13);
      expect(version.patch, 0);
      expect(version.preRelease, 'alpha');
      expect(version.isPreRelease, isTrue);
    });

    test('hyväksyy GitHub-tagin v-etuliitteen', () {
      final version = AppVersion.parse('v0.13.0-alpha');

      expect(
        version,
        const AppVersion(major: 0, minor: 13, patch: 0, preRelease: 'alpha'),
      );
    });

    test('ohittaa build-numeron', () {
      final version = AppVersion.parse('0.13.0-alpha+14');

      expect(version.toString(), '0.13.0-alpha');
    });

    test('hyväksyy vakaan version', () {
      final version = AppVersion.parse('1.0.0');

      expect(version.preRelease, isNull);
      expect(version.isPreRelease, isFalse);
    });

    test('hylkää virheellisen versionumeron', () {
      expect(() => AppVersion.parse('versio 13'), throwsFormatException);
    });
  });

  group('AppVersion.compareTo', () {
    test('0.12.1-alpha on vanhempi kuin 0.13.0-alpha', () {
      final current = AppVersion.parse('0.12.1-alpha');

      final newer = AppVersion.parse('0.13.0-alpha');

      expect(current.compareTo(newer), lessThan(0));

      expect(newer.isNewerThan(current), isTrue);
    });

    test('patch-version kasvu tunnistetaan', () {
      final oldVersion = AppVersion.parse('0.13.0-alpha');

      final newVersion = AppVersion.parse('0.13.1-alpha');

      expect(newVersion.isNewerThan(oldVersion), isTrue);
    });

    test('major-version kasvu tunnistetaan', () {
      final oldVersion = AppVersion.parse('0.99.0-alpha');

      final newVersion = AppVersion.parse('1.0.0-alpha');

      expect(newVersion.isNewerThan(oldVersion), isTrue);
    });

    test('sama versio ei ole uudempi', () {
      final current = AppVersion.parse('0.13.0-alpha');

      final same = AppVersion.parse('v0.13.0-alpha');

      expect(same.isNewerThan(current), isFalse);

      expect(same.compareTo(current), 0);
    });

    test('vakaa julkaisu on saman version alphaa uudempi', () {
      final alpha = AppVersion.parse('1.0.0-alpha');

      final stable = AppVersion.parse('1.0.0');

      expect(stable.isNewerThan(alpha), isTrue);
    });

    test('alpha.2 on vanhempi kuin alpha.10', () {
      final oldVersion = AppVersion.parse('1.0.0-alpha.2');

      final newVersion = AppVersion.parse('1.0.0-alpha.10');

      expect(newVersion.isNewerThan(oldVersion), isTrue);
    });
  });
}
