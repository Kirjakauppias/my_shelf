import 'package:flutter/material.dart';

import '../models/book.dart';

class ReadingStatusBadge extends StatelessWidget {
  final ReadingStatus status;

  const ReadingStatusBadge({super.key, required this.status});

  IconData get _icon {
    switch (status) {
      case ReadingStatus.unread:
        return Icons.radio_button_unchecked;

      case ReadingStatus.reading:
        return Icons.menu_book_outlined;

      case ReadingStatus.read:
        return Icons.check;
    }
  }

  Color _iconColor(BuildContext context) {
    switch (status) {
      case ReadingStatus.unread:
        return Theme.of(context).colorScheme.onSurfaceVariant;

      case ReadingStatus.reading:
        return const Color(0xFFB85C20);

      case ReadingStatus.read:
        return const Color(0xFF2E7D32);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: status.label,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Icon(_icon, size: 15, color: _iconColor(context)),
      ),
    );
  }
}
