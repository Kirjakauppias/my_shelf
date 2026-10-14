import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_shelf/models/shelf.dart';
import 'package:my_shelf/theme/shelf_theme_palette.dart';

void main() {
  group('ShelfThemePalette', () {
    test('classic-teemalla on odotettu perusväri', () {
      expect(ShelfTheme.classic.palette.board, const Color(0xFF926346));
    });

    test('dark-teeman nimikyltin teksti on valkoinen', () {
      expect(ShelfTheme.dark.palette.nameplateText, const Color(0xFFFFFFFF));
    });

    test('jokaiselle ShelfTheme-arvolle löytyy paletti', () {
      for (final theme in ShelfTheme.values) {
        expect(theme.palette, isA<ShelfThemePalette>());
      }
    });

    test('eri teemoilla on eri hyllylaudan värit', () {
      final colors = ShelfTheme.values
          .map((theme) => theme.palette.board)
          .toSet();

      expect(colors.length, ShelfTheme.values.length);
    });
  });
}
