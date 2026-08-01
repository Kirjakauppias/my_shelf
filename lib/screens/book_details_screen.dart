import 'package:flutter/material.dart';

import '../models/book.dart';
import '../dialogs/manual_book_dialog.dart';
import '../services/custom_cover_service.dart';
import '../widgets/book_cover_hero.dart';

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

  static final CustomCoverService _customCoverService = CustomCoverService();

  const BookDetailsScreen({super.key, required this.book});

  void _closeWithResult(BuildContext context, BookDetailsResult result) {
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pop(result);
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

  String _ratingLabel(int? rating) {
    if (rating == null) {
      return 'Ei arviota';
    }

    return '$rating / 5';
  }

  Future<void> _changeRating(BuildContext context) async {
    final selectedRating = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Anna arvosana'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                book.rating == null
                    ? 'Kirjaa ei ole vielä arvioitu.'
                    : 'Nykyinen arvio: ${book.rating} / 5',
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                children: List.generate(5, (index) {
                  final rating = index + 1;

                  final isFilled =
                      book.rating != null && rating <= book.rating!;

                  return IconButton(
                    tooltip: rating == 1 ? '1 tähti' : '$rating tähteä',
                    onPressed: () {
                      Navigator.of(dialogContext).pop(rating);
                    },
                    icon: Icon(isFilled ? Icons.star : Icons.star_border),
                  );
                }),
              ),
            ],
          ),
          actions: [
            if (book.rating != null)
              TextButton.icon(
                onPressed: () {
                  // Arvo 0 tarkoittaa arvosanan poistamista.
                  Navigator.of(dialogContext).pop(0);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Poista arvio'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Peruuta'),
            ),
          ],
        );
      },
    );

    if (selectedRating == null || !context.mounted) {
      return;
    }

    if (selectedRating == book.rating) {
      return;
    }

    final updatedBook = selectedRating == 0
        ? book.copyWith(clearRating: true)
        : book.copyWith(rating: selectedRating);

    _closeWithResult(context, BookDetailsResult.updated(updatedBook));
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

  Future<void> _editNotes(BuildContext context) async {
    var draftNotes = book.notes;

    final updatedNotes = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            book.notes.trim().isEmpty
                ? 'Lisää muistiinpano'
                : 'Muokkaa muistiinpanoa',
          ),
          content: TextFormField(
            initialValue: book.notes,
            autofocus: true,
            minLines: 4,
            maxLines: 8,
            maxLength: 2000,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Kirjoita oma muistiinpano kirjasta...',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            onChanged: (value) {
              draftNotes = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Peruuta'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(draftNotes.trim());
              },
              child: const Text('Tallenna'),
            ),
          ],
        );
      },
    );

    if (updatedNotes == null ||
        updatedNotes == book.notes ||
        !context.mounted) {
      return;
    }

    final updatedBook = book.copyWith(notes: updatedNotes);

    _closeWithResult(context, BookDetailsResult.updated(updatedBook));
  }

  Future<void> _changeCover(BuildContext context) async {
    final action = await showModalBottomSheet<_CoverAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(
                  book.customCoverFileName == null
                      ? 'Valitse oma kansikuva'
                      : 'Vaihda oma kansikuva',
                ),
                subtitle: const Text('Valitse kuva laitteen galleriasta'),
                onTap: () {
                  Navigator.of(
                    sheetContext,
                  ).pop(_CoverAction.chooseFromGallery);
                },
              ),
              if (book.customCoverFileName != null)
                ListTile(
                  leading: const Icon(Icons.restore),
                  title: Text(
                    book.coverUrl?.trim().isNotEmpty == true
                        ? 'Palauta verkkokansi'
                        : 'Poista oma kansikuva',
                  ),
                  subtitle: Text(
                    book.coverUrl?.trim().isNotEmpty == true
                        ? 'Kirjalle haettu alkuperäinen kansi otetaan käyttöön'
                        : 'Kirjalle näytetään automaattinen varakansi',
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop(_CoverAction.removeCustomCover);
                  },
                ),
            ],
          ),
        );
      },
    );

    if (action == null || !context.mounted) {
      return;
    }

    switch (action) {
      case _CoverAction.chooseFromGallery:
        await _chooseCoverFromGallery(context);
        break;

      case _CoverAction.removeCustomCover:
        final shouldRemove = await _confirmRemoveCustomCover(context);

        if (!shouldRemove || !context.mounted) {
          return;
        }

        final updatedBook = book.copyWith(clearCustomCover: true);

        _closeWithResult(context, BookDetailsResult.updated(updatedBook));
        break;
    }
  }

  Future<void> _chooseCoverFromGallery(BuildContext context) async {
    try {
      final fileName = await _customCoverService.pickAndSaveFromGallery(
        bookId: book.id,
      );

      if (fileName == null || !context.mounted) {
        return;
      }

      final updatedBook = book.copyWith(customCoverFileName: fileName);

      _closeWithResult(context, BookDetailsResult.updated(updatedBook));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kansikuvan tallentaminen epäonnistui.')),
      );
    }
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
              _BookCover(
                book: book,
                onChangeCover: () {
                  _changeCover(context);
                },
              ),
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
                      const Divider(),
                      _BookDetailRow(
                        icon: book.rating == null
                            ? Icons.star_border
                            : Icons.star,
                        label: 'Arvosana',
                        value: _ratingLabel(book.rating),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.notes_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Muistiinpano',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        book.notes.trim().isEmpty
                            ? 'Ei muistiinpanoa'
                            : book.notes,
                        style: TextStyle(
                          color: book.notes.trim().isEmpty
                              ? Colors.black54
                              : null,
                          fontStyle: book.notes.trim().isEmpty
                              ? FontStyle.italic
                              : FontStyle.normal,
                          height: 1.4,
                        ),
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
                  _changeRating(context);
                },
                icon: Icon(
                  book.rating == null ? Icons.star_border : Icons.star,
                ),
                label: Text(
                  book.rating == null
                      ? 'Anna arvosana'
                      : 'Muuta arvosanaa: ${book.rating} / 5',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  _editNotes(context);
                },
                icon: const Icon(Icons.notes_outlined),
                label: Text(
                  book.notes.trim().isEmpty
                      ? 'Lisää muistiinpano'
                      : 'Muokkaa muistiinpanoa',
                ),
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

  Future<bool> _confirmRemoveCustomCover(BuildContext context) async {
    final hasNetworkCover = book.coverUrl?.trim().isNotEmpty == true;

    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            hasNetworkCover ? 'Palauta verkkokansi' : 'Poista oma kansikuva',
          ),
          content: Text(
            hasNetworkCover
                ? 'Haluatko poistaa itse valitsemasi kannen ja palauttaa kirjalle verkosta haetun kansikuvan?'
                : 'Haluatko poistaa itse valitsemasi kansikuvan? Kirjalle näytetään tämän jälkeen automaattinen varakansi.',
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
              child: Text(
                hasNetworkCover ? 'Palauta verkkokansi' : 'Poista kansikuva',
              ),
            ),
          ],
        );
      },
    );

    return shouldRemove ?? false;
  }
}

enum _CoverAction { chooseFromGallery, removeCustomCover }

class _BookCover extends StatelessWidget {
  final Book book;
  final VoidCallback onChangeCover;

  const _BookCover({required this.book, required this.onChangeCover});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onChangeCover,
            borderRadius: BorderRadius.circular(5),
            child: BookCoverHero(book: book, width: 150, height: 220),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onChangeCover,
          icon: const Icon(Icons.image_outlined),
          label: Text(
            book.customCoverFileName == null
                ? 'Valitse oma kansikuva'
                : 'Vaihda kansikuva',
          ),
        ),
      ],
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
