import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/book_search_result.dart';
import '../utils/isbn_utils.dart';
import 'book_api_exception.dart';
import 'finna_book_search_service.dart';

typedef BookApiHttpGet = Future<http.Response> Function(Uri uri);

class BookApiService {
  static const Duration _requestTimeout = Duration(seconds: 15);

  final BookApiHttpGet _get;
  final FinnaBookSearchService _finnaService;

  BookApiService({BookApiHttpGet? get, FinnaBookSearchService? finnaService})
    : _get = get ?? _defaultHttpGet,
      _finnaService =
          finnaService ?? FinnaBookSearchService(get: get ?? _defaultHttpGet);

  static Future<http.Response> _defaultHttpGet(Uri uri) {
    return http.get(uri);
  }

  /// Hakee kirjan ISBN-tunnuksen perusteella useasta palvelusta.
  ///
  /// Finna ja Google Books haetaan rinnakkain. Open Librarya käytetään,
  /// jos kahden ensimmäisen palvelun tuloksista puuttuu tietoja.
  Future<Book?> findBookByIsbn(String isbn) async {
    final normalizedIsbn = IsbnUtils.normalize(isbn);

    if (!IsbnUtils.isValid(normalizedIsbn)) {
      throw const BookApiException('ISBN-tunnus ei ole kelvollinen.');
    }

    final primaryAttempts = await Future.wait([
      _attemptSearch(() => _finnaService.findBookByIsbn(normalizedIsbn)),
      _attemptSearch(() => _findFromGoogleBooks(normalizedIsbn)),
    ]);

    final results = <BookSearchResult>[];
    var attemptedSourceCount = primaryAttempts.length;
    var technicalErrorCount = 0;

    for (final attempt in primaryAttempts) {
      final result = attempt.result;

      if (result != null) {
        results.add(result);
      }

      if (attempt.error != null) {
        technicalErrorCount += 1;
      }
    }

    var mergedData = _mergeResults(results);

    if (_needsAdditionalSource(mergedData)) {
      final openLibraryAttempt = await _attemptSearch(
        () => _findFromOpenLibrary(normalizedIsbn),
      );

      attemptedSourceCount += 1;

      if (openLibraryAttempt.result != null) {
        results.add(openLibraryAttempt.result!);
      }

      if (openLibraryAttempt.error != null) {
        technicalErrorCount += 1;
      }

      mergedData = _mergeResults(results);
    }

    if (!mergedData.hasAnyData) {
      if (technicalErrorCount == attemptedSourceCount) {
        throw const BookApiException(
          'Kirjan tietojen hakeminen epäonnistui '
          'kaikista kirjapalveluista.',
        );
      }

      return null;
    }

    return Book(
      id: normalizedIsbn,
      shelfId: 'default-shelf',
      isbn: normalizedIsbn,
      title: mergedData.title ?? 'Tuntematon kirja',
      author: mergedData.author ?? 'Tuntematon kirjailija',
      pageCount: mergedData.pageCount ?? 300,
      coverUrl: mergedData.coverUrl,
      spineColor: _createSpineColor(normalizedIsbn),
    );
  }

  Future<_BookSearchAttempt> _attemptSearch(
    Future<BookSearchResult?> Function() search,
  ) async {
    try {
      return _BookSearchAttempt(result: await search());
    } on Object catch (error) {
      return _BookSearchAttempt(error: error);
    }
  }

  /// Hakee kirjan Google Books API:sta.
  Future<BookSearchResult?> _findFromGoogleBooks(String isbn) async {
    final uri = Uri.https('www.googleapis.com', '/books/v1/volumes', {
      'q': 'isbn:$isbn',
      'maxResults': '5',
      'printType': 'books',
    });

    final response = await _get(uri).timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw BookApiException(
        'Google Books palautti virheen '
        '${response.statusCode}.',
      );
    }

    final decodedResponse = _decodeJsonObject(
      response,
      serviceName: 'Google Books',
    );

    final itemsRaw = decodedResponse['items'];

    if (itemsRaw is! List) {
      return null;
    }

    for (final itemRaw in itemsRaw) {
      if (itemRaw is! Map) {
        continue;
      }

      final item = Map<String, dynamic>.from(itemRaw);
      final volumeInfoRaw = item['volumeInfo'];

      if (volumeInfoRaw is! Map) {
        continue;
      }

      final volumeInfo = Map<String, dynamic>.from(volumeInfoRaw);

      if (!_googleRecordMatchesIsbn(volumeInfo, isbn)) {
        continue;
      }

      final authorsRaw = volumeInfo['authors'];

      String? author;

      if (authorsRaw is List) {
        final authorNames = authorsRaw
            .map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty)
            .toList();

        if (authorNames.isNotEmpty) {
          author = authorNames.join(', ');
        }
      }

      final pageCountRaw = volumeInfo['pageCount'];

      final pageCount = pageCountRaw is num && pageCountRaw > 0
          ? pageCountRaw.toInt()
          : null;

      final result = BookSearchResult(
        source: BookDataSource.googleBooks,
        isbn: isbn,
        title: _readNonEmptyString(volumeInfo['title']),
        author: author,
        pageCount: pageCount,
        coverUrl: _readGoogleCoverUrl(volumeInfo),
      );

      if (result.hasAnyData) {
        return result;
      }
    }

    return null;
  }

  bool _googleRecordMatchesIsbn(
    Map<String, dynamic> volumeInfo,
    String requestedIsbn,
  ) {
    final identifiersRaw = volumeInfo['industryIdentifiers'];

    if (identifiersRaw is! List) {
      return false;
    }

    for (final identifierRaw in identifiersRaw) {
      if (identifierRaw is! Map) {
        continue;
      }

      final identifier = Map<String, dynamic>.from(identifierRaw);

      final value = identifier['identifier'];

      if (value is String && IsbnUtils.areEquivalent(value, requestedIsbn)) {
        return true;
      }
    }

    return false;
  }

  /// Hakee kirjan Open Libraryn Search API:sta.
  Future<BookSearchResult?> _findFromOpenLibrary(String isbn) async {
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
      'limit': '5',
    });

    final response = await _get(uri).timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw BookApiException(
        'Open Library palautti virheen '
        '${response.statusCode}.',
      );
    }

    final decodedResponse = _decodeJsonObject(
      response,
      serviceName: 'Open Library',
    );

    final documentsRaw = decodedResponse['docs'];

    if (documentsRaw is! List) {
      return null;
    }

    for (final documentRaw in documentsRaw) {
      if (documentRaw is! Map) {
        continue;
      }

      final document = Map<String, dynamic>.from(documentRaw);

      if (!_openLibraryRecordMatchesIsbn(document, isbn)) {
        continue;
      }

      final authorNamesRaw = document['author_name'];

      String? author;

      if (authorNamesRaw is List) {
        final authorNames = authorNamesRaw
            .map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty)
            .toList();

        if (authorNames.isNotEmpty) {
          author = authorNames.join(', ');
        }
      }

      final pageCountRaw = document['number_of_pages_median'];

      final pageCount = pageCountRaw is num && pageCountRaw > 0
          ? pageCountRaw.toInt()
          : null;

      final coverId = document['cover_i'];

      final coverUrl = coverId is num
          ? 'https://covers.openlibrary.org/b/id/'
                '${coverId.toInt()}-L.jpg'
          : null;

      final result = BookSearchResult(
        source: BookDataSource.openLibrary,
        isbn: isbn,
        title: _readNonEmptyString(document['title']),
        author: author,
        pageCount: pageCount,
        coverUrl: coverUrl,
      );

      if (result.hasAnyData) {
        return result;
      }
    }

    return null;
  }

  bool _openLibraryRecordMatchesIsbn(
    Map<String, dynamic> document,
    String requestedIsbn,
  ) {
    final isbnValues = document['isbn'];

    if (isbnValues is! List) {
      return false;
    }

    for (final value in isbnValues) {
      if (value is String && IsbnUtils.areEquivalent(value, requestedIsbn)) {
        return true;
      }
    }

    return false;
  }

  _MergedBookData _mergeResults(List<BookSearchResult> results) {
    BookSearchResult? finna;
    BookSearchResult? google;
    BookSearchResult? openLibrary;

    for (final result in results) {
      switch (result.source) {
        case BookDataSource.finna:
          finna ??= result;

        case BookDataSource.googleBooks:
          google ??= result;

        case BookDataSource.openLibrary:
          openLibrary ??= result;
      }
    }

    return _MergedBookData(
      title: finna?.title ?? google?.title ?? openLibrary?.title,
      author: finna?.author ?? google?.author ?? openLibrary?.author,
      pageCount:
          finna?.pageCount ?? google?.pageCount ?? openLibrary?.pageCount,

      // Google ja Open Library asetetaan Finnan edelle,
      // koska Finnan kuvapalvelu voi palauttaa puuttuvan
      // kannen tilalla pienen läpinäkyvän GIF-kuvan.
      coverUrl: google?.coverUrl ?? openLibrary?.coverUrl ?? finna?.coverUrl,
    );
  }

  bool _needsAdditionalSource(_MergedBookData data) {
    return data.title == null ||
        data.author == null ||
        data.pageCount == null ||
        data.coverUrl == null;
  }

  Map<String, dynamic> _decodeJsonObject(
    http.Response response, {
    required String serviceName,
  }) {
    try {
      final decoded = jsonDecode(
        utf8.decode(response.bodyBytes, allowMalformed: false),
      );

      if (decoded is! Map) {
        throw const FormatException();
      }

      return Map<String, dynamic>.from(decoded);
    } on Object {
      throw BookApiException('$serviceName palautti virheellisen vastauksen.');
    }
  }

  String? _readGoogleCoverUrl(Map<String, dynamic> volumeInfo) {
    final imageLinksRaw = volumeInfo['imageLinks'];

    if (imageLinksRaw is! Map) {
      return null;
    }

    final imageLinks = Map<String, dynamic>.from(imageLinksRaw);

    final coverUrl =
        imageLinks['extraLarge'] ??
        imageLinks['large'] ??
        imageLinks['medium'] ??
        imageLinks['small'] ??
        imageLinks['thumbnail'] ??
        imageLinks['smallThumbnail'];

    if (coverUrl is! String || coverUrl.trim().isEmpty) {
      return null;
    }

    return coverUrl.replaceFirst('http://', 'https://');
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

class _BookSearchAttempt {
  final BookSearchResult? result;
  final Object? error;

  const _BookSearchAttempt({this.result, this.error});
}

class _MergedBookData {
  final String? title;
  final String? author;
  final int? pageCount;
  final String? coverUrl;

  const _MergedBookData({
    this.title,
    this.author,
    this.pageCount,
    this.coverUrl,
  });

  bool get hasAnyData {
    return title != null ||
        author != null ||
        pageCount != null ||
        coverUrl != null;
  }
}
