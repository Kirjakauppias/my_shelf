import 'package:flutter/material.dart';

import '../models/book.dart';
import '../dialogs/manual_book_dialog.dart';
import '../services/custom_cover_service.dart';
import '../widgets/book_cover_hero.dart';
import '../widgets/shelf_board.dart';
import '../models/book_binding.dart';

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

  Widget _buildBookHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEBD8BC), Color(0xFFDEC09A), Color(0xFFD2AB7E)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF805033), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _BookCover(
            book: book,
            onChangeCover: () {
              _changeCover(context);
            },
          ),
          const SizedBox(height: 22),
          Text(
            book.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF3F281B),
              fontWeight: FontWeight.bold,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.author,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F1E9),
      appBar: AppBar(
        title: const Text('Kirjan tiedot'),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F1E9),
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Muokkaa kirjan tietoja',
            onPressed: () {
              _editBook(context);
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBookHeader(context),

              _buildSectionTitle(context, 'Lukeminen'),
              Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    _BookDetailRow(
                      icon: _readingStatusIcon(book.readingStatus),
                      label: 'Lukutila',
                      value: book.readingStatus.label,
                      onTap: () {
                        _changeReadingStatus(context);
                      },
                    ),
                    const Divider(height: 1),
                    _BookDetailRow(
                      icon: book.rating == null
                          ? Icons.star_border
                          : Icons.star,
                      label: 'Arvosana',
                      value: _ratingLabel(book.rating),
                      onTap: () {
                        _changeRating(context);
                      },
                    ),
                  ],
                ),
              ),

              _buildSectionTitle(context, 'Kirjan tiedot'),
              Card(
                clipBehavior: Clip.antiAlias,
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    _BookDetailRow(
                      icon: Icons.numbers,
                      label: 'ISBN',
                      value: book.isbn ?? 'Ei saatavilla',
                    ),
                    const Divider(height: 1),
                    _BookDetailRow(
                      icon: Icons.format_list_numbered,
                      label: 'Sivumäärä',
                      value: '${book.pageCount}',
                    ),
                    const Divider(height: 1),
                    _BookDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Julkaisuvuosi',
                      value: book.publicationYear?.toString() ?? 'Ei tiedossa',
                    ),
                    const Divider(height: 1),
                    _BookDetailRow(
                      icon: Icons.business_outlined,
                      label: 'Kustantaja',
                      value: book.publisher ?? 'Ei tiedossa',
                    ),
                    const Divider(height: 1),
                    _BookDetailRow(
                      icon: Icons.auto_stories_outlined,
                      label: 'Sidosasu',
                      value: book.binding.label,
                    ),
                  ],
                ),
              ),

              _buildSectionTitle(context, 'Muistiinpano'),
              _buildNotesCard(context),

              const SizedBox(height: 28),

              TextButton.icon(
                onPressed: () {
                  _confirmDelete(context);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Poista kirja kirjahyllystä'),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 22, 4, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF4A2919),
        ),
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasNotes = book.notes.trim().isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () {
          _editNotes(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.notes_outlined, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Oma muistiinpano',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                hasNotes
                    ? book.notes
                    : 'Napauta lisätäksesi oman muistiinpanon kirjasta.',
                maxLines: hasNotes ? 6 : 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasNotes
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                  fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
                  height: 1.4,
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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        SizedBox(
          width: 170,
          height: 250,
          child: Stack(
            children: [
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: Tooltip(
                    message: 'Vaihda kansikuva',
                    child: InkWell(
                      onTap: onChangeCover,
                      borderRadius: BorderRadius.circular(5),
                      child: BookCoverHero(book: book, width: 170, height: 250),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Material(
                  color: colorScheme.surface.withValues(alpha: 0.94),
                  elevation: 3,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Vaihda kansikuva',
                    onPressed: onChangeCover,
                    icon: const Icon(Icons.photo_camera_outlined),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 2),
        const SizedBox(width: 210, child: ShelfBoard()),
      ],
    );
  }
}

class _BookDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _BookDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 21, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
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
          if (onTap != null)
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(onTap: onTap, child: content);
  }
}
