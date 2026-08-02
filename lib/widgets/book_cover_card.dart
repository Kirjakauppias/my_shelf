import 'package:flutter/material.dart';

import '../models/book.dart';
import 'book_cover_image.dart';
import 'book_cover_hero.dart';
import 'reading_status_badge.dart';

class BookCoverCard extends StatefulWidget {
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
  State<BookCoverCard> createState() => _BookCoverCardState();
}

class _BookCoverCardState extends State<BookCoverCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }

    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!widget.canReorder) {
          return _buildInteractiveCover(context);
        }

        return DragTarget<Book>(
          onWillAcceptWithDetails: (details) {
            return details.data != widget.book;
          },
          onAcceptWithDetails: (details) {
            widget.onReorder(
              draggedBook: details.data,
              targetBook: widget.book,
            );
          },
          builder: (context, candidateData, rejectedData) {
            final isDropTarget = candidateData.isNotEmpty;

            return LongPressDraggable<Book>(
              data: widget.book,
              delay: const Duration(milliseconds: 300),
              hapticFeedbackOnStart: true,
              onDragStarted: () {
                _setPressed(false);
              },
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Transform.rotate(
                    angle: -0.025,
                    child: Transform.scale(
                      scale: 1.055,
                      child: _buildCoverVisual(context, isDragging: true),
                    ),
                  ),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.18,
                child: _buildCoverVisual(context),
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
      label: '${widget.book.title}, ${widget.book.author}',
      child: Tooltip(
        message:
            '${widget.book.title}\n'
            '${widget.book.author}',
        child: Listener(
          onPointerDown: (_) {
            _setPressed(true);
          },
          onPointerUp: (_) {
            _setPressed(false);
          },
          onPointerCancel: (_) {
            _setPressed(false);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _isPressed ? 0.975 : 1,
              duration: const Duration(milliseconds: 100),
              curve: Curves.easeOut,
              child: _buildCoverVisual(
                context,
                isPressed: _isPressed,
                isDropTarget: isDropTarget,
                useHero: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverVisual(
    BuildContext context, {
    bool isPressed = false,
    bool isDragging = false,
    bool isDropTarget = false,
    bool useHero = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    final Widget coverImage = useHero
        ? BookCoverHero(book: widget.book, fit: BoxFit.cover)
        : BookCoverImage(book: widget.book, fit: BoxFit.cover);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 170),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: widget.book.spineColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isDropTarget ? colorScheme.primary : const Color(0x44000000),
          width: isDropTarget ? 2.5 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: isDragging
                ? const Color(0x60000000)
                : isPressed
                ? const Color(0x24000000)
                : const Color(0x3D000000),
            blurRadius: isDragging
                ? 14
                : isPressed
                ? 2
                : 6,
            offset: isDragging
                ? const Offset(6, 9)
                : isPressed
                ? const Offset(1, 2)
                : const Offset(2, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          coverImage,

          // Kevyt valo- ja varjostuskerros kannen päällä.
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 0.38, 0.72, 1],
                  colors: [
                    Color(0x24FFFFFF),
                    Color(0x08FFFFFF),
                    Color(0x06000000),
                    Color(0x18000000),
                  ],
                ),
              ),
            ),
          ),

          // Hienovarainen kirjan taitos vasemmassa reunassa.
          const Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            width: 4,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0x36000000), Color(0x00000000)],
                  ),
                ),
              ),
            ),
          ),

          // Raahauksen pudotuskohteen korostus.
          if (isDropTarget)
            Positioned.fill(
              child: IgnorePointer(
                child: ColoredBox(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                ),
              ),
            ),

          // Lukutilatunniste pidetään viimeisenä,
          // jotta se näkyy kaikkien kansikerrosten päällä.
          if (widget.showReadingStatusBadge)
            Positioned(
              top: 5,
              right: 5,
              child: ReadingStatusBadge(status: widget.book.readingStatus),
            ),
        ],
      ),
    );
  }
}
