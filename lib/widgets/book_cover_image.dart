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
            if (snapshot.connectionState == ConnectionState.waiting &&
                widget.book.customCoverFileName != null) {
              return _buildLoadingCover();
            }

            final customCoverFile = snapshot.data;

            if (customCoverFile != null) {
              return Image.file(
                customCoverFile,
                width: double.infinity,
                height: double.infinity,
                fit: widget.fit,
                gaplessPlayback: true,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) {
                    return child;
                  }

                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    child: child,
                  );
                },
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

    if (coverUrl == null || coverUrl.isEmpty) {
      return _buildFallbackCover();
    }

    return Image.network(
      coverUrl,
      width: double.infinity,
      height: double.infinity,
      fit: widget.fit,
      gaplessPlayback: true,

      // Kansikuva ilmestyy pehmeästi latauduttuaan.
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }

        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          child: child,
        );
      },

      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        final expectedBytes = loadingProgress.expectedTotalBytes;

        final progress = expectedBytes == null
            ? null
            : loadingProgress.cumulativeBytesLoaded / expectedBytes;

        return _buildLoadingCover(progress: progress);
      },

      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackCover();
      },
    );
  }

  Widget _buildLoadingCover({double? progress}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showLabel =
            constraints.maxWidth >= 90 && constraints.maxHeight >= 125;

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFECE3D8), Color(0xFFDDD0C1), Color(0xFFD2C1AF)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: showLabel ? 25 : 20,
                      color: const Color(0xFF806957),
                    ),
                    if (showLabel) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Ladataan kantta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF6F5B4C),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Positioned(
                left: 10,
                right: 10,
                bottom: 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 2,
                    backgroundColor: const Color(0x33795548),
                    color: const Color(0xFF795548),
                  ),
                ),
              ),

              // Hienovarainen kirjan selkä vasemmassa reunassa.
              const Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0x28000000), Color(0x00000000)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFallbackCover() {
    final baseColor = widget.book.spineColor;
    final useLightText = baseColor.computeLuminance() < 0.42;

    final foregroundColor = useLightText
        ? Colors.white
        : const Color(0xFF2F241E);

    final secondaryColor = foregroundColor.withValues(alpha: 0.74);

    final borderColor = useLightText
        ? Colors.white.withValues(alpha: 0.48)
        : Colors.black.withValues(alpha: 0.28);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 80;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor.withValues(alpha: 0.88),
                baseColor,
                Color.lerp(baseColor, Colors.black, 0.18) ?? baseColor,
              ],
              stops: const [0, 0.56, 1],
            ),
          ),
          child: Stack(
            children: [
              // Kirjan selkä/taitos vasemmassa reunassa.
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                width: isNarrow ? 4 : 6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.30),
                        Colors.black.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                ),
              ),

              // Hillitty koristekehys.
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isNarrow ? 8 : 11,
                    isNarrow ? 8 : 11,
                    isNarrow ? 6 : 9,
                    isNarrow ? 7 : 10,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  isNarrow ? 10 : 14,
                  isNarrow ? 12 : 17,
                  isNarrow ? 8 : 12,
                  isNarrow ? 10 : 14,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: isNarrow ? 18 : 23,
                      color: secondaryColor,
                    ),
                    SizedBox(height: isNarrow ? 5 : 8),
                    Container(
                      width: isNarrow ? 22 : 32,
                      height: 1,
                      color: borderColor,
                    ),
                    SizedBox(height: isNarrow ? 7 : 11),

                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: constraints.maxWidth - (isNarrow ? 20 : 28),
                            child: Text(
                              widget.book.title,
                              maxLines: isNarrow ? 5 : 6,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: foregroundColor,
                                fontSize: isNarrow ? 13 : 16,
                                fontWeight: FontWeight.w700,
                                height: 1.12,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isNarrow ? 5 : 8),
                    Text(
                      widget.book.author,
                      maxLines: isNarrow ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: isNarrow ? 9 : 10.5,
                        fontWeight: FontWeight.w500,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
