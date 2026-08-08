import 'package:flutter/material.dart';

import 'shelf_board.dart';

class ShelfEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  const ShelfEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEBD8BC), Color(0xFFDFC19B), Color(0xFFD3AD80)],
          stops: [0, 0.55, 1],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF805033), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final minimumHeight = constraints.hasBoundedHeight
              ? (constraints.maxHeight - 32).clamp(0.0, double.infinity)
              : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minimumHeight),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.88),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF8A5A3B)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x28000000),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Icon(icon, size: 31, color: colorScheme.primary),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 360),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF8A5A3B),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x28000000),
                            blurRadius: 6,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4A2919),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                          if (actionLabel != null && onAction != null) ...[
                            const SizedBox(height: 16),
                            FilledButton.tonalIcon(
                              onPressed: onAction,
                              icon: Icon(actionIcon ?? Icons.arrow_forward),
                              label: Text(actionLabel!),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const SizedBox(width: 260, child: ShelfBoard()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
