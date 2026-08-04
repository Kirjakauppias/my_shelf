import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../utils/isbn_utils.dart';
import 'book_api_exception.dart';

typedef FinnaHttpGet = Future<http.Response> Function(Uri uri);

/// Hakee kirjojen tietoja Finna-palvelusta ISBN-tunnuksen perusteella.
class FinnaBookSearchService {
  static const Duration _requestTimeout = Duration(seconds: 15);

  final FinnaHttpGet _get;

  FinnaBookSearchService({FinnaHttpGet? get})
    : _get = get ?? ((uri) => http.get(uri));

  Future<Book?> findBookByIsbn(String isbn) async {
    final normalizedIsbn = IsbnUtils.normalize(isbn);

    if (!IsbnUtils.isValid(normalizedIsbn)) {
      throw const BookApiException('ISBN-tunnus ei ole kelvollinen.');
    }

    final uri = Uri.https('api.finna.fi', '/v1/search', {
      'lookfor': normalizedIsbn,
      'type': 'ISN',
      'filter[]': 'format:"0/Book/"',
      'limit': '10',
      'lng': 'fi',
      'field[]': const <String>[
        'id',
        'title',
        'authors',
        'nonPresenterAuthors',
        'isbns',
        'cleanIsbn',
        'images',
        'physicalDescriptions',
      ],
    });

    late final http.Response response;

    try {
      response = await _get(uri).timeout(_requestTimeout);
    } on Object {
      throw const BookApiException(
        'Yhteyden muodostaminen Finna-palveluun epäonnistui.',
      );
    }

    if (response.statusCode != 200) {
      throw BookApiException('Finna palautti virheen ${response.statusCode}.');
    }

    final decodedResponse = _decodeResponse(response);

    final status = decodedResponse['status'];

    if (status is String && status.toUpperCase() != 'OK') {
      throw const BookApiException(
        'Finna ei pystynyt suorittamaan kirjahakua.',
      );
    }

    final recordsRaw = decodedResponse['records'];

    if (recordsRaw is! List) {
      throw const BookApiException('Finna palautti virheellisen vastauksen.');
    }

    for (final recordRaw in recordsRaw) {
      if (recordRaw is! Map) {
        continue;
      }

      final record = Map<String, dynamic>.from(recordRaw);

      if (!_recordMatchesIsbn(record, normalizedIsbn)) {
        continue;
      }

      final book = _bookFromRecord(record, isbn: normalizedIsbn);

      if (book != null) {
        return book;
      }
    }

    return null;
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    try {
      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes, allowMalformed: false),
      );

      if (decoded is! Map) {
        throw const FormatException();
      }

      return Map<String, dynamic>.from(decoded);
    } on Object {
      throw const BookApiException('Finna palautti virheellisen vastauksen.');
    }
  }

  bool _recordMatchesIsbn(Map<String, dynamic> record, String requestedIsbn) {
    for (final candidate in _readRecordIsbns(record)) {
      if (IsbnUtils.areEquivalent(candidate, requestedIsbn)) {
        return true;
      }
    }

    return false;
  }

  Iterable<String> _readRecordIsbns(Map<String, dynamic> record) sync* {
    final cleanIsbnRaw = record['cleanIsbn'];

    if (cleanIsbnRaw is String) {
      final isbn = _extractIsbn(cleanIsbnRaw);

      if (isbn != null) {
        yield isbn;
      }
    }

    if (cleanIsbnRaw is List) {
      for (final value in cleanIsbnRaw) {
        if (value is! String) {
          continue;
        }

        final isbn = _extractIsbn(value);

        if (isbn != null) {
          yield isbn;
        }
      }
    }

    final isbnsRaw = record['isbns'];

    if (isbnsRaw is! List) {
      return;
    }

    for (final value in isbnsRaw) {
      if (value is! String) {
        continue;
      }

      final isbn = _extractIsbn(value);

      if (isbn != null) {
        yield isbn;
      }
    }
  }

  String? _extractIsbn(String source) {
    var value = source.trim();

    value = value.replaceFirst(
      RegExp(r'^ISBN(?:-1[03])?\s*:?\s*', caseSensitive: false),
      '',
    );

    // Finna voi palauttaa esimerkiksi:
    // 978-951-0-31435-7 (sid.)
    value = value.split('(').first.trim();

    final normalizedIsbn = IsbnUtils.normalize(value);

    return IsbnUtils.isValid(normalizedIsbn) ? normalizedIsbn : null;
  }

  Book? _bookFromRecord(Map<String, dynamic> record, {required String isbn}) {
    final title = _readNonEmptyString(record['title']);

    if (title == null) {
      return null;
    }

    return Book(
      id: isbn,
      shelfId: 'default-shelf',
      isbn: isbn,
      title: title,
      author: _readAuthor(record),
      pageCount: _readPageCount(record),
      coverUrl: _readCoverUrl(record),
      spineColor: _createSpineColor(isbn),
    );
  }

  String _readAuthor(Map<String, dynamic> record) {
    final authorsRaw = record['authors'];

    if (authorsRaw is Map) {
      final authors = Map<String, dynamic>.from(authorsRaw);

      final mainAuthor = _readNonEmptyString(authors['main']);

      if (mainAuthor != null) {
        return mainAuthor;
      }

      final corporateAuthor = _readNonEmptyString(authors['corporate']);

      if (corporateAuthor != null) {
        return corporateAuthor;
      }

      final secondaryAuthors = authors['secondary'];

      if (secondaryAuthors is List) {
        final names = secondaryAuthors
            .whereType<String>()
            .map((name) => name.trim())
            .where((name) => name.isNotEmpty)
            .toList();

        if (names.isNotEmpty) {
          return names.join(', ');
        }
      }
    }

    final nonPresenterAuthors = record['nonPresenterAuthors'];

    if (nonPresenterAuthors is List) {
      final names = <String>[];

      for (final authorRaw in nonPresenterAuthors) {
        if (authorRaw is! Map) {
          continue;
        }

        final author = Map<String, dynamic>.from(authorRaw);
        final name = _readNonEmptyString(author['name']);

        if (name != null) {
          names.add(name);
        }
      }

      if (names.isNotEmpty) {
        return names.join(', ');
      }
    }

    return 'Tuntematon kirjailija';
  }

  int _readPageCount(Map<String, dynamic> record) {
    final descriptionsRaw = record['physicalDescriptions'];

    if (descriptionsRaw is! List) {
      return 300;
    }

    final pageExpression = RegExp(
      r'(\d{1,5})\s*(?:sivua|sivut?|s\.)',
      caseSensitive: false,
    );

    for (final value in descriptionsRaw) {
      if (value is! String) {
        continue;
      }

      final match = pageExpression.firstMatch(value);
      final pageCount = int.tryParse(match?.group(1) ?? '');

      if (pageCount != null && pageCount > 0) {
        return pageCount;
      }
    }

    return 300;
  }

  String? _readCoverUrl(Map<String, dynamic> record) {
    final imagesRaw = record['images'];

    if (imagesRaw is! List) {
      return null;
    }

    for (final value in imagesRaw) {
      final imagePath = _readNonEmptyString(value);

      if (imagePath == null) {
        continue;
      }

      if (imagePath.startsWith('https://')) {
        return imagePath;
      }

      if (imagePath.startsWith('http://')) {
        return imagePath.replaceFirst('http://', 'https://');
      }

      if (imagePath.startsWith('/')) {
        return 'https://api.finna.fi$imagePath';
      }

      return 'https://api.finna.fi/$imagePath';
    }

    return null;
  }

  String? _readNonEmptyString(Object? value) {
    if (value is! String) {
      return null;
    }

    final trimmedValue = value.trim();

    return trimmedValue.isEmpty ? null : trimmedValue;
  }

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

    return colors[isbn.hashCode.abs() % colors.length];
  }
}
