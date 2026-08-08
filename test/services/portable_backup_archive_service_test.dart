import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/book.dart';
import 'package:my_shelf/models/library_backup.dart';
import 'package:my_shelf/models/portable_backup_manifest.dart';
import 'package:my_shelf/models/shelf.dart';
import 'package:my_shelf/services/portable_backup_archive_service.dart';

void main() {
  const service = PortableBackupArchiveService();

  group('PortableBackupArchiveService', () {
    test(
      'muodostaa ZIP-arkiston manifestista, kirjastosta ja kansikuvasta',
      () {
        final backup = _createBackup(customCoverFileName: 'book-1-cover.jpg');

        final coverBytes = Uint8List.fromList(<int>[1, 2, 3, 4, 5]);

        final zipBytes = service.encode(
          backup: backup,
          coverFiles: {
            'book-1-cover.jpg': coverBytes,

            // Tätä tiedostoa mikään kirja ei käytä.
            'orphan-cover.jpg': Uint8List.fromList(<int>[9, 9, 9]),
          },
        );

        final archive = ZipDecoder().decodeBytes(zipBytes);

        final manifestFile = archive.find(
          PortableBackupManifest.manifestFileName,
        );

        final libraryFile = archive.find(
          PortableBackupManifest.libraryFileName,
        );

        final coverFile = archive.find(
          '${PortableBackupManifest.coversDirectoryName}/'
          'book-1-cover.jpg',
        );

        expect(manifestFile, isNotNull);
        expect(libraryFile, isNotNull);
        expect(coverFile, isNotNull);

        final restoredManifest = PortableBackupManifest.decode(
          utf8.decode(manifestFile!.readBytes()!),
        );

        final restoredBackup = LibraryBackup.decode(
          utf8.decode(libraryFile!.readBytes()!),
        );

        expect(
          restoredManifest.archiveVersion,
          PortableBackupManifest.currentArchiveVersion,
        );

        expect(restoredManifest.createdAt, backup.createdAt);

        expect(restoredBackup.books, hasLength(1));

        expect(
          restoredBackup.books.single.customCoverFileName,
          'book-1-cover.jpg',
        );

        expect(coverFile!.readBytes(), orderedEquals(coverBytes));
      },
    );

    test('ei lisää arkistoon tarpeettomia kansikuvatiedostoja', () {
      final backup = _createBackup(customCoverFileName: 'used-cover.jpg');

      final zipBytes = service.encode(
        backup: backup,
        coverFiles: {
          'used-cover.jpg': Uint8List.fromList(<int>[1, 2, 3]),
          'unused-cover.jpg': Uint8List.fromList(<int>[4, 5, 6]),
        },
      );

      final archive = ZipDecoder().decodeBytes(zipBytes);

      expect(archive.find('covers/used-cover.jpg'), isNotNull);

      expect(archive.find('covers/unused-cover.jpg'), isNull);
    });

    test('muodostaa arkiston myös ilman paikallisia kansikuvia', () {
      final backup = _createBackup();

      final zipBytes = service.encode(backup: backup, coverFiles: const {});

      final archive = ZipDecoder().decodeBytes(zipBytes);

      expect(archive.find(PortableBackupManifest.manifestFileName), isNotNull);

      expect(archive.find(PortableBackupManifest.libraryFileName), isNotNull);

      expect(
        archive.find('${PortableBackupManifest.coversDirectoryName}/'),
        isNotNull,
      );

      final coverEntries = archive.where(
        (entry) =>
            entry.isFile &&
            entry.name.startsWith(
              '${PortableBackupManifest.coversDirectoryName}/',
            ),
      );

      expect(coverEntries, isEmpty);
    });

    test('hylkää puuttuvan kansikuvatiedoston', () {
      final backup = _createBackup(customCoverFileName: 'missing-cover.jpg');

      expect(
        () => service.encode(backup: backup, coverFiles: const {}),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('missing-cover.jpg'),
          ),
        ),
      );
    });

    test('hylkää tyhjän kansikuvatiedoston', () {
      final backup = _createBackup(customCoverFileName: 'empty-cover.jpg');

      expect(
        () => service.encode(
          backup: backup,
          coverFiles: {'empty-cover.jpg': Uint8List(0)},
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('on tyhjä'),
          ),
        ),
      );
    });

    test('hylkää turvattoman kansikuvatiedostonimen', () {
      final backup = _createBackup(customCoverFileName: '../secret.jpg');

      expect(
        () => service.encode(
          backup: backup,
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
    });

    test('lisää kahden kirjan käyttämän saman kuvan vain kerran', () {
      final backup = LibraryBackup(
        formatVersion: LibraryBackup.currentFormatVersion,
        createdAt: DateTime.utc(2026, 8, 2, 9, 30),
        shelves: const [
          Shelf(id: 'default-shelf', name: 'Oletushylly', position: 0),
        ],
        books: const [
          Book(
            id: 'book-1',
            shelfId: 'default-shelf',
            title: 'Ensimmäinen kirja',
            author: 'Ensimmäinen kirjailija',
            pageCount: 100,
            customCoverFileName: 'shared-cover.jpg',
            spineColor: Color(0xFF795548),
          ),
          Book(
            id: 'book-2',
            shelfId: 'default-shelf',
            title: 'Toinen kirja',
            author: 'Toinen kirjailija',
            pageCount: 200,
            customCoverFileName: 'shared-cover.jpg',
            spineColor: Color(0xFF5D4037),
          ),
        ],
      );

      final zipBytes = service.encode(
        backup: backup,
        coverFiles: {
          'shared-cover.jpg': Uint8List.fromList(<int>[1, 2, 3]),
        },
      );

      final archive = ZipDecoder().decodeBytes(zipBytes);

      final matchingEntries = archive.where(
        (entry) => entry.name == 'covers/shared-cover.jpg',
      );

      expect(matchingEntries, hasLength(1));
    });
  });
}

LibraryBackup _createBackup({String? customCoverFileName}) {
  return LibraryBackup(
    formatVersion: LibraryBackup.currentFormatVersion,
    createdAt: DateTime.utc(2026, 8, 2, 9, 30),
    shelves: const [
      Shelf(id: 'default-shelf', name: 'Oletushylly', position: 0),
    ],
    books: [
      Book(
        id: 'book-1',
        shelfId: 'default-shelf',
        isbn: '9789510428262',
        title: 'Testikirja',
        author: 'Testikirjailija',
        pageCount: 320,
        customCoverFileName: customCoverFileName,
        spineColor: const Color(0xFF795548),
        readingStatus: ReadingStatus.reading,
      ),
    ],
  );
}
