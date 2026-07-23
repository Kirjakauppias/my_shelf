import 'package:flutter/material.dart';

import '../models/book.dart';
import 'book_cover_card.dart';

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

  static const double _horizontalSpacing = 10;
  static const double _coverAspectRatio = 0.66;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE2C69F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF8A5634), width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28000000),
            blurRadius: 9,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          // Estää negatiiviset mitat väliaikaisissa layout-tilanteissa.
          if (!availableWidth.isFinite || availableWidth <= 0) {
            return const SizedBox.shrink();
          }

          final columnCount = _columnCount(availableWidth);

          final totalSpacing = (columnCount - 1) * _horizontalSpacing;

          final coverWidth = (availableWidth - totalSpacing) / columnCount;

          if (coverWidth <= 0) {
            return const SizedBox.shrink();
          }

          final coverHeight = coverWidth / _coverAspectRatio;

          final rows = _createRows(books, columnCount);

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: rows.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 14);
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
                        return _buildShelfBoard(
                          highlighted: candidateData.isNotEmpty,
                        );
                      },
                    )
                  else
                    _buildShelfBoard(),
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
      final endIndex = (index + columnCount < books.length)
          ? index + columnCount
          : books.length;

      rows.add(books.sublist(index, endIndex));
    }

    return rows;
  }

  Widget _buildShelfBoard({bool highlighted = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 13,
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFB96B3E) : const Color(0xFF744126),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(3),
          bottomRight: Radius.circular(3),
        ),
        border: Border.all(
          color: highlighted
              ? const Color(0xFFFFD2A9)
              : const Color(0xFF4A2716),
          width: highlighted ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 3,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
