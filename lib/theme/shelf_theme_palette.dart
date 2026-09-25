import 'package:flutter/material.dart';

import '../models/shelf.dart';

/// Yhden kirjahyllyteeman visuaaliset värit.
@immutable
class ShelfThemePalette {
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color frameBorder;

  final Color board;
  final Color boardEdge;
  final Color boardBorder;
  final Color boardLip;

  final Color highlightedBoard;
  final Color highlightedBoardEdge;
  final Color highlightedBoardBorder;

  final Color nameplate;
  final Color nameplateText;

  final Color coverBackgroundTop;
  final Color coverBackgroundMiddle;
  final Color coverBackgroundBottom;
  final Color coverFrameBorder;

  const ShelfThemePalette({
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.frameBorder,
    required this.board,
    required this.boardEdge,
    required this.boardBorder,
    required this.boardLip,
    required this.highlightedBoard,
    required this.highlightedBoardEdge,
    required this.highlightedBoardBorder,
    required this.nameplate,
    required this.nameplateText,
    required this.coverBackgroundTop,
    required this.coverBackgroundMiddle,
    required this.coverBackgroundBottom,
    required this.coverFrameBorder,
  });
}

/// Muuntaa ShelfTheme-arvon käyttöliittymän käyttämäksi väripaletiksi.
extension ShelfThemePaletteExtension on ShelfTheme {
  ShelfThemePalette get palette {
    switch (this) {
      case ShelfTheme.classic:
        return const ShelfThemePalette(
          // Nykyisen My Shelf -ulkoasun tarkat värit.
          backgroundTop: Color(0xFFE6D0B1),
          backgroundBottom: Color(0xFFE6D0B1),
          frameBorder: Color(0xFF9A7150),
          board: Color(0xFF926346),
          boardEdge: Color(0xFF5C3522),
          boardBorder: Color(0xFF4A2818),
          boardLip: Color(0xFF3E2114),
          highlightedBoard: Color(0xFFC77C4C),
          highlightedBoardEdge: Color(0xFF8E4F2E),
          highlightedBoardBorder: Color(0xFFEFB789),
          nameplate: Color(0xFFD1A66D),
          nameplateText: Color(0xFF2E1B10),
          coverBackgroundTop: Color(0xFFEBD8BC),
          coverBackgroundMiddle: Color(0xFFDFC19B),
          coverBackgroundBottom: Color(0xFFD3AD80),
          coverFrameBorder: Color(0xFF805033),
        );

      case ShelfTheme.light:
        return const ShelfThemePalette(
          backgroundTop: Color(0xFFF2E4CF),
          backgroundBottom: Color(0xFFE4CBA8),
          frameBorder: Color(0xFFC29B70),
          board: Color(0xFFD8B184),
          boardEdge: Color(0xFFB9895C),
          boardBorder: Color(0xFFA7774D),
          boardLip: Color(0xFF8D603D),
          highlightedBoard: Color(0xFFEBC79E),
          highlightedBoardEdge: Color(0xFFC89A69),
          highlightedBoardBorder: Color(0xFFF7E2C8),
          nameplate: Color(0xFFF3E4CC),
          nameplateText: Color(0xFF3C2B1F),
          coverBackgroundTop: Color(0xFFF7EBDD),
          coverBackgroundMiddle: Color(0xFFEBD4B6),
          coverBackgroundBottom: Color(0xFFD9B98E),
          coverFrameBorder: Color(0xFFB8895D),
        );

      case ShelfTheme.oak:
        return const ShelfThemePalette(
          backgroundTop: Color(0xFFE3BD82),
          backgroundBottom: Color(0xFFC99452),
          frameBorder: Color(0xFFA76A32),
          board: Color(0xFFB77A3E),
          boardEdge: Color(0xFF8B552A),
          boardBorder: Color(0xFF6F401E),
          boardLip: Color(0xFF5A3217),
          highlightedBoard: Color(0xFFD69B58),
          highlightedBoardEdge: Color(0xFFA86732),
          highlightedBoardBorder: Color(0xFFF0C58E),
          nameplate: Color(0xFFE0B875),
          nameplateText: Color(0xFF35200F),
          coverBackgroundTop: Color(0xFFE9C98F),
          coverBackgroundMiddle: Color(0xFFD7A65F),
          coverBackgroundBottom: Color(0xFFBA7E3D),
          coverFrameBorder: Color(0xFF8C5428),
        );

      case ShelfTheme.walnut:
        return const ShelfThemePalette(
          backgroundTop: Color(0xFF8A634B),
          backgroundBottom: Color(0xFF5B3D2D),
          frameBorder: Color(0xFF432B20),
          board: Color(0xFF72503A),
          boardEdge: Color(0xFF4F3426),
          boardBorder: Color(0xFF39251B),
          boardLip: Color(0xFF2C1C15),
          highlightedBoard: Color(0xFF96684B),
          highlightedBoardEdge: Color(0xFF684532),
          highlightedBoardBorder: Color(0xFFC8A084),
          nameplate: Color(0xFFA47A58),
          nameplateText: Color(0xFFF7EFE8),
          coverBackgroundTop: Color(0xFF8B6750),
          coverBackgroundMiddle: Color(0xFF684936),
          coverBackgroundBottom: Color(0xFF493124),
          coverFrameBorder: Color(0xFF352219),
        );

      case ShelfTheme.dark:
        return const ShelfThemePalette(
          backgroundTop: Color(0xFF414141),
          backgroundBottom: Color(0xFF242424),
          frameBorder: Color(0xFF161616),
          board: Color(0xFF4A4A4A),
          boardEdge: Color(0xFF2E2E2E),
          boardBorder: Color(0xFF1C1C1C),
          boardLip: Color(0xFF121212),
          highlightedBoard: Color(0xFF666666),
          highlightedBoardEdge: Color(0xFF444444),
          highlightedBoardBorder: Color(0xFF888888),
          nameplate: Color(0xFF555555),
          nameplateText: Color(0xFFFFFFFF),
          coverBackgroundTop: Color(0xFF464646),
          coverBackgroundMiddle: Color(0xFF323232),
          coverBackgroundBottom: Color(0xFF202020),
          coverFrameBorder: Color(0xFF121212),
        );

      case ShelfTheme.gray:
        return const ShelfThemePalette(
          backgroundTop: Color(0xFFB7B3AD),
          backgroundBottom: Color(0xFF84807A),
          frameBorder: Color(0xFF66615B),
          board: Color(0xFF87827B),
          boardEdge: Color(0xFF66615F),
          boardBorder: Color(0xFF55514C),
          boardLip: Color(0xFF45413D),
          highlightedBoard: Color(0xFFAAA49C),
          highlightedBoardEdge: Color(0xFF7A756E),
          highlightedBoardBorder: Color(0xFFD2CDC6),
          nameplate: Color(0xFFB9B4AD),
          nameplateText: Color(0xFF252321),
          coverBackgroundTop: Color(0xFFC2BEB8),
          coverBackgroundMiddle: Color(0xFFA39E97),
          coverBackgroundBottom: Color(0xFF817C76),
          coverFrameBorder: Color(0xFF5D5954),
        );
    }
  }
}
