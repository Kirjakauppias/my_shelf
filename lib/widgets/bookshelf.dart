import 'package:flutter/material.dart';

import '../models/book.dart';
import 'shelf_board.dart';
import 'shelf_row.dart';

class Bookshelf extends StatelessWidget {
  final List<Book> books;

  final void Function(Book draggedBook) onMoveToEnd;

  final void Function({required Book draggedBook, required Book targetBook})
  onReorder;

  const Bookshelf({
    super.key,
    required this.books,
    required this.onReorder,
    required this.onMoveToEnd,
  });

  static const double bookSpacing = 3;
  static const double endDropTargetWidth = 24;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE6D0B1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF9A7150), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shelfRows = _createShelfRows(
            books: books,
            availableWidth: constraints.maxWidth - endDropTargetWidth,
          );

          return ListView.builder(
            itemCount: shelfRows.length,
            itemBuilder: (context, index) {
              return SizedBox(
                height: 170,
                child: Column(
                  children: [
                    Expanded(
                      child: ShelfRow(
                        books: shelfRows[index],
                        onReorder: onReorder,
                        onMoveToEnd: onMoveToEnd,
                        showEndDropTarget: index == shelfRows.length - 1,
                      ),
                    ),
                    const ShelfBoard(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<List<Book>> _createShelfRows({
    required List<Book> books,
    required double availableWidth,
  }) {
    if (books.isEmpty) {
      return [[]];
    }

    final rows = <List<Book>>[];
    var currentRow = <Book>[];
    var currentRowWidth = 0.0;

    for (final book in books) {
      final requiredWidth = currentRow.isEmpty
          ? book.spineWidth
          : book.spineWidth + bookSpacing;

      final bookFitsCurrentRow =
          currentRowWidth + requiredWidth <= availableWidth;

      if (bookFitsCurrentRow) {
        currentRow.add(book);
        currentRowWidth += requiredWidth;
      } else {
        rows.add(currentRow);

        currentRow = [book];
        currentRowWidth = book.spineWidth;
      }
    }

    if (currentRow.isNotEmpty) {
      rows.add(currentRow);
    }

    return rows;
  }
}
