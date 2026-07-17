import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/book.dart';

void main() {
  group('Book', () {
    test('toJson ja fromJson säilyttävät kirjan tiedot', () {
      const originalBook = Book(
        id: '9780575083837',
        shelfId: 'default-shelf',
        isbn: '9780575083837',
        title: 'The Heroes',
        author: 'Joe Abercrombie',
        pageCount: 608,
        coverUrl: 'https://example.com/cover.jpg',
        spineColor: Color(0xFF335C67),
      );

      final json = originalBook.toJson();
      final restoredBook = Book.fromJson(json);

      expect(restoredBook.id, originalBook.id);
      expect(restoredBook.shelfId, originalBook.shelfId);
      expect(restoredBook.isbn, originalBook.isbn);
      expect(restoredBook.title, originalBook.title);
      expect(restoredBook.author, originalBook.author);
      expect(restoredBook.pageCount, originalBook.pageCount);
      expect(restoredBook.coverUrl, originalBook.coverUrl);
      expect(
        restoredBook.spineColor.toARGB32(),
        originalBook.spineColor.toARGB32(),
      );
    });

    test('selkämyksen leveys määräytyy sivumäärästä', () {
      const shortBook = Book(
        id: 'short',
        shelfId: 'default-shelf',
        title: 'Lyhyt',
        author: 'Kirjailija',
        pageCount: 150,
        spineColor: Colors.blue,
      );

      const mediumBook = Book(
        id: 'medium',
        shelfId: 'default-shelf',
        title: 'Keskipitkä',
        author: 'Kirjailija',
        pageCount: 300,
        spineColor: Colors.green,
      );

      const longBook = Book(
        id: 'long',
        shelfId: 'default-shelf',
        title: 'Pitkä',
        author: 'Kirjailija',
        pageCount: 600,
        spineColor: Colors.red,
      );

      expect(shortBook.spineWidth, 34);
      expect(mediumBook.spineWidth, 46);
      expect(longBook.spineWidth, 58);
    });

    test('kirjat ovat samoja, jos id on sama', () {
      const firstBook = Book(
        id: 'same-id',
        shelfId: 'default-shelf',
        title: 'Ensimmäinen nimi',
        author: 'Kirjailija',
        pageCount: 200,
        spineColor: Colors.blue,
      );

      const secondBook = Book(
        id: 'same-id',
        shelfId: 'default-shelf',
        title: 'Toinen nimi',
        author: 'Toinen kirjailija',
        pageCount: 400,
        spineColor: Colors.red,
      );

      expect(firstBook, secondBook);
      expect(firstBook.hashCode, secondBook.hashCode);
    });
  });
}
