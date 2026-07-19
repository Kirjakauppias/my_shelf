import 'dart:convert';

import 'book.dart';
import 'shelf.dart';

/// Sisältää My Shelf -sovelluksen JSON-varmuuskopion tiedot.
class LibraryBackup {
  /// Tällä hetkellä tuettu varmuuskopion rakennemuoto.
  static const int currentFormatVersion = 1;

  /// Varmuuskopion rakenteen versionumero.
  final int formatVersion;

  /// Varmuuskopion luontiaika UTC-muodossa.
  final DateTime createdAt;

  /// Varmuuskopioon sisältyvät kirjat.
  final List<Book> books;

  /// Varmuuskopioon sisältyvät kirjahyllyt.
  final List<Shelf> shelves;

  LibraryBackup({
    required this.formatVersion,
    required this.createdAt,
    required List<Book> books,
    required List<Shelf> shelves,
  }) : books = List.unmodifiable(books),
       shelves = List.unmodifiable(shelves);

  /// Luo uuden varmuuskopion nykyisistä kirjoista ja hyllyistä.
  factory LibraryBackup.create({
    required List<Book> books,
    required List<Shelf> shelves,
  }) {
    return LibraryBackup(
      formatVersion: currentFormatVersion,
      createdAt: DateTime.now().toUtc(),
      books: books,
      shelves: shelves,
    );
  }

  /// Muuntaa varmuuskopion JSON-rakenteeksi.
  Map<String, dynamic> toJson() {
    return {
      'formatVersion': formatVersion,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'books': books.map((book) => book.toJson()).toList(),
      'shelves': shelves.map((shelf) => shelf.toJson()).toList(),
    };
  }

  /// Muuntaa varmuuskopion JSON-merkkijonoksi.
  ///
  /// Oletuksena JSON muotoillaan ihmisen luettavaan muotoon.
  String encode({bool pretty = true}) {
    final encoder = pretty
        ? const JsonEncoder.withIndent('  ')
        : const JsonEncoder();

    return encoder.convert(toJson());
  }

  /// Muodostaa varmuuskopion JSON-merkkijonosta.
  factory LibraryBackup.decode(String source) {
    final decodedValue = jsonDecode(source);

    if (decodedValue is! Map) {
      throw const FormatException(
        'Varmuuskopion ylimmän tason täytyy olla JSON-olio.',
      );
    }

    return LibraryBackup.fromJson(Map<String, dynamic>.from(decodedValue));
  }

  /// Muodostaa varmuuskopion JSON-rakenteesta.
  factory LibraryBackup.fromJson(Map<String, dynamic> json) {
    final formatVersionValue = json['formatVersion'];

    if (formatVersionValue is! int) {
      throw const FormatException(
        'Varmuuskopiosta puuttuu kelvollinen formatVersion.',
      );
    }

    if (formatVersionValue != currentFormatVersion) {
      throw FormatException(
        'Varmuuskopion versiota $formatVersionValue ei tueta.',
      );
    }

    final createdAtValue = json['createdAt'];

    if (createdAtValue is! String) {
      throw const FormatException(
        'Varmuuskopiosta puuttuu kelvollinen createdAt.',
      );
    }

    final booksValue = json['books'];
    final shelvesValue = json['shelves'];

    if (booksValue is! List) {
      throw const FormatException(
        'Varmuuskopion books-kentän täytyy olla lista.',
      );
    }

    if (shelvesValue is! List) {
      throw const FormatException(
        'Varmuuskopion shelves-kentän täytyy olla lista.',
      );
    }

    try {
      final createdAt = DateTime.parse(createdAtValue).toUtc();

      final books = booksValue.map((item) {
        if (item is! Map) {
          throw const FormatException(
            'Varmuuskopio sisältää virheellisen kirjan.',
          );
        }

        return Book.fromJson(Map<String, dynamic>.from(item));
      }).toList();

      final shelves = shelvesValue.map((item) {
        if (item is! Map) {
          throw const FormatException(
            'Varmuuskopio sisältää virheellisen kirjahyllyn.',
          );
        }

        return Shelf.fromJson(Map<String, dynamic>.from(item));
      }).toList();

      return LibraryBackup(
        formatVersion: formatVersionValue,
        createdAt: createdAt,
        books: books,
        shelves: shelves,
      );
    } on FormatException {
      rethrow;
    } on Object {
      throw const FormatException('Varmuuskopion sisältö on virheellinen.');
    }
  }
}
