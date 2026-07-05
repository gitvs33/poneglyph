import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class ImportPage extends StatelessWidget {
  const ImportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final importOptions = [
      (Icons.phone_android, 'Device', 'Import from storage'),
      (Icons.link, 'URL', 'Download from link'),
      (Icons.drive_file_move_outlined, 'Google Drive', 'Sync from Drive'),
      (Icons.cloud_upload_outlined, 'Dropbox', 'Import from Dropbox'),
    ];

    return Padding(
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
          ...importOptions.map((option) => Padding(
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
              ),
            ),
          )),
        ],
      ),
    );
  }
}
