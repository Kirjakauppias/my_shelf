import 'package:flutter/material.dart';

import '../models/shelf.dart';

/// Yhden kirjahyllyteeman visuaaliset värit.
@immutable
class ShelfThemePalette {
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color board;
  final Color boardEdge;
  final Color nameplate;
  final Color nameplateText;

  const ShelfThemePalette({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.board,
    required this.boardEdge,
    required this.nameplate,
    required this.nameplateText,
  });
}

/// Muuntaa ShelfTheme-arvon käyttöliittymän käyttämäksi väripaletiksi.
extension ShelfThemePaletteExtension on ShelfTheme {
  ShelfThemePalette get palette {
    switch (this) {
      case ShelfTheme.classic:
        return const ShelfThemePalette(
          backgroundTop: Color(0xFF8D5A34),
          backgroundBottom: Color(0xFF5D3823),
          board: Color(0xFF9B633D),
          boardEdge: Color(0xFF704326),
          nameplate: Color(0xFFD1A66D),
          nameplateText: Color(0xFF2E1B10),
        );

      case ShelfTheme.light:
        return const ShelfThemePalette(
          backgroundTop: Color(0xFFE6D2B5),
          backgroundBottom: Color(0xFFC9A77C),
          board: Color(0xFFDDBF98),
          boardEdge: Color(0xFFB48D62),
          nameplate: Color(0xFFF3E4CC),
          nameplateText: Color(0xFF3C2B1F),
        );

      case ShelfTheme.oak:
        return const ShelfThemePalette(
          backgroundTop: Color(0xFFC18A4D),
          backgroundBottom: Color(0xFF8B5B2E),
          board: Color(0xFFB77A3E),
          boardEdge: Color(0xFF7E4D25),
          nameplate: Color(0xFFE0B875),
          nameplateText: Color(0xFF35200F),
        );

      case ShelfTheme.walnut:
        return const ShelfThemePalette(
          backgroundTop: Color(0xFF68452F),
          backgroundBottom: Color(0xFF3E291D),
          board: Color(0xFF72503A),
          boardEdge: Color(0xFF3C281D),
          nameplate: Color(0xFFA47A58),
          nameplateText: Color(0xFFF7EFE8),
        );

      case ShelfTheme.dark:
        return const ShelfThemePalette(
          backgroundTop: Color(0xFF303030),
          backgroundBottom: Color(0xFF181818),
          board: Color(0xFF3A3A3A),
          boardEdge: Color(0xFF202020),
          nameplate: Color(0xFF555555),
          nameplateText: Color(0xFFFFFFFF),
        );

      case ShelfTheme.gray:
        return const ShelfThemePalette(
          backgroundTop: Color(0xFF9A9690),
          backgroundBottom: Color(0xFF68645F),
          board: Color(0xFF87827B),
          boardEdge: Color(0xFF5E5A55),
          nameplate: Color(0xFFB9B4AD),
          nameplateText: Color(0xFF252321),
        );
    }
  }
}
