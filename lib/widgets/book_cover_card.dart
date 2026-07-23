import 'package:flutter/material.dart';

import '../models/book.dart';
import 'reading_status_badge.dart';
import 'book_cover_image.dart';

class BookCoverCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  final bool canReorder;
  final bool showReadingStatusBadge;

  final void Function({required Book draggedBook, required Book targetBook})
  onReorder;

  const BookCoverCard({
    super.key,
    required this.book,
    required this.onTap,
    required this.canReorder,
    required this.showReadingStatusBadge,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!canReorder) {
          return _buildInteractiveCover(context);
        }

        return DragTarget<Book>(
          onWillAcceptWithDetails: (details) {
            return details.data != book;
          },
          onAcceptWithDetails: (details) {
            onReorder(draggedBook: details.data, targetBook: book);
          },
          builder: (context, candidateData, rejectedData) {
            final isDropTarget = candidateData.isNotEmpty;

            return LongPressDraggable<Book>(
              data: book,
              delay: const Duration(milliseconds: 300),
              hapticFeedbackOnStart: true,
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Transform.scale(
                    scale: 1.04,
                    child: _buildCoverVisual(context, isDragging: true),
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.25,
                child: _buildInteractiveCover(context),
              ),
              child: _buildInteractiveCover(
                context,
                isDropTarget: isDropTarget,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInteractiveCover(
    BuildContext context, {
    bool isDropTarget = false,
  }) {
    return Semantics(
      button: true,
      label: '${book.title}, ${book.author}',
      child: Tooltip(
        message: '${book.title}\n${book.author}',
        child: GestureDetector(
          onTap: onTap,
          child: _buildCoverVisual(context, isDropTarget: isDropTarget),
        ),
      ),
    );
  }

  Widget _buildCoverVisual(
    BuildContext context, {
    bool isDragging = false,
    bool isDropTarget = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: book.spineColor,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isDropTarget
              ? Theme.of(context).colorScheme.primary
              : Colors.black26,
          width: isDropTarget ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDragging
                ? const Color(0x55000000)
                : const Color(0x35000000),
            blurRadius: isDragging ? 12 : 5,
            offset: isDragging ? const Offset(5, 7) : const Offset(2, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BookCoverImage(book: book, fit: BoxFit.cover),

          if (showReadingStatusBadge)
            Positioned(
              top: 5,
              right: 5,
              child: ReadingStatusBadge(status: book.readingStatus),
            ),
        ],
      ),
    );
    /*return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: book.spineColor,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: isDropTarget
              ? Theme.of(context).colorScheme.primary
              : Colors.black26,
          width: isDropTarget ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDragging
                ? const Color(0x55000000)
                : const Color(0x35000000),
            blurRadius: isDragging ? 12 : 5,
            offset: isDragging ? const Offset(5, 7) : const Offset(2, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasCover)
            Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallbackCover(context);
              },
            )
          else
            _buildFallbackCover(context),

          if (showReadingStatusBadge)
            Positioned(
              top: 5,
              right: 5,
              child: ReadingStatusBadge(status: book.readingStatus),
            ),
        ],
      ),
    );*/
  }

  /*Widget _buildFallbackCover(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final titleWidth = constraints.maxWidth > 20
            ? constraints.maxWidth - 20
            : 1.0;

        return Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          decoration: BoxDecoration(
            color: book.spineColor,
            border: const Border(
              left: BorderSide(color: Colors.black26, width: 4),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.auto_stories_outlined,
                color: Colors.white70,
                size: 21,
              ),
              const SizedBox(height: 6),

              // Skaalaa pitkän otsikon käytettävissä olevaan tilaan.
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: titleWidth,
                      child: Text(
                        book.title,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 5),
              Text(
                book.author,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }*/
}
