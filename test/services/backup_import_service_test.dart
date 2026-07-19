import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/book.dart';
import 'package:my_shelf/models/library_backup.dart';
import 'package:my_shelf/models/shelf.dart';
import 'package:my_shelf/services/backup_import_service.dart';

void main() {
  const importService = BackupImportService();

  group('BackupImportService.decodeAndValidate', () {
    test('hyväksyy kelvollisen varmuuskopion', () {
      final source = _createBackupJson();

      final backup = importService.decodeAndValidate(source);

      expect(backup.formatVersion, LibraryBackup.currentFormatVersion);
      expect(backup.shelves, hasLength(1));
      expect(backup.books, hasLength(1));

      expect(backup.shelves.single.id, 'default-shelf');
      expect(backup.books.single.id, 'book-1');
      expect(backup.books.single.shelfId, 'default-shelf');
    });

    test('hylkää varmuuskopion, jossa ei ole kirjahyllyjä', () {
      final source = _createBackupJson(shelves: const [], books: const []);

      expect(
        () => importService.decodeAndValidate(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('vähintään yksi kirjahylly'),
          ),
        ),
      );
    });

    test('hylkää kirjahyllyn, jolla ei ole tunnistetta', () {
      final source = _createBackupJson(
        shelves: const [Shelf(id: '', name: 'Virheellinen hylly', position: 0)],
        books: const [],
      );

      expect(
        () => importService.decodeAndValidate(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('ilman tunnistetta'),
          ),
        ),
      );
    });

    test('hylkää päällekkäiset kirjahyllytunnisteet', () {
      final source = _createBackupJson(
        shelves: const [
          Shelf(id: 'duplicate-shelf', name: 'Ensimmäinen hylly', position: 0),
          Shelf(id: 'duplicate-shelf', name: 'Toinen hylly', position: 1),
        ],
        books: const [],
      );

      expect(
        () => importService.decodeAndValidate(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('saman kirjahyllyn useita kertoja'),
          ),
        ),
      );
    });

    test('hylkää kirjan, jolla ei ole tunnistetta', () {
      final source = _createBackupJson(
        books: const [
          Book(
            id: '',
            shelfId: 'default-shelf',
            title: 'Virheellinen kirja',
            author: 'Testikirjailija',
            pageCount: 100,
            spineColor: Color(0xFF795548),
          ),
        ],
      );

      expect(
        () => importService.decodeAndValidate(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('kirjan ilman tunnistetta'),
          ),
        ),
      );
    });

    test('hylkää päällekkäiset kirjatunnisteet', () {
      final source = _createBackupJson(
        books: const [
          Book(
            id: 'duplicate-book',
            shelfId: 'default-shelf',
            title: 'Ensimmäinen kirja',
            author: 'Ensimmäinen kirjailija',
            pageCount: 100,
            spineColor: Color(0xFF795548),
          ),
          Book(
            id: 'duplicate-book',
            shelfId: 'default-shelf',
            title: 'Toinen kirja',
            author: 'Toinen kirjailija',
            pageCount: 200,
            spineColor: Color(0xFF5D4037),
          ),
        ],
      );

      expect(
        () => importService.decodeAndValidate(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('saman kirjan useita kertoja'),
          ),
        ),
      );
    });

    test('hylkää kirjan, jonka kirjahyllyä ei löydy', () {
      final source = _createBackupJson(
        books: const [
          Book(
            id: 'book-with-missing-shelf',
            shelfId: 'missing-shelf',
            title: 'Eksynyt kirja',
            author: 'Testikirjailija',
            pageCount: 250,
            spineColor: Color(0xFF795548),
          ),
        ],
      );

      expect(
        () => importService.decodeAndValidate(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('kirjahyllyä ei löydy'),
          ),
        ),
      );
    });

    test('hylkää virheellisen JSON-merkkijonon', () {
      const invalidJson = '''
      {
        "formatVersion": 1,
        "createdAt": "2026-07-19T10:30:00.000Z",
        "books": [
      }
      ''';

      expect(
        () => importService.decodeAndValidate(invalidJson),
        throwsA(isA<FormatException>()),
      );
    });

    test('hylkää tuntemattoman varmuuskopioversion', () {
      final source = _createBackupJson(formatVersion: 999);

      expect(
        () => importService.decodeAndValidate(source),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'message',
            contains('versiota 999 ei tueta'),
          ),
        ),
      );
    });

    test('säilyttää kirjojen lukutilat palautuksessa', () {
      final source = _createBackupJson(
        books: const [
          Book(
            id: 'unread-book',
            shelfId: 'default-shelf',
            title: 'Lukematon kirja',
            author: 'Kirjailija',
            pageCount: 100,
            spineColor: Color(0xFF795548),
            readingStatus: ReadingStatus.unread,
          ),
          Book(
            id: 'reading-book',
            shelfId: 'default-shelf',
            title: 'Kesken oleva kirja',
            author: 'Kirjailija',
            pageCount: 200,
            spineColor: Color(0xFF5D4037),
            readingStatus: ReadingStatus.reading,
          ),
          Book(
            id: 'read-book',
            shelfId: 'default-shelf',
            title: 'Luettu kirja',
            author: 'Kirjailija',
            pageCount: 300,
            spineColor: Color(0xFF6D4C41),
            readingStatus: ReadingStatus.read,
          ),
        ],
      );

      final backup = importService.decodeAndValidate(source);

      expect(backup.books, hasLength(3));
      expect(backup.books[0].readingStatus, ReadingStatus.unread);
      expect(backup.books[1].readingStatus, ReadingStatus.reading);
      expect(backup.books[2].readingStatus, ReadingStatus.read);
    });
  });
}

/// Luo JSON-varmuuskopion testejä varten.
///
/// Ellei listoja anneta, varmuuskopio sisältää yhden oletushyllyn
/// ja yhden siihen kuuluvan kirjan.
String _createBackupJson({
  int formatVersion = LibraryBackup.currentFormatVersion,
  List<Shelf>? shelves,
  List<Book>? books,
}) {
  final backup = LibraryBackup(
    formatVersion: formatVersion,
    createdAt: DateTime.utc(2026, 7, 19, 10, 30),
    shelves:
        shelves ??
        const [Shelf(id: 'default-shelf', name: 'Oletushylly', position: 0)],
    books:
        books ??
        const [
          Book(
            id: 'book-1',
            shelfId: 'default-shelf',
            isbn: '9789510428262',
            title: 'Testikirja',
            author: 'Testikirjailija',
            pageCount: 320,
            spineColor: Color(0xFF795548),
            readingStatus: ReadingStatus.reading,
          ),
        ],
  );

  return backup.encode(pretty: false);
}
