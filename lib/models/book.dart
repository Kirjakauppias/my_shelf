import 'package:flutter/material.dart';

class Book {
  final String id;
  final String shelfId;
  final String? isbn;
  final String title;
  final String author;
  final int pageCount;
  final String? coverUrl;
  final Color spineColor;

  const Book({
    required this.id,
    required this.shelfId,
    this.isbn,
    required this.title,
    required this.author,
    required this.pageCount,
    this.coverUrl,
    required this.spineColor,
  });

  double get spineWidth {
    if (pageCount < 200) {
      return 34;
    }

    if (pageCount < 400) {
      return 46;
    }

    return 58;
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
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      shelfId: json['shelfId'] as String? ?? 'default-shelf',
      isbn: json['isbn'] as String?,
      title: json['title'] as String,
      author: json['author'] as String,
      pageCount: json['pageCount'] as int,
      coverUrl: json['coverUrl'] as String?,
      spineColor: Color(json['spineColor'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is Book && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
