import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/utils/isbn_utils.dart';

void main() {
  group('IsbnUtils', () {
    test('normalisoi välilyönnit ja väliviivat', () {
      expect(IsbnUtils.normalize('978-951-0-31435-7'), '9789510314357');
    });

    test('hyväksyy kelvollisen ISBN-13-tunnuksen', () {
      expect(IsbnUtils.isValid('9789510314357'), isTrue);
    });

    test('hyväksyy kelvollisen ISBN-10-tunnuksen', () {
      expect(IsbnUtils.isValid('9510314358'), isTrue);
    });

    test('hylkää virheellisen tarkistusnumeron', () {
      expect(IsbnUtils.isValid('9789510314358'), isFalse);
    });

    test('tunnistaa vastaavat ISBN-10- ja ISBN-13-tunnukset', () {
      expect(
        IsbnUtils.areEquivalent('951-0-31435-8', '978-951-0-31435-7'),
        isTrue,
      );
    });
  });
}
