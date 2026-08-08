import 'package:flutter/material.dart';
import 'book_binding.dart';

enum ReadingStatus { unread, reading, read }

extension ReadingStatusExtension on ReadingStatus {
  String get label {
    switch (this) {
      case ReadingStatus.unread:
        return 'Lukematta';

      case ReadingStatus.reading:
        return 'Kesken';

      case ReadingStatus.read:
        return 'Luettu';
    }
  }
}

class Book {
  final String id;
  final String shelfId;
  final String? isbn;
  final String title;
  final String author;
  final int pageCount;

  final int? publicationYear;
  final String? publisher;
  final BookBinding binding;

  /// ISBN-haun tai muun verkkopalvelun palauttama kansikuva.
  final String? coverUrl;

  /// Käyttäjän itse valitseman paikallisen kansikuvan tiedostonimi.
  ///
  /// Malliin tallennetaan vain tiedostonimi, ei absoluuttista
  /// tiedostopolkua. Esimerkiksi: `book-12345.jpg`.
  final String? customCoverFileName;

  final Color spineColor;
  final ReadingStatus readingStatus;
  final int? rating;
  final String notes;

  const Book({
    required this.id,
    required this.shelfId,
    this.isbn,
    required this.title,
    required this.author,
    required this.pageCount,
    this.publicationYear,
    this.publisher,
    this.binding = BookBinding.unknown,
    this.coverUrl,
    this.customCoverFileName,
    required this.spineColor,
    this.readingStatus = ReadingStatus.unread,
    this.rating,
    this.notes = '',
  }) : assert(
         rating == null || (rating >= 1 && rating <= 5),
         'Arvosanan täytyy olla välillä 1–5.',
       );

  double get spineWidth {
    if (pageCount < 200) {
      return 34;
    }

    if (pageCount < 400) {
      return 46;
    }

    return 58;
  }

  Book copyWith({
    String? id,
    String? shelfId,
    String? isbn,
    String? title,
    String? author,
    int? pageCount,
    int? publicationYear,
    bool clearPublicationYear = false,
    String? publisher,
    bool clearPublisher = false,
    BookBinding? binding,
    String? coverUrl,
    String? customCoverFileName,
    bool clearCustomCover = false,
    Color? spineColor,
    ReadingStatus? readingStatus,
    int? rating,
    bool clearRating = false,
    String? notes,
  }) {
    return Book(
      id: id ?? this.id,
      shelfId: shelfId ?? this.shelfId,
      isbn: isbn ?? this.isbn,
      title: title ?? this.title,
      author: author ?? this.author,
      pageCount: pageCount ?? this.pageCount,
      publicationYear: clearPublicationYear
          ? null
          : publicationYear ?? this.publicationYear,
      publisher: clearPublisher ? null : publisher ?? this.publisher,
      binding: binding ?? this.binding,
      coverUrl: coverUrl ?? this.coverUrl,
      customCoverFileName: clearCustomCover
          ? null
          : customCoverFileName ?? this.customCoverFileName,
      spineColor: spineColor ?? this.spineColor,
      readingStatus: readingStatus ?? this.readingStatus,
      rating: clearRating ? null : rating ?? this.rating,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shelfId': shelfId,
      'isbn': isbn,
      'title': title,
      'author': author,
      'pageCount': pageCount,
      'publicationYear': publicationYear,
      'publisher': publisher,
      'binding': binding.name,
      'coverUrl': coverUrl,
      'customCoverFileName': customCoverFileName,
      'spineColor': spineColor.toARGB32(),
      'readingStatus': readingStatus.name,
      'rating': rating,
      'notes': notes,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    final readingStatusName = json['readingStatus'] as String?;

    final readingStatus = ReadingStatus.values.firstWhere(
      (status) => status.name == readingStatusName,
      orElse: () => ReadingStatus.unread,
    );

    final ratingValue = json['rating'];

    if (ratingValue != null &&
        (ratingValue is! int || ratingValue < 1 || ratingValue > 5)) {
      throw const FormatException('Kirjan arvosanan täytyy olla välillä 1–5.');
    }

    final customCoverValue = json['customCoverFileName'];

    if (customCoverValue != null && customCoverValue is! String) {
      throw const FormatException(
        'Oman kansikuvan tiedostonimen täytyy olla merkkijono.',
      );
    }

    final customCoverFileName =
        customCoverValue is String && customCoverValue.trim().isNotEmpty
        ? customCoverValue.trim()
        : null;

    final publicationYearValue = json['publicationYear'];

    if (publicationYearValue != null &&
        (publicationYearValue is! int ||
            publicationYearValue < 1 ||
            publicationYearValue > 9999)) {
      throw const FormatException(
        'Kirjan julkaisuvuoden täytyy olla välillä 1–9999.',
      );
    }

    final publisherValue = json['publisher'];

    if (publisherValue != null && publisherValue is! String) {
      throw const FormatException('Kirjan kustantajan täytyy olla merkkijono.');
    }

    final publisher =
        publisherValue is String && publisherValue.trim().isNotEmpty
        ? publisherValue.trim()
        : null;

    final bindingName = json['binding'];

    if (bindingName != null && bindingName is! String) {
      throw const FormatException('Kirjan sidosasun täytyy olla merkkijono.');
    }

    final binding = BookBinding.values.firstWhere(
      (value) => value.name == bindingName,
      orElse: () => BookBinding.unknown,
    );

    return Book(
      id: json['id'] as String,
      shelfId: json['shelfId'] as String? ?? 'default-shelf',
      isbn: json['isbn'] as String?,
      title: json['title'] as String,
      author: json['author'] as String,
      pageCount: json['pageCount'] as int,
      publicationYear: publicationYearValue as int?,
      publisher: publisher,
      binding: binding,
      coverUrl: json['coverUrl'] as String?,
      customCoverFileName: customCoverFileName,
      spineColor: Color(json['spineColor'] as int),
      readingStatus: readingStatus,
      rating: ratingValue as int?,
      notes: json['notes'] as String? ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
