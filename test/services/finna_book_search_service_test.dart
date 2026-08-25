import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:my_shelf/services/book_api_exception.dart';
import 'package:my_shelf/services/finna_book_search_service.dart';
import 'package:my_shelf/models/book_binding.dart';

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

    test(
      'lukee julkaisuvuoden kustantajan ja kovakantisen sidosasun',
      () async {
        final service = FinnaBookSearchService(
          get: (_) async {
            return _jsonResponse({
              'status': 'OK',
              'records': [
                {
                  'id': 'fennica.metadata-test',
                  'title': 'Testikirja',
                  'authors': {'main': 'Testikirjailija'},
                  'isbns': ['$isbn13 kovakantinen'],
                  'publicationDates': ['[2024]'],
                  'publishers': ['Testikustantaja'],
                },
              ],
            });
          },
        );

        final result = await service.findBookByIsbn(isbn13);

        expect(result, isNotNull);
        expect(result!.publicationYear, 2024);
        expect(result.publisher, 'Testikustantaja');
        expect(result.binding, BookBinding.hardcover);
      },
    );

    test(
      'valitsee sidosasun juuri haettua ISBN-tunnusta vastaavasta merkinnästä',
      () async {
        const paperbackIsbn = '9513030148';
        const hardcoverIsbn = '9513030156';

        final service = FinnaBookSearchService(
          get: (_) async {
            return _jsonResponse({
              'status': 'OK',
              'records': [
                {
                  'id': 'fennica.binding-test',
                  'title': 'Kaksi sidosasua',
                  'authors': {'main': 'Testikirjailija'},
                  'isbns': ['951-30-3014-8 nidottu', '951-30-3015-6 sidottu'],
                },
              ],
            });
          },
        );

        final paperback = await service.findBookByIsbn(paperbackIsbn);

        final hardcover = await service.findBookByIsbn(hardcoverIsbn);

        expect(paperback!.binding, BookBinding.paperback);

        expect(hardcover!.binding, BookBinding.hardcover);
      },
    );

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
      'täydentää puuttuvan sidosasun myöhemmästä täsmällisestä ISBN-osumasta',
      () async {
        final service = FinnaBookSearchService(
          get: (_) async {
            return _jsonResponse({
              'status': 'OK',
              'records': [
                {
                  'id': 'library.first',
                  'title': 'Vieraat',
                  'authors': {'main': 'Sinisalo, Johanna'},
                  'isbns': ['9789512367375'],
                  'publicationDates': ['2020'],
                  'publishers': ['Karisto'],
                },
                {
                  'id': 'library.second',
                  'title': 'Vieraat',
                  'authors': {'main': 'Sinisalo, Johanna'},
                  'isbns': ['9789512367375 kovakantinen'],
                },
              ],
            });
          },
        );

        final result = await service.findBookByIsbn('9789512367375');

        expect(result, isNotNull);
        expect(result!.title, 'Vieraat');
        expect(result.publicationYear, 2020);
        expect(result.publisher, 'Karisto');
        expect(result.binding, BookBinding.hardcover);
      },
    );

    test('täydentää puuttuvan sidosasun tietueen fullRecord-datasta', () async {
      var recordCallCount = 0;

      final service = FinnaBookSearchService(
        get: (uri) async {
          if (uri.path == '/v1/search') {
            return _jsonResponse({
              'status': 'OK',
              'records': [
                {
                  'id':
                      'anders.'
                      '7b463df6-c870-4b32-80ba-99dce35c7b41',
                  'title': 'Vieraat : romaani',
                  'authors': {'main': 'Sinisalo, Johanna'},
                  'isbns': ['978-951-23-6737-5'],
                  'physicalDescriptions': ['448 sivua ; 22 cm'],
                  'publicationDates': ['2020'],
                  'publishers': ['Karisto'],
                  'formats': [
                    {'value': '0/Book/', 'translated': 'Kirja'},
                    {'value': '1/Book/Book/', 'translated': 'Kirja'},
                  ],
                },
              ],
            });
          }

          if (uri.path == '/v1/record') {
            recordCallCount += 1;

            expect(
              uri.queryParameters['id'],
              'anders.'
              '7b463df6-c870-4b32-80ba-99dce35c7b41',
            );

            expect(uri.queryParametersAll['field[]'], contains('fullRecord'));

            return _jsonResponse({
              'status': 'OK',
              'records': [
                {
                  'fullRecord':
                      '978-951-23-6737-5 '
                      'Vieraat Johanna Sinisalo '
                      'Karisto 2020 448 sivua '
                      'txtnnc sidottu '
                      'Kariston suuren '
                      'kauhuromaanikilpailun voittaja',
                },
              ],
            });
          }

          throw StateError('Odottamaton Finna-osoite: $uri');
        },
      );

      final result = await service.findBookByIsbn('9789512367375');

      expect(result, isNotNull);
      expect(result!.publicationYear, 2020);
      expect(result.publisher, 'Karisto');
      expect(result.binding, BookBinding.hardcover);
      expect(recordCallCount, 1);
    });

    test('täydentää puuttuvan sidosasun tietueen fullRecord-datasta', () async {
      var recordCallCount = 0;

      final service = FinnaBookSearchService(
        get: (uri) async {
          if (uri.path == '/v1/search') {
            return _jsonResponse({
              'status': 'OK',
              'records': [
                {
                  'id':
                      'anders.'
                      '7b463df6-c870-4b32-80ba-99dce35c7b41',
                  'title': 'Vieraat : romaani',
                  'authors': {'main': 'Sinisalo, Johanna'},
                  'isbns': ['978-951-23-6737-5'],
                  'physicalDescriptions': ['448 sivua ; 22 cm'],
                  'publicationDates': ['2020'],
                  'publishers': ['Karisto'],
                  'formats': [
                    {'value': '0/Book/', 'translated': 'Kirja'},
                    {'value': '1/Book/Book/', 'translated': 'Kirja'},
                  ],
                },
              ],
            });
          }

          if (uri.path == '/v1/record') {
            recordCallCount += 1;

            expect(
              uri.queryParameters['id'],
              'anders.'
              '7b463df6-c870-4b32-80ba-99dce35c7b41',
            );

            expect(uri.queryParametersAll['field[]'], contains('fullRecord'));

            return _jsonResponse({
              'status': 'OK',
              'records': [
                {
                  'fullRecord':
                      '978-951-23-6737-5 '
                      'Vieraat Johanna Sinisalo '
                      'Karisto 2020 448 sivua '
                      'txtnnc sidottu '
                      'Kariston suuren '
                      'kauhuromaanikilpailun voittaja',
                },
              ],
            });
          }

          throw StateError('Odottamaton Finna-osoite: $uri');
        },
      );

      final result = await service.findBookByIsbn('9789512367375');

      expect(result, isNotNull);
      expect(result!.publicationYear, 2020);
      expect(result.publisher, 'Karisto');
      expect(result.binding, BookBinding.hardcover);
      expect(recordCallCount, 1);
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
