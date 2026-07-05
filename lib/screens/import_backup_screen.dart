import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

/// Merged Import & Backup screen.
///
/// Combines the import-options list from [import_screen.dart] with
/// the cloud-sync toggles previously in [profile_screen.dart]'s bottom sheet.
///
/// Design spec: frontend_changes.md §15
class ImportBackupScreen extends StatelessWidget {
  const ImportBackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const importOptions = [
      _ImportOptionData(
        icon: Icons.phone_android,
        title: 'From Device',
        subtitle: 'Browse files on your device',
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
              child: ListView(
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
                  ...importOptions.map(_buildImportTile),

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
                  ...backupOptions.map(_buildBackupTile),
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
                  onPressed: () {},
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

  Widget _buildImportTile(_ImportOptionData opt) {
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
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        opt.subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }

  Widget _buildBackupTile(_BackupOptionData opt) {
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
        style: TextStyle(
          fontWeight: FontWeight.w600,
        ),
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
        onChanged: (_) {},
      ),
      onTap: () {},
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
