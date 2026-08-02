import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/book.dart';
import 'package:my_shelf/models/portable_backup_manifest.dart';
import 'package:my_shelf/models/shelf.dart';
import 'package:my_shelf/services/backup_export_service.dart';
import 'package:path/path.dart' as path;

void main() {
  late Directory temporaryDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'my_shelf_backup_export_test_',
    );
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  group('BackupExportService.buildPortableBackupArchive', () {
    test('lisää paikallisen kansikuvatiedoston ZIP-arkistoon', () async {
      const fileName = 'book-1-cover.jpg';
      final expectedBytes = Uint8List.fromList(<int>[10, 20, 30, 40, 50]);

      final coverFile = File(path.join(temporaryDirectory.path, fileName));

      await coverFile.writeAsBytes(expectedBytes);

      final service = BackupExportService(
        coverFileLoader: (requestedFileName) async {
          if (requestedFileName != fileName) {
            return null;
          }

          return coverFile;
        },
      );

      final zipBytes = await service.buildPortableBackupArchive(
        books: const [
          Book(
            id: 'book-1',
            shelfId: 'default-shelf',
            title: 'Testikirja',
            author: 'Testikirjailija',
            pageCount: 320,
            customCoverFileName: fileName,
            spineColor: Color(0xFF795548),
          ),
        ],
        shelves: const [
          Shelf(id: 'default-shelf', name: 'Oletushylly', position: 0),
        ],
      );

      final archive = ZipDecoder().decodeBytes(zipBytes);

      final archivedCover = archive.find(
        '${PortableBackupManifest.coversDirectoryName}/$fileName',
      );

      expect(archivedCover, isNotNull);

      expect(archivedCover!.readBytes(), orderedEquals(expectedBytes));
    });

    test('lukee kahden kirjan yhteisen kansikuvan vain kerran', () async {
      const fileName = 'shared-cover.jpg';

      final coverFile = File(path.join(temporaryDirectory.path, fileName));

      await coverFile.writeAsBytes(<int>[1, 2, 3]);

      var loaderCallCount = 0;

      final service = BackupExportService(
        coverFileLoader: (requestedFileName) async {
          loaderCallCount += 1;

          if (requestedFileName != fileName) {
            return null;
          }

          return coverFile;
        },
      );

      final zipBytes = await service.buildPortableBackupArchive(
        books: const [
          Book(
            id: 'book-1',
            shelfId: 'default-shelf',
            title: 'Ensimmäinen kirja',
            author: 'Ensimmäinen kirjailija',
            pageCount: 100,
            customCoverFileName: fileName,
            spineColor: Color(0xFF795548),
          ),
          Book(
            id: 'book-2',
            shelfId: 'default-shelf',
            title: 'Toinen kirja',
            author: 'Toinen kirjailija',
            pageCount: 200,
            customCoverFileName: fileName,
            spineColor: Color(0xFF5D4037),
          ),
        ],
        shelves: const [
          Shelf(id: 'default-shelf', name: 'Oletushylly', position: 0),
        ],
      );

      final archive = ZipDecoder().decodeBytes(zipBytes);

      final matchingEntries = archive.where(
        (entry) => entry.name == 'covers/$fileName',
      );

      expect(loaderCallCount, 1);
      expect(matchingEntries, hasLength(1));
    });

    test('hylkää puuttuvan paikallisen kansikuvan', () async {
      final service = BackupExportService(coverFileLoader: (_) async => null);

      expect(
        () => service.buildPortableBackupArchive(
          books: const [
            Book(
              id: 'book-1',
              shelfId: 'default-shelf',
              title: 'Kadonneen kannen kirja',
              author: 'Testikirjailija',
              pageCount: 200,
              customCoverFileName: 'missing-cover.jpg',
              spineColor: Color(0xFF795548),
            ),
          ],
          shelves: const [
            Shelf(id: 'default-shelf', name: 'Oletushylly', position: 0),
          ],
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('Kadonneen kannen kirja'),
              contains('missing-cover.jpg'),
              contains('ei löydy'),
            ),
          ),
        ),
      );
    });

    test('ei kutsu tiedostonlatausta ilman paikallisia kansikuvia', () async {
      var loaderCallCount = 0;

      final service = BackupExportService(
        coverFileLoader: (_) async {
          loaderCallCount += 1;
          return null;
        },
      );

      final zipBytes = await service.buildPortableBackupArchive(
        books: const [
          Book(
            id: 'book-1',
            shelfId: 'default-shelf',
            title: 'Kirja ilman omaa kantta',
            author: 'Testikirjailija',
            pageCount: 150,
            spineColor: Color(0xFF795548),
          ),
        ],
        shelves: const [
          Shelf(id: 'default-shelf', name: 'Oletushylly', position: 0),
        ],
      );

      final archive = ZipDecoder().decodeBytes(zipBytes);

      final archivedCovers = archive.where(
        (entry) =>
            entry.isFile &&
            entry.name.startsWith(
              '${PortableBackupManifest.coversDirectoryName}/',
            ),
      );

      expect(loaderCallCount, 0);
      expect(archivedCovers, isEmpty);
    });
  });
}
