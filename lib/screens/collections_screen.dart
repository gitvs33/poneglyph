import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/design_tokens.dart';
import '../../providers/collections_provider.dart';
import '../../providers/library_provider.dart';
import '../../models/collection.dart';
import '../../widgets/dialogs.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionsProvider>().initialize();
    });
  }

  void _showCreateDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Collection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Collection name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<CollectionsProvider>().createCollection(
                  controller.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(Collection collection) {
    final controller = TextEditingController(text: collection.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Collection'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'New name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<CollectionsProvider>().renameCollection(
                  collection.id,
                  controller.text.trim(),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<CollectionsProvider>(
      builder: (context, collections, _) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.grid24,
                    DesignTokens.grid16,
                    DesignTokens.grid24,
                    DesignTokens.grid8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Collections', style: theme.textTheme.displaySmall),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _showCreateDialog,
                      ),
                    ],
                  ),
                ),
                if (collections.collections.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open, size: 56,
                              color: theme.textTheme.bodySmall?.color?.withAlpha(80)),
                          const SizedBox(height: 16),
                          Text('No collections yet',
                              style: theme.textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Text('Create your first collection to organize books',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                              )),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _showCreateDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Create Collection'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.all(DesignTokens.grid16),
                      itemCount: collections.collections.length,
                      onReorder: collections.reorderCollections,
                      itemBuilder: (context, index) {
                        final collection = collections.collections[index];
                        return Card(
                          key: ValueKey(collection.id),
                          margin: const EdgeInsets.only(bottom: DesignTokens.grid12),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                              ),
                              child: Icon(
                                _collectionIcon(collection.icon),
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            title: Text(collection.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                )),
                            subtitle: Text('${collection.bookCount} books'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () => _showRenameDialog(collection),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, size: 18,
                                      color: Colors.red[400]),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (ctx) => DeleteDialog(
                                      title: 'Delete Collection',
                                      message: 'Are you sure you want to delete this collection?',
                                      itemName: collection.name,
                                      onConfirm: () {
                                        context.read<CollectionsProvider>()
                                            .deleteCollection(collection.id);
                                      },
                                    ),
                                  ),
                                ),
                                const Icon(Icons.drag_handle),
                              ],
                            ),
                            onTap: () {
                              // Show books in this collection
                              _showCollectionBooks(context, collection);
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _collectionIcon(String? icon) {
    switch (icon) {
      case 'star': return Icons.star;
      case 'book': return Icons.book;
      case 'rocket': return Icons.rocket_launch;
      case 'playlist_add': return Icons.playlist_add;
      default: return Icons.folder;
    }
  }

  void _showCollectionBooks(BuildContext context, Collection collection) {
    final library = context.read<LibraryProvider>();
    final books = library.books.where((b) => collection.bookIds.contains(b.id)).toList();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              width: 40, height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(DesignTokens.grid24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(collection.name, style: theme.textTheme.titleLarge),
                  Text('${books.length} books', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (books.isEmpty)
              const Expanded(
                child: Center(child: Text('No books in this collection')),
              )
            else
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemCount: books.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return ListTile(
                      leading: Container(
                        width: 36, height: 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.menu_book, size: 18),
                      ),
                      title: Text(book.title, style: const TextStyle(fontSize: 14)),
                      subtitle: Text(book.author, style: const TextStyle(fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 18),
                        onPressed: () {
                          context.read<CollectionsProvider>()
                              .removeBookFromCollection(collection.id, book.id);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
