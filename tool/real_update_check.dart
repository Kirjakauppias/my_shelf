import 'dart:io';

import 'package:my_shelf/models/app_version.dart';
import 'package:my_shelf/services/update_service.dart';

Future<void> main() async {
  final service = UpdateService();

  stdout.writeln('Testataan oikeaa GitHub Releases API:a...');
  stdout.writeln('');

  await _runTest(
    service: service,
    currentVersion: '0.12.0-alpha',
    expectUpdate: true,
  );

  stdout.writeln('');
  stdout.writeln('----------------------------------------');
  stdout.writeln('');

  await _runTest(
    service: service,
    currentVersion: '0.13.0-alpha',
    expectUpdate: false,
  );
}

Future<void> _runTest({
  required UpdateService service,
  required String currentVersion,
  required bool expectUpdate,
}) async {
  final version = AppVersion.parse(currentVersion);

  stdout.writeln('Testin nykyinen versio: $version');
  stdout.writeln(
    'Odotus: ${expectUpdate ? 'päivitys löytyy' : 'päivitystä ei löydy'}',
  );

  try {
    final release = await service.checkForUpdate(version);

    if (release == null) {
      stdout.writeln('Päivitystä ei löytynyt.');

      if (expectUpdate) {
        stdout.writeln('TESTI EPÄONNISTUI');
      } else {
        stdout.writeln('TESTI ONNISTUI');
      }

      return;
    }

    stdout.writeln('Päivitys löytyi!');
    stdout.writeln('Tagi: ${release.tagName}');
    stdout.writeln('Versio: ${release.version}');
    stdout.writeln('Nimi: ${release.name}');
    stdout.writeln('Prerelease: ${release.prerelease}');
    stdout.writeln('URL: ${release.htmlUrl}');

    if (!expectUpdate) {
      stdout.writeln('TESTI EPÄONNISTUI');
      stdout.writeln('Päivitystä ei olisi pitänyt tarjota.');
      return;
    }

    if (!release.version.isNewerThan(version)) {
      stdout.writeln('TESTI EPÄONNISTUI');
      stdout.writeln('Löydettyä versiota ei tunnistettu nykyistä uudemmaksi.');
      return;
    }

    stdout.writeln('TESTI ONNISTUI');
  } catch (error) {
    stdout.writeln('TESTI EPÄONNISTUI');
    stdout.writeln('Virhe: $error');
  }
}
