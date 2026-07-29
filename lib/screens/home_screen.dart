import 'package:flutter/material.dart';

import '../dialogs/manual_book_dialog.dart';
import '../models/book.dart';
import '../models/shelf.dart';
import '../services/book_storage_service.dart';
import '../services/shelf_storage_service.dart';
import '../widgets/bookshelf.dart';
import '../widgets/isbn_search_dialog.dart';
import 'barcode_scanner_screen.dart';
import 'book_details_screen.dart';
import '../services/backup_export_service.dart';
import '../services/backup_import_service.dart';
import '../utils/book_query.dart';
import '../widgets/book_cover_shelf.dart';
import '../services/custom_cover_service.dart';

enum BookViewMode { covers, spines }

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

  bool _isSearchOpen = false;
  final BookStorageService _storageService = BookStorageService();
  final ShelfStorageService _shelfStorageService = ShelfStorageService();
  final TextEditingController _searchController = TextEditingController();

  final List<Shelf> shelves = [];

  String selectedShelfId = defaultShelf.id;
  bool _isLoading = true;
  String searchQuery = '';

  BookViewMode _bookViewMode = BookViewMode.covers;

  bool _showReadingStatusBadges = false;

  final List<Book> books = [];

  final BackupExportService _backupExportService = const BackupExportService();
  final BackupImportService _backupImportService = BackupImportService();

  BookSortOption _selectedSortOption = BookSortOption.custom;

  ReadingStatusFilter _selectedReadingStatusFilter = ReadingStatusFilter.all;

  BookContentFilter _selectedBookContentFilter = BookContentFilter.all;

  final CustomCoverService _customCoverService = CustomCoverService();

  bool _isShelfFullscreen = false;

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

  List<Book> get visibleBooks {
    return queryBooks(
      books: books,
      shelfId: selectedShelfId,
      searchQuery: searchQuery,
      sortOption: _selectedSortOption,
      readingStatusFilter: _selectedReadingStatusFilter,
      contentFilter: _selectedBookContentFilter,
    );
  }

  bool get _canReorderBooks {
    return _selectedSortOption == BookSortOption.custom &&
        searchQuery.trim().isEmpty &&
        _selectedReadingStatusFilter == ReadingStatusFilter.all &&
        _selectedBookContentFilter == BookContentFilter.all;
  }

  void _disabledReorder({
    required Book draggedBook,
    required Book targetBook,
  }) {}

  void _disabledMoveToEnd(Book draggedBook) {}

  void _openShelfFullscreen() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isShelfFullscreen = true;
    });
  }

  void _closeShelfFullscreen() {
    setState(() {
      _isShelfFullscreen = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isShelfFullscreen) {
      return _buildFullscreenShelf();
    }
    final mediaQuery = MediaQuery.of(context);

    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;

    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return Scaffold(
      floatingActionButton: isLandscape && !isKeyboardVisible
          ? FloatingActionButton(
              mini: true,
              tooltip: 'Skannaa kirja',
              onPressed: _openBarcodeScanner,
              child: const Icon(Icons.qr_code_scanner),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isLandscape ? 10 : 20,
            isLandscape ? 6 : 12,
            isLandscape ? 10 : 20,
            isLandscape ? 6 : 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              SizedBox(height: isLandscape ? 8 : 18),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          _buildShelfSelector(),
                          _buildToolbar(),
                          Expanded(child: _buildShelfContent()),
                        ],
                      ),
              ),

              if (!isKeyboardVisible && !isLandscape) ...[
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _openBarcodeScanner,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Skannaa kirja'),
                  style: const ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(Size.fromHeight(56)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openManualIsbnSearch,
                        icon: const Icon(Icons.keyboard),
                        label: const Text('Syötä ISBN'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openManualBookDialog,
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Lisää käsin'),
                      ),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              key: ValueKey(selectedShelfId),
              initialValue: selectedShelfId,
              isExpanded: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.shelves),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
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
                case 'create':
                  _openCreateShelfDialog();
                  break;

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
                  value: 'create',
                  child: ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Uusi hylly'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
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

    final previousBook = books[bookIndex];

    final previousCustomCover = previousBook.customCoverFileName;

    final newCustomCover = updatedBook.customCoverFileName;

    setState(() {
      books[bookIndex] = updatedBook;
    });

    try {
      await _saveBooks();
    } catch (error) {
      if (mounted) {
        setState(() {
          final rollbackIndex = books.indexWhere(
            (book) => book.id == previousBook.id,
          );

          if (rollbackIndex != -1) {
            books[rollbackIndex] = previousBook;
          }
        });
      }

      // Uusi kuva ehdittiin tallentaa ennen Book-tietojen
      // tallentamista. Poistetaan se, jos päivitys epäonnistui.
      if (newCustomCover != null && newCustomCover != previousCustomCover) {
        await _deleteCustomCoverQuietly(newCustomCover);
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kirjan muutosten tallentaminen epäonnistui.'),
        ),
      );

      return;
    }

    // Kirjan uusi versio on tallennettu turvallisesti.
    // Vanhaa omaa kantta ei enää tarvita.
    if (previousCustomCover != null && previousCustomCover != newCustomCover) {
      await _deleteCustomCoverQuietly(previousCustomCover);
    }

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

    final removedBook = books[bookIndex];

    setState(() {
      books.removeAt(bookIndex);
    });

    try {
      await _saveBooks();
    } catch (error) {
      if (mounted) {
        setState(() {
          final restoreIndex = bookIndex <= books.length
              ? bookIndex
              : books.length;

          books.insert(restoreIndex, removedBook);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kirjan poistaminen epäonnistui.')),
        );
      }

      return;
    }

    await _deleteCustomCoverQuietly(removedBook.customCoverFileName);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${removedBook.title} poistettiin kirjahyllystä.'),
      ),
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

  Widget _buildSearchField({bool autofocus = false}) {
    return TextField(
      controller: _searchController,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Hae kirjoista',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'Tyhjennä haku',
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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

  void _closeSearch() {
    _searchController.clear();
    FocusScope.of(context).unfocus();

    setState(() {
      searchQuery = '';
      _isSearchOpen = false;
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

    final hasActiveFilter =
        _selectedReadingStatusFilter != ReadingStatusFilter.all ||
        _selectedBookContentFilter != BookContentFilter.all;

    if (visibleBooks.isEmpty && hasActiveFilter) {
      return _buildNoFilteredBooks();
    }

    return _buildLibraryView();
    /*return Bookshelf(
      books: visibleBooks,
      onReorder: _canReorderBooks ? _reorderVisibleBooks : _disabledReorder,
      onMoveToEnd: _canReorderBooks ? _moveBookToEnd : _disabledMoveToEnd,
      onBookTap: _openBookActions,
    );*/
  }

  Widget _buildNoFilteredBooks() {
    final activeFilters = <String>[];

    if (_selectedReadingStatusFilter != ReadingStatusFilter.all) {
      activeFilters.add('Lukutila: ${_selectedReadingStatusFilter.label}');
    }

    if (_selectedBookContentFilter != BookContentFilter.all) {
      activeFilters.add('Rajaus: ${_selectedBookContentFilter.label}');
    }

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
            if (activeFilters.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(activeFilters.join('\n'), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedReadingStatusFilter = ReadingStatusFilter.all;

                  _selectedBookContentFilter = BookContentFilter.all;
                });
              },
              child: const Text('Poista suodatukset'),
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
        _selectedBookContentFilter = BookContentFilter.all;
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

  Widget _buildHeader() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(Icons.menu_book_rounded, size: 32, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          'My Shelf',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),

        // Kirjastoyhteenveto logon ja valikon välissä.
        Expanded(
          child: Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 19,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      '${books.length} kirjaa · '
                      '${shelves.length} hyllyä',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),

        Builder(
          builder: (menuContext) {
            return PopupMenuButton<String>(
              tooltip: 'Sovelluksen valikko',
              icon: const Icon(Icons.more_vert),
              enabled: !_isLoading,
              onSelected: (value) {
                switch (value) {
                  case 'view-covers':
                    setState(() {
                      _bookViewMode = BookViewMode.covers;
                    });
                    break;

                  case 'view-spines':
                    setState(() {
                      _bookViewMode = BookViewMode.spines;
                    });
                    break;

                  case 'toggle-reading-status':
                    setState(() {
                      _showReadingStatusBadges = !_showReadingStatusBadges;
                    });
                    break;

                  case 'export':
                    _exportBackup(menuContext);
                    break;

                  case 'restore':
                    _restoreBackup();
                    break;
                }
              },
              itemBuilder: (context) {
                return [
                  const PopupMenuItem<String>(
                    enabled: false,
                    child: Text(
                      'Kirjojen esitystapa',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  CheckedPopupMenuItem<String>(
                    value: 'view-covers',
                    checked: _bookViewMode == BookViewMode.covers,
                    child: const Text('Kansikuvat'),
                  ),
                  CheckedPopupMenuItem<String>(
                    value: 'view-spines',
                    checked: _bookViewMode == BookViewMode.spines,
                    child: const Text('Selkämykset'),
                  ),
                  const PopupMenuDivider(),
                  CheckedPopupMenuItem<String>(
                    value: 'toggle-reading-status',
                    checked: _showReadingStatusBadges,
                    child: const Text('Näytä lukutilatunnisteet'),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'export',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.cloud_upload_outlined),
                      title: Text('Luo varmuuskopio'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'restore',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.restore),
                      title: Text('Palauta varmuuskopio'),
                    ),
                  ),
                ];
              },
            );
          },
        ),
      ],
    );
  }

  String _sortOptionLabel(BookSortOption option) {
    switch (option) {
      case BookSortOption.custom:
        return 'Oma järjestys';

      case BookSortOption.titleAscending:
        return 'Nimi A–Ö';

      case BookSortOption.titleDescending:
        return 'Nimi Ö–A';

      case BookSortOption.authorAscending:
        return 'Tekijä A–Ö';

      case BookSortOption.authorDescending:
        return 'Tekijä Ö–A';

      case BookSortOption.ratingDescending:
        return 'Arvosana 5–1';

      case BookSortOption.ratingAscending:
        return 'Arvosana 1–5';
    }
  }

  Widget _buildToolbarMenuChild({
    required IconData icon,
    required String label,
    bool active = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: active ? colorScheme.secondaryContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 21),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
    );
  }

  Widget _buildSortMenuButton() {
    return PopupMenuButton<BookSortOption>(
      tooltip: 'Lajittele kirjat',
      initialValue: _selectedSortOption,
      onSelected: (option) {
        setState(() {
          _selectedSortOption = option;
        });
      },
      itemBuilder: (context) {
        return BookSortOption.values.map((option) {
          return CheckedPopupMenuItem<BookSortOption>(
            value: option,
            checked: option == _selectedSortOption,
            child: Text(_sortOptionLabel(option)),
          );
        }).toList();
      },
      child: _buildToolbarMenuChild(
        icon: Icons.sort,
        label: 'Järjestys',
        active: _selectedSortOption != BookSortOption.custom,
      ),
    );
  }

  Widget _buildCombinedFilterButton() {
    final readingFilterActive =
        _selectedReadingStatusFilter != ReadingStatusFilter.all;

    final contentFilterActive =
        _selectedBookContentFilter != BookContentFilter.all;

    final activeFilterCount =
        (readingFilterActive ? 1 : 0) + (contentFilterActive ? 1 : 0);

    return PopupMenuButton<String>(
      tooltip: 'Suodata kirjat',
      onSelected: (value) {
        final parts = value.split(':');

        if (parts.length != 2) {
          return;
        }

        final filterType = parts[0];
        final filterName = parts[1];

        setState(() {
          if (filterType == 'reading') {
            _selectedReadingStatusFilter = ReadingStatusFilter.values
                .firstWhere((filter) => filter.name == filterName);
          }

          if (filterType == 'content') {
            _selectedBookContentFilter = BookContentFilter.values.firstWhere(
              (filter) => filter.name == filterName,
            );
          }
        });
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<String>(
            enabled: false,
            child: Text(
              'Lukutila',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...ReadingStatusFilter.values.map((filter) {
            return CheckedPopupMenuItem<String>(
              value: 'reading:${filter.name}',
              checked: filter == _selectedReadingStatusFilter,
              child: Text(filter.label),
            );
          }),
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            enabled: false,
            child: Text(
              'Kirjan tiedot',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ...BookContentFilter.values.map((filter) {
            return CheckedPopupMenuItem<String>(
              value: 'content:${filter.name}',
              checked: filter == _selectedBookContentFilter,
              child: Text(filter.label),
            );
          }),
        ];
      },
      child: _buildToolbarMenuChild(
        icon: activeFilterCount > 0
            ? Icons.filter_alt
            : Icons.filter_alt_outlined,
        label: activeFilterCount == 0
            ? 'Suodattimet'
            : 'Suodattimet ($activeFilterCount)',
        active: activeFilterCount > 0,
      ),
    );
  }

  Widget _buildToolbar() {
    if (_isSearchOpen) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(child: _buildSearchField(autofocus: true)),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Sulje haku',
              onPressed: _closeSearch,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: _buildSortMenuButton()),
          const SizedBox(width: 8),
          Expanded(child: _buildCombinedFilterButton()),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: 'Hae kirjoista',
            onPressed: () {
              setState(() {
                _isSearchOpen = true;
              });
            },
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            tooltip: 'Avaa kirjahylly koko näytölle',
            onPressed: _openShelfFullscreen,
            icon: const Icon(Icons.fullscreen),
          ),
        ],
      ),
    );
  }

  Widget _buildLibraryView() {
    switch (_bookViewMode) {
      case BookViewMode.covers:
        return BookCoverShelf(
          books: visibleBooks,
          canReorder: _canReorderBooks,
          showReadingStatusBadges: _showReadingStatusBadges,
          isFullscreen: _isShelfFullscreen,
          onReorder: _reorderVisibleBooks,
          onMoveToEnd: _moveBookToEnd,
          onBookTap: _openBookActions,
        );

      case BookViewMode.spines:
        return Bookshelf(
          books: visibleBooks,
          showReadingStatusBadges: _showReadingStatusBadges,
          onReorder: _canReorderBooks ? _reorderVisibleBooks : _disabledReorder,
          onMoveToEnd: _canReorderBooks ? _moveBookToEnd : _disabledMoveToEnd,
          onBookTap: _openBookActions,
        );
    }
  }

  Future<void> _deleteCustomCoverQuietly(String? fileName) async {
    if (fileName == null || fileName.trim().isEmpty) {
      return;
    }

    try {
      await _customCoverService.deleteCover(fileName);
    } catch (error) {
      debugPrint('Kansikuvatiedoston poistaminen epäonnistui: $error');
    }
  }

  Widget _buildFullscreenShelf() {
    final selectedShelf = shelves.firstWhere(
      (shelf) => shelf.id == selectedShelfId,
      orElse: () => defaultShelf,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _closeShelfFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
            child: Column(
              children: [
                _buildFullscreenHeader(shelfName: selectedShelf.name),
                const SizedBox(height: 10),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildShelfContent(),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Skannaa kirja',
          onPressed: _openBarcodeScanner,
          child: const Icon(Icons.qr_code_scanner),
        ),
      ),
    );
  }

  Widget _buildFullscreenHeader({required String shelfName}) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 64,
      child: Row(
        children: [
          _FullscreenButton(
            tooltip: 'Poistu koko näytön tilasta',
            icon: Icons.arrow_back,
            onPressed: _closeShelfFullscreen,
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2C092),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF7A482A), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x30000000),
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  shelfName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF4A2919),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          PopupMenuButton<String>(
            tooltip: 'Kirjahyllyn asetukset',
            onSelected: (value) {
              switch (value) {
                case 'covers':
                  setState(() {
                    _bookViewMode = BookViewMode.covers;
                  });
                  break;

                case 'spines':
                  setState(() {
                    _bookViewMode = BookViewMode.spines;
                  });
                  break;

                case 'reading-status':
                  setState(() {
                    _showReadingStatusBadges = !_showReadingStatusBadges;
                  });
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                CheckedPopupMenuItem<String>(
                  value: 'covers',
                  checked: _bookViewMode == BookViewMode.covers,
                  child: const Text('Kansikuvat'),
                ),
                CheckedPopupMenuItem<String>(
                  value: 'spines',
                  checked: _bookViewMode == BookViewMode.spines,
                  child: const Text('Selkämykset'),
                ),
                const PopupMenuDivider(),
                CheckedPopupMenuItem<String>(
                  value: 'reading-status',
                  checked: _showReadingStatusBadges,
                  child: const Text('Näytä lukutilatunnisteet'),
                ),
              ];
            },
            child: const _FullscreenButtonVisual(icon: Icons.more_vert),
          ),
        ],
      ),
    );
  }
}

class _FullscreenButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _FullscreenButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        elevation: 4,
        shape: const CircleBorder(),
        child: IconButton(onPressed: onPressed, icon: Icon(icon)),
      ),
    );
  }
}

class _FullscreenButtonVisual extends StatelessWidget {
  final IconData icon;

  const _FullscreenButtonVisual({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
      elevation: 4,
      shape: const CircleBorder(),
      child: Padding(padding: const EdgeInsets.all(12), child: Icon(icon)),
    );
  }
}
