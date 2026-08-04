/// ISBN-tunnusten normalisointi- ja tarkistustoiminnot.
class IsbnUtils {
  const IsbnUtils._();

  /// Poistaa ISBN-tunnuksesta välilyönnit ja väliviivat.
  static String normalize(String value) {
    return value.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
  }

  /// Tarkistaa ISBN-10- tai ISBN-13-tunnuksen rakenteen ja tarkistusnumeron.
  static bool isValid(String value) {
    final isbn = normalize(value);

    if (isbn.length == 10) {
      return _isValidIsbn10(isbn);
    }

    if (isbn.length == 13) {
      return _isValidIsbn13(isbn);
    }

    return false;
  }

  /// Vertaa ISBN-tunnuksia myös ISBN-10- ja ISBN-13-muotojen välillä.
  static bool areEquivalent(String first, String second) {
    final normalizedFirst = normalize(first);
    final normalizedSecond = normalize(second);

    if (!isValid(normalizedFirst) || !isValid(normalizedSecond)) {
      return false;
    }

    if (normalizedFirst == normalizedSecond) {
      return true;
    }

    return toIsbn13(normalizedFirst) == toIsbn13(normalizedSecond);
  }

  /// Muuntaa ISBN-10-tunnuksen vastaavaksi ISBN-13-tunnukseksi.
  ///
  /// ISBN-13 palautetaan muuttamattomana. Virheelliselle tunnukselle
  /// palautetaan null.
  static String? toIsbn13(String value) {
    final isbn = normalize(value);

    if (!isValid(isbn)) {
      return null;
    }

    if (isbn.length == 13) {
      return isbn;
    }

    final base = '978${isbn.substring(0, 9)}';

    var sum = 0;

    for (var index = 0; index < base.length; index++) {
      final digit = int.parse(base[index]);
      sum += index.isEven ? digit : digit * 3;
    }

    final checkDigit = (10 - (sum % 10)) % 10;

    return '$base$checkDigit';
  }

  static bool _isValidIsbn10(String isbn) {
    if (!RegExp(r'^\d{9}[\dX]$').hasMatch(isbn)) {
      return false;
    }

    var sum = 0;

    for (var index = 0; index < 9; index++) {
      final digit = int.parse(isbn[index]);
      sum += digit * (10 - index);
    }

    final checkDigit = isbn[9] == 'X' ? 10 : int.parse(isbn[9]);

    sum += checkDigit;

    return sum % 11 == 0;
  }

  static bool _isValidIsbn13(String isbn) {
    if (!RegExp(r'^\d{13}$').hasMatch(isbn)) {
      return false;
    }

    var sum = 0;

    for (var index = 0; index < 12; index++) {
      final digit = int.parse(isbn[index]);
      sum += index.isEven ? digit : digit * 3;
    }

    final expectedCheckDigit = (10 - (sum % 10)) % 10;
    final actualCheckDigit = int.parse(isbn[12]);

    return expectedCheckDigit == actualCheckDigit;
  }
}
