import 'package:flutter/material.dart';

import '../models/book.dart';
import 'book_spine.dart';

class ShelfRow extends StatelessWidget {
  final List<Book> books;

  final void Function({required Book draggedBook, required Book targetBook})
  onReorder;

  final void Function(Book draggedBook) onMoveToEnd;

  final bool showEndDropTarget;

  const ShelfRow({
    super.key,
    required this.books,
    required this.onReorder,
    required this.onMoveToEnd,
    required this.showEndDropTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final book in books) ...[
            DragTarget<Book>(
              onWillAcceptWithDetails: (details) {
                return details.data.id != book.id;
              },
              onAcceptWithDetails: (details) {
                onReorder(draggedBook: details.data, targetBook: book);
              },
              builder: (context, candidateData, rejectedData) {
                final isTargeted = candidateData.isNotEmpty;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(horizontal: isTargeted ? 5 : 0),
                  decoration: BoxDecoration(
                    color: isTargeted
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: BookSpine(key: ValueKey(book.id), book: book),
                );
              },
            ),
            const SizedBox(width: 3),
          ],

          if (showEndDropTarget)
            DragTarget<Book>(
              onWillAcceptWithDetails: (details) {
                return books.isEmpty || details.data.id != books.last.id;
              },
              onAcceptWithDetails: (details) {
                onMoveToEnd(details.data);
              },
              builder: (context, candidateData, rejectedData) {
                final isTargeted = candidateData.isNotEmpty;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: isTargeted ? 34 : 18,
                  height: 132,
                  margin: const EdgeInsets.only(left: 2),
                  decoration: BoxDecoration(
                    color: isTargeted
                        ? Colors.white.withValues(alpha: 0.35)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: isTargeted
                        ? Border.all(color: Colors.white70, width: 2)
                        : null,
                  ),
                  child: isTargeted
                      ? const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                );
              },
            ),
        ],
      ),
    );
  }
}
