import 'package:flutter/material.dart';

import '../models/book.dart';
import 'book_cover_image.dart';

class BookCoverHero extends StatelessWidget {
  final Book book;
  final double? width;
  final double? height;
  final BoxFit fit;

  const BookCoverHero({
    super.key,
    required this.book,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  static String tagFor(Book book) {
    return 'book-cover-${book.id}';
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tagFor(book),

      // Mahdollistaa Hero-animaation myös esimerkiksi
      // iOS:n takaisinpyyhkäisyn yhteydessä.
      transitionOnUserGestures: true,

      child: Material(
        type: MaterialType.transparency,
        child: BookCoverImage(
          book: book,
          width: width,
          height: height,
          fit: fit,

          // Sama pyöristys sekä hyllyssä että tietosivulla
          // tekee animaatiosta yhtenäisemmän.
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
