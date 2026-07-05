import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/design_tokens.dart';

class ThemeSelectionPage extends StatelessWidget {
  final ValueChanged<AppThemeMode> onThemeChanged;

  const ThemeSelectionPage({super.key, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themes = [
      (AppThemeMode.light, Icons.light_mode, 'Light', Colors.white),
      (AppThemeMode.dark, Icons.dark_mode, 'Dark', const Color(0xFF2A2A3E)),
      (AppThemeMode.sepia, Icons.wb_sunny, 'Sepia', const Color(0xFFF5EDD6)),
      (AppThemeMode.amoled, Icons.nights_stay, 'AMOLED', const Color(0xFF0A0A0A)),
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
              Icons.palette_outlined,
              size: 56,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: DesignTokens.grid32),
          Text(
            'Choose Your Theme',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: DesignTokens.grid12),
          Text(
            'Pick a reading theme that suits your style.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withAlpha(150),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.grid32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: themes.map((t) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => onThemeChanged(t.$1),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 96,
                        decoration: BoxDecoration(
                          color: t.$4,
                          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                          border: Border.all(
                            color: theme.colorScheme.primary.withAlpha(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(t.$2,
                            color: t.$1 == AppThemeMode.light || t.$1 == AppThemeMode.sepia
                                ? Colors.black54
                                : Colors.white60,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(t.$3, style: theme.textTheme.labelSmall),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
