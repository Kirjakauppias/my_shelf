import 'package:flutter/material.dart';

import '../models/book.dart';
import 'book_cover_card.dart';
import 'shelf_board.dart';

class BookCoverShelf extends StatelessWidget {
  final List<Book> books;
  final void Function(Book book) onBookTap;

  final bool canReorder;
  final bool showReadingStatusBadges;
  final bool isFullscreen;

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
    this.isFullscreen = false,
  });

  static const double _coverAspectRatio = 0.67;

  double _horizontalSpacing(Orientation orientation) {
    if (orientation == Orientation.landscape) {
      return isFullscreen ? 9 : 7;
    }

    return isFullscreen ? 10 : 8;
  }

  double _rowSpacing(Orientation orientation) {
    if (orientation == Orientation.landscape) {
      return isFullscreen ? 16 : 12;
    }

    return isFullscreen ? 20 : 16;
  }

  EdgeInsets _shelfPadding(Orientation orientation) {
    if (orientation == Orientation.landscape) {
      return isFullscreen
          ? const EdgeInsets.fromLTRB(7, 8, 7, 8)
          : const EdgeInsets.fromLTRB(8, 8, 8, 8);
    }

    return isFullscreen
        ? const EdgeInsets.fromLTRB(8, 10, 8, 10)
        : const EdgeInsets.fromLTRB(10, 12, 10, 10);
  }

  double _targetCoverWidth(Orientation orientation) {
    if (orientation == Orientation.landscape) {
      return isFullscreen ? 102 : 84;
    }

    return isFullscreen ? 96 : 78;
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return Container(
      width: double.infinity,
      padding: _shelfPadding(orientation),
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

          final horizontalSpacing = _horizontalSpacing(orientation);

          final rowSpacing = _rowSpacing(orientation);

          final columnCount = _columnCount(availableWidth, orientation);

          final totalSpacing = (columnCount - 1) * horizontalSpacing;

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
              return SizedBox(height: rowSpacing);
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
                            SizedBox(width: horizontalSpacing),
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

  int _columnCount(double width, Orientation orientation) {
    final horizontalSpacing = _horizontalSpacing(orientation);

    final targetCoverWidth = _targetCoverWidth(orientation);

    final calculatedColumnCount =
        ((width + horizontalSpacing) / (targetCoverWidth + horizontalSpacing))
            .floor();

    final minimumColumnCount = switch (orientation) {
      Orientation.portrait => width >= 300 ? 3 : 2,
      Orientation.landscape => width >= 420 ? 4 : 3,
    };

    final maximumColumnCount = switch (orientation) {
      Orientation.portrait => isFullscreen ? 7 : 8,
      Orientation.landscape => isFullscreen ? 10 : 12,
    };

    return calculatedColumnCount
        .clamp(minimumColumnCount, maximumColumnCount)
        .toInt();
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
