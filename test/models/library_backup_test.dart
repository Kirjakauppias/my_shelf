import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/book.dart';
import 'package:my_shelf/models/library_backup.dart';

void main() {
  group('LibraryBackup', () {
    test('muuntaa varmuuskopion JSONiksi ja takaisin', () {
      final originalBackup = LibraryBackup(
        formatVersion: LibraryBackup.currentFormatVersion,
        createdAt: DateTime.utc(2026, 7, 19, 10, 30),
        books: const [
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
        shelves: const [],
      );

      final encodedBackup = originalBackup.encode();
      final restoredBackup = LibraryBackup.decode(encodedBackup);

      expect(restoredBackup.formatVersion, LibraryBackup.currentFormatVersion);

      expect(restoredBackup.createdAt, DateTime.utc(2026, 7, 19, 10, 30));

      expect(restoredBackup.books, hasLength(1));
      expect(restoredBackup.shelves, isEmpty);

      expect(
        restoredBackup.books.single.toJson(),
        originalBackup.books.single.toJson(),
      );
    });

    test('hylkää tuntemattoman varmuuskopioversion', () {
      const invalidBackup = '''
      {
        "formatVersion": 999,
        "createdAt": "2026-07-19T10:30:00.000Z",
        "books": [],
        "shelves": []
      }
      ''';

      expect(
        () => LibraryBackup.decode(invalidBackup),
        throwsA(isA<FormatException>()),
      );
    });

    test('hylkää varmuuskopion, jonka ylin taso ei ole olio', () {
      expect(() => LibraryBackup.decode('[]'), throwsA(isA<FormatException>()));
    });

    test('hylkää varmuuskopion, josta books-kenttä puuttuu', () {
      const invalidBackup = '''
      {
        "formatVersion": 1,
        "createdAt": "2026-07-19T10:30:00.000Z",
        "shelves": []
      }
      ''';

      expect(
        () => LibraryBackup.decode(invalidBackup),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
