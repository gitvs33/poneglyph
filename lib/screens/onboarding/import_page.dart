import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
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
      int added = 0;

      for (final xf in xFiles) {
        final path = xf.path;
        if (path.isEmpty) continue;

        final name = xf.name;
        final ext = name.contains('.')
            ? name.split('.').last.toLowerCase()
            : 'epub';

        BookFormat format = BookFormat.epub;
        if (ext == 'pdf') format = BookFormat.pdf;
        if (ext == 'mobi') format = BookFormat.mobi;

        final title = name.replaceAll(RegExp(r'\.[^.]+$'), '');

        await library.addBook(Book(
          id: 'onboard_${DateTime.now().millisecondsSinceEpoch}_$added',
          title: title,
          author: 'Unknown',
          format: format,
          source: BookSource.device,
          filePath: path,
          totalPages: 0,
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
