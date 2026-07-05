import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../models/book.dart';
import '../utils/helpers.dart';

// Book Card (Grid)
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onFavorite;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onLongPress,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _coverColor(book.title),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(DesignTokens.radiusLg),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 40,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                    if (book.isFavorite)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.red[400],
                          size: 20,
                        ),
                      ),
                    if (book.progress > 0 && book.progress < 1.0)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(DesignTokens.radiusLg),
                          ),
                          child: LinearProgressIndicator(
                            value: book.progress,
                            backgroundColor: Colors.black26,
                            color: Colors.white,
                            minHeight: 3,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(DesignTokens.grid12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _coverColor(String title) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6584),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFFEAA7),
      const Color(0xFFDDA0DD),
      const Color(0xFF98D8C8),
      const Color(0xFFF7DC6F),
    ];
    return colors[title.length % colors.length];
  }
}

// Progress Card
class ProgressCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;

  const ProgressCard({
    super.key,
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignTokens.grid16,
        vertical: DesignTokens.grid8,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.grid16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: _coverColor(book.title),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white.withAlpha(180),
                  size: 28,
                ),
              ),
              const SizedBox(width: DesignTokens.grid16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: DesignTokens.grid12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: book.progress,
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.grid12),
                        Text(
                          Helpers.readingProgressText(book.currentPage, book.totalPages),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _coverColor(String title) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6584),
      const Color(0xFF45B7D1),
      const Color(0xFF96CEB4),
      const Color(0xFFFFEAA7),
      const Color(0xFFDDA0DD),
    ];
    return colors[title.length % colors.length];
  }
}

// Stats Card
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const StatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statColor = color ?? theme.colorScheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.grid16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.grid8),
              decoration: BoxDecoration(
                color: statColor.withAlpha(20),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Icon(icon, color: statColor, size: 24),
            ),
            const SizedBox(height: DesignTokens.grid16),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statColor,
              ),
            ),
            const SizedBox(height: DesignTokens.grid4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Book List Tile (for List view)
class BookListTile extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const BookListTile({
    super.key,
    required this.book,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      leading: Container(
        width: 40,
        height: 56,
        decoration: BoxDecoration(
          color: _coverColor(book.title),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        child: Icon(
          Icons.menu_book_rounded,
          color: Colors.white.withAlpha(180),
          size: 20,
        ),
      ),
      title: Text(
        book.title,
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.author,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withAlpha(150),
            ),
          ),
          if (book.progress > 0) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: book.progress,
                      minHeight: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  Helpers.readingProgressText(book.currentPage, book.totalPages),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: book.isFavorite
          ? Icon(Icons.favorite, color: Colors.red[400], size: 20)
          : null,
    );
  }

  Color _coverColor(String title) {
    final colors = [
      const Color(0xFF6C63FF), const Color(0xFFFF6584),
      const Color(0xFF45B7D1), const Color(0xFF96CEB4),
      const Color(0xFFFFEAA7), const Color(0xFFDDA0DD),
    ];
    return colors[title.length % colors.length];
  }
}
