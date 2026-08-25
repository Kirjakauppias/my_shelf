import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/book.dart';
import 'package:my_shelf/models/book_binding.dart';

void main() {
  group('Book metadata', () {
    test('uuden kirjan bibliografisten tietojen oletusarvot', () {
      final book = _createBook();

      expect(book.publicationYear, isNull);
      expect(book.publisher, isNull);
      expect(book.binding, BookBinding.unknown);
    });

    test('bibliografiset tiedot tallennetaan JSON-muotoon', () {
      final book = _createBook().copyWith(
        publicationYear: 2024,
        publisher: 'Otava',
        binding: BookBinding.hardcover,
      );

      final json = book.toJson();

      expect(json['publicationYear'], 2024);
      expect(json['publisher'], 'Otava');
      expect(json['binding'], 'hardcover');
    });

    test('bibliografiset tiedot palautetaan JSON-muodosta', () {
      final json = _createBook().toJson()
        ..['publicationYear'] = 2021
        ..['publisher'] = 'Tammi'
        ..['binding'] = 'paperback';

      final book = Book.fromJson(json);

      expect(book.publicationYear, 2021);
      expect(book.publisher, 'Tammi');
      expect(book.binding, BookBinding.paperback);
    });

    test('vanha JSON ilman uusia kenttiä toimii edelleen', () {
      final json = _createBook().toJson()
        ..remove('publicationYear')
        ..remove('publisher')
        ..remove('binding');

      final book = Book.fromJson(json);

      expect(book.publicationYear, isNull);
      expect(book.publisher, isNull);
      expect(book.binding, BookBinding.unknown);
    });

    test('tuntematon sidosasu palautuu unknown-arvoksi', () {
      final json = _createBook().toJson()..['binding'] = 'future-format';

      final book = Book.fromJson(json);

      expect(book.binding, BookBinding.unknown);
    });

    test('virheellinen julkaisuvuosi hylätään', () {
      final json = _createBook().toJson()..['publicationYear'] = 0;

      expect(() => Book.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('virheellisen tyyppinen kustantaja hylätään', () {
      final json = _createBook().toJson()..['publisher'] = 123;

      expect(() => Book.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('copyWith säilyttää bibliografiset tiedot', () {
      final book = _createBook().copyWith(
        publicationYear: 2019,
        publisher: 'WSOY',
        binding: BookBinding.hardcover,
      );

      final updatedBook = book.copyWith(title: 'Uusi nimi');

      expect(updatedBook.publicationYear, 2019);
      expect(updatedBook.publisher, 'WSOY');
      expect(updatedBook.binding, BookBinding.hardcover);
    });

    test('copyWith voi tyhjentää valinnaiset bibliografiset tiedot', () {
      final book = _createBook().copyWith(
        publicationYear: 2019,
        publisher: 'WSOY',
      );

      final updatedBook = book.copyWith(
        clearPublicationYear: true,
        clearPublisher: true,
      );

      expect(updatedBook.publicationYear, isNull);
      expect(updatedBook.publisher, isNull);
    });
  });
}

Book _createBook() {
  return const Book(
    id: 'book-1',
    shelfId: 'default-shelf',
    isbn: '9789510507339',
    title: 'Testikirja',
    author: 'Testikirjailija',
    pageCount: 300,
    spineColor: Color(0xFF335C67),
  );
}
