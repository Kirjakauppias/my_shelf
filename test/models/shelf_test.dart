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
}
