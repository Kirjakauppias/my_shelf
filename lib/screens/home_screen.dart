import 'package:flutter/material.dart';

import '../dialogs/manual_book_dialog.dart';
import '../models/book.dart';
import '../models/shelf.dart';
import '../services/book_storage_service.dart';
import '../services/shelf_storage_service.dart';
import '../widgets/bookshelf.dart';
import '../widgets/isbn_search_dialog.dart';
import '../widgets/welcome_card.dart';
import 'barcode_scanner_screen.dart';
import 'book_details_screen.dart';
import '../services/backup_export_service.dart';
import '../services/backup_import_service.dart';

enum BookSortOption {
  custom,
  titleAscending,
  titleDescending,
  authorAscending,
  authorDescending,
}

enum ReadingStatusFilter { all, unread, reading, read }

extension ReadingStatusFilterExtension on ReadingStatusFilter {
  String get label {
    switch (this) {
      case ReadingStatusFilter.all:
        return 'Kaikki';
      case ReadingStatusFilter.unread:
        return 'Lukematta';
      case ReadingStatusFilter.reading:
        return 'Kesken';
      case ReadingStatusFilter.read:
        return 'Luettu';
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Shelf defaultShelf = Shelf(
    id: 'default-shelf',
    name: 'Oma kirjahylly',
    position: 0,
  );

  final BookStorageService _storageService = BookStorageService();
  final ShelfStorageService _shelfStorageService = ShelfStorageService();
  final TextEditingController _searchController = TextEditingController();

  final List<Shelf> shelves = [];

  String selectedShelfId = defaultShelf.id;
  bool _isLoading = true;
  String searchQuery = '';

  final List<Book> books = [];

  final BackupExportService _backupExportService = const BackupExportService();
  final BackupImportService _backupImportService = const BackupImportService();

  BookSortOption _selectedSortOption = BookSortOption.custom;

  ReadingStatusFilter _selectedReadingStatusFilter = ReadingStatusFilter.all;

  String _formatBackupDate(DateTime dateTime) {
    final localDateTime = dateTime.toLocal();

    String twoDigits(int value) {
      return value.toString().padLeft(2, '0');
    }

    final day = twoDigits(localDateTime.day);
    final month = twoDigits(localDateTime.month);
    final year = localDateTime.year;
    final hour = twoDigits(localDateTime.hour);
    final minute = twoDigits(localDateTime.minute);

    return '$day.$month.$year klo $hour:$minute';
  }

  bool _matchesReadingStatusFilter(Book book) {
    switch (_selectedReadingStatusFilter) {
      case ReadingStatusFilter.all:
        return true;

      case ReadingStatusFilter.unread:
        return book.readingStatus == ReadingStatus.unread;

      case ReadingStatusFilter.reading:
        return book.readingStatus == ReadingStatus.reading;

      case ReadingStatusFilter.read:
        return book.readingStatus == ReadingStatus.read;
    }
  }

  List<Book> get visibleBooks {
    final normalizedQuery = searchQuery.trim().toLowerCase();

    final filteredBooks = selectedShelfBooks.where((book) {
      if (!_matchesReadingStatusFilter(book)) {
        return false;
      }
      if (normalizedQuery.isEmpty) {
        return true;
      }

      final title = book.title.toLowerCase();
      final author = book.author.toLowerCase();
      final isbn = (book.isbn ?? '').toLowerCase();

      return title.contains(normalizedQuery) ||
          author.contains(normalizedQuery) ||
          isbn.contains(normalizedQuery);
    }).toList();

    filteredBooks.sort((firstBook, secondBook) {
      switch (_selectedSortOption) {
        case BookSortOption.titleAscending:
          return firstBook.title.toLowerCase().compareTo(
            secondBook.title.toLowerCase(),
          );

        case BookSortOption.titleDescending:
          return secondBook.title.toLowerCase().compareTo(
            firstBook.title.toLowerCase(),
          );

        case BookSortOption.authorAscending:
          return firstBook.author.toLowerCase().compareTo(
            secondBook.author.toLowerCase(),
          );

        case BookSortOption.authorDescending:
          return secondBook.author.toLowerCase().compareTo(
            firstBook.author.toLowerCase(),
          );

        case BookSortOption.custom:
          return 0;
      }
    });

    return filteredBooks;
  }

  bool get _canReorderBooks {
    return _selectedSortOption == BookSortOption.custom &&
        searchQuery.trim().isEmpty &&
        _selectedReadingStatusFilter == ReadingStatusFilter.all;
  }

  void _disabledReorder({
    required Book draggedBook,
    required Book targetBook,
  }) {}

  void _disabledMoveToEnd(Book draggedBook) {}

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Shelf',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F3ED),
        actions: [
          Builder(
            builder: (buttonContext) {
              return IconButton(
                tooltip: 'Luo varmuuskopio',
                onPressed: _isLoading
                    ? null
                    : () {
                        _exportBackup(buttonContext);
                      },
                icon: const Icon(Icons.backup_outlined),
              );
            },
          ),
          IconButton(
            tooltip: 'Palauta varmuuskopio',
            onPressed: _isLoading ? null : _restoreBackup,
            icon: const Icon(Icons.restore),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WelcomeCard(bookCount: books.length),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          _buildShelfSelector(),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(child: _buildSearchField()),
                                const SizedBox(width: 4),
                                _buildSortButton(),
                                _buildReadingStatusFilterButton(),
                              ],
                            ),
                          ),

                          Expanded(child: _buildShelfContent()),
                        ],
                      ),
                /*Column(
                        children: [
                          _buildShelfSelector(),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSearchField(),
                              ),
                              const SizedBox(width: 8),
                              _buildSortButton(),
                            ],
                          ),
                          Expanded(child: _buildShelfContent()),
                        ],
                      ),*/
              ),
              if (!isKeyboardVisible) ...[
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FilledButton.icon(
                      onPressed: _openBarcodeScanner,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Skannaa kirja'),
                      style: const ButtonStyle(
                        minimumSize: WidgetStatePropertyAll(
                          Size.fromHeight(56),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _openManualIsbnSearch,
                            icon: const Icon(Icons.keyboard),
                            label: const Text('Syötä ISBN'),
                          ),
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: _openManualBookDialog,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Lisää käsin'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadAppData() async {
    final results = await Future.wait([
      _storageService.loadBooks(),
      _shelfStorageService.loadShelves(),
    ]);

    final storedBooks = results[0] as List<Book>;
    final storedShelves = results[1] as List<Shelf>;

    if (!mounted) {
      return;
    }

    if (storedShelves.isEmpty) {
      shelves.add(defaultShelf);
      await _shelfStorageService.saveShelves(shelves);
    } else {
      shelves.addAll(storedShelves);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      if (storedBooks.isNotEmpty) {
        books
          ..clear()
          ..addAll(storedBooks);
      }

      selectedShelfId = shelves.any((shelf) => shelf.id == selectedShelfId)
          ? selectedShelfId
          : shelves.first.id;

      _isLoading = false;
    });
  }

  Future<void> _saveBooks() async {
    await _storageService.saveBooks(books);
  }

  Future<void> _reorderVisibleBooks({
    required Book draggedBook,
    required Book targetBook,
  }) async {
    final shelfBooks = visibleBooks;

    final draggedIndex = shelfBooks.indexWhere(
      (book) => book.id == draggedBook.id,
    );

    final targetIndex = shelfBooks.indexWhere(
      (book) => book.id == targetBook.id,
    );

    if (draggedIndex == -1 ||
        targetIndex == -1 ||
        draggedIndex == targetIndex) {
      return;
    }

    final movedBook = shelfBooks.removeAt(draggedIndex);
    shelfBooks.insert(targetIndex, movedBook);

    final reorderedBooks = <Book>[];
    var shelfBookIndex = 0;

    for (final book in books) {
      if (book.shelfId == selectedShelfId) {
        reorderedBooks.add(shelfBooks[shelfBookIndex]);
        shelfBookIndex++;
      } else {
        reorderedBooks.add(book);
      }
    }

    setState(() {
      books
        ..clear()
        ..addAll(reorderedBooks);
    });

    await _saveBooks();
  }

  Future<void> _moveBookToEnd(Book book) async {
    final shelfBooks = visibleBooks;
    final bookIndex = shelfBooks.indexWhere((item) => item.id == book.id);

    if (bookIndex == -1 || bookIndex == shelfBooks.length - 1) {
      return;
    }

    shelfBooks.removeAt(bookIndex);
    shelfBooks.add(book);

    final reorderedBooks = <Book>[];
    var shelfBookIndex = 0;

    for (final currentBook in books) {
      if (currentBook.shelfId == selectedShelfId) {
        reorderedBooks.add(shelfBooks[shelfBookIndex]);
        shelfBookIndex++;
      } else {
        reorderedBooks.add(currentBook);
      }
    }

    setState(() {
      books
        ..clear()
        ..addAll(reorderedBooks);
    });

    await _saveBooks();
  }

  void _selectShelf(String? shelfId) {
    if (shelfId == null) {
      return;
    }

    _searchController.clear();

    setState(() {
      selectedShelfId = shelfId;
      searchQuery = '';
    });
  }

  Widget _buildShelfSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  key: ValueKey(selectedShelfId),
                  initialValue: selectedShelfId,
                  decoration: InputDecoration(
                    labelText: 'Kirjahylly',
                    prefixIcon: const Icon(Icons.shelves),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: shelves.map((shelf) {
                    final bookCount = books
                        .where((book) => book.shelfId == shelf.id)
                        .length;

                    return DropdownMenuItem<String>(
                      value: shelf.id,
                      child: Text(
                        '${shelf.name} ($bookCount)',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _selectShelf,
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                tooltip: 'Hyllyn toiminnot',
                onSelected: (value) {
                  switch (value) {
                    case 'rename':
                      _openRenameShelfDialog();
                      break;

                    case 'delete':
                      _confirmDeleteShelf();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'rename',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Nimeä uudelleen'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      enabled: selectedShelfId != defaultShelf.id,
                      child: ListTile(
                        leading: const Icon(Icons.delete_outline),
                        title: const Text('Poista hylly'),
                        contentPadding: EdgeInsets.zero,
                        enabled: selectedShelfId != defaultShelf.id,
                      ),
                    ),
                  ];
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _openCreateShelfDialog,
              icon: const Icon(Icons.add),
              label: const Text('Uusi hylly'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyShelf() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu_book_outlined, size: 64),
            SizedBox(height: 16),
            Text(
              'Tämä kirjahylly on vielä tyhjä.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Lisää ensimmäinen kirja skannaamalla viivakoodi tai '
              'syöttämällä tiedot käsin.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBarcodeScanner() async {
    final scannedIsbn = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) {
          return const BarcodeScannerScreen();
        },
      ),
    );

    if (scannedIsbn == null || !mounted) {
      return;
    }

    await _openBookSearchWithIsbn(scannedIsbn);
  }

  Future<void> _openBookSearchWithIsbn(String isbn) async {
    final foundBook = await showDialog<Book>(
      context: context,
      builder: (context) {
        return IsbnSearchDialog(initialIsbn: isbn, searchAutomatically: true);
      },
    );

    if (foundBook == null || !mounted) {
      return;
    }

    await _addFoundBook(foundBook);
  }

  Future<void> _openManualIsbnSearch() async {
    final foundBook = await showDialog<Book>(
      context: context,
      builder: (context) {
        return const IsbnSearchDialog();
      },
    );

    if (foundBook == null || !mounted) {
      return;
    }

    await _addFoundBook(foundBook);
  }

  Future<void> _openManualBookDialog({String? initialIsbn}) async {
    final manualBook = await showDialog<Book>(
      context: context,
      builder: (context) {
        return ManualBookDialog(initialIsbn: initialIsbn);
      },
    );

    if (manualBook == null || !mounted) {
      return;
    }

    await _addFoundBook(manualBook);
  }

  Future<void> _addFoundBook(Book foundBook) async {
    final bookAlreadyExists = books.any((book) => book.id == foundBook.id);

    if (bookAlreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kirja on jo kirjahyllyssä.')),
      );

      return;
    }

    final bookForSelectedShelf = Book(
      id: foundBook.id,
      shelfId: selectedShelfId,
      isbn: foundBook.isbn,
      title: foundBook.title,
      author: foundBook.author,
      pageCount: foundBook.pageCount,
      coverUrl: foundBook.coverUrl,
      spineColor: foundBook.spineColor,
    );

    setState(() {
      books.add(bookForSelectedShelf);
    });

    await _saveBooks();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${bookForSelectedShelf.title} lisättiin hyllyyn '
          '${selectedShelf.name}.',
        ),
      ),
    );
  }

  Future<void> _openBookDetails(Book book) async {
    final result = await Navigator.of(context).push<BookDetailsResult>(
      MaterialPageRoute<BookDetailsResult>(
        builder: (context) {
          return BookDetailsScreen(book: book);
        },
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    if (result.deleted) {
      await _deleteBook(book);
      return;
    }

    final updatedBook = result.updatedBook;

    if (updatedBook != null) {
      await _updateBook(updatedBook);
    }
  }

  Future<void> _updateBook(Book updatedBook) async {
    final bookIndex = books.indexWhere((book) => book.id == updatedBook.id);

    if (bookIndex == -1) {
      return;
    }

    setState(() {
      books[bookIndex] = updatedBook;
    });

    await _saveBooks();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${updatedBook.title} päivitettiin.')),
    );
  }

  Future<void> _deleteBook(Book book) async {
    final bookIndex = books.indexWhere((item) => item.id == book.id);

    if (bookIndex == -1) {
      return;
    }

    setState(() {
      books.removeAt(bookIndex);
    });

    await _saveBooks();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book.title} poistettiin kirjahyllystä.')),
    );
  }

  Future<void> _saveShelves() async {
    await _shelfStorageService.saveShelves(shelves);
  }

  Future<void> _openCreateShelfDialog() async {
    var enteredShelfName = '';

    final shelfName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Uusi kirjahylly'),
          content: TextField(
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Kirjahyllyn nimi',
              hintText: 'Esimerkiksi Fantasia',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              enteredShelfName = value;
            },
            onSubmitted: (value) {
              final trimmedName = value.trim();

              if (trimmedName.isEmpty) {
                return;
              }

              Navigator.of(dialogContext).pop(trimmedName);
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
                final trimmedName = enteredShelfName.trim();

                if (trimmedName.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(trimmedName);
              },
              child: const Text('Luo'),
            ),
          ],
        );
      },
    );

    if (shelfName == null || !mounted) {
      return;
    }

    await _createShelf(shelfName);
  }

  Future<void> _createShelf(String shelfName) async {
    final normalizedName = shelfName.trim();

    if (normalizedName.isEmpty) {
      return;
    }

    final shelfAlreadyExists = shelves.any(
      (shelf) =>
          shelf.name.trim().toLowerCase() == normalizedName.toLowerCase(),
    );

    if (shelfAlreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Samanniminen kirjahylly on jo olemassa.'),
        ),
      );

      return;
    }

    final newShelf = Shelf(
      id: 'shelf-${DateTime.now().microsecondsSinceEpoch}',
      name: normalizedName,
      position: shelves.length,
    );

    setState(() {
      shelves.add(newShelf);
      selectedShelfId = newShelf.id;
    });

    await _saveShelves();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$normalizedName luotiin.')));
  }

  Shelf get selectedShelf {
    return shelves.firstWhere(
      (shelf) => shelf.id == selectedShelfId,
      orElse: () => defaultShelf,
    );
  }

  Future<void> _openRenameShelfDialog() async {
    var enteredShelfName = selectedShelf.name;

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nimeä kirjahylly uudelleen'),
          content: TextFormField(
            initialValue: selectedShelf.name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Kirjahyllyn nimi',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              enteredShelfName = value;
            },
            onFieldSubmitted: (value) {
              final trimmedName = value.trim();

              if (trimmedName.isNotEmpty) {
                Navigator.of(dialogContext).pop(trimmedName);
              }
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
                final trimmedName = enteredShelfName.trim();

                if (trimmedName.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(trimmedName);
              },
              child: const Text('Tallenna'),
            ),
          ],
        );
      },
    );

    if (newName == null || !mounted) {
      return;
    }

    await _renameSelectedShelf(newName);
  }

  Future<void> _renameSelectedShelf(String newName) async {
    final normalizedName = newName.trim();

    if (normalizedName.isEmpty) {
      return;
    }

    final nameAlreadyExists = shelves.any(
      (shelf) =>
          shelf.id != selectedShelfId &&
          shelf.name.trim().toLowerCase() == normalizedName.toLowerCase(),
    );

    if (nameAlreadyExists) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Samanniminen kirjahylly on jo olemassa.'),
        ),
      );

      return;
    }

    final shelfIndex = shelves.indexWhere(
      (shelf) => shelf.id == selectedShelfId,
    );

    if (shelfIndex == -1) {
      return;
    }

    final currentShelf = shelves[shelfIndex];

    final renamedShelf = Shelf(
      id: currentShelf.id,
      name: normalizedName,
      position: currentShelf.position,
    );

    setState(() {
      shelves[shelfIndex] = renamedShelf;
    });

    await _saveShelves();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kirjahyllyn nimeksi vaihdettiin "$normalizedName".'),
      ),
    );
  }

  Future<void> _confirmDeleteShelf() async {
    if (selectedShelfId == defaultShelf.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oletushyllyä ei voi poistaa.')),
      );

      return;
    }

    final shelfToDelete = selectedShelf;

    final bookCount = books
        .where((book) => book.shelfId == shelfToDelete.id)
        .length;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Poistetaanko kirjahylly?'),
          content: Text(
            bookCount == 0
                ? 'Hylly "${shelfToDelete.name}" poistetaan.'
                : 'Hyllyssä "${shelfToDelete.name}" on '
                      '$bookCount ${bookCount == 1 ? 'kirja' : 'kirjaa'}. '
                      'Kirjat siirretään oletushyllyyn.',
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
              child: const Text('Poista'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    await _deleteShelf(shelfToDelete);
  }

  Book _moveBookToShelf(Book book, String newShelfId) {
    return Book(
      id: book.id,
      shelfId: newShelfId,
      isbn: book.isbn,
      title: book.title,
      author: book.author,
      pageCount: book.pageCount,
      coverUrl: book.coverUrl,
      spineColor: book.spineColor,
    );
  }

  Future<void> _deleteShelf(Shelf shelfToDelete) async {
    if (shelfToDelete.id == defaultShelf.id) {
      return;
    }

    final updatedBooks = books.map((book) {
      if (book.shelfId == shelfToDelete.id) {
        return _moveBookToShelf(book, defaultShelf.id);
      }

      return book;
    }).toList();

    final updatedShelves = shelves
        .where((shelf) => shelf.id != shelfToDelete.id)
        .toList();

    for (var index = 0; index < updatedShelves.length; index++) {
      final shelf = updatedShelves[index];

      updatedShelves[index] = Shelf(
        id: shelf.id,
        name: shelf.name,
        position: index,
      );
    }

    setState(() {
      books
        ..clear()
        ..addAll(updatedBooks);

      shelves
        ..clear()
        ..addAll(updatedShelves);

      selectedShelfId = defaultShelf.id;
    });

    await Future.wait([_saveBooks(), _saveShelves()]);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Kirjahylly "${shelfToDelete.name}" poistettiin.'),
      ),
    );
  }

  Future<void> _openBookActions(Book book) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  book.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(book.author),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Muokkaa'),
                onTap: () async {
                  Navigator.of(bottomSheetContext).pop();

                  await _openBookDetails(book);
                },
              ),
              ListTile(
                leading: const Icon(Icons.drive_file_move_outlined),
                title: const Text('Siirrä hyllyyn'),
                enabled: shelves.length > 1,
                onTap: shelves.length > 1
                    ? () {
                        Navigator.of(bottomSheetContext).pop();

                        _openMoveBookDialog(book);
                      }
                    : null,
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Poista'),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();

                  _deleteBook(book);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openMoveBookDialog(Book book) async {
    final availableShelves = shelves
        .where((shelf) => shelf.id != book.shelfId)
        .toList();

    if (availableShelves.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kirjan siirtämistä varten tarvitaan toinen hylly.'),
        ),
      );

      return;
    }

    final destinationShelfId = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text('Siirrä "${book.title}"'),
          children: availableShelves.map((shelf) {
            final bookCount = books
                .where((currentBook) => currentBook.shelfId == shelf.id)
                .length;

            return SimpleDialogOption(
              onPressed: () {
                Navigator.of(dialogContext).pop(shelf.id);
              },
              child: ListTile(
                leading: const Icon(Icons.shelves),
                title: Text(shelf.name),
                subtitle: Text(
                  '$bookCount ${bookCount == 1 ? 'kirja' : 'kirjaa'}',
                ),
                contentPadding: EdgeInsets.zero,
              ),
            );
          }).toList(),
        );
      },
    );

    if (destinationShelfId == null || !mounted) {
      return;
    }

    await _moveBookToAnotherShelf(
      book: book,
      destinationShelfId: destinationShelfId,
    );
  }

  Future<void> _moveBookToAnotherShelf({
    required Book book,
    required String destinationShelfId,
  }) async {
    if (book.shelfId == destinationShelfId) {
      return;
    }

    final bookIndex = books.indexWhere(
      (currentBook) => currentBook.id == book.id,
    );

    if (bookIndex == -1) {
      return;
    }

    final destinationShelfIndex = shelves.indexWhere(
      (shelf) => shelf.id == destinationShelfId,
    );

    if (destinationShelfIndex == -1) {
      return;
    }

    final destinationShelf = shelves[destinationShelfIndex];

    final movedBook = _moveBookToShelf(book, destinationShelfId);

    setState(() {
      books[bookIndex] = movedBook;
    });

    await _saveBooks();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${book.title}" siirrettiin hyllyyn '
          '"${destinationShelf.name}".',
        ),
        action: SnackBarAction(
          label: 'Näytä',
          onPressed: () {
            setState(() {
              selectedShelfId = destinationShelfId;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: 'Hae kirjoista',
        hintText: 'Nimi, tekijä tai ISBN',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'Tyhjennä haku',
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
    );
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      searchQuery = '';
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> get selectedShelfBooks {
    return books.where((book) => book.shelfId == selectedShelfId).toList();
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ei hakutuloksia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Haulla "$searchQuery" ei löytynyt kirjoja.',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _clearSearch,
              child: const Text('Tyhjennä haku'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShelfContent() {
    if (selectedShelfBooks.isEmpty) {
      return _buildEmptyShelf();
    }

    if (visibleBooks.isEmpty && searchQuery.trim().isNotEmpty) {
      return _buildNoSearchResults();
    }

    if (visibleBooks.isEmpty &&
        _selectedReadingStatusFilter != ReadingStatusFilter.all) {
      return _buildNoFilteredBooks();
    }

    return Bookshelf(
      books: visibleBooks,
      onReorder: _canReorderBooks ? _reorderVisibleBooks : _disabledReorder,
      onMoveToEnd: _canReorderBooks ? _moveBookToEnd : _disabledMoveToEnd,
      onBookTap: _openBookActions,
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<BookSortOption>(
      tooltip: 'Lajittele kirjat',
      initialValue: _selectedSortOption,
      onSelected: (sortOption) {
        setState(() {
          _selectedSortOption = sortOption;
        });
      },
      itemBuilder: (context) {
        return const [
          PopupMenuItem(
            value: BookSortOption.custom,
            child: Text('Oma järjestys'),
          ),
          PopupMenuItem(
            value: BookSortOption.titleAscending,
            child: Text('Nimi A–Ö'),
          ),
          PopupMenuItem(
            value: BookSortOption.titleDescending,
            child: Text('Nimi Ö–A'),
          ),
          PopupMenuItem(
            value: BookSortOption.authorAscending,
            child: Text('Tekijä A–Ö'),
          ),
          PopupMenuItem(
            value: BookSortOption.authorDescending,
            child: Text('Tekijä Ö–A'),
          ),
        ];
      },
      icon: const Icon(Icons.sort),
    );
  }

  Widget _buildReadingStatusFilterButton() {
    final isFilterActive =
        _selectedReadingStatusFilter != ReadingStatusFilter.all;

    return PopupMenuButton<ReadingStatusFilter>(
      tooltip: 'Suodata lukutilan mukaan',
      initialValue: _selectedReadingStatusFilter,
      onSelected: (filter) {
        setState(() {
          _selectedReadingStatusFilter = filter;
        });
      },
      itemBuilder: (context) {
        return ReadingStatusFilter.values.map((filter) {
          return CheckedPopupMenuItem<ReadingStatusFilter>(
            value: filter,
            checked: filter == _selectedReadingStatusFilter,
            child: Text(filter.label),
          );
        }).toList();
      },
      icon: Icon(isFilterActive ? Icons.filter_alt : Icons.filter_alt_outlined),
    );
  }

  Widget _buildNoFilteredBooks() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ei kirjoja tällä suodatuksella',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Lukutila: ${_selectedReadingStatusFilter.label}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedReadingStatusFilter = ReadingStatusFilter.all;
                });
              },
              child: const Text('Näytä kaikki'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportBackup(BuildContext shareButtonContext) async {
    final renderObject = shareButtonContext.findRenderObject();

    final sharePositionOrigin = renderObject is RenderBox
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : null;

    try {
      final outcome = await _backupExportService.exportBackup(
        books: books,
        shelves: shelves,
        sharePositionOrigin: sharePositionOrigin,
      );

      if (!mounted) {
        return;
      }

      switch (outcome) {
        case BackupExportOutcome.shared:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Varmuuskopio jaettiin tai tallennettiin.'),
            ),
          );

        case BackupExportOutcome.dismissed:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Varmuuskopion vienti peruutettiin.')),
          );

        case BackupExportOutcome.statusUnavailable:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Varmuuskopio avattiin jakovalikkoon.'),
            ),
          );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Varmuuskopion luominen epäonnistui: $error')),
      );
    }
  }

  Future<bool> _confirmBackupRestore(BackupImportSelection selection) async {
    final backup = selection.backup;

    final shouldRestore = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Palauta varmuuskopio?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selection.fileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text('Luotu: ${_formatBackupDate(backup.createdAt)}'),
              const SizedBox(height: 6),
              Text('Kirjoja: ${backup.books.length}'),
              Text('Kirjahyllyjä: ${backup.shelves.length}'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Nykyiset kirjat ja kirjahyllyt korvataan '
                'varmuuskopion tiedoilla.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
              child: const Text('Palauta'),
            ),
          ],
        );
      },
    );

    return shouldRestore ?? false;
  }

  Future<void> _restoreBackup() async {
    try {
      final selection = await _backupImportService.pickBackup();

      if (selection == null || !mounted) {
        return;
      }

      final shouldRestore = await _confirmBackupRestore(selection);

      if (!shouldRestore || !mounted) {
        return;
      }

      final restoredBooks = List<Book>.from(selection.backup.books);

      final restoredShelves = List<Shelf>.from(selection.backup.shelves);

      // Säilytetään nykyiset tiedot mahdollista palautusta varten,
      // jos uuden varmuuskopion tallennus epäonnistuu.
      final previousBooks = List<Book>.from(books);
      final previousShelves = List<Shelf>.from(shelves);

      try {
        await Future.wait([
          _storageService.saveBooks(restoredBooks),
          _shelfStorageService.saveShelves(restoredShelves),
        ]);
      } catch (_) {
        // Yritetään palauttaa aiemmat tiedot.
        try {
          await Future.wait([
            _storageService.saveBooks(previousBooks),
            _shelfStorageService.saveShelves(previousShelves),
          ]);
        } catch (_) {
          // Alkuperäinen tallennusvirhe käsitellään alempana.
        }

        rethrow;
      }

      if (!mounted) {
        return;
      }

      final currentShelfStillExists = restoredShelves.any(
        (shelf) => shelf.id == selectedShelfId,
      );

      final nextSelectedShelfId = currentShelfStillExists
          ? selectedShelfId
          : restoredShelves.first.id;

      _searchController.clear();

      setState(() {
        books
          ..clear()
          ..addAll(restoredBooks);

        shelves
          ..clear()
          ..addAll(restoredShelves);

        selectedShelfId = nextSelectedShelfId;
        searchQuery = '';

        _selectedSortOption = BookSortOption.custom;

        _selectedReadingStatusFilter = ReadingStatusFilter.all;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Varmuuskopio palautettiin: '
            '${restoredBooks.length} kirjaa ja '
            '${restoredShelves.length} kirjahyllyä.',
          ),
        ),
      );
    } on FormatException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tiedosto ei ole kelvollinen My Shelf '
            '-varmuuskopio: ${error.message}',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Varmuuskopion palauttaminen epäonnistui: $error'),
        ),
      );
    }
  }
}
