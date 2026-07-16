import 'package:flutter/material.dart';

import '../models/book.dart';

class BookSpine extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookSpine({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Book>(
      // Raahattavan kirjan tiedot.
      data: book,
      delay: const Duration(milliseconds: 300),
      // Pieni värinä, kun pitkä painallus aloittaa raahaamisen.
      hapticFeedbackOnStart: true,

      // Tämä widget näkyy alkuperäisessä paikassa raahaamisen aikana.
      childWhenDragging: Opacity(opacity: 0.25, child: _buildBookSpine()),

      // Tämä widget seuraa käyttäjän sormea tai hiirtä.
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.08,
          child: _buildBookSpine(isDragging: true),
        ),
      ),

      // Kirjan normaali näkymä.
      child: Tooltip(
        message: '${book.title}\n${book.author}',
        child: GestureDetector(onTap: onTap, child: _buildBookSpine()),
      ),
    );
  }

  Widget _buildBookSpine({bool isDragging = false}) {
    return Container(
      width: book.spineWidth,
      height: 132,
      decoration: BoxDecoration(
        color: book.spineColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
        border: Border.all(color: Colors.black26),
        boxShadow: [
          BoxShadow(
            color: isDragging
                ? const Color(0x55000000)
                : const Color(0x33000000),
            blurRadius: isDragging ? 10 : 3,
            offset: isDragging ? const Offset(4, 6) : const Offset(2, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            margin: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.white38),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
              child: RotatedBox(
                quarterTurns: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    book.title,
                    maxLines: 1,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 8,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
