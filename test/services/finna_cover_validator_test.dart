import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:my_shelf/services/finna_cover_validator.dart';

void main() {
  const coverUrl = 'https://www.finna.fi/Cover/Show?id=test';

  group('FinnaCoverValidator', () {
    test('hylkää läpinäkyvän 10 x 10 GIF-paikkamerkin', () async {
      final validator = FinnaCoverValidator(
        get: (_) async {
          return http.Response.bytes(
            _gifHeader(width: 10, height: 10),
            200,
            headers: const {'content-type': 'image/gif'},
          );
        },
      );

      final result = await validator.isUsableCoverUrl(coverUrl);

      expect(result, isFalse);
    });

    test('hyväksyy oikean kokoisen GIF-kuvan', () async {
      final validator = FinnaCoverValidator(
        get: (_) async {
          return http.Response.bytes(
            _gifHeader(width: 300, height: 450),
            200,
            headers: const {'content-type': 'image/gif'},
          );
        },
      );

      final result = await validator.isUsableCoverUrl(coverUrl);

      expect(result, isTrue);
    });

    test('hylkää vastauksen joka ei ole kuva', () async {
      final validator = FinnaCoverValidator(
        get: (_) async {
          return http.Response(
            '<html>Ei kuvaa</html>',
            200,
            headers: const {'content-type': 'text/html'},
          );
        },
      );

      final result = await validator.isUsableCoverUrl(coverUrl);

      expect(result, isFalse);
    });

    test('hylkää epäonnistuneen HTTP-vastauksen', () async {
      final validator = FinnaCoverValidator(
        get: (_) async {
          return http.Response('', 404);
        },
      );

      final result = await validator.isUsableCoverUrl(coverUrl);

      expect(result, isFalse);
    });

    test('palauttaa false verkkovirheessä', () async {
      final validator = FinnaCoverValidator(
        get: (_) async {
          throw Exception('Verkkovirhe');
        },
      );

      final result = await validator.isUsableCoverUrl(coverUrl);

      expect(result, isFalse);
    });
  });
}

List<int> _gifHeader({required int width, required int height}) {
  return <int>[
    0x47, // G
    0x49, // I
    0x46, // F
    0x38, // 8
    0x39, // 9
    0x61, // a
    width & 0xFF,
    (width >> 8) & 0xFF,
    height & 0xFF,
    (height >> 8) & 0xFF,
  ];
}
