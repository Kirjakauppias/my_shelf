import 'package:flutter/material.dart';
import '../services/book_storage_service.dart';
import '../widgets/isbn_search_dialog.dart';
import 'barcode_scanner_screen.dart';
import '../dialogs/manual_book_dialog.dart';
import 'book_details_screen.dart';

import '../models/book.dart';
import '../widgets/bookshelf.dart';
import '../widgets/welcome_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final BookStorageService _storageService = BookStorageService();

  bool _isLoading = true;

  final List<Book> books = [
    const Book(
      id: 'dune',
      title: 'Dune',
      author: 'Frank Herbert',
      pageCount: 604,
      spineColor: Color(0xFFB85C38),
    ),
    const Book(
      id: 'hobbit',
      title: 'The Hobbit',
      author: 'J. R. R. Tolkien',
      pageCount: 310,
      spineColor: Color(0xFF41644A),
    ),
    const Book(
      id: '1984',
      title: '1984',
      author: 'George Orwell',
      pageCount: 328,
      spineColor: Color(0xFF37474F),
    ),
    const Book(
      id: 'sapiens',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      pageCount: 498,
      spineColor: Color(0xFFC28B36),
    ),
    const Book(
      id: 'foundation',
      title: 'Foundation',
      author: 'Isaac Asimov',
      pageCount: 255,
      spineColor: Color(0xFF394867),
    ),
    const Book(
      id: 'it',
      title: 'It',
      author: 'Stephen King',
      pageCount: 1168,
      spineColor: Color(0xFF7D2636),
    ),
    const Book(
      id: 'dracula',
      title: 'Dracula',
      author: 'Bram Stoker',
      pageCount: 418,
      spineColor: Color(0xFF4A2C2A),
    ),
    const Book(
      id: 'frankestein',
      title: 'Frankenstein',
      author: 'Mary Shelley',
      pageCount: 280,
      spineColor: Color(0xFF556B2F),
    ),
    const Book(
      id: 'solaris',
      title: 'Solaris',
      author: 'Stanislaw Lem',
      pageCount: 224,
      spineColor: Color(0xFF315B72),
    ),
    const Book(
      id: 'neuromancer',
      title: 'Neuromancer',
      author: 'William Gibson',
      pageCount: 271,
      spineColor: Color(0xFF5B3A70),
    ),
  ];

  void _reorderBooks({required Book draggedBook, required Book targetBook}) {
    final oldIndex = books.indexWhere((book) => book.id == draggedBook.id);

    var targetIndex = books.indexWhere((book) => book.id == targetBook.id);

    if (oldIndex == -1 || targetIndex == -1 || oldIndex == targetIndex) {
      return;
    }

    setState(() {
      final movedBook = books.removeAt(oldIndex);

      if (oldIndex < targetIndex) {
        targetIndex--;
      }

      books.insert(targetIndex, movedBook);
    });

    _saveBooks();
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
              const SizedBox(height: 20),
              const Text(
                'Oma kirjahylly',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Bookshelf(
                        books: books,
                        onReorder: _reorderBooks,
                        onMoveToEnd: _moveBookToEnd,
                        onBookTap: _openBookDetails,
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
              /*Column(
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
                  TextButton.icon(
                    onPressed: _openManualIsbnSearch,
                    icon: const Icon(Icons.keyboard),
                    label: const Text('Syötä ISBN käsin'),
                  ),
                ],
              ),*/
              /*FilledButton.icon(
                onPressed: _openIsbnSearch,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Skannaa kirja'),
                style: const ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size.fromHeight(56)),
                ),
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  void _moveBookToEnd(Book draggedBook) {
    final oldIndex = books.indexWhere((book) => book.id == draggedBook.id);

    if (oldIndex == -1 || oldIndex == books.length - 1) {
      return;
    }

    setState(() {
      final movedBook = books.removeAt(oldIndex);
      books.add(movedBook);
    });

    _saveBooks();
  }

  @override
  void initState() {
    super.initState();
    _loadBooks();
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

  Future<void> _loadBooks() async {
    final storedBooks = await _storageService.loadBooks();

    if (!mounted) {
      return;
    }

    setState(() {
      if (storedBooks.isNotEmpty) {
        books
          ..clear()
          ..addAll(storedBooks);
      }

      _isLoading = false;
    });
  }

  Future<void> _saveBooks() async {
    await _storageService.saveBooks(books);
  }

  /*Future<void> _openIsbnSearch() async {
    final foundBook = await showDialog<Book>(
      context: context,
      builder: (context) {
        return const IsbnSearchDialog();
      },
    );

    if (foundBook == null || !mounted) {
      return;
    }

    final bookAlreadyExists = books.any((book) => book.id == foundBook.id);

    if (bookAlreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kirja on jo kirjahyllyssä.')),
      );

      return;
    }

    setState(() {
      books.add(foundBook);
    });

    await _saveBooks();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${foundBook.title} lisättiin kirjahyllyyn.')),
    );
  }*/

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

  Future<void> _addFoundBook(Book foundBook) async {
    final bookAlreadyExists = books.any((book) => book.id == foundBook.id);

    if (bookAlreadyExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kirja on jo kirjahyllyssä.')),
      );

      return;
    }

    setState(() {
      books.add(foundBook);
    });

    await _saveBooks();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${foundBook.title} lisättiin kirjahyllyyn.')),
    );
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
}
