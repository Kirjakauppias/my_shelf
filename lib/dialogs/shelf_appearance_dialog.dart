import 'package:flutter/material.dart';

import '../models/shelf.dart';
import '../theme/shelf_theme_palette.dart';

class ShelfAppearanceDialog extends StatefulWidget {
  final ShelfTheme initialTheme;

  const ShelfAppearanceDialog({super.key, required this.initialTheme});

  @override
  State<ShelfAppearanceDialog> createState() => _ShelfAppearanceDialogState();
}

class _ShelfAppearanceDialogState extends State<ShelfAppearanceDialog> {
  late ShelfTheme _selectedTheme;

  @override
  void initState() {
    super.initState();

    _selectedTheme = widget.initialTheme;
  }

  String _themeLabel(ShelfTheme theme) {
    switch (theme) {
      case ShelfTheme.classic:
        return 'Klassinen';

      case ShelfTheme.light:
        return 'Vaalea';

      case ShelfTheme.oak:
        return 'Tammi';

      case ShelfTheme.walnut:
        return 'Pähkinä';

      case ShelfTheme.dark:
        return 'Tumma';

      case ShelfTheme.gray:
        return 'Harmaa';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Muokkaa hyllyn ulkoasua'),
      content: SizedBox(
        width: 420,
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: ShelfTheme.values.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final theme = ShelfTheme.values[index];

            final isSelected = theme == _selectedTheme;

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  _selectedTheme = theme;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: 3,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildThemePreview(theme, isSelected: isSelected),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _themeLabel(theme),
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Peruuta'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedTheme);
          },
          child: const Text('Tallenna'),
        ),
      ],
    );
  }

  Widget _buildThemePreview(ShelfTheme theme, {required bool isSelected}) {
    final palette = theme.palette;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.coverBackgroundTop,
                palette.coverBackgroundMiddle,
                palette.coverBackgroundBottom,
              ],
              stops: const [0, 0.55, 1],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: palette.coverFrameBorder, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
            child: Column(
              children: [
                // Pieni nimikyltti.
                Container(
                  constraints: const BoxConstraints(maxWidth: 100),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: palette.nameplate,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: palette.nameplateBorder),
                  ),
                  child: Text(
                    _themeLabel(theme),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: palette.nameplateText,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),

                const Spacer(),

                // Muutama kirja antamassa mittakaavaa.
                SizedBox(
                  height: 38,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPreviewBook(
                        width: 13,
                        height: 31,
                        color: const Color(0xFF8C4A3C),
                      ),
                      const SizedBox(width: 3),
                      _buildPreviewBook(
                        width: 15,
                        height: 36,
                        color: const Color(0xFF3F627A),
                      ),
                      const SizedBox(width: 3),
                      _buildPreviewBook(
                        width: 12,
                        height: 29,
                        color: const Color(0xFF6D7442),
                      ),
                      const SizedBox(width: 3),
                      _buildPreviewBook(
                        width: 14,
                        height: 34,
                        color: const Color(0xFF8A683F),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 2),

                // Hyllylauta.
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [palette.board, palette.boardEdge],
                    ),
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(color: palette.boardBorder),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Valitun teeman merkki.
        if (isSelected)
          Positioned(
            top: 5,
            right: 5,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 14,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreviewBook({
    required double width,
    required double height,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(2),
          topRight: Radius.circular(2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
    );
  }
}
