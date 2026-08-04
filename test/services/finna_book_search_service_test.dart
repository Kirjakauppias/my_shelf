import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:my_shelf/services/book_api_exception.dart';
import 'package:my_shelf/services/finna_book_search_service.dart';

void main() {
  const isbn13 = '9789510314357';

  group('FinnaBookSearchService', () {
    test('hakee kirjan täsmällisen ISBN-osuman perusteella', () async {
      final service = FinnaBookSearchService(
        get: (uri) async {
          expect(uri.host, 'api.finna.fi');
          expect(uri.path, '/v1/search');
          expect(uri.queryParameters['lookfor'], isbn13);
          expect(uri.queryParameters['type'], 'ISN');

          expect(
            uri.queryParametersAll['filter[]'],
            contains('format:"0/Book/"'),
          );

          return _jsonResponse({
            'status': 'OK',
            'records': [
              {
                'title': 'Testikirja',
                'authors': {'main': 'Kirjailija, Testi'},
                'isbns': ['978-951-0-31435-7 (sid.)'],
                'physicalDescriptions': ['320 sivua'],
                'images': ['/Cover/Show?id=fennica.test&index=0'],
              },
            ],
          });
        },
      );

      final book = await service.findBookByIsbn(isbn13);

      expect(book, isNotNull);
      expect(book!.isbn, isbn13);
      expect(book.title, 'Testikirja');
      expect(book.author, 'Kirjailija, Testi');
      expect(book.pageCount, 320);

      expect(
        book.coverUrl,
        'https://api.finna.fi/'
        'Cover/Show?id=fennica.test&index=0',
      );
    });

    test('ohittaa väärän ISBN-painoksen', () async {
      final service = FinnaBookSearchService(
        get: (_) async {
          return _jsonResponse({
            'status': 'OK',
            'records': [
              {
                'title': 'Väärä painos',
                'authors': {'main': 'Väärä kirjailija'},
                'isbns': ['978-952-0-00000-1'],
              },
              {
                'title': 'Oikea painos',
                'authors': {'main': 'Oikea kirjailija'},
                'isbns': ['978-951-0-31435-7'],
              },
            ],
          });
        },
      );

      final book = await service.findBookByIsbn(isbn13);

      expect(book, isNotNull);
      expect(book!.title, 'Oikea painos');
    });

    test(
      'tunnistaa ISBN-10- ja ISBN-13-tunnukset samaksi painokseksi',
      () async {
        final service = FinnaBookSearchService(
          get: (_) async {
            return _jsonResponse({
              'status': 'OK',
              'records': [
                {
                  'title': 'ISBN-muunnoksen testikirja',
                  'authors': {'main': 'Testikirjailija'},
                  'isbns': ['978-951-0-31435-7'],
                },
              ],
            });
          },
        );

        final book = await service.findBookByIsbn('9510314358');

        expect(book, isNotNull);
        expect(book!.title, 'ISBN-muunnoksen testikirja');
      },
    );

    test('käyttää nonPresenterAuthors-kenttää varatekijänä', () async {
      final service = FinnaBookSearchService(
        get: (_) async {
          return _jsonResponse({
            'status': 'OK',
            'records': [
              {
                'title': 'Kirja ilman authors-kenttää',
                'nonPresenterAuthors': [
                  {'name': 'Varatekijä, Veera'},
                ],
                'isbns': ['978-951-0-31435-7'],
              },
            ],
          });
        },
      );

      final book = await service.findBookByIsbn(isbn13);

      expect(book, isNotNull);
      expect(book!.author, 'Varatekijä, Veera');
    });

    test('palauttaa null kun täsmällistä ISBN-osumaa ei löydy', () async {
      final service = FinnaBookSearchService(
        get: (_) async {
          return _jsonResponse({
            'status': 'OK',
            'records': [
              {
                'title': 'Toinen kirja',
                'isbns': ['978-952-0-00000-1'],
              },
            ],
          });
        },
      );

      final book = await service.findBookByIsbn(isbn13);

      expect(book, isNull);
    });

    test('muuntaa HTTP-virheen BookApiExceptioniksi', () async {
      final service = FinnaBookSearchService(
        get: (_) async {
          return http.Response('Palvelinvirhe', 500);
        },
      );

      expect(
        () => service.findBookByIsbn(isbn13),
        throwsA(
          isA<BookApiException>().having(
            (error) => error.message,
            'message',
            contains('virheen 500'),
          ),
        ),
      );
    });
  });
}

http.Response _jsonResponse(Map<String, dynamic> data) {
  return http.Response(
    jsonEncode(data),
    200,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}
