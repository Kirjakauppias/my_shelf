import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:my_shelf/models/book_search_result.dart';
import 'package:my_shelf/services/book_api_exception.dart';
import 'package:my_shelf/services/book_api_service.dart';
import 'package:my_shelf/services/finna_book_search_service.dart';

void main() {
  const requestedIsbn = '9789510314357';
  const otherIsbn = '9780140328721';

  group('BookApiService', () {
    test('yhdistää Finnan perustiedot ja Google Books -kannen', () async {
      var openLibraryCallCount = 0;

      final service = BookApiService(
        finnaService: _FakeFinnaBookSearchService((_) async {
          return const BookSearchResult(
            source: BookDataSource.finna,
            isbn: requestedIsbn,
            title: 'Finnan kirjan nimi',
            author: 'Finnan kirjailija',
          );
        }),
        get: (uri) async {
          if (uri.host == 'www.googleapis.com') {
            return _jsonResponse({
              'items': [
                {
                  'volumeInfo': {
                    'title': 'Googlen kirjan nimi',
                    'authors': ['Googlen kirjailija'],
                    'pageCount': 412,
                    'industryIdentifiers': [
                      {'type': 'ISBN_13', 'identifier': requestedIsbn},
                    ],
                    'imageLinks': {'large': 'http://example.com/cover.jpg'},
                  },
                },
              ],
            });
          }

          if (uri.host == 'openlibrary.org') {
            openLibraryCallCount += 1;

            return _jsonResponse({'docs': []});
          }

          throw StateError('Odottamaton palvelu: ${uri.host}');
        },
      );

      final book = await service.findBookByIsbn(requestedIsbn);

      expect(book, isNotNull);
      expect(book!.title, 'Finnan kirjan nimi');
      expect(book.author, 'Finnan kirjailija');
      expect(book.pageCount, 412);

      expect(book.coverUrl, 'https://example.com/cover.jpg');

      expect(openLibraryCallCount, 0);
    });

    test('hylkää Finnan 10 x 10 paikkamerkin ja käyttää '
        'Open Libraryn kansikuvaa', () async {
      final service = BookApiService(
        finnaService: _FakeFinnaBookSearchService((_) async {
          return const BookSearchResult(
            source: BookDataSource.finna,
            isbn: requestedIsbn,
            title: 'Suomalainen kirja',
            author: 'Suomalainen kirjailija',
            pageCount: 320,
            coverUrl:
                'https://www.finna.fi/'
                'Cover/Show?id=test-record',
          );
        }),
        get: (uri) async {
          if (uri.host == 'www.googleapis.com') {
            return _jsonResponse({'items': []});
          }

          if (uri.host == 'www.finna.fi' && uri.path == '/Cover/Show') {
            return http.Response.bytes(
              _gifHeader(width: 10, height: 10),
              200,
              headers: const {'content-type': 'image/gif'},
            );
          }

          if (uri.host == 'openlibrary.org') {
            return _jsonResponse({
              'docs': [
                {
                  'title': 'Open Libraryn kirja',
                  'author_name': ['Open Libraryn kirjailija'],
                  'number_of_pages_median': 320,
                  'cover_i': 98765,
                  'isbn': [requestedIsbn],
                },
              ],
            });
          }

          throw StateError('Odottamaton palvelu: ${uri.host}');
        },
      );

      final book = await service.findBookByIsbn(requestedIsbn);

      expect(book, isNotNull);

      expect(
        book!.coverUrl,
        'https://covers.openlibrary.org/'
        'b/id/98765-L.jpg',
      );
    });

    test(
      'Google Books ohittaa väärän painoksen ja valitsee täsmällisen ISBN-osuman',
      () async {
        final service = BookApiService(
          finnaService: _FakeFinnaBookSearchService((_) async => null),
          get: (uri) async {
            if (uri.host == 'www.googleapis.com') {
              return _jsonResponse({
                'items': [
                  {
                    'volumeInfo': {
                      'title': 'Väärä painos',
                      'authors': ['Väärä kirjailija'],
                      'pageCount': 100,
                      'industryIdentifiers': [
                        {'type': 'ISBN_13', 'identifier': otherIsbn},
                      ],
                    },
                  },
                  {
                    'volumeInfo': {
                      'title': 'Oikea painos',
                      'authors': ['Oikea kirjailija'],
                      'pageCount': 250,
                      'industryIdentifiers': [
                        {'type': 'ISBN_13', 'identifier': requestedIsbn},
                      ],
                      'imageLinks': {
                        'thumbnail': 'https://example.com/right.jpg',
                      },
                    },
                  },
                ],
              });
            }

            return _jsonResponse({'docs': []});
          },
        );

        final book = await service.findBookByIsbn(requestedIsbn);

        expect(book, isNotNull);
        expect(book!.title, 'Oikea painos');
        expect(book.author, 'Oikea kirjailija');
      },
    );

    test(
      'käyttää Open Librarya kun Finna ja Google Books eivät löydä kirjaa',
      () async {
        final service = BookApiService(
          finnaService: _FakeFinnaBookSearchService((_) async => null),
          get: (uri) async {
            if (uri.host == 'www.googleapis.com') {
              return _jsonResponse({'items': []});
            }

            if (uri.host == 'openlibrary.org') {
              return _jsonResponse({
                'docs': [
                  {
                    'title': 'Open Libraryn kirja',
                    'author_name': ['Open Libraryn kirjailija'],
                    'number_of_pages_median': 275,
                    'cover_i': 12345,
                    'isbn': [requestedIsbn],
                  },
                ],
              });
            }

            throw StateError('Odottamaton palvelu: ${uri.host}');
          },
        );

        final book = await service.findBookByIsbn(requestedIsbn);

        expect(book, isNotNull);
        expect(book!.title, 'Open Libraryn kirja');
        expect(book.author, 'Open Libraryn kirjailija');
        expect(book.pageCount, 275);
      },
    );

    test('Finnan tekninen virhe ei estä Google Books -tulosta', () async {
      final service = BookApiService(
        finnaService: _FakeFinnaBookSearchService((_) async {
          throw const BookApiException('Finna ei vastaa.');
        }),
        get: (uri) async {
          if (uri.host == 'www.googleapis.com') {
            return _jsonResponse({
              'items': [
                {
                  'volumeInfo': {
                    'title': 'Google-tulos',
                    'authors': ['Google-kirjailija'],
                    'pageCount': 200,
                    'industryIdentifiers': [
                      {'type': 'ISBN_13', 'identifier': requestedIsbn},
                    ],
                    'imageLinks': {
                      'thumbnail': 'https://example.com/google.jpg',
                    },
                  },
                },
              ],
            });
          }

          return _jsonResponse({'docs': []});
        },
      );

      final book = await service.findBookByIsbn(requestedIsbn);

      expect(book, isNotNull);
      expect(book!.title, 'Google-tulos');
    });

    test('hylkää haun kun kaikki palvelut epäonnistuvat teknisesti', () async {
      final service = BookApiService(
        finnaService: _FakeFinnaBookSearchService((_) async {
          throw const BookApiException('Finna ei vastaa.');
        }),
        get: (_) async {
          return http.Response('Palvelinvirhe', 503);
        },
      );

      await expectLater(
        service.findBookByIsbn(requestedIsbn),
        throwsA(
          isA<BookApiException>().having(
            (error) => error.message,
            'message',
            contains('kaikista kirjapalveluista'),
          ),
        ),
      );
    });

    test('hylkää virheellisen ISBN-tunnuksen ennen verkkohakuja', () async {
      var finnaCallCount = 0;
      var httpCallCount = 0;

      final service = BookApiService(
        finnaService: _FakeFinnaBookSearchService((_) async {
          finnaCallCount += 1;
          return null;
        }),
        get: (_) async {
          httpCallCount += 1;

          return _jsonResponse({});
        },
      );

      await expectLater(
        service.findBookByIsbn('123'),
        throwsA(isA<BookApiException>()),
      );

      expect(finnaCallCount, 0);
      expect(httpCallCount, 0);
    });

    test(
      'palauttaa null kun palvelut vastaavat mutta täsmällistä ISBN-osumaa ei löydy',
      () async {
        final service = BookApiService(
          finnaService: _FakeFinnaBookSearchService((_) async => null),
          get: (uri) async {
            if (uri.host == 'www.googleapis.com') {
              return _jsonResponse({
                'items': [
                  {
                    'volumeInfo': {
                      'title': 'Väärä Google-tulos',
                      'industryIdentifiers': [
                        {'type': 'ISBN_13', 'identifier': otherIsbn},
                      ],
                    },
                  },
                ],
              });
            }

            return _jsonResponse({
              'docs': [
                {
                  'title': 'Väärä Open Library -tulos',
                  'isbn': [otherIsbn],
                },
              ],
            });
          },
        );

        final book = await service.findBookByIsbn(requestedIsbn);

        expect(book, isNull);
      },
    );
  });

  test('muodostaa Finna.fi-kansiosoitteen kirjan metatiedoista', () async {
    final service = FinnaBookSearchService(
      get: (_) async {
        return _jsonResponse({
          'status': 'OK',
          'records': [
            {
              'id': 'fennica.test-record',
              'title': 'Vanhempi suomalainen kirja',
              'authors': {'main': 'Kotimainen, Kirjailija'},
              'isbns': ['951-0-31435-8', '978-951-0-31435-7'],
            },
          ],
        });
      },
    );

    final result = await service.findBookByIsbn(requestedIsbn);

    expect(result, isNotNull);
    expect(result!.coverUrl, isNotNull);

    final coverUri = Uri.parse(result.coverUrl!);

    expect(coverUri.scheme, 'https');
    expect(coverUri.host, 'www.finna.fi');
    expect(coverUri.path, '/Cover/Show');

    expect(coverUri.queryParameters['recordid'], 'fennica.test-record');

    expect(coverUri.queryParameters['invisbn'], requestedIsbn);

    expect(coverUri.queryParameters['isbns[0]'], '9510314358');

    expect(coverUri.queryParameters['isbns[1]'], requestedIsbn);

    expect(coverUri.queryParameters['author'], 'Kotimainen, Kirjailija');

    expect(coverUri.queryParameters['title'], 'Vanhempi suomalainen kirja');

    expect(coverUri.queryParameters['source'], 'Solr');

    expect(coverUri.queryParameters['size'], 'large');
  });
}

class _FakeFinnaBookSearchService extends FinnaBookSearchService {
  final Future<BookSearchResult?> Function(String isbn) _handler;

  _FakeFinnaBookSearchService(this._handler)
    : super(
        get: (_) async {
          throw UnsupportedError('Testin HTTP-kutsua ei pitäisi suorittaa.');
        },
      );

  @override
  Future<BookSearchResult?> findBookByIsbn(String isbn) {
    return _handler(isbn);
  }
}

http.Response _jsonResponse(Map<String, dynamic> data) {
  return http.Response(
    jsonEncode(data),
    200,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}

List<int> _gifHeader({required int width, required int height}) {
  return <int>[
    0x47,
    0x49,
    0x46,
    0x38,
    0x39,
    0x61,
    width & 0xFF,
    (width >> 8) & 0xFF,
    height & 0xFF,
    (height >> 8) & 0xFF,
  ];
}
