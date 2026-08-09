import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/book_search_result.dart';
import '../utils/isbn_utils.dart';
import 'book_api_exception.dart';
import '../models/book_binding.dart';

typedef FinnaHttpGet = Future<http.Response> Function(Uri uri);

/// Hakee kirjojen tietoja Finna-palvelusta ISBN-tunnuksen perusteella.
class FinnaBookSearchService {
  static const Duration _requestTimeout = Duration(seconds: 15);

  final FinnaHttpGet _get;

  int? _readPublicationYear(Map<String, dynamic> record) {
    final publicationDatesRaw = record['publicationDates'];

    if (publicationDatesRaw is! List) {
      return null;
    }

    final yearExpression = RegExp(r'\b(\d{4})\b');

    for (final value in publicationDatesRaw) {
      if (value is! String) {
        continue;
      }

      final match = yearExpression.firstMatch(value);

      if (match == null) {
        continue;
      }

      final year = int.tryParse(match.group(1)!);

      if (year != null && year >= 1 && year <= 9999) {
        return year;
      }
    }

    return null;
  }

  String? _readPublisher(Map<String, dynamic> record) {
    final publishersRaw = record['publishers'];

    if (publishersRaw is! List) {
      return null;
    }

    for (final value in publishersRaw) {
      final publisher = _readNonEmptyString(value);

      if (publisher != null) {
        return publisher;
      }
    }

    return null;
  }

  FinnaBookSearchService({FinnaHttpGet? get})
    : _get = get ?? ((uri) => http.get(uri));

  Future<BookSearchResult?> findBookByIsbn(String isbn) async {
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
        'publicationDates',
        'publishers',
        'formats',
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

      final result = _resultFromRecord(record, isbn: normalizedIsbn);

      if (result.hasAnyData) {
        return result;
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

    // ISBN on Finna-merkinnässä alussa. Sen jälkeen voi tulla
    // esimerkiksi "kovakantinen", "nidottu" tai "(sid.)".
    final match = RegExp(r'^[0-9Xx\s-]+').firstMatch(value);

    if (match == null) {
      return null;
    }

    final normalizedIsbn = IsbnUtils.normalize(match.group(0)!.trim());

    return IsbnUtils.isValid(normalizedIsbn) ? normalizedIsbn : null;
  }

  BookSearchResult _resultFromRecord(
    Map<String, dynamic> record, {
    required String isbn,
  }) {
    final title = _readNonEmptyString(record['title']);
    final author = _readAuthor(record);

    return BookSearchResult(
      source: BookDataSource.finna,
      isbn: isbn,
      title: title,
      author: author,
      pageCount: _readPageCount(record),
      publicationYear: _readPublicationYear(record),
      publisher: _readPublisher(record),
      binding: _readBinding(record, requestedIsbn: isbn),
      coverUrl: _readCoverUrl(
        record,
        requestedIsbn: isbn,
        title: title,
        author: author,
      ),
    );
  }

  String? _readAuthor(Map<String, dynamic> record) {
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

    return null;
  }

  int? _readPageCount(Map<String, dynamic> record) {
    final descriptionsRaw = record['physicalDescriptions'];

    if (descriptionsRaw is! List) {
      return null;
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

    return null;
  }

  String? _readCoverUrl(
    Map<String, dynamic> record, {
    required String requestedIsbn,
    required String? title,
    required String? author,
  }) {
    final recordId = _readNonEmptyString(record['id']);

    // Finna.fi:n oma käyttöliittymä hakee kirjojen kansia
    // tietueen tunnisteen lisäksi ISBN:n, nimen ja tekijän avulla.
    //
    // Tämä löytää kansia, joita pelkkä API:n images-kenttä
    // tai /Cover/Show?id=... ei välttämättä löydä.
    if (recordId != null) {
      final recordIsbns = _readRecordIsbns(record).toSet().toList();

      final normalizedRequestedIsbn = IsbnUtils.normalize(requestedIsbn);

      if (!recordIsbns.contains(normalizedRequestedIsbn)) {
        recordIsbns.add(normalizedRequestedIsbn);
      }

      // ISBN-10 ensin ja ISBN-13 sen jälkeen, kuten Finnan
      // omissa kansikuvaosoitteissa usein tehdään.
      recordIsbns.sort((first, second) {
        final lengthComparison = first.length.compareTo(second.length);

        if (lengthComparison != 0) {
          return lengthComparison;
        }

        return first.compareTo(second);
      });

      final queryParameters = <String, String>{
        'author': author ?? '',
        'callnumber': '',
        'index': '0',
        'invisbn':
            IsbnUtils.toIsbn13(normalizedRequestedIsbn) ??
            normalizedRequestedIsbn,
        'recordid': recordId,
        'size': 'large',
        'source': 'Solr',
        'title': title ?? '',
      };

      for (var index = 0; index < recordIsbns.length; index++) {
        queryParameters['isbns[$index]'] = recordIsbns[index];
      }

      return Uri.https(
        'www.finna.fi',
        '/Cover/Show',
        queryParameters,
      ).toString();
    }

    // Jos tietueen tunnistetta ei poikkeuksellisesti ole,
    // käytetään API:n suoraan palauttamaa kuvaosoitetta.
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

  BookBinding? _bindingFromText(String source) {
    final value = source.toLowerCase();

    if (value.contains('kovakantinen') ||
        value.contains('hardcover') ||
        value.contains('hardback') ||
        value.contains('sidottu') ||
        RegExp(r'(^|[\s(])sid\.?([\s)]|$)').hasMatch(value)) {
      return BookBinding.hardcover;
    }

    if (value.contains('pehmeäkantinen') ||
        value.contains('paperback') ||
        value.contains('softcover') ||
        value.contains('softback') ||
        value.contains('nidottu') ||
        RegExp(r'(^|[\s(])nid\.?([\s)]|$)').hasMatch(value)) {
      return BookBinding.paperback;
    }

    if (value.contains('e-kirja') ||
        value.contains('ebook') ||
        value.contains('e-book')) {
      return BookBinding.ebook;
    }

    if (value.contains('äänikirja') || value.contains('audiobook')) {
      return BookBinding.audiobook;
    }

    return null;
  }

  BookBinding? _readBinding(
    Map<String, dynamic> record, {
    required String requestedIsbn,
  }) {
    final isbnsRaw = record['isbns'];

    // Ensisijaisesti päätellään sidosasu juuri haettua ISBN:ää
    // vastaavasta ISBN-merkinnästä.
    if (isbnsRaw is List) {
      for (final value in isbnsRaw) {
        if (value is! String) {
          continue;
        }

        final recordIsbn = _extractIsbn(value);

        if (recordIsbn == null ||
            !IsbnUtils.areEquivalent(recordIsbn, requestedIsbn)) {
          continue;
        }

        final binding = _bindingFromText(value);

        if (binding != null) {
          return binding;
        }
      }
    }

    // Jos ISBN-merkintä ei kerro sidosasua, voidaan tunnistaa
    // esimerkiksi e-kirja Finnan aineistotyypistä.
    final formatsRaw = record['formats'];

    if (formatsRaw is List) {
      for (final formatRaw in formatsRaw) {
        if (formatRaw is! Map) {
          continue;
        }

        final format = Map<String, dynamic>.from(formatRaw);

        final value = _readNonEmptyString(format['value']) ?? '';

        final translated = _readNonEmptyString(format['translated']) ?? '';

        final binding = _bindingFromText('$value $translated');

        if (binding != null) {
          return binding;
        }
      }
    }

    return null;
  }
}
