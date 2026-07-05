import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/design_tokens.dart';
import '../../providers/settings_provider.dart';

class AccessibilityScreen extends StatelessWidget {
  const AccessibilityScreen({super.key});

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
                  child: Text('Accessibility', style: theme.textTheme.displaySmall),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    DesignTokens.grid24,
                    0,
                    DesignTokens.grid24,
                    DesignTokens.grid16,
                  ),
                  child: Text(
                    'Customize your reading experience for accessibility',
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
                              title: const Text('Dynamic Text'),
                              subtitle: const Text('Adjust text size dynamically based on system settings'),
                              value: settings.dynamicTextScale != 1.0,
                              onChanged: (value) {
                                settings.setDynamicTextScale(value ? 1.2 : 1.0);
                              },
                            ),
                            if (settings.dynamicTextScale != 1.0)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Scale', style: theme.textTheme.labelMedium),
                                        Text('${settings.dynamicTextScale.toStringAsFixed(1)}x',
                                            style: theme.textTheme.titleSmall),
                                      ],
                                    ),
                                    Slider(
                                      value: settings.dynamicTextScale,
                                      min: 0.8,
                                      max: 2.0,
                                      divisions: 12,
                                      onChanged: settings.setDynamicTextScale,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.grid12),
                      Card(
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('High Contrast'),
                              subtitle: const Text('Increase contrast for better readability'),
                              value: settings.highContrast,
                              onChanged: settings.setHighContrast,
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            SwitchListTile(
                              title: const Text('Dyslexia-Friendly Font'),
                              subtitle: const Text('Use OpenDyslexic font for easier reading'),
                              value: settings.dyslexiaFont,
                              onChanged: settings.setDyslexiaFont,
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            SwitchListTile(
                              title: const Text('Screen Reader Support'),
                              subtitle: const Text('Optimize for TalkBack and VoiceOver'),
                              value: settings.screenReaderEnabled,
                              onChanged: settings.setScreenReaderEnabled,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DesignTokens.grid24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid8),
                        child: Text('Reading Aids',
                            style: theme.textTheme.titleMedium),
                      ),
                      const SizedBox(height: DesignTokens.grid12),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.text_fields),
                              title: const Text('Font Size'),
                              subtitle: Text('${settings.defaultFontSize.round()}pt'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {},
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            ListTile(
                              leading: const Icon(Icons.space_bar),
                              title: const Text('Line Spacing'),
                              subtitle: const Text('1.6'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {},
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            ListTile(
                              leading: const Icon(Icons.read_more),
                              title: const Text('Reading Ruler'),
                              subtitle: const Text('Highlight the current line'),
                              trailing: Switch(
                                value: false,
                                onChanged: (_) {},
                              ),
                            ),
                          ],
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
