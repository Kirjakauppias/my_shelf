import 'package:flutter/material.dart';

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
  final String? coverUrl;
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
    this.coverUrl,
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
    String? coverUrl,
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
      coverUrl: coverUrl ?? this.coverUrl,
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
      'coverUrl': coverUrl,
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

    return Book(
      id: json['id'] as String,
      shelfId: json['shelfId'] as String? ?? 'default-shelf',
      isbn: json['isbn'] as String?,
      title: json['title'] as String,
      author: json['author'] as String,
      pageCount: json['pageCount'] as int,
      coverUrl: json['coverUrl'] as String?,
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
