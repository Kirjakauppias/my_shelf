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

  final List<Shelf> shelves = [];

  String selectedShelfId = defaultShelf.id;
  bool _isLoading = true;

  final List<Book> books = [
    const Book(
      id: 'dune',
      shelfId: 'default-shelf',
      title: 'Dune',
      author: 'Frank Herbert',
      pageCount: 604,
      spineColor: Color(0xFFB85C38),
    ),
    const Book(
      id: 'hobbit',
      shelfId: 'default-shelf',
      title: 'The Hobbit',
      author: 'J. R. R. Tolkien',
      pageCount: 310,
      spineColor: Color(0xFF41644A),
    ),
    const Book(
      id: '1984',
      shelfId: 'default-shelf',
      title: '1984',
      author: 'George Orwell',
      pageCount: 328,
      spineColor: Color(0xFF37474F),
    ),
    const Book(
      id: 'sapiens',
      shelfId: 'default-shelf',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      pageCount: 498,
      spineColor: Color(0xFFC28B36),
    ),
    const Book(
      id: 'foundation',
      shelfId: 'default-shelf',
      title: 'Foundation',
      author: 'Isaac Asimov',
      pageCount: 255,
      spineColor: Color(0xFF394867),
    ),
    const Book(
      id: 'it',
      shelfId: 'default-shelf',
      title: 'It',
      author: 'Stephen King',
      pageCount: 1168,
      spineColor: Color(0xFF7D2636),
    ),
    const Book(
      id: 'dracula',
      shelfId: 'default-shelf',
      title: 'Dracula',
      author: 'Bram Stoker',
      pageCount: 418,
      spineColor: Color(0xFF4A2C2A),
    ),
    const Book(
      id: 'frankestein',
      shelfId: 'default-shelf',
      title: 'Frankenstein',
      author: 'Mary Shelley',
      pageCount: 280,
      spineColor: Color(0xFF556B2F),
    ),
    const Book(
      id: 'solaris',
      shelfId: 'default-shelf',
      title: 'Solaris',
      author: 'Stanislaw Lem',
      pageCount: 224,
      spineColor: Color(0xFF315B72),
    ),
    const Book(
      id: 'neuromancer',
      shelfId: 'default-shelf',
      title: 'Neuromancer',
      author: 'William Gibson',
      pageCount: 271,
      spineColor: Color(0xFF5B3A70),
    ),
  ];

  List<Book> get visibleBooks {
    return books.where((book) => book.shelfId == selectedShelfId).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadAppData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Shelf',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F3ED),
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
                          Expanded(
                            child: visibleBooks.isEmpty
                                ? _buildEmptyShelf()
                                : Bookshelf(
                                    books: visibleBooks,
                                    onReorder: _reorderVisibleBooks,
                                    onMoveToEnd: _moveBookToEnd,
                                    onBookTap: _openBookActions,
                                  ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
    if (shelfId == null || shelfId == selectedShelfId) {
      return;
    }

    setState(() {
      selectedShelfId = shelfId;
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
}
