import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/design_tokens.dart';
import '../../providers/library_provider.dart';
import '../../models/book.dart';

/// Merged Import & Backup screen with REAL file importing.
///
/// "From Device" opens the native file picker for EPUB/PDF/MOBI files.
/// "From URL" shows a dialog to paste a download link.
/// Other sources show "Coming soon".
class ImportBackupScreen extends StatefulWidget {
  const ImportBackupScreen({super.key});

  @override
  State<ImportBackupScreen> createState() => _ImportBackupScreenState();
}

class _ImportBackupScreenState extends State<ImportBackupScreen> {
  bool _isImporting = false;

  Future<void> _importFromDevice() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub', 'pdf', 'mobi'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) return;

      setState(() => _isImporting = true);
      final library = context.read<LibraryProvider>();
      int added = 0;

      for (final file in result.files) {
        if (file.path == null) continue;

        final filePath = file.path!;
        final fileName = file.name;
        final ext = (file.extension ?? '').toLowerCase();

        // Determine format from extension
        BookFormat format;
        switch (ext) {
          case 'epub':
            format = BookFormat.epub;
            break;
          case 'pdf':
            format = BookFormat.pdf;
            break;
          case 'mobi':
            format = BookFormat.mobi;
            break;
          default:
            continue; // skip unknown
        }

        // Extract title from filename (strip extension)
        final title = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');

        // Create a unique ID from path + timestamp
        final id = 'book_${DateTime.now().millisecondsSinceEpoch}_$added';

        final book = Book(
          id: id,
          title: title,
          author: 'Unknown',
          format: format,
          source: BookSource.device,
          filePath: filePath,
          totalPages: 0,
        );

        await library.addBook(book);
        added++;
      }

      setState(() => _isImporting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              added == 1
                  ? 'Imported 1 book'
                  : 'Imported $added books',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _importFromUrl() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import from URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com/book.epub',
            labelText: 'Book URL',
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (url == null || url.isEmpty) return;

    // Extract filename from URL for the title
    final uri = Uri.tryParse(url);
    final pathSegments = uri?.pathSegments ?? [];
    final fileName = pathSegments.isNotEmpty ? pathSegments.last : 'book';
    final title = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');

    // Guess format from extension
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'epub';
    BookFormat format;
    switch (ext) {
      case 'pdf':
        format = BookFormat.pdf;
        break;
      case 'mobi':
        format = BookFormat.mobi;
        break;
      default:
        format = BookFormat.epub;
    }

    final id = 'book_url_${DateTime.now().millisecondsSinceEpoch}';
    final book = Book(
      id: id,
      title: title,
      author: 'Unknown',
      format: format,
      source: BookSource.url,
      filePath: url,
      description: 'Imported from URL: $url',
      totalPages: 0,
    );

    await context.read<LibraryProvider>().addBook(book);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "$title" to library'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _comingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature — coming in next update'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const importOptions = [
      _ImportOptionData(
        icon: Icons.phone_android,
        title: 'From Device',
        subtitle: 'Browse EPUB, PDF, MOBI files',
        color: Color(0xFF6C63FF),
      ),
      _ImportOptionData(
        icon: Icons.link,
        title: 'From URL',
        subtitle: 'Download from a web link',
        color: Color(0xFF45B7D1),
      ),
      _ImportOptionData(
        icon: Icons.folder_zip_outlined,
        title: 'From ZIP',
        subtitle: 'Import compressed archives',
        color: Color(0xFFFFAA44),
      ),
      _ImportOptionData(
        icon: Icons.folder_open,
        title: 'From Folder',
        subtitle: 'Import an entire folder',
        color: Color(0xFF81C784),
      ),
      _ImportOptionData(
        icon: Icons.drive_file_move_outlined,
        title: 'Google Drive',
        subtitle: 'Sync from your Drive',
        color: Color(0xFF4285F4),
      ),
      _ImportOptionData(
        icon: Icons.cloud_upload_outlined,
        title: 'Dropbox',
        subtitle: 'Import from Dropbox',
        color: Color(0xFF007EE5),
      ),
      _ImportOptionData(
        icon: Icons.more_horiz,
        title: 'More Sources',
        subtitle: 'Discover more import options',
        color: Color(0xFF888888),
      ),
    ];

    const backupOptions = [
      _BackupOptionData(
        icon: Icons.drive_file_move_outlined,
        title: 'Google Drive',
        subtitle: 'Last sync: Today, 9:41 AM',
        color: Color(0xFF4285F4),
      ),
      _BackupOptionData(
        icon: Icons.cloud_upload_outlined,
        title: 'Dropbox',
        subtitle: 'Last sync: Yesterday',
        color: Color(0xFF007EE5),
      ),
      _BackupOptionData(
        icon: Icons.sync,
        title: 'Auto Backup',
        subtitle: 'Wi-Fi only',
        color: Color(0xFF34C759),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid4,
                DesignTokens.grid8,
                DesignTokens.grid24,
                DesignTokens.grid8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: DesignTokens.grid4),
                  Text('Import & Backup', style: theme.textTheme.displaySmall),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(bottom: DesignTokens.grid16),
                    children: [
                      //  ··· Import Books section ···
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          DesignTokens.grid24,
                          DesignTokens.grid20,
                          DesignTokens.grid24,
                          DesignTokens.grid8,
                        ),
                        child: Text(
                          'Import Books',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...importOptions.map(
                        (opt) => _buildImportTile(
                          context,
                          opt,
                          _isImporting,
                          _importFromDevice,
                          _importFromUrl,
                          _comingSoon,
                        ),
                      ),

                      const SizedBox(height: DesignTokens.grid16),

                      //  ··· Backup & Sync section ···
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          DesignTokens.grid24,
                          DesignTokens.grid8,
                          DesignTokens.grid24,
                          DesignTokens.grid8,
                        ),
                        child: Text(
                          'Backup & Sync',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...backupOptions.map(
                        (opt) => _buildBackupTile(context, opt),
                      ),
                    ],
                  ),

                  // Loading overlay
                  if (_isImporting)
                    Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),

            // ── Sync Now button (pinned to bottom) ──────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid16,
                DesignTokens.grid8,
                DesignTokens.grid16,
                DesignTokens.grid16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isImporting ? null : () => _comingSoon('Sync'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    ),
                  ),
                  child: const Text('Sync Now', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportTile(
    BuildContext context,
    _ImportOptionData opt,
    bool isImporting,
    VoidCallback importFromDevice,
    VoidCallback importFromUrl,
    void Function(String) comingSoon,
  ) {
    VoidCallback? onTap;
    switch (opt.title) {
      case 'From Device':
        onTap = isImporting ? null : importFromDevice;
        break;
      case 'From URL':
        onTap = isImporting ? null : importFromUrl;
        break;
      default:
        onTap = () => comingSoon(opt.title);
    }

    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: opt.color.withAlpha(20),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        child: Icon(opt.icon, color: opt.color, size: 22),
      ),
      title: Text(
        opt.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        opt.subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildBackupTile(BuildContext context, _BackupOptionData opt) {
    return ListTile(
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: opt.color.withAlpha(20),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        child: Icon(opt.icon, color: opt.color, size: 22),
      ),
      title: Text(
        opt.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        opt.subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      trailing: Switch(
        value: false,
        activeColor: const Color(0xFF34C759),
        onChanged: (_) => _comingSoon(opt.title),
      ),
      onTap: () => _comingSoon(opt.title),
    );
  }
}

// ── Private data classes ──────────────────────────────────────

class _ImportOptionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _ImportOptionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

class _BackupOptionData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _BackupOptionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
