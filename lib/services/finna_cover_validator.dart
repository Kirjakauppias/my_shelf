import 'package:http/http.dart' as http;

typedef FinnaCoverHttpGet = Future<http.Response> Function(Uri uri);

/// Tarkistaa, palauttaako Finnan kansikuvaosoite oikean kansikuvan.
///
/// Finna palauttaa puuttuvan kirjankannen tilalla läpinäkyvän
/// 10 × 10 pikselin GIF-kuvan. Tällainen kuva tulkitaan puuttuvaksi.
class FinnaCoverValidator {
  static const Duration _requestTimeout = Duration(seconds: 10);

  final FinnaCoverHttpGet _get;

  FinnaCoverValidator({FinnaCoverHttpGet? get}) : _get = get ?? _defaultHttpGet;

  static Future<http.Response> _defaultHttpGet(Uri uri) {
    return http.get(uri);
  }

  Future<bool> isUsableCoverUrl(String? coverUrl) async {
    if (coverUrl == null || coverUrl.trim().isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(coverUrl);

    if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
      return false;
    }

    try {
      final response = await _get(uri).timeout(_requestTimeout);

      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        return false;
      }

      final contentType = response.headers['content-type']
          ?.split(';')
          .first
          .trim()
          .toLowerCase();

      if (contentType != null && !contentType.startsWith('image/')) {
        return false;
      }

      if (_isTenByTenGif(response.bodyBytes)) {
        return false;
      }

      return true;
    } catch (_) {
      // Kansikuvan tarkistus ei saa estää muiden kirjatietojen käyttöä.
      return false;
    }
  }

  bool _isTenByTenGif(List<int> bytes) {
    if (!_isGif(bytes) || bytes.length < 10) {
      return false;
    }

    // GIF-kuvan leveys ja korkeus ovat otsakkeessa
    // little-endian-muodossa tavuissa 6–9.
    final width = bytes[6] | (bytes[7] << 8);
    final height = bytes[8] | (bytes[9] << 8);

    return width == 10 && height == 10;
  }

  bool _isGif(List<int> bytes) {
    if (bytes.length < 6) {
      return false;
    }

    final hasGifPrefix =
        bytes[0] == 0x47 && // G
        bytes[1] == 0x49 && // I
        bytes[2] == 0x46 && // F
        bytes[3] == 0x38 && // 8
        (bytes[4] == 0x37 || bytes[4] == 0x39) && // 7 tai 9
        bytes[5] == 0x61; // a

    return hasGifPrefix;
  }
}
