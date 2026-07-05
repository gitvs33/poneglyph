import 'package:flutter/material.dart';
import '../../models/book.dart';

/// Reusable context menu for a book. Shows favorite, add-to-collection,
/// share, and delete options.
class BookContextMenuSheet extends StatelessWidget {
  final Book book;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onAddToCollection;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const BookContextMenuSheet({
    super.key,
    required this.book,
    this.onToggleFavorite,
    this.onAddToCollection,
    this.onShare,
    this.onDelete,
  });

  /// Convenience method to show this sheet.
  static Future<void> show(
    BuildContext context, {
    required Book book,
    VoidCallback? onToggleFavorite,
    VoidCallback? onAddToCollection,
    VoidCallback? onShare,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => BookContextMenuSheet(
        book: book,
        onToggleFavorite: onToggleFavorite,
        onAddToCollection: onAddToCollection,
        onShare: onShare,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dragHandle(context),
          ListTile(
            leading: Icon(book.isFavorite ? Icons.favorite : Icons.favorite_border),
            title: Text(book.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
            onTap: () {
              Navigator.pop(context);
              onToggleFavorite?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: const Text('Add to Collection'),
            onTap: () {
              Navigator.pop(context);
              onAddToCollection?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              Navigator.pop(context);
              onShare?.call();
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red[400]),
            title: Text('Delete', style: TextStyle(color: Colors.red[400])),
            onTap: () {
              Navigator.pop(context);
              onDelete?.call();
            },
          ),
        ],
      ),
    );
  }

  static Widget _dragHandle(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodySmall?.color?.withAlpha(60),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
