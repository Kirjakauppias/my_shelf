import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/book.dart';

void main() {
  Book createBook({String? customCoverFileName}) {
    return Book(
      id: 'book-1',
      shelfId: 'shelf-1',
      isbn: '9781234567890',
      title: 'Testikirja',
      author: 'Testikirjailija',
      pageCount: 320,
      coverUrl: 'https://example.com/cover.jpg',
      customCoverFileName: customCoverFileName,
      spineColor: const Color(0xFF795548),
    );
  }

  group('Book custom cover', () {
    test('oman kansikuvan oletusarvo on null', () {
      final book = createBook();

      expect(book.customCoverFileName, isNull);
    });

    test('copyWith lisää oman kansikuvan', () {
      final book = createBook();

      final updatedBook = book.copyWith(customCoverFileName: 'book-1.jpg');

      expect(updatedBook.customCoverFileName, 'book-1.jpg');
      expect(updatedBook.coverUrl, book.coverUrl);
    });

    test('copyWith poistaa oman kansikuvan', () {
      final book = createBook(customCoverFileName: 'book-1.jpg');

      final updatedBook = book.copyWith(clearCustomCover: true);

      expect(updatedBook.customCoverFileName, isNull);
      expect(updatedBook.coverUrl, book.coverUrl);
    });

    test('JSON round-trip säilyttää oman kansikuvan', () {
      final book = createBook(customCoverFileName: 'book-1.jpg');

      final json = book.toJson();
      final restoredBook = Book.fromJson(json);

      expect(restoredBook.customCoverFileName, 'book-1.jpg');

      expect(restoredBook.coverUrl, 'https://example.com/cover.jpg');
    });

    test('vanha JSON ilman customCoverFileName-kenttää toimii', () {
      final json = createBook().toJson()..remove('customCoverFileName');

      final restoredBook = Book.fromJson(json);

      expect(restoredBook.customCoverFileName, isNull);
    });

    test('tyhjä tiedostonimi tulkitaan puuttuvaksi kanneksi', () {
      final json = createBook().toJson();

      json['customCoverFileName'] = '   ';

      final restoredBook = Book.fromJson(json);

      expect(restoredBook.customCoverFileName, isNull);
    });

    test('virheellinen tiedostonimen tyyppi hylätään', () {
      final json = createBook().toJson();

      json['customCoverFileName'] = 123;

      expect(() => Book.fromJson(json), throwsFormatException);
    });
  });
}
