import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/services/portable_cover_restore_service.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory temporaryDirectory;
  late Directory coversDirectory;
  late PortableCoverRestoreService service;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'my_shelf_cover_restore_test_',
    );

    coversDirectory = Directory(path.join(temporaryDirectory.path, 'covers'));

    service = PortableCoverRestoreService(
      coversDirectoryProvider: () async => coversDirectory,
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  group('PortableCoverRestoreService', () {
    test('ottaa uuden kansikuvan käyttöön ja vahvistaa palautuksen', () async {
      const fileName = 'new-cover.jpg';
      final expectedBytes = Uint8List.fromList(<int>[1, 2, 3, 4]);

      final transaction = await service.beginRestore(
        coverFiles: {fileName: expectedBytes},
      );

      final targetFile = File(path.join(coversDirectory.path, fileName));

      expect(await targetFile.exists(), isTrue);
      expect(await targetFile.readAsBytes(), orderedEquals(expectedBytes));
      expect(transaction.isActive, isTrue);
      expect(transaction.restoredFileNames, contains(fileName));

      await transaction.commit();

      expect(transaction.isActive, isFalse);
      expect(await targetFile.exists(), isTrue);
      expect(await targetFile.readAsBytes(), orderedEquals(expectedBytes));

      final temporaryRestoreDirectories = await _findRestoreWorkingDirectories(
        coversDirectory,
      );

      expect(temporaryRestoreDirectories, isEmpty);
    });

    test('palauttaa ylikirjoitetun kansikuvan rollbackissa', () async {
      await coversDirectory.create(recursive: true);

      const fileName = 'existing-cover.jpg';

      final targetFile = File(path.join(coversDirectory.path, fileName));

      final originalBytes = Uint8List.fromList(<int>[9, 9, 9]);

      final restoredBytes = Uint8List.fromList(<int>[1, 2, 3]);

      await targetFile.writeAsBytes(originalBytes);

      final transaction = await service.beginRestore(
        coverFiles: {fileName: restoredBytes},
      );

      expect(await targetFile.readAsBytes(), orderedEquals(restoredBytes));

      await transaction.rollback();

      expect(transaction.isActive, isFalse);
      expect(await targetFile.exists(), isTrue);
      expect(await targetFile.readAsBytes(), orderedEquals(originalBytes));

      final temporaryRestoreDirectories = await _findRestoreWorkingDirectories(
        coversDirectory,
      );

      expect(temporaryRestoreDirectories, isEmpty);
    });

    test('poistaa uuden kansikuvan rollbackissa', () async {
      const fileName = 'temporary-cover.jpg';

      final transaction = await service.beginRestore(
        coverFiles: {
          fileName: Uint8List.fromList(<int>[1, 2, 3]),
        },
      );

      final targetFile = File(path.join(coversDirectory.path, fileName));

      expect(await targetFile.exists(), isTrue);

      await transaction.rollback();

      expect(await targetFile.exists(), isFalse);
    });

    test(
      'hylkää turvattoman tiedostonimen ennen tiedostojen kirjoittamista',
      () async {
        await expectLater(
          service.beginRestore(
            coverFiles: {
              '../secret.jpg': Uint8List.fromList(<int>[1, 2, 3]),
            },
          ),
          throwsA(
            isA<FormatException>().having(
              (error) => error.message,
              'message',
              contains('nimi on virheellinen'),
            ),
          ),
        );

        expect(await coversDirectory.exists(), isFalse);
      },
    );

    test('hylkää tyhjän kansikuvatiedoston', () async {
      await expectLater(
        service.beginRestore(coverFiles: {'empty-cover.jpg': Uint8List(0)}),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('on tyhjä'),
          ),
        ),
      );

      expect(await coversDirectory.exists(), isFalse);
    });

    test('vahvistettua tapahtumaa ei voi enää perua', () async {
      final transaction = await service.beginRestore(
        coverFiles: {
          'committed-cover.jpg': Uint8List.fromList(<int>[1, 2, 3]),
        },
      );

      await transaction.commit();

      await expectLater(
        transaction.rollback(),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('ei ole enää aktiivinen'),
          ),
        ),
      );
    });
  });
}

Future<List<FileSystemEntity>> _findRestoreWorkingDirectories(
  Directory coversDirectory,
) async {
  if (!await coversDirectory.exists()) {
    return const [];
  }

  return coversDirectory
      .list()
      .where(
        (entity) =>
            entity is Directory &&
            (path.basename(entity.path).startsWith('.restore_stage_') ||
                path.basename(entity.path).startsWith('.restore_backup_')),
      )
      .toList();
}
