import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/library_view_settings.dart';

void main() {
  group('LibraryViewSettings', () {
    test(
      'puuttuvat arvot palauttavat oletusasetukset',
      () {
        final settings =
            LibraryViewSettings.fromStoredValues();

        expect(
          settings.bookViewMode,
          BookViewMode.covers,
        );

        expect(
          settings.showReadingStatusBadges,
          isFalse,
        );
      },
    );

    test(
      'selkämyksenäkymä palautetaan tallennetusta arvosta',
      () {
        final settings =
            LibraryViewSettings.fromStoredValues(
              bookViewModeName: 'spines',
            );

        expect(
          settings.bookViewMode,
          BookViewMode.spines,
        );
      },
    );

    test(
      'lukutilatunnisteasetus palautetaan',
      () {
        final settings =
            LibraryViewSettings.fromStoredValues(
              showReadingStatusBadges: true,
            );

        expect(
          settings.showReadingStatusBadges,
          isTrue,
        );
      },
    );

    test(
      'tuntematon näkymä palautuu kansikuviin',
      () {
        final settings =
            LibraryViewSettings.fromStoredValues(
              bookViewModeName: 'unknown-mode',
            );

        expect(
          settings.bookViewMode,
          BookViewMode.covers,
        );
      },
    );
  });
}