import 'package:my_shelf/models/app_version.dart';
import 'package:my_shelf/services/update_service.dart';

Future<void> main() async {
  final service = UpdateService();

  print('Testataan oikeaa GitHub Releases API:a...');
  print('');

  await _runTest(
    service: service,
    currentVersion: '0.12.0-alpha',
    expectUpdate: true,
  );

  print('');
  print('----------------------------------------');
  print('');

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

  print('Testin nykyinen versio: $version');
  print('Odotus: ${expectUpdate ? 'päivitys löytyy' : 'päivitystä ei löydy'}');

  try {
    final release = await service.checkForUpdate(version);

    if (release == null) {
      print('Päivitystä ei löytynyt.');

      if (expectUpdate) {
        print('TESTI EPÄONNISTUI');
      } else {
        print('TESTI ONNISTUI');
      }

      return;
    }

    print('Päivitys löytyi!');
    print('Tagi: ${release.tagName}');
    print('Versio: ${release.version}');
    print('Nimi: ${release.name}');
    print('Prerelease: ${release.prerelease}');
    print('URL: ${release.htmlUrl}');

    if (!expectUpdate) {
      print('TESTI EPÄONNISTUI');
      print('Päivitystä ei olisi pitänyt tarjota.');
      return;
    }

    if (!release.version.isNewerThan(version)) {
      print('TESTI EPÄONNISTUI');
      print('Löydettyä versiota ei tunnistettu nykyistä uudemmaksi.');
      return;
    }

    print('TESTI ONNISTUI');
  } catch (error) {
    print('TESTI EPÄONNISTUI');
    print('Virhe: $error');
  }
}
