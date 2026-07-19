import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/book.dart';

void main() {
  group('Book notes', () {
    test('uuden kirjan muistiinpano on oletuksena tyhjä', () {
      const book = Book(
        id: 'book-1',
        shelfId: 'default-shelf',
        title: 'Testikirja',
        author: 'Testikirjailija',
        pageCount: 200,
        spineColor: Color(0xFF795548),
      );

      expect(book.notes, isEmpty);
    });

    test('säilyttää muistiinpanon JSON-muunnoksessa', () {
      const originalBook = Book(
        id: 'book-1',
        shelfId: 'default-shelf',
        title: 'Testikirja',
        author: 'Testikirjailija',
        pageCount: 200,
        spineColor: Color(0xFF795548),
        notes: 'Pidin erityisesti kirjan lopusta.',
      );

      final restoredBook = Book.fromJson(originalBook.toJson());

      expect(restoredBook.notes, 'Pidin erityisesti kirjan lopusta.');
    });

    test('vanha JSON ilman notes-kenttää saa tyhjän muistiinpanon', () {
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
        'rating': null,
      });

      expect(book.notes, isEmpty);
    });

    test('copyWith muuttaa muistiinpanon', () {
      const book = Book(
        id: 'book-1',
        shelfId: 'default-shelf',
        title: 'Testikirja',
        author: 'Testikirjailija',
        pageCount: 200,
        spineColor: Color(0xFF795548),
      );

      final updatedBook = book.copyWith(notes: 'Uusi muistiinpano');

      expect(updatedBook.notes, 'Uusi muistiinpano');
    });

    test('copyWith voi tyhjentää muistiinpanon', () {
      const book = Book(
        id: 'book-1',
        shelfId: 'default-shelf',
        title: 'Testikirja',
        author: 'Testikirjailija',
        pageCount: 200,
        spineColor: Color(0xFF795548),
        notes: 'Poistettava muistiinpano',
      );

      final updatedBook = book.copyWith(notes: '');

      expect(updatedBook.notes, isEmpty);
    });
  });
}
