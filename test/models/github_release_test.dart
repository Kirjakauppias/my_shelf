import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/github_release.dart';

void main() {
  group('GitHubRelease.fromJson', () {
    test('lukee kelvollisen GitHub-julkaisun', () {
      final release = GitHubRelease.fromJson({
        'tag_name': 'v0.13.0-alpha',
        'name': 'My Shelf v0.13.0-alpha',
        'html_url':
            'https://github.com/'
            'Kirjakauppias/my_shelf/'
            'releases/tag/v0.13.0-alpha',
        'prerelease': true,
        'draft': false,
      });

      expect(release.tagName, 'v0.13.0-alpha');
      expect(release.name, 'My Shelf v0.13.0-alpha');
      expect(release.prerelease, isTrue);
      expect(release.draft, isFalse);
      expect(release.version.toString(), '0.13.0-alpha');
    });

    test('hylkää julkaisun ilman tagia', () {
      expect(
        () => GitHubRelease.fromJson({
          'name': 'Test release',
          'html_url': 'https://github.com/example/release',
          'prerelease': true,
          'draft': false,
        }),
        throwsFormatException,
      );
    });

    test('hylkää virheellisen URL-osoitteen', () {
      expect(
        () => GitHubRelease.fromJson({
          'tag_name': 'v0.13.0-alpha',
          'name': 'Test release',
          'html_url': 'ei-verkko-osoite',
          'prerelease': true,
          'draft': false,
        }),
        throwsFormatException,
      );
    });
  });
}
