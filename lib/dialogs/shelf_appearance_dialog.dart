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
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final theme = ShelfTheme.values[index];
            final palette = theme.palette;
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
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
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: palette.coverFrameBorder,
                            width: 2,
                          ),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 10,
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [palette.board, palette.boardEdge],
                              ),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(color: palette.boardBorder),
                            ),
                          ),
                        ),
                      ),
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
}
