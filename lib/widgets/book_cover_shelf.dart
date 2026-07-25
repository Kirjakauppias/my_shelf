import 'package:flutter/material.dart';

import '../models/book.dart';
import 'book_cover_card.dart';
import 'shelf_board.dart';

class BookCoverShelf extends StatelessWidget {
  final List<Book> books;
  final void Function(Book book) onBookTap;

  final bool canReorder;
  final bool showReadingStatusBadges;

  final void Function(Book draggedBook) onMoveToEnd;

  final void Function({required Book draggedBook, required Book targetBook})
  onReorder;

  const BookCoverShelf({
    super.key,
    required this.books,
    required this.onBookTap,
    required this.canReorder,
    required this.showReadingStatusBadges,
    required this.onMoveToEnd,
    required this.onReorder,
  });

  static const double _horizontalSpacing = 8;
  static const double _coverAspectRatio = 0.67;
  static const double _rowSpacing = 16;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEBD8BC), Color(0xFFDFC19B), Color(0xFFD3AD80)],
          stops: [0, 0.55, 1],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF805033), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Color(0x22FFFFFF),
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          // Layout voi saada hetkellisesti nollan levyisen tilan
          // esimerkiksi näkymää vaihdettaessa.
          if (!availableWidth.isFinite || availableWidth <= 0) {
            return const SizedBox.shrink();
          }

          final columnCount = _columnCount(availableWidth);

          final totalSpacing = (columnCount - 1) * _horizontalSpacing;

          final usableCoverWidth = availableWidth - totalSpacing;

          if (usableCoverWidth <= 0) {
            return const SizedBox.shrink();
          }

          final coverWidth = usableCoverWidth / columnCount;

          if (coverWidth <= 0) {
            return const SizedBox.shrink();
          }

          final coverHeight = coverWidth / _coverAspectRatio;

          final rows = _createRows(books, columnCount);

          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 8),
            itemCount: rows.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: _rowSpacing);
            },
            itemBuilder: (context, rowIndex) {
              final rowBooks = rows[rowIndex];
              final isLastRow = rowIndex == rows.length - 1;

              return Column(
                children: [
                  SizedBox(
                    height: coverHeight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        for (var index = 0; index < columnCount; index++) ...[
                          Expanded(
                            child: index < rowBooks.length
                                ? BookCoverCard(
                                    book: rowBooks[index],
                                    canReorder: canReorder,
                                    showReadingStatusBadge:
                                        showReadingStatusBadges,
                                    onTap: () {
                                      onBookTap(rowBooks[index]);
                                    },
                                    onReorder: onReorder,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          if (index < columnCount - 1)
                            const SizedBox(width: _horizontalSpacing),
                        ],
                      ],
                    ),
                  ),

                  if (isLastRow && canReorder)
                    DragTarget<Book>(
                      onWillAcceptWithDetails: (details) {
                        return true;
                      },
                      onAcceptWithDetails: (details) {
                        onMoveToEnd(details.data);
                      },
                      builder: (context, candidateData, rejectedData) {
                        return ShelfBoard(
                          highlighted: candidateData.isNotEmpty,
                        );
                      },
                    )
                  else
                    const ShelfBoard(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  int _columnCount(double width) {
    if (width >= 700) {
      return 7;
    }

    if (width >= 560) {
      return 6;
    }

    if (width >= 430) {
      return 5;
    }

    if (width >= 330) {
      return 4;
    }

    return 3;
  }

  List<List<Book>> _createRows(List<Book> books, int columnCount) {
    final rows = <List<Book>>[];

    for (var index = 0; index < books.length; index += columnCount) {
      final endIndex = index + columnCount < books.length
          ? index + columnCount
          : books.length;

      rows.add(books.sublist(index, endIndex));
    }

    return rows;
  }
}
