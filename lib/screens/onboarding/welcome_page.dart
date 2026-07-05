import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.grid32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 80,
                  color: theme.colorScheme.primary.withAlpha(100),
                ),
                Positioned(
                  right: 30,
                  bottom: 30,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DesignTokens.grid48),
          Text(
            'Welcome to Poneglyph',
            style: theme.textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.grid16),
          Text(
            'Your premium eBook reader with support for EPUB, PDF, and MOBI formats. Read anywhere, anytime.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withAlpha(150),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.grid32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _featureIcon(context, Icons.bookmark_add, 'Bookmarks'),
              const SizedBox(width: DesignTokens.grid24),
              _featureIcon(context, Icons.highlight, 'Highlights'),
              const SizedBox(width: DesignTokens.grid24),
              _featureIcon(context, Icons.sync, 'Cloud Sync'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureIcon(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
