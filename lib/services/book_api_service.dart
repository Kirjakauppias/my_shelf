import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';

class BookApiService {
  static const Duration _requestTimeout = Duration(seconds: 15);

  /// Hakee kirjan ISBN-tunnuksen perusteella.
  ///
  /// Hakujärjestys:
  /// 1. Google Books
  /// 2. Open Library
  ///
  /// Palauttaa null-arvon, jos kirjaa ei löydy kummastakaan palvelusta.
  Future<Book?> findBookByIsbn(String isbn) async {
    final normalizedIsbn = _normalizeIsbn(isbn);

    Object? googleError;
    Object? openLibraryError;

    try {
      final googleBook = await _findFromGoogleBooks(normalizedIsbn);

      if (googleBook != null) {
        return googleBook;
      }
    } catch (error) {
      googleError = error;
    }

    try {
      final openLibraryBook = await _findFromOpenLibrary(normalizedIsbn);

      if (openLibraryBook != null) {
        return openLibraryBook;
      }
    } catch (error) {
      openLibraryError = error;
    }

    // Jos molemmat palvelut epäonnistuivat tekniseen virheeseen,
    // näytetään käyttäjälle verkkohakuun liittyvä virhe.
    if (googleError != null && openLibraryError != null) {
      throw const BookApiException(
        'Kirjan tietojen hakeminen epäonnistui molemmista kirjapalveluista.',
      );
    }

    // Ainakin toinen palvelu vastasi normaalisti, mutta kirjaa ei löytynyt.
    return null;
  }

  /// Hakee kirjan Google Books API:sta.
  Future<Book?> _findFromGoogleBooks(String isbn) async {
    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': 'isbn:$isbn',
      'maxResults': '1',
      'printType': 'books',
    });

    final response = await http.get(uri).timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw BookApiException(
        'Google Books palautti virheen ${response.statusCode}.',
      );
    }

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

    final items = decodedResponse['items'] as List<dynamic>?;

    if (items == null || items.isEmpty) {
      return null;
    }

    final firstItem = Map<String, dynamic>.from(items.first as Map);

    final volumeInfoRaw = firstItem['volumeInfo'];

    if (volumeInfoRaw is! Map) {
      return null;
    }

    final volumeInfo = Map<String, dynamic>.from(volumeInfoRaw);

    final title = volumeInfo['title'] as String? ?? 'Tuntematon kirja';

    final authorsRaw = volumeInfo['authors'] as List<dynamic>?;

    final author = authorsRaw == null || authorsRaw.isEmpty
        ? 'Tuntematon kirjailija'
        : authorsRaw.map((author) => author.toString()).join(', ');

    final pageCountRaw = volumeInfo['pageCount'];

    final pageCount = pageCountRaw is num ? pageCountRaw.toInt() : 300;

    final coverUrl = _readGoogleCoverUrl(volumeInfo);

    return Book(
      id: isbn,
      shelfId: 'default-shelf',
      isbn: isbn,
      title: title,
      author: author,
      pageCount: pageCount,
      coverUrl: coverUrl,
      spineColor: _createSpineColor(isbn),
    );
  }

  /// Hakee kirjan Open Libraryn Search API:sta.
  Future<Book?> _findFromOpenLibrary(String isbn) async {
    final uri = Uri.https('openlibrary.org', '/search.json', {
      'q': 'isbn:$isbn',
      'fields': [
        'key',
        'title',
        'author_name',
        'number_of_pages_median',
        'cover_i',
        'isbn',
      ].join(','),
      'limit': '1',
    });

    final response = await http.get(uri).timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw BookApiException(
        'Open Library palautti virheen ${response.statusCode}.',
      );
    }

    final decodedResponse = jsonDecode(response.body) as Map<String, dynamic>;

    final documents = decodedResponse['docs'] as List<dynamic>? ?? <dynamic>[];

    if (documents.isEmpty) {
      return null;
    }

    final document = Map<String, dynamic>.from(documents.first as Map);

    final title = document['title'] as String? ?? 'Tuntematon kirja';

    final authorNames =
        document['author_name'] as List<dynamic>? ?? <dynamic>[];

    final author = authorNames.isEmpty
        ? 'Tuntematon kirjailija'
        : authorNames.map((name) => name.toString()).join(', ');

    final pageCountRaw = document['number_of_pages_median'];

    final pageCount = pageCountRaw is num ? pageCountRaw.toInt() : 300;

    final coverId = document['cover_i'];

    final coverUrl = coverId is num
        ? 'https://covers.openlibrary.org/b/id/'
              '${coverId.toInt()}-L.jpg'
        : null;

    return Book(
      id: isbn,
      shelfId: 'default-shelf',
      isbn: isbn,
      title: title,
      author: author,
      pageCount: pageCount,
      coverUrl: coverUrl,
      spineColor: _createSpineColor(isbn),
    );
  }

  /// Lukee Google Booksin kansikuvan osoitteen.
  ///
  /// Suositaan suurempaa kuvaa, mutta käytetään tarvittaessa
  /// pienempää vaihtoehtoa.
  String? _readGoogleCoverUrl(Map<String, dynamic> volumeInfo) {
    final imageLinksRaw = volumeInfo['imageLinks'];

    if (imageLinksRaw is! Map) {
      return null;
    }

    final imageLinks = Map<String, dynamic>.from(imageLinksRaw);

    final coverUrl =
        imageLinks['large'] ??
        imageLinks['medium'] ??
        imageLinks['small'] ??
        imageLinks['thumbnail'] ??
        imageLinks['smallThumbnail'];

    if (coverUrl is! String || coverUrl.isEmpty) {
      return null;
    }

    // Google Books voi palauttaa kuvan HTTP-osoitteena.
    // Androidissa ja webissä HTTPS toimii luotettavammin.
    return coverUrl.replaceFirst('http://', 'https://');
  }

  /// Poistaa ISBN-tunnuksesta välilyönnit ja väliviivat.
  String _normalizeIsbn(String isbn) {
    return isbn.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
  }

  /// Valitsee ISBN:n perusteella samalle kirjalle aina saman värin.
  Color _createSpineColor(String isbn) {
    const colors = [
      Color(0xFF8D3B3B),
      Color(0xFF335C67),
      Color(0xFF6B705C),
      Color(0xFF8A5A44),
      Color(0xFF5E548E),
      Color(0xFF9C6644),
      Color(0xFF3D5A80),
      Color(0xFF7F5539),
    ];

    final colorIndex = isbn.hashCode.abs() % colors.length;

    return colors[colorIndex];
  }
}

class BookApiException implements Exception {
  final String message;

  const BookApiException(this.message);

  @override
  String toString() => message;
}
