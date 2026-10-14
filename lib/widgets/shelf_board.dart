import 'package:flutter/material.dart';

import '../models/shelf.dart';
import '../theme/shelf_theme_palette.dart';

class ShelfBoard extends StatelessWidget {
  final bool highlighted;
  final ShelfTheme theme;

  const ShelfBoard({
    super.key,
    this.highlighted = false,
    this.theme = ShelfTheme.classic,
  });

  @override
  Widget build(BuildContext context) {
    final palette = theme.palette;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: double.infinity,
      height: highlighted ? 13 : 10,
      margin: const EdgeInsets.only(top: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: highlighted
              ? [palette.highlightedBoard, palette.highlightedBoardEdge]
              : [palette.board, palette.boardEdge],
        ),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: highlighted
              ? palette.highlightedBoardBorder
              : palette.boardBorder,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 2,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            color: palette.boardLip,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(2),
              bottomRight: Radius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
