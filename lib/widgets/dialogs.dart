import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// Delete Confirmation Dialog
class DeleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final String itemName;
  final VoidCallback onConfirm;

  const DeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.itemName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.delete_outline, size: 48, color: Colors.red[400]),
          const SizedBox(height: DesignTokens.grid16),
          Text(message),
          const SizedBox(height: DesignTokens.grid8),
          Text(
            '"$itemName"',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[400],
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

// Sync Conflict Dialog
class SyncConflictDialog extends StatelessWidget {
  final String bookTitle;
  final VoidCallback onKeepLocal;
  final VoidCallback onKeepCloud;

  const SyncConflictDialog({
    super.key,
    required this.bookTitle,
    required this.onKeepLocal,
    required this.onKeepCloud,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sync Conflict'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sync_problem, size: 48, color: Colors.orange[400]),
          const SizedBox(height: DesignTokens.grid16),
          Text('A sync conflict was detected for "$bookTitle".'),
          const SizedBox(height: DesignTokens.grid8),
          const Text('Which version would you like to keep?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onKeepLocal();
          },
          child: const Text('Keep Local'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onKeepCloud();
          },
          child: const Text('Keep Cloud'),
        ),
      ],
    );
  }
}

// Duplicate Book Dialog
class DuplicateBookDialog extends StatelessWidget {
  final String bookTitle;
  final VoidCallback onKeepBoth;
  final VoidCallback onReplace;

  const DuplicateBookDialog({
    super.key,
    required this.bookTitle,
    required this.onKeepBoth,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duplicate Book'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.copy, size: 48, color: Colors.amber[400]),
          const SizedBox(height: DesignTokens.grid16),
          Text('"$bookTitle" already exists in your library.'),
          const SizedBox(height: DesignTokens.grid8),
          const Text('What would you like to do?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onKeepBoth();
          },
          child: const Text('Keep Both'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onReplace();
          },
          child: const Text('Replace'),
        ),
      ],
    );
  }
}

// Generic confirmation dialog
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final Color? confirmColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    required this.onConfirm,
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onConfirm();
          },
          style: confirmColor != null
              ? ElevatedButton.styleFrom(backgroundColor: confirmColor)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
