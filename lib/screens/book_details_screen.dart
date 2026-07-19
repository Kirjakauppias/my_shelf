import 'package:flutter/material.dart';

import '../models/book.dart';
import '../dialogs/manual_book_dialog.dart';

class BookDetailsResult {
  final bool deleted;
  final Book? updatedBook;

  const BookDetailsResult._({required this.deleted, this.updatedBook});

  const BookDetailsResult.deleted() : this._(deleted: true);

  const BookDetailsResult.updated(Book book)
    : this._(deleted: false, updatedBook: book);
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  const BookDetailsScreen({super.key, required this.book});

  void _closeWithResult(BuildContext context, BookDetailsResult result) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(result);
    });
  }

  IconData _readingStatusIcon(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.unread:
        return Icons.radio_button_unchecked;
      case ReadingStatus.reading:
        return Icons.menu_book_outlined;
      case ReadingStatus.read:
        return Icons.check_circle_outline;
    }
  }

  Future<void> _changeReadingStatus(BuildContext context) async {
    final selectedStatus = await showDialog<ReadingStatus>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: const Text('Valitse lukutila'),
          children: ReadingStatus.values.map((status) {
            final isSelected = status == book.readingStatus;

            return ListTile(
              leading: Icon(_readingStatusIcon(status)),
              title: Text(status.label),
              trailing: isSelected ? const Icon(Icons.check) : null,
              onTap: () {
                Navigator.of(dialogContext).pop(status);
              },
            );
          }).toList(),
        );
      },
    );

    if (selectedStatus == null ||
        selectedStatus == book.readingStatus ||
        !context.mounted) {
      return;
    }

    final updatedBook = book.copyWith(readingStatus: selectedStatus);

    _closeWithResult(context, BookDetailsResult.updated(updatedBook));
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Poista kirja'),
          content: Text(
            'Haluatko varmasti poistaa kirjan "${book.title}" kirjahyllystä?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Peruuta'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Poista'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    _closeWithResult(context, const BookDetailsResult.deleted());
  }

  Future<void> _editBook(BuildContext context) async {
    final updatedBook = await showDialog<Book>(
      context: context,
      builder: (context) {
        return ManualBookDialog(book: book);
      },
    );

    if (updatedBook == null || !context.mounted) {
      return;
    }

    _closeWithResult(context, BookDetailsResult.updated(updatedBook));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kirjan tiedot')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BookCover(coverUrl: book.coverUrl),
              const SizedBox(height: 24),
              Text(
                book.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book.author,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _BookDetailRow(
                        icon: Icons.numbers,
                        label: 'ISBN',
                        value: book.isbn ?? 'Ei saatavilla',
                      ),
                      const Divider(),
                      _BookDetailRow(
                        icon: Icons.format_list_numbered,
                        label: 'Sivumäärä',
                        value: '${book.pageCount}',
                      ),
                      const Divider(),
                      _BookDetailRow(
                        icon: _readingStatusIcon(book.readingStatus),
                        label: 'Lukutila',
                        value: book.readingStatus.label,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  _changeReadingStatus(context);
                },
                icon: Icon(_readingStatusIcon(book.readingStatus)),
                label: Text('Muuta lukutilaa: ${book.readingStatus.label}'),
              ),
              const SizedBox(height: 10),

              OutlinedButton.icon(
                onPressed: () {
                  _editBook(context);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Muokkaa kirjaa'),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () {
                  _confirmDelete(context);
                },
                //onPressed: null,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Poista kirja'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BookCover extends StatelessWidget {
  final String? coverUrl;

  const _BookCover({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    if (coverUrl == null) {
      return Center(
        child: Container(
          width: 150,
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFFE8DDD3),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.menu_book,
            size: 64,
            color: Color(0xFF6D4C41),
          ),
        ),
      );
    }

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          coverUrl!,
          width: 150,
          height: 220,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 150,
              height: 220,
              color: const Color(0xFFE8DDD3),
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined, size: 56),
            );
          },
        ),
      ),
    );
  }
}

class _BookDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BookDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
