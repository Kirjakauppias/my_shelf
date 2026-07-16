import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';

class BookStorageService {
  static const String _booksKey = 'books';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  /// Tallentaa koko kirjalistan nykyisessä järjestyksessä.
  Future<void> saveBooks(List<Book> books) async {
    final booksAsJson = books.map((book) => book.toJson()).toList();

    final encodedBooks = jsonEncode(booksAsJson);

    await _preferences.setString(_booksKey, encodedBooks);
  }

  /// Lataa tallennetut kirjat.
  ///
  /// Jos tallennettuja kirjoja ei vielä ole, palautetaan tyhjä lista.
  Future<List<Book>> loadBooks() async {
    final encodedBooks = await _preferences.getString(_booksKey);

    if (encodedBooks == null || encodedBooks.isEmpty) {
      return [];
    }

    try {
      final decodedBooks = jsonDecode(encodedBooks) as List<dynamic>;

      return decodedBooks
          .map((item) => Book.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } on FormatException {
      return [];
    }
  }
}
