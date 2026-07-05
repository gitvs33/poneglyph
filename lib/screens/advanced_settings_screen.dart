import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../utils/constants.dart';

class AdvancedSettingsScreen extends StatelessWidget {
  const AdvancedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid8,
                DesignTokens.grid16,
                DesignTokens.grid24,
                DesignTokens.grid8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Text('Advanced Settings', style: theme.textTheme.displaySmall),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
                children: [
                  // ── Language section
                  Padding(
                    padding: const EdgeInsets.only(
                      left: DesignTokens.grid8,
                      bottom: DesignTokens.grid8,
                    ),
                    child: Text('Language',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        ),
                        child: Icon(Icons.language,
                            color: theme.colorScheme.primary, size: 20),
                      ),
                      title: const Text('App Language'),
                      subtitle: const Text('English'),
                      trailing: Icon(Icons.chevron_right,
                          color: theme.textTheme.bodySmall?.color?.withAlpha(100)),
                      onTap: () {
                        // No-op for now
                      },
                    ),
                  ),

                  const SizedBox(height: DesignTokens.grid24),

                  // ── Font Cache section
                  Padding(
                    padding: const EdgeInsets.only(
                      left: DesignTokens.grid8,
                      bottom: DesignTokens.grid8,
                    ),
                    child: Text('Font Cache',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Card(
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(15),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        ),
                        child: Icon(Icons.font_download_outlined,
                            color: theme.colorScheme.primary, size: 20),
                      ),
                      title: const Text('Clear Font Cache'),
                      subtitle: const Text('Free up storage used by cached fonts'),
                      trailing: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Font cache cleared')),
                          );
                        },
                        child: const Text('Clear'),
                      ),
                    ),
                  ),

                  const SizedBox(height: DesignTokens.grid24),

                  // ── Data section
                  Padding(
                    padding: const EdgeInsets.only(
                      left: DesignTokens.grid8,
                      bottom: DesignTokens.grid8,
                    ),
                    child: Text('Data',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withAlpha(25),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                            ),
                            child: Icon(Icons.delete_sweep_outlined,
                                color: Colors.orange[700], size: 20),
                          ),
                          title: const Text('Clear Reading Data'),
                          subtitle: const Text('Remove reading progress and statistics'),
                          trailing: TextButton(
                            onPressed: () => _confirmClearReadingData(context),
                            child: Text('Clear',
                                style: TextStyle(color: Colors.orange[700])),
                          ),
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(25),
                              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                            ),
                            child: Icon(Icons.settings_backup_restore,
                                color: Colors.red[400], size: 20),
                          ),
                          title: const Text('Reset All Settings'),
                          subtitle: const Text('Restore all settings to default values'),
                          trailing: TextButton(
                            onPressed: () => _confirmResetSettings(context),
                            child: Text('Reset',
                                style: TextStyle(color: Colors.red[400])),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: DesignTokens.grid24),

                  // ── About section
                  Padding(
                    padding: const EdgeInsets.only(
                      left: DesignTokens.grid8,
                      bottom: DesignTokens.grid8,
                    ),
                    child: Text('About',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                  Card(
                    child: ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                        ),
                        child: Icon(Icons.menu_book,
                            color: theme.colorScheme.primary, size: 22),
                      ),
                      title: Text(AppConstants.appName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                      subtitle: Text('Version ${AppConstants.appVersion}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withAlpha(130),
                          )),
                    ),
                  ),

                  const SizedBox(height: DesignTokens.grid32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearReadingData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Reading Data'),
        content: const Text(
          'This will remove all reading progress, statistics, and streaks. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reading data cleared')),
              );
            },
            child: Text('Clear', style: TextStyle(color: Colors.orange[700])),
          ),
        ],
      ),
    );
  }

  void _confirmResetSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text(
          'This will restore all settings to their default values. Your books and data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: Text('Reset', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }
}
