import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/dialogs/manual_book_dialog.dart';
import 'package:my_shelf/models/book.dart';
import 'package:my_shelf/models/book_binding.dart';

void main() {
  group('ManualBookDialog - kirjan muokkaaminen', () {
    testWidgets('useita tietoja voi muuttaa ennen yhtä tallennusta', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final originalBook = Book(
        id: 'book-1',
        shelfId: 'default-shelf',
        isbn: '9789510507339',
        title: 'Vanha nimi',
        author: 'Vanha kirjailija',
        pageCount: 100,
        publicationYear: 2020,
        publisher: 'Vanha kustantaja',
        binding: BookBinding.hardcover,
        spineColor: const Color(0xFF335C67),
        readingStatus: ReadingStatus.unread,
        rating: 2,
        notes: 'Vanha muistiinpano',
      );

      Book? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await showDialog<Book>(
                        context: context,
                        builder: (_) {
                          return ManualBookDialog(book: originalBook);
                        },
                      );
                    },
                    child: const Text('Muokkaa'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Muokkaa'));

      await tester.pumpAndSettle();

      // Muutetaan nimi.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Vanha nimi'),
        'Uusi nimi',
      );

      // Muutetaan lukutila.
      final readingStatusDropdown = find.byType(
        DropdownButtonFormField<ReadingStatus>,
      );

      expect(readingStatusDropdown, findsOneWidget);

      final formScrollView = find.byType(SingleChildScrollView);

      expect(formScrollView, findsOneWidget);

      await tester.dragUntilVisible(
        readingStatusDropdown,
        formScrollView,
        const Offset(0, -200),
      );

      await tester.pumpAndSettle();

      await tester.tap(readingStatusDropdown);

      await tester.pumpAndSettle();

      final readOption = find.text(ReadingStatus.read.label).last;

      expect(readOption, findsOneWidget);

      await tester.tap(readOption);

      await tester.pumpAndSettle();

      // Muutetaan arvosanaksi 4 / 5.
      final fourStarButton = find.byTooltip('4 tähteä');

      expect(fourStarButton, findsOneWidget);

      await tester.dragUntilVisible(
        fourStarButton,
        formScrollView,
        const Offset(0, -200),
      );

      await tester.pumpAndSettle();

      await tester.tap(fourStarButton);

      await tester.pumpAndSettle();

      // Muutetaan muistiinpano.
      final notesField = find.byWidgetPredicate((widget) {
        return widget is TextFormField &&
            widget.controller?.text == 'Vanha muistiinpano';
      });

      expect(notesField, findsOneWidget);

      await tester.dragUntilVisible(
        notesField,
        formScrollView,
        const Offset(0, -200),
      );

      await tester.pumpAndSettle();

      await tester.enterText(notesField, 'Uusi muistiinpano');

      await tester.pumpAndSettle();

      // Mitään ei ole vielä palautettu.
      expect(result, isNull);

      // Tallennetaan kaikki yhdellä kertaa.
      final saveButton = find.widgetWithText(
        FilledButton,
        'Tallenna muutokset',
      );
      expect(saveButton, findsOneWidget);

      await tester.tap(saveButton);

      await tester.pumpAndSettle();

      expect(result, isNotNull);

      expect(result!.title, 'Uusi nimi');
      expect(result!.readingStatus, ReadingStatus.read);
      expect(result!.rating, 4);
      expect(result!.notes, 'Uusi muistiinpano');
      // Muut muuttamattomat tiedot säilyvät.
      expect(result!.author, originalBook.author);

      expect(result!.isbn, originalBook.isbn);

      expect(result!.publisher, originalBook.publisher);

      expect(result!.binding, originalBook.binding);

      expect(result!.shelfId, originalBook.shelfId);
    });

    testWidgets('Peruuta hylkää kaikki tehdyt muutokset', (tester) async {
      final originalBook = Book(
        id: 'book-2',
        shelfId: 'default-shelf',
        title: 'Alkuperäinen nimi',
        author: 'Kirjailija',
        pageCount: 200,
        spineColor: const Color(0xFF335C67),
        readingStatus: ReadingStatus.unread,
        notes: 'Alkuperäinen muistiinpano',
      );

      Book? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      result = await showDialog<Book>(
                        context: context,
                        builder: (_) {
                          return ManualBookDialog(book: originalBook);
                        },
                      );
                    },
                    child: const Text('Muokkaa'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Muokkaa'));

      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Alkuperäinen nimi'),
        'Tätä ei tallenneta',
      );

      await tester.tap(find.widgetWithText(TextButton, 'Peruuta'));

      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });
}
