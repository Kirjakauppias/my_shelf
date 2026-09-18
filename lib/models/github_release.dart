import 'app_version.dart';

class GitHubRelease {
  final String tagName;
  final String? name;
  final String htmlUrl;
  final bool prerelease;
  final bool draft;

  const GitHubRelease({
    required this.tagName,
    this.name,
    required this.htmlUrl,
    required this.prerelease,
    required this.draft,
  });

  factory GitHubRelease.fromJson(Map<String, dynamic> json) {
    final tagName = json['tag_name'];
    final name = json['name'];
    final htmlUrl = json['html_url'];
    final prerelease = json['prerelease'];
    final draft = json['draft'];

    if (tagName is! String || tagName.trim().isEmpty) {
      throw const FormatException('GitHub-julkaisulta puuttuu tag_name.');
    }

    if (name != null && name is! String) {
      throw const FormatException('GitHub-julkaisun name on virheellinen.');
    }

    if (htmlUrl is! String || htmlUrl.trim().isEmpty) {
      throw const FormatException('GitHub-julkaisulta puuttuu html_url.');
    }

    final uri = Uri.tryParse(htmlUrl);

    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      throw const FormatException('GitHub-julkaisun html_url on virheellinen.');
    }

    if (prerelease is! bool) {
      throw const FormatException(
        'GitHub-julkaisun prerelease on virheellinen.',
      );
    }

    if (draft is! bool) {
      throw const FormatException('GitHub-julkaisun draft on virheellinen.');
    }

    return GitHubRelease(
      tagName: tagName.trim(),
      name: name?.trim(),
      htmlUrl: htmlUrl.trim(),
      prerelease: prerelease,
      draft: draft,
    );
  }

  AppVersion get version {
    return AppVersion.parse(tagName);
  }
}
