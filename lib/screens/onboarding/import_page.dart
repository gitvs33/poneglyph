import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/design_tokens.dart';
import '../../providers/library_provider.dart';
import '../../models/book.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  bool _isImporting = false;

  Future<void> _importFromDevice() async {
    try {
      final xFiles = await openFiles(
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'eBooks',
            extensions: ['epub', 'pdf', 'mobi'],
          ),
        ],
      );

      if (xFiles.isEmpty) return;

      if (!mounted) return;
      setState(() => _isImporting = true);

      final library = context.read<LibraryProvider>();

      // Get app documents directory for local file storage
      final docsDir = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${docsDir.path}/books');
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      int added = 0;

      for (final xf in xFiles) {
        final path = xf.path;
        if (path.isEmpty) continue;

        final name = xf.name;
        final title = name.replaceAll(RegExp(r'\.[^.]+$'), '');

        // Copy file to local storage (content:// URIs from file_selector
        // cannot be read via File() later — only via XFile.readAsBytes()).
        final bytes = await xf.readAsBytes();
        final localPath = '${booksDir.path}/${DateTime.now().millisecondsSinceEpoch}_$name';
        final localFile = File(localPath);
        await localFile.writeAsBytes(bytes);

        // Detect format by magic bytes — more reliable than extension.
        BookFormat format = BookFormat.epub;
        if (bytes.length >= 4) {
          if (bytes[0] == 0x25 && bytes[1] == 0x50 &&
              bytes[2] == 0x44 && bytes[3] == 0x46) {
            format = BookFormat.pdf;
          } else if (bytes.length >= 8) {
            if ((bytes[0] == 0x42 && bytes[1] == 0x4F &&
                 bytes[2] == 0x4F && bytes[3] == 0x4B &&
                 bytes[4] == 0x4D && bytes[5] == 0x4F &&
                 bytes[6] == 0x42 && bytes[7] == 0x49) ||
                (bytes[0] == 0x54 && bytes[1] == 0x45 &&
                 bytes[2] == 0x78 && bytes[3] == 0x74 &&
                 bytes[4] == 0x52 && bytes[5] == 0x45 &&
                 bytes[6] == 0x41 && bytes[7] == 0x64)) {
              format = BookFormat.mobi;
            }
          }
        }

        await library.addBook(Book(
          id: 'onboard_${DateTime.now().millisecondsSinceEpoch}_$added',
          title: title,
          author: 'Unknown',
          format: format,
          source: BookSource.device,
          filePath: localPath,
          totalPages: 300,
        ));
        added++;
      }

      if (!mounted) return;
      setState(() => _isImporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$added book(s) imported')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isImporting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Import error: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final importOptions = [
      (Icons.phone_android, 'Device', 'Import from storage'),
      (Icons.link, 'URL', 'Download from link'),
      (Icons.drive_file_move_outlined, 'Google Drive', 'Sync from Drive'),
      (Icons.cloud_upload_outlined, 'Dropbox', 'Import from Dropbox'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(DesignTokens.grid32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
            ),
            child: Icon(
              Icons.file_download_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: DesignTokens.grid32),
          Text(
            'Import Your Books',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: DesignTokens.grid12),
          Text(
            'Choose how you want to add books to your library.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withAlpha(150),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.grid32),
          ...importOptions.map((option) {
            final isDevice = option.$2 == 'Device';
            return Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.grid12),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                ),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                    child: Icon(option.$1, color: theme.colorScheme.primary, size: 20),
                  ),
                  title: Text(option.$2, style: theme.textTheme.titleMedium),
                  subtitle: Text(option.$3, style: theme.textTheme.bodySmall),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: isDevice
                      ? (_isImporting ? null : _importFromDevice)
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
