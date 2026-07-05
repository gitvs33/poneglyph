import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/design_tokens.dart';
import '../../providers/settings_provider.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
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
                  child: Text('Security', style: theme.textTheme.displaySmall),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.grid24,
                    0,
                    DesignTokens.grid24,
                    DesignTokens.grid16,
                  ),
                  child: Text(
                    'Protect your library and reading privacy',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withAlpha(150),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
                    children: [
                      Card(
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('App Lock'),
                              subtitle: const Text('Require authentication to open the app'),
                              value: settings.appLockEnabled,
                              onChanged: (value) {
                                settings.setAppLockEnabled(value);
                                if (value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('App lock enabled'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                            ),
                            if (settings.appLockEnabled) ...[
                              const Divider(height: 1, indent: 16, endIndent: 16),
                              SwitchListTile(
                                title: const Text('Biometric Lock'),
                                subtitle: const Text('Use fingerprint or face unlock'),
                                value: settings.biometricLockEnabled,
                                onChanged: settings.setBiometricLockEnabled,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.grid12),
                      Card(
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Hidden Library'),
                              subtitle: const Text('Hide selected books from the main library'),
                              value: false,
                              onChanged: (_) {},
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            ListTile(
                              leading: const Icon(Icons.lock_outline),
                              title: const Text('Lock Individual Books'),
                              subtitle: const Text('Password-protect specific books'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.grid24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid8),
                        child: Text('Privacy',
                            style: theme.textTheme.titleMedium),
                      ),
                      const SizedBox(height: DesignTokens.grid12),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.visibility_off),
                              title: const Text('Private Reading Mode'),
                              subtitle: const Text('Hide reading activity from notifications'),
                              trailing: Switch(value: false, onChanged: (_) {}),
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            ListTile(
                              leading: const Icon(Icons.analytics_outlined),
                              title: const Text('Reading Analytics'),
                              subtitle: const Text('Collect reading statistics and habits'),
                              trailing: Switch(value: true, onChanged: (_) {}),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.grid24),
                      // Security tip
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid8),
                        child: Container(
                          padding: const EdgeInsets.all(DesignTokens.grid16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(10),
                            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                            border: Border.all(
                              color: theme.colorScheme.primary.withAlpha(30),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.shield_outlined,
                                  color: theme.colorScheme.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Security Tip',
                                        style: theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        )),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Enable biometric lock for quick and secure access to your library. Your reading data stays private on your device.',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.textTheme.bodySmall?.color?.withAlpha(150),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
