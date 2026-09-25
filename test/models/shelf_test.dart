import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/shelf.dart';

void main() {
  group('Shelf', () {
    test('toJson ja fromJson säilyttävät hyllyn tiedot', () {
      const originalShelf = Shelf(id: 'fantasy', name: 'Fantasia', position: 1);

      final json = originalShelf.toJson();
      final restoredShelf = Shelf.fromJson(json);

      expect(restoredShelf.id, originalShelf.id);
      expect(restoredShelf.name, originalShelf.name);
      expect(restoredShelf.position, originalShelf.position);
    });

    test('copyWith muuttaa vain annetut tiedot', () {
      const shelf = Shelf(
        id: 'default-shelf',
        name: 'Oma kirjahylly',
        position: 0,
      );

      final updatedShelf = shelf.copyWith(name: 'Olohuone');

      expect(updatedShelf.id, shelf.id);
      expect(updatedShelf.name, 'Olohuone');
      expect(updatedShelf.position, shelf.position);
    });

    test('samat id:t tarkoittavat samaa hyllyä', () {
      const firstShelf = Shelf(id: 'same-id', name: 'Ensimmäinen', position: 0);

      const secondShelf = Shelf(id: 'same-id', name: 'Toinen', position: 4);

      expect(firstShelf, secondShelf);
      expect(firstShelf.hashCode, secondShelf.hashCode);
    });
  });

  test('uuden hyllyn oletusteema on classic', () {
    const shelf = Shelf(id: '1', name: 'Fantasia', position: 0);

    expect(shelf.theme, ShelfTheme.classic);
  });

  test('hyllyn teema tallennetaan JSON-muotoon', () {
    const shelf = Shelf(
      id: '1',
      name: 'Fantasia',
      position: 0,
      theme: ShelfTheme.walnut,
    );

    final json = shelf.toJson();

    expect(json['theme'], 'walnut');
  });

  test('hyllyn teema palautetaan JSON-datasta', () {
    final shelf = Shelf.fromJson({
      'id': '1',
      'name': 'Fantasia',
      'position': 0,
      'theme': 'dark',
    });

    expect(shelf.theme, ShelfTheme.dark);
  });

  test('vanha JSON ilman teemaa käyttää classic-teemaa', () {
    final shelf = Shelf.fromJson({
      'id': '1',
      'name': 'Fantasia',
      'position': 0,
    });

    expect(shelf.theme, ShelfTheme.classic);
  });

  test('tuntematon teema palautuu classic-teemaksi', () {
    final shelf = Shelf.fromJson({
      'id': '1',
      'name': 'Fantasia',
      'position': 0,
      'theme': 'unknown-theme',
    });

    expect(shelf.theme, ShelfTheme.classic);
  });

  test('copyWith voi vaihtaa hyllyn teeman', () {
    const shelf = Shelf(id: '1', name: 'Fantasia', position: 0);

    final updatedShelf = shelf.copyWith(theme: ShelfTheme.oak);

    expect(updatedShelf.theme, ShelfTheme.oak);
  });
}
