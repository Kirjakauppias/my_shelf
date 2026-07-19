import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/book.dart';

void main() {
  group('Book rating', () {
    test('uuden kirjan arvosana on oletuksena null', () {
      const book = Book(
        id: 'book-1',
        shelfId: 'default-shelf',
        title: 'Testikirja',
        author: 'Testikirjailija',
        pageCount: 200,
        spineColor: Color(0xFF795548),
      );

      expect(book.rating, isNull);
    });

    test('säilyttää arvosanan JSON-muunnoksessa', () {
      const originalBook = Book(
        id: 'book-1',
        shelfId: 'default-shelf',
        title: 'Testikirja',
        author: 'Testikirjailija',
        pageCount: 200,
        spineColor: Color(0xFF795548),
        rating: 4,
      );

      final restoredBook = Book.fromJson(originalBook.toJson());

      expect(restoredBook.rating, 4);
    });

    test('vanha JSON ilman rating-kenttää saa null-arvosanan', () {
      final book = Book.fromJson({
        'id': 'book-1',
        'shelfId': 'default-shelf',
        'isbn': null,
        'title': 'Vanha kirja',
        'author': 'Kirjailija',
        'pageCount': 150,
        'coverUrl': null,
        'spineColor': const Color(0xFF795548).toARGB32(),
        'readingStatus': 'unread',
      });

      expect(book.rating, isNull);
    });

    test('copyWith muuttaa arvosanan', () {
      const book = Book(
        id: 'book-1',
        shelfId: 'default-shelf',
        title: 'Testikirja',
        author: 'Testikirjailija',
        pageCount: 200,
        spineColor: Color(0xFF795548),
      );

      final updatedBook = book.copyWith(rating: 5);

      expect(updatedBook.rating, 5);
    });

    test('copyWith voi poistaa arvosanan', () {
      const book = Book(
        id: 'book-1',
        shelfId: 'default-shelf',
        title: 'Testikirja',
        author: 'Testikirjailija',
        pageCount: 200,
        spineColor: Color(0xFF795548),
        rating: 4,
      );

      final updatedBook = book.copyWith(clearRating: true);

      expect(updatedBook.rating, isNull);
    });

    test('hylkää liian pienen JSON-arvosanan', () {
      expect(
        () => Book.fromJson({
          'id': 'book-1',
          'shelfId': 'default-shelf',
          'isbn': null,
          'title': 'Testikirja',
          'author': 'Testikirjailija',
          'pageCount': 200,
          'coverUrl': null,
          'spineColor': const Color(0xFF795548).toARGB32(),
          'readingStatus': 'unread',
          'rating': 0,
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('hylkää liian suuren JSON-arvosanan', () {
      expect(
        () => Book.fromJson({
          'id': 'book-1',
          'shelfId': 'default-shelf',
          'isbn': null,
          'title': 'Testikirja',
          'author': 'Testikirjailija',
          'pageCount': 200,
          'coverUrl': null,
          'spineColor': const Color(0xFF795548).toARGB32(),
          'readingStatus': 'unread',
          'rating': 6,
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
