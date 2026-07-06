import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/design_tokens.dart';
import '../../providers/reading_stats_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/constants.dart';
import 'import_backup_screen.dart';
import 'advanced_settings_screen.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = context.watch<ReadingStatsProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DesignTokens.grid24,
                  DesignTokens.grid24,
                  DesignTokens.grid24,
                  DesignTokens.grid8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Profile', style: theme.textTheme.displaySmall),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AdvancedSettingsScreen()),
                      ),
                    ),
                  ],
                ),
              ),

              // User card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(DesignTokens.grid20),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withAlpha(150),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              'R',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.grid20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Reader',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  )),
                              const SizedBox(height: 4),
                              Text(
                                '${stats.totalPagesRead} pages read',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: DesignTokens.grid24),

              // Reading goal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(DesignTokens.grid20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Reading Goal', style: theme.textTheme.titleMedium),
                            GestureDetector(
                              onTap: () => _showGoalPicker(context, settings),
                              child: Text(
                                '${settings.readingGoalMinutes} min/day',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: DesignTokens.grid16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (stats.totalTimeRead.inMinutes / settings.readingGoalMinutes)
                                .clamp(0, 1.0),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: DesignTokens.grid12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${stats.totalTimeRead.inMinutes} min today',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                              ),
                            ),
                            Text(
                              '${stats.readingStreak} day streak 🔥',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: DesignTokens.grid24),

              // Menu items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
                child: Card(
                  child: Column(
                    children: [
                      _menuItem(context, Icons.backup_outlined, 'Backup Library',
                          'Export your data to cloud', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ImportBackupScreen()),
                        );
                      }),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _menuItem(context, Icons.file_download_outlined, 'Export Data',
                          'Download your library as a file', () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Export feature coming in next update'),
                          ),
                        );
                      }),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _menuItem(context, Icons.sync, 'Cloud Sync',
                          'Sync across devices', () {
                        showModalBottomSheet(
                          context: context,
                          builder: (ctx) => SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Cloud Sync',
                                      style: theme.textTheme.titleLarge),
                                  const SizedBox(height: 16),
                                  ListTile(
                                    leading: Icon(Icons.drive_file_move_outlined,
                                        color: const Color(0xFF4285F4)),
                                    title: const Text('Google Drive'),
                                    trailing: Switch(value: false, onChanged: (_) {}),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.cloud_upload_outlined,
                                        color: const Color(0xFF007EE5)),
                                    title: const Text('Dropbox'),
                                    trailing: Switch(value: false, onChanged: (_) {}),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.cloud,
                                        color: const Color(0xFF0078D4)),
                                    title: const Text('OneDrive'),
                                    trailing: Switch(value: false, onChanged: (_) {}),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      _menuItem(context, Icons.info_outline, 'About',
                          'Poneglyph v1.0.0', () {
                        showAboutDialog(
                          context: context,
                          applicationName: AppConstants.appName,
                          applicationVersion: AppConstants.appVersion,
                          applicationIcon: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.menu_book, color: Colors.white),
                          ),
                          children: [
                            const Text('A premium mobile eBook reader supporting EPUB, PDF, and MOBI formats.'),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: DesignTokens.grid32),

              // Version
              Center(
                child: Text(
                  'Poneglyph v${AppConstants.appVersion}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(80),
                  ),
                ),
              ),

              const SizedBox(height: DesignTokens.grid32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(
        color: theme.textTheme.bodySmall?.color?.withAlpha(120),
      )),
      trailing: const Icon(Icons.chevron_right, size: 18),
      onTap: onTap,
    );
  }

  void _showGoalPicker(BuildContext context, SettingsProvider settings) {
    int selectedMinutes = settings.readingGoalMinutes;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Daily Reading Goal',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('$selectedMinutes minutes per day',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  )),
              StatefulBuilder(
                builder: (context, setInnerState) => Slider(
                  value: selectedMinutes.toDouble(),
                  min: 5,
                  max: 120,
                  divisions: 23,
                  label: '$selectedMinutes min',
                  onChanged: (v) => setInnerState(() => selectedMinutes = v.round()),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('5 min', style: Theme.of(context).textTheme.bodySmall),
                  Text('120 min', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    settings.setReadingGoalMinutes(selectedMinutes);
                    Navigator.pop(ctx);
                  },
                  child: const Text('Set Goal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
