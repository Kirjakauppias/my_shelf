import 'dart:io';

import 'package:flutter/material.dart';

import '../models/book.dart';
import '../services/custom_cover_service.dart';

class BookCoverImage extends StatefulWidget {
  final Book book;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const BookCoverImage({
    super.key,
    required this.book,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<BookCoverImage> createState() => _BookCoverImageState();
}

class _BookCoverImageState extends State<BookCoverImage> {
  static final CustomCoverService _coverService = CustomCoverService();

  late Future<File?> _customCoverFuture;

  @override
  void initState() {
    super.initState();
    _loadCustomCover();
  }

  @override
  void didUpdateWidget(covariant BookCoverImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.book.customCoverFileName != widget.book.customCoverFileName) {
      _loadCustomCover();
    }
  }

  void _loadCustomCover() {
    _customCoverFuture = _coverService.getCoverFile(
      widget.book.customCoverFileName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: FutureBuilder<File?>(
          future: _customCoverFuture,
          builder: (context, snapshot) {
            final customCoverFile = snapshot.data;

            if (customCoverFile != null) {
              return Image.file(
                customCoverFile,
                width: double.infinity,
                height: double.infinity,
                fit: widget.fit,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return _buildNetworkOrFallbackCover();
                },
              );
            }

            return _buildNetworkOrFallbackCover();
          },
        ),
      ),
    );
  }

  Widget _buildNetworkOrFallbackCover() {
    final coverUrl = widget.book.coverUrl?.trim();

    if (coverUrl != null && coverUrl.isNotEmpty) {
      return Image.network(
        coverUrl,
        width: double.infinity,
        height: double.infinity,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackCover();
        },
      );
    }

    return _buildFallbackCover();
  }

  Widget _buildFallbackCover() {
    return Container(
      color: widget.book.spineColor,
      padding: const EdgeInsets.fromLTRB(9, 12, 9, 9),
      child: Column(
        children: [
          const Icon(
            Icons.auto_stories_outlined,
            color: Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                widget.book.title,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.book.author,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
