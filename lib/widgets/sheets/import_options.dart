import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Reusable import-options bottom sheet.
class ImportOptionsSheet extends StatelessWidget {
  final VoidCallback? onFromDevice;
  final VoidCallback? onFromUrl;
  final VoidCallback? onFromDrive;
  final VoidCallback? onFromDropbox;
  final VoidCallback? onFromFolder;
  final VoidCallback? onFromClipboard;

  const ImportOptionsSheet({
    super.key,
    this.onFromDevice,
    this.onFromUrl,
    this.onFromDrive,
    this.onFromDropbox,
    this.onFromFolder,
    this.onFromClipboard,
  });

  static Future<void> show(BuildContext context, {VoidCallback? onFromDevice}) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => ImportOptionsSheet(onFromDevice: onFromDevice),
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
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: Text('Import Book', style: Theme.of(context).textTheme.titleLarge),
          ),
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('From Device'),
            subtitle: const Text('Browse files on your device'),
            onTap: () {
              Navigator.pop(context);
              onFromDevice?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('From URL'),
            subtitle: const Text('Download from a web link'),
            onTap: () {
              Navigator.pop(context);
              onFromUrl?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open),
            title: const Text('From Folder'),
            subtitle: const Text('Import all books from a directory'),
            onTap: () {
              Navigator.pop(context);
              onFromFolder?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.drive_file_move_outlined),
            title: const Text('Google Drive'),
            onTap: () {
              Navigator.pop(context);
              onFromDrive?.call();
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('Dropbox'),
            onTap: () {
              Navigator.pop(context);
              onFromDropbox?.call();
            },
          ),
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
