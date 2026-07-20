import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/book.dart';
import 'package:my_shelf/utils/book_query.dart';

void main() {
  group('queryBooks', () {
    test('palauttaa vain valitun kirjahyllyn kirjat', () {
      final result = queryBooks(books: _testBooks, shelfId: 'shelf-1');

      expect(result.map((book) => book.id), [
        'book-a',
        'book-b',
        'book-c',
        'book-d',
        'book-e',
      ]);
    });

    test('hakee kirjan nimellä kirjainkoosta riippumatta', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        searchQuery: 'ALFA',
      );

      expect(result.map((book) => book.id), ['book-a']);
    });

    test('hakee kirjan tekijän nimellä', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        searchQuery: 'tekijä beta',
      );

      expect(result.map((book) => book.id), ['book-b']);
    });

    test('hakee kirjan ISBN-numerolla', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        searchQuery: '2222',
      );

      expect(result.map((book) => book.id), ['book-b']);
    });

    test('suodattaa kirjat lukutilan mukaan', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        readingStatusFilter: ReadingStatusFilter.reading,
      );

      expect(result.map((book) => book.id), ['book-b', 'book-e']);
    });

    test('näyttää vain arvioidut kirjat', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        contentFilter: BookContentFilter.rated,
      );

      expect(result.map((book) => book.id), ['book-a', 'book-b', 'book-d']);
    });

    test('näyttää vain arvioimattomat kirjat', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        contentFilter: BookContentFilter.unrated,
      );

      expect(result.map((book) => book.id), ['book-c', 'book-e']);
    });

    test('näyttää vain muistiinpanon sisältävät kirjat', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        contentFilter: BookContentFilter.hasNotes,
      );

      expect(result.map((book) => book.id), ['book-a', 'book-e']);
    });

    test('yhdistää lukutilan ja sisältösuodattimen', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        readingStatusFilter: ReadingStatusFilter.read,
        contentFilter: BookContentFilter.rated,
      );

      expect(result.map((book) => book.id), ['book-a', 'book-d']);
    });

    test('yhdistää tekstinhaun ja suodattimet', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        searchQuery: 'epsilon',
        readingStatusFilter: ReadingStatusFilter.reading,
        contentFilter: BookContentFilter.hasNotes,
      );

      expect(result.map((book) => book.id), ['book-e']);
    });

    test('säilyttää oman järjestyksen', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        sortOption: BookSortOption.custom,
      );

      expect(result.map((book) => book.id), [
        'book-a',
        'book-b',
        'book-c',
        'book-d',
        'book-e',
      ]);
    });

    test('lajittelee nimen mukaan A–Ö', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        sortOption: BookSortOption.titleAscending,
      );

      expect(result.map((book) => book.title), [
        'Alfa',
        'Beta',
        'Delta',
        'Epsilon',
        'Gamma',
      ]);
    });

    test('lajittelee nimen mukaan Ö–A', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        sortOption: BookSortOption.titleDescending,
      );

      expect(result.map((book) => book.title), [
        'Gamma',
        'Epsilon',
        'Delta',
        'Beta',
        'Alfa',
      ]);
    });

    test('lajittelee tekijän mukaan', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        sortOption: BookSortOption.authorAscending,
      );

      expect(result.map((book) => book.author), [
        'Tekijä Alfa',
        'Tekijä Beta',
        'Tekijä Delta',
        'Tekijä Epsilon',
        'Tekijä Gamma',
      ]);
    });

    test('lajittelee arvosanan mukaan 5–1', () {
      final result = queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        sortOption: BookSortOption.ratingDescending,
      );

      expect(result.map((book) => book.id), [
        'book-b', // 5 tähteä
        'book-a', // 4 tähteä, Alfa tulee oikeasti ensin
        'book-d', // 4 tähteä, Delta
        'book-e', // ei arviota
        'book-c', // ei arviota
      ]);
    });

    test(
      'lajittelee arvosanan mukaan 1–5 ja jättää arvioimattomat loppuun',
      () {
        final result = queryBooks(
          books: _testBooks,
          shelfId: 'shelf-1',
          sortOption: BookSortOption.ratingAscending,
        );

        expect(result.map((book) => book.id), [
          'book-a',
          'book-d',
          'book-b',
          'book-e',
          'book-c',
        ]);
      },
    );

    test('ei muuta alkuperäistä kirjalistaa', () {
      final originalOrder = _testBooks.map((book) => book.id).toList();

      queryBooks(
        books: _testBooks,
        shelfId: 'shelf-1',
        sortOption: BookSortOption.titleAscending,
      );

      expect(_testBooks.map((book) => book.id), originalOrder);
    });
  });
}

final List<Book> _testBooks = [
  const Book(
    id: 'book-a',
    shelfId: 'shelf-1',
    isbn: '1111',
    title: 'Alfa',
    author: 'Tekijä Alfa',
    pageCount: 100,
    spineColor: Color(0xFF795548),
    readingStatus: ReadingStatus.read,
    rating: 4,
    notes: 'Hyvä kirja.',
  ),
  const Book(
    id: 'book-b',
    shelfId: 'shelf-1',
    isbn: '2222',
    title: 'Beta',
    author: 'Tekijä Beta',
    pageCount: 200,
    spineColor: Color(0xFF5D4037),
    readingStatus: ReadingStatus.reading,
    rating: 5,
  ),
  const Book(
    id: 'book-c',
    shelfId: 'shelf-1',
    isbn: '3333',
    title: 'Gamma',
    author: 'Tekijä Gamma',
    pageCount: 300,
    spineColor: Color(0xFF6D4C41),
    readingStatus: ReadingStatus.unread,
  ),
  const Book(
    id: 'book-d',
    shelfId: 'shelf-1',
    isbn: '4444',
    title: 'Delta',
    author: 'Tekijä Delta',
    pageCount: 400,
    spineColor: Color(0xFF8D6E63),
    readingStatus: ReadingStatus.read,
    rating: 4,
  ),
  const Book(
    id: 'book-e',
    shelfId: 'shelf-1',
    isbn: '5555',
    title: 'Epsilon',
    author: 'Tekijä Epsilon',
    pageCount: 500,
    spineColor: Color(0xFFA1887F),
    readingStatus: ReadingStatus.reading,
    notes: 'Muistiinpano kesken olevasta kirjasta.',
  ),
  const Book(
    id: 'book-other-shelf',
    shelfId: 'shelf-2',
    isbn: '9999',
    title: 'Toisen hyllyn kirja',
    author: 'Muu kirjailija',
    pageCount: 150,
    spineColor: Color(0xFF4E342E),
    readingStatus: ReadingStatus.read,
    rating: 5,
    notes: 'Ei saa näkyä ensimmäisen hyllyn tuloksissa.',
  ),
];
