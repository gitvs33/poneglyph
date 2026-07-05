import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/design_tokens.dart';
import '../../providers/settings_provider.dart';

class AccessibilityScreen extends StatefulWidget {
  const AccessibilityScreen({super.key});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
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
                      Text('Accessibility', style: theme.textTheme.displaySmall),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
                    children: [
                      // ── Display section
                      Padding(
                        padding: const EdgeInsets.only(
                          left: DesignTokens.grid8,
                          bottom: DesignTokens.grid8,
                        ),
                        child: Text('Display',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      Card(
                        child: Column(
                          children: [
                            // Font Size slider
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Font Size', style: theme.textTheme.titleMedium),
                                  Text('${settings.defaultFontSize.round()}pt',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Slider(
                                value: settings.defaultFontSize,
                                min: 12,
                                max: 24,
                                divisions: 6,
                                label: '${settings.defaultFontSize.round()}pt',
                                onChanged: (v) => settings.setDefaultFontSize(v),
                              ),
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
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
                          ],
                        ),
                      ),

                      const SizedBox(height: DesignTokens.grid24),

                      // ── Interaction section
                      Padding(
                        padding: const EdgeInsets.only(
                          left: DesignTokens.grid8,
                          bottom: DesignTokens.grid8,
                        ),
                        child: Text('Interaction',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                      Card(
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Screen Reader'),
                              subtitle: const Text('Optimize for TalkBack and VoiceOver'),
                              value: settings.screenReaderEnabled,
                              onChanged: settings.setScreenReaderEnabled,
                            ),
                            const Divider(height: 1, indent: 16, endIndent: 16),
                            // Dynamic Text Scale slider
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Dynamic Text Scale', style: theme.textTheme.titleMedium),
                                  Text('${settings.dynamicTextScale.toStringAsFixed(2)}x',
                                      style: theme.textTheme.titleSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                              child: Slider(
                                value: settings.dynamicTextScale,
                                min: 0.5,
                                max: 2.0,
                                divisions: 6,
                                label: '${settings.dynamicTextScale.toStringAsFixed(2)}x',
                                onChanged: (v) => settings.setDynamicTextScale(v),
                              ),
                            ),
                          ],
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
      },
    );
  }
}
