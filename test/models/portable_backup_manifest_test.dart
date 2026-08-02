import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/portable_backup_manifest.dart';

void main() {
  group('PortableBackupManifest', () {
    test('muuntaa manifestin JSONiksi ja takaisin', () {
      final originalManifest = PortableBackupManifest(
        archiveVersion: PortableBackupManifest.currentArchiveVersion,
        createdAt: DateTime.utc(2026, 8, 2, 9, 20),
      );

      final encodedManifest = originalManifest.encode();
      final restoredManifest = PortableBackupManifest.decode(encodedManifest);

      expect(
        restoredManifest.archiveVersion,
        PortableBackupManifest.currentArchiveVersion,
      );

      expect(restoredManifest.createdAt, DateTime.utc(2026, 8, 2, 9, 20));
    });

    test('create käyttää nykyistä arkistoversiota', () {
      final manifest = PortableBackupManifest.create(
        createdAt: DateTime.utc(2026, 8, 2, 9, 20),
      );

      expect(
        manifest.archiveVersion,
        PortableBackupManifest.currentArchiveVersion,
      );

      expect(manifest.createdAt, DateTime.utc(2026, 8, 2, 9, 20));
    });

    test('hylkää väärän formaattitunnisteen', () {
      const invalidManifest = '''
      {
        "format": "jokin-muu-varmuuskopio",
        "archiveVersion": 1,
        "createdAt": "2026-08-02T09:20:00.000Z"
      }
      ''';

      expect(
        () => PortableBackupManifest.decode(invalidManifest),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('ei ole My Shelf'),
          ),
        ),
      );
    });

    test('hylkää tuntemattoman arkistoversion', () {
      const invalidManifest = '''
      {
        "format": "my-shelf-portable-backup",
        "archiveVersion": 999,
        "createdAt": "2026-08-02T09:20:00.000Z"
      }
      ''';

      expect(
        () => PortableBackupManifest.decode(invalidManifest),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('versiota 999 ei tueta'),
          ),
        ),
      );
    });

    test('hylkää virheellisen luontiajan', () {
      const invalidManifest = '''
      {
        "format": "my-shelf-portable-backup",
        "archiveVersion": 1,
        "createdAt": "ei-aikaleima"
      }
      ''';

      expect(
        () => PortableBackupManifest.decode(invalidManifest),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('aikaleima on virheellinen'),
          ),
        ),
      );
    });
  });
}
