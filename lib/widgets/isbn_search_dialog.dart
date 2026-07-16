import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/book_api_service.dart';

class IsbnSearchDialog extends StatefulWidget {
  final String? initialIsbn;
  final bool searchAutomatically;

  const IsbnSearchDialog({
    super.key,
    this.initialIsbn,
    this.searchAutomatically = false,
  });

  @override
  State<IsbnSearchDialog> createState() => _IsbnSearchDialogState();
}

class _IsbnSearchDialogState extends State<IsbnSearchDialog> {
  late final TextEditingController _isbnController;
  final BookApiService _bookApiService = BookApiService();

  Book? _foundBook;
  String? _errorMessage;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();

    _isbnController = TextEditingController(text: widget.initialIsbn ?? '');

    if (widget.searchAutomatically &&
        widget.initialIsbn != null &&
        widget.initialIsbn!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchBook();
      });
    }
  }

  @override
  void dispose() {
    _isbnController.dispose();
    super.dispose();
  }

  Future<void> _searchBook() async {
    final isbn = _isbnController.text.trim();
    final normalizedIsbn = isbn.replaceAll(RegExp(r'[\s-]'), '');

    if (!_isValidIsbn(normalizedIsbn)) {
      setState(() {
        _foundBook = null;
        _errorMessage = 'Syötä kelvollinen ISBN-10 tai ISBN-13.';
      });

      return;
    }

    setState(() {
      _isSearching = true;
      _foundBook = null;
      _errorMessage = null;
    });

    try {
      final book = await _bookApiService.findBookByIsbn(normalizedIsbn);

      if (!mounted) {
        return;
      }

      setState(() {
        _foundBook = book;
        _isSearching = false;

        if (book == null) {
          _errorMessage = 'Kirjaa ei löytynyt tällä ISBN-tunnuksella.';
        }
      });
    } on BookApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSearching = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSearching = false;
        _errorMessage =
            'Kirjan tietojen hakeminen epäonnistui. '
            'Tarkista verkkoyhteys.';
      });
    }
  }

  bool _isValidIsbn(String isbn) {
    return RegExp(r'^\d{13}$').hasMatch(isbn) ||
        RegExp(r'^\d{9}[\dXx]$').hasMatch(isbn);
  }

  void _addBook() {
    final book = _foundBook;

    if (book == null) {
      return;
    }

    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lisää kirja ISBN:llä'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _isbnController,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _searchBook(),
                decoration: const InputDecoration(
                  labelText: 'ISBN',
                  hintText: 'Esimerkiksi 9789510451623',
                  prefixIcon: Icon(Icons.numbers),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSearching ? null : _searchBook,
                  icon: _isSearching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.search),
                  label: Text(_isSearching ? 'Haetaan...' : 'Hae kirja'),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (_foundBook != null) ...[
                const SizedBox(height: 20),
                _BookPreview(book: _foundBook!),
              ],
            ],
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
        FilledButton(
          onPressed: _foundBook == null ? null : _addBook,
          child: const Text('Lisää hyllyyn'),
        ),
      ],
    );
  }
}

class _BookPreview extends StatelessWidget {
  final Book book;

  const _BookPreview({required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverImage(coverUrl: book.coverUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(book.author),
                  const SizedBox(height: 10),
                  Text('ISBN: ${book.isbn ?? 'Ei saatavilla'}'),
                  Text('Sivuja: ${book.pageCount}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String? coverUrl;

  const _CoverImage({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    if (coverUrl == null) {
      return Container(
        width: 76,
        height: 110,
        color: const Color(0xFFE8DDD3),
        alignment: Alignment.center,
        child: const Icon(Icons.menu_book, size: 36, color: Color(0xFF6D4C41)),
      );
    }

    return Image.network(
      coverUrl!,
      width: 76,
      height: 110,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 76,
          height: 110,
          color: const Color(0xFFE8DDD3),
          alignment: Alignment.center,
          child: const Icon(Icons.broken_image_outlined, size: 32),
        );
      },
    );
  }
}
