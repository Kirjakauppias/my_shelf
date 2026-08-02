import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/book.dart';
import 'package:my_shelf/models/library_backup.dart';
import 'package:my_shelf/models/portable_backup_manifest.dart';
import 'package:my_shelf/models/shelf.dart';
import 'package:my_shelf/services/portable_backup_archive_reader.dart';

void main() {
  const reader = PortableBackupArchiveReader();

  group('PortableBackupArchiveReader', () {
    test('lukee kelvollisen ZIP-varmuuskopion', () {
      final backup = _createBackup(customCoverFileName: 'book-cover.jpg');

      final source = _createArchive(
        backup: backup,
        covers: const {
          'book-cover.jpg': <int>[1, 2, 3, 4],
        },
      );

      final result = reader.decode(source);

      expect(result.backup.books, hasLength(1));
      expect(result.backup.shelves, hasLength(1));

      expect(result.backup.books.single.customCoverFileName, 'book-cover.jpg');

      expect(
        result.coverFiles['book-cover.jpg'],
        orderedEquals(<int>[1, 2, 3, 4]),
      );

      expect(result.manifest.createdAt, backup.createdAt);
    });

    test('hylkää tiedoston, joka ei ole kelvollinen ZIP-arkisto', () {
      expect(
        () => reader.decode(Uint8List.fromList(<int>[1, 2, 3, 4])),
        throwsA(isA<FormatException>()),
      );
    });

    test('hylkää arkiston, josta manifesti puuttuu', () {
      final source = _createArchive(
        backup: _createBackup(),
        includeManifest: false,
      );

      expect(
        () => reader.decode(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('manifest.json'),
          ),
        ),
      );
    });

    test('hylkää turvattoman arkistopolun', () {
      final source = _createArchive(
        backup: _createBackup(),
        additionalEntries: <ArchiveFile>[
          ArchiveFile.bytes('covers/../secret.jpg', <int>[1, 2, 3]),
        ],
      );

      expect(
        () => reader.decode(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('turvattoman polun'),
          ),
        ),
      );
    });

    test('hylkää puuttuvan viitatun kansikuvan', () {
      final source = _createArchive(
        backup: _createBackup(customCoverFileName: 'missing-cover.jpg'),
      );

      expect(
        () => reader.decode(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('missing-cover.jpg'),
          ),
        ),
      );
    });

    test('hylkää käyttämättömän kansikuvan', () {
      final source = _createArchive(
        backup: _createBackup(),
        covers: const {
          'unused-cover.jpg': <int>[1, 2, 3],
        },
      );

      expect(
        () => reader.decode(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('käyttämättömän kansikuvatiedoston'),
          ),
        ),
      );
    });

    test('hylkää arkiston, josta library.json puuttuu', () {
      final source = _createArchive(
        backup: _createBackup(),
        includeLibrary: false,
      );

      expect(
        () => reader.decode(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('library.json'),
          ),
        ),
      );
    });

    test('hylkää tietosisällöltään epäkelvon kirjaston', () {
      final invalidBackup = LibraryBackup(
        formatVersion: LibraryBackup.currentFormatVersion,
        createdAt: DateTime.utc(2026, 8, 2, 10, 0),
        shelves: const [
          Shelf(id: 'default-shelf', name: 'Oletushylly', position: 0),
        ],
        books: const [
          Book(
            id: 'book-1',
            shelfId: 'missing-shelf',
            title: 'Eksynyt kirja',
            author: 'Kirjailija',
            pageCount: 100,
            spineColor: Color(0xFF795548),
          ),
        ],
      );

      final source = _createArchive(backup: invalidBackup);

      expect(
        () => reader.decode(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('kirjahyllyä ei löydy'),
          ),
        ),
      );
    });

    test('hylkää tyhjän kansikuvatiedoston', () {
      final source = _createArchive(
        backup: _createBackup(customCoverFileName: 'empty-cover.jpg'),
        covers: const {'empty-cover.jpg': <int>[]},
      );

      expect(
        () => reader.decode(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('on tyhjä'),
          ),
        ),
      );
    });
  });
}

LibraryBackup _createBackup({String? customCoverFileName}) {
  return LibraryBackup(
    formatVersion: LibraryBackup.currentFormatVersion,
    createdAt: DateTime.utc(2026, 8, 2, 10, 0),
    shelves: const [
      Shelf(id: 'default-shelf', name: 'Oletushylly', position: 0),
    ],
    books: [
      Book(
        id: 'book-1',
        shelfId: 'default-shelf',
        title: 'Testikirja',
        author: 'Testikirjailija',
        pageCount: 320,
        customCoverFileName: customCoverFileName,
        spineColor: const Color(0xFF795548),
      ),
    ],
  );
}

Uint8List _createArchive({
  required LibraryBackup backup,
  Map<String, List<int>> covers = const {},
  bool includeManifest = true,
  bool includeLibrary = true,
  List<ArchiveFile> additionalEntries = const [],
}) {
  final archive = Archive();

  if (includeManifest) {
    final manifest = PortableBackupManifest.create(createdAt: backup.createdAt);

    archive.add(
      ArchiveFile.string(
        PortableBackupManifest.manifestFileName,
        manifest.encode(),
      ),
    );
  }

  if (includeLibrary) {
    archive.add(
      ArchiveFile.string(
        PortableBackupManifest.libraryFileName,
        backup.encode(),
      ),
    );
  }

  archive.add(
    ArchiveFile.directory('${PortableBackupManifest.coversDirectoryName}/'),
  );

  for (final entry in covers.entries) {
    archive.add(
      ArchiveFile.bytes(
        '${PortableBackupManifest.coversDirectoryName}/${entry.key}',
        entry.value,
      ),
    );
  }

  for (final entry in additionalEntries) {
    archive.add(entry);
  }

  return ZipEncoder().encodeBytes(archive);
}
