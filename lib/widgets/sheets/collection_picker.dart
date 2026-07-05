import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../models/collection.dart';

/// Reusable collection picker bottom sheet.
class CollectionPickerSheet extends StatelessWidget {
  final List<Collection> collections;
  final String? bookId;
  final ValueChanged<String>? onPicked;

  const CollectionPickerSheet({
    super.key,
    required this.collections,
    required this.bookId,
    this.onPicked,
  });

  static Future<void> show(
    BuildContext context, {
    required List<Collection> collections,
    required String? bookId,
    ValueChanged<String>? onPicked,
  }) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => CollectionPickerSheet(
        collections: collections,
        bookId: bookId,
        onPicked: onPicked,
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
          Padding(
            padding: const EdgeInsets.all(DesignTokens.grid24),
            child: Text('Add to Collection', style: Theme.of(context).textTheme.titleLarge),
          ),
          ...collections.map((c) => ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(c.name),
                trailing: Text('${c.bookCount}', style: Theme.of(context).textTheme.bodySmall),
                onTap: () {
                  Navigator.pop(context);
                  onPicked?.call(c.id);
                },
              )),
          const SizedBox(height: DesignTokens.grid16),
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
