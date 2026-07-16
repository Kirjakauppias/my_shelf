import 'package:flutter/material.dart';

import '../models/book.dart';

class ManualBookDialog extends StatefulWidget {
  final String? initialIsbn;

  const ManualBookDialog({super.key, this.initialIsbn});

  @override
  State<ManualBookDialog> createState() => _ManualBookDialogState();
}

class _ManualBookDialogState extends State<ManualBookDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _pageCountController;

  Color _selectedColor = const Color(0xFF335C67);

  static const List<Color> _spineColors = [
    Color(0xFF8D3B3B),
    Color(0xFF335C67),
    Color(0xFF6B705C),
    Color(0xFF8A5A44),
    Color(0xFF5E548E),
    Color(0xFF9C6644),
    Color(0xFF3D5A80),
    Color(0xFF7F5539),
  ];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _isbnController = TextEditingController(text: widget.initialIsbn ?? '');
    _pageCountController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _pageCountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final isbn = _isbnController.text.trim().replaceAll(RegExp(r'[\s-]'), '');

    final pageCount = int.parse(_pageCountController.text.trim());

    final id = isbn.isNotEmpty
        ? isbn
        : DateTime.now().microsecondsSinceEpoch.toString();

    final book = Book(
      id: id,
      isbn: isbn.isEmpty ? null : isbn,
      title: title,
      author: author,
      pageCount: pageCount,
      coverUrl: null,
      spineColor: _selectedColor,
    );

    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lisää kirja käsin'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Kirjan nimi',
                    prefixIcon: Icon(Icons.menu_book),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Syötä kirjan nimi.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _authorController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Kirjailija',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Syötä kirjailijan nimi.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _isbnController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'ISBN (valinnainen)',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final normalized =
                        value?.trim().replaceAll(RegExp(r'[\s-]'), '') ?? '';

                    if (normalized.isEmpty) {
                      return null;
                    }

                    final isIsbn10 = RegExp(
                      r'^\d{9}[\dXx]$',
                    ).hasMatch(normalized);
                    final isIsbn13 = RegExp(r'^\d{13}$').hasMatch(normalized);

                    if (!isIsbn10 && !isIsbn13) {
                      return 'Syötä ISBN-10 tai ISBN-13.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _pageCountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'Sivumäärä',
                    prefixIcon: Icon(Icons.format_list_numbered),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final pageCount = int.tryParse(value?.trim() ?? '');

                    if (pageCount == null || pageCount <= 0) {
                      return 'Syötä kelvollinen sivumäärä.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selkämyksen väri',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final color in _spineColors)
                      _ColorChoice(
                        color: color,
                        isSelected: color == _selectedColor,
                        onSelected: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Peruuta'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Lisää hyllyyn')),
      ],
    );
  }
}

class _ColorChoice extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onSelected;

  const _ColorChoice({
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 4,
          ),
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
