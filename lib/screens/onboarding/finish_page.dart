import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';

class FinishPage extends StatelessWidget {
  const FinishPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.grid32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withAlpha(150),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              size: 72,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: DesignTokens.grid48),
          Text(
            "You're All Set!",
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: DesignTokens.grid16),
          Text(
            'Your library is ready. Start reading your favorite books today.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodyLarge?.color?.withAlpha(150),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: DesignTokens.grid32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _statChip(context, Icons.auto_stories, 'EPUB'),
              const SizedBox(width: 12),
              _statChip(context, Icons.picture_as_pdf, 'PDF'),
              const SizedBox(width: 12),
              _statChip(context, Icons.book, 'MOBI'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary)),
        ],
      ),
    );
  }
}
