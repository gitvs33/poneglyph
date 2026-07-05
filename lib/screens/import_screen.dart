import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final options = [
      _ImportOption(
        icon: Icons.phone_android,
        title: 'From Device',
        subtitle: 'Browse files on your device',
        color: const Color(0xFF6C63FF),
      ),
      _ImportOption(
        icon: Icons.link,
        title: 'From URL',
        subtitle: 'Download from a web link',
        color: const Color(0xFF45B7D1),
      ),
      _ImportOption(
        icon: Icons.folder_zip_outlined,
        title: 'From ZIP',
        subtitle: 'Import compressed archives',
        color: const Color(0xFFFFAA44),
      ),
      _ImportOption(
        icon: Icons.folder_open,
        title: 'From Folder',
        subtitle: 'Import an entire folder',
        color: const Color(0xFF81C784),
      ),
      _ImportOption(
        icon: Icons.drive_file_move_outlined,
        title: 'Google Drive',
        subtitle: 'Sync from your Drive',
        color: const Color(0xFF4285F4),
      ),
      _ImportOption(
        icon: Icons.cloud_upload_outlined,
        title: 'Dropbox',
        subtitle: 'Import from Dropbox',
        color: const Color(0xFF007EE5),
      ),
      _ImportOption(
        icon: Icons.cloud,
        title: 'OneDrive',
        subtitle: 'Microsoft cloud storage',
        color: const Color(0xFF0078D4),
      ),
      _ImportOption(
        icon: Icons.apple,
        title: 'iCloud',
        subtitle: 'Apple cloud service',
        color: const Color(0xFF555555),
      ),
    ];

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
              child: Text('Import Books', style: theme.textTheme.displaySmall),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid24,
                0,
                DesignTokens.grid24,
                DesignTokens.grid16,
              ),
              child: Text(
                'Choose a source to import your books from',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
                itemCount: options.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final option = options[index];
                  return ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: option.color.withAlpha(20),
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Icon(option.icon, color: option.color, size: 22),
                    ),
                    title: Text(option.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                    subtitle: Text(option.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                        )),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
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

class _ImportOption {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  _ImportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
