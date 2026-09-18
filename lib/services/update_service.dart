import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_version.dart';
import '../models/github_release.dart';
import 'update_check_exception.dart';

typedef UpdateHttpGet =
    Future<http.Response> Function(Uri uri, {Map<String, String>? headers});

class UpdateService {
  static const Duration _requestTimeout = Duration(seconds: 10);

  static final Uri _releasesUri = Uri.https(
    'api.github.com',
    '/repos/Kirjakauppias/my_shelf/releases',
    {'per_page': '20'},
  );

  final UpdateHttpGet _get;

  UpdateService({UpdateHttpGet get = http.get}) : _get = get;

  Future<GitHubRelease?> checkForUpdate(AppVersion currentVersion) async {
    late final http.Response response;

    try {
      response = await _get(
        _releasesUri,
        headers: const {
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'My-Shelf',
        },
      ).timeout(_requestTimeout);
    } on TimeoutException {
      throw const UpdateCheckException(
        'Päivitysten tarkistus aikakatkaistiin.',
      );
    } catch (_) {
      throw const UpdateCheckException(
        'Päivitystietojen hakeminen epäonnistui.',
      );
    }

    if (response.statusCode != 200) {
      throw UpdateCheckException(
        'GitHub palautti virheen '
        '(${response.statusCode}).',
      );
    }

    late final dynamic decoded;

    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const UpdateCheckException('GitHub palautti virheellistä tietoa.');
    }

    if (decoded is! List) {
      throw const UpdateCheckException(
        'GitHubin julkaisuvastaus on virheellinen.',
      );
    }

    GitHubRelease? latestRelease;
    AppVersion? latestVersion;

    for (final item in decoded) {
      if (item is! Map) {
        continue;
      }

      GitHubRelease release;

      try {
        release = GitHubRelease.fromJson(Map<String, dynamic>.from(item));
      } on FormatException {
        // Yksi virheellinen GitHub-julkaisu ei saa
        // estää muiden julkaisujen tarkistamista.
        continue;
      }

      if (release.draft) {
        continue;
      }

      AppVersion version;

      try {
        version = release.version;
      } on FormatException {
        // Esimerkiksi muu kuin sovelluksen versionumerona
        // käytettävä tagi voidaan turvallisesti ohittaa.
        continue;
      }

      if (!version.isNewerThan(currentVersion)) {
        continue;
      }

      if (latestVersion == null || version.isNewerThan(latestVersion)) {
        latestVersion = version;
        latestRelease = release;
      }
    }

    return latestRelease;
  }
}
