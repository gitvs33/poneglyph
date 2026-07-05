import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/design_tokens.dart';

// Theme Bottom Sheet
class ThemeBottomSheet extends StatelessWidget {
  final AppThemeMode currentMode;
  final ValueChanged<AppThemeMode> onThemeChanged;

  const ThemeBottomSheet({
    super.key,
    required this.currentMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modes = [
      (AppThemeMode.light, Icons.light_mode, 'Light'),
      (AppThemeMode.dark, Icons.dark_mode, 'Dark'),
      (AppThemeMode.sepia, Icons.wb_sunny, 'Sepia'),
      (AppThemeMode.amoled, Icons.nights_stay, 'AMOLED'),
      (AppThemeMode.custom, Icons.palette, 'Custom'),
    ];

    return Padding(
      padding: const EdgeInsets.all(DesignTokens.grid24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme', style: theme.textTheme.titleLarge),
          const SizedBox(height: DesignTokens.grid20),
          Wrap(
            spacing: DesignTokens.grid16,
            runSpacing: DesignTokens.grid16,
            children: modes.map((m) {
              final selected = currentMode == m.$1;
              return GestureDetector(
                onTap: () => onThemeChanged(m.$1),
                child: Container(
                  width: 64,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _themeColor(m.$1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                    border: selected
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : null,
                    boxShadow: selected
                        ? [BoxShadow(
                            color: theme.colorScheme.primary.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(m.$2, color: _iconColor(m.$1), size: 24),
                      const SizedBox(height: 4),
                      Text(
                        m.$3,
                        style: TextStyle(
                          fontSize: 10,
                          color: _iconColor(m.$1),
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: DesignTokens.grid24),
        ],
      ),
    );
  }

  Color _themeColor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light: return Colors.white;
      case AppThemeMode.dark: return const Color(0xFF2A2A3E);
      case AppThemeMode.sepia: return const Color(0xFFF5EDD6);
      case AppThemeMode.amoled: return const Color(0xFF0A0A0A);
      case AppThemeMode.custom: return const Color(0xFFF5F5F5);
    }
  }

  Color _iconColor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light: return const Color(0xFF1A1A2E);
      case AppThemeMode.dark: return Colors.white70;
      case AppThemeMode.sepia: return const Color(0xFF3B2F1A);
      case AppThemeMode.amoled: return Colors.white54;
      case AppThemeMode.custom: return const Color(0xFF1A1A2E);
    }
  }
}

// Font Bottom Sheet
class FontBottomSheet extends StatefulWidget {
  final double fontSize;
  final String fontFamily;
  final double lineHeight;
  final double paragraphSpacing;
  final bool justification;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<String> onFontFamilyChanged;
  final ValueChanged<double> onLineHeightChanged;
  final ValueChanged<double> onParagraphSpacingChanged;
  final ValueChanged<bool> onJustificationChanged;

  const FontBottomSheet({
    super.key,
    required this.fontSize,
    required this.fontFamily,
    required this.lineHeight,
    required this.paragraphSpacing,
    required this.justification,
    required this.onFontSizeChanged,
    required this.onFontFamilyChanged,
    required this.onLineHeightChanged,
    required this.onParagraphSpacingChanged,
    required this.onJustificationChanged,
  });

  @override
  State<FontBottomSheet> createState() => _FontBottomSheetState();
}

class _FontBottomSheetState extends State<FontBottomSheet> {
  static const _fontFamilies = ['System', 'Serif', 'Sans Serif', 'Dyslexia', 'Merriweather', 'Lora'];
  static const _fontSizes = [12, 14, 16, 18, 20, 22, 24, 28, 32, 36];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.grid24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Font', style: theme.textTheme.titleLarge),
          const SizedBox(height: DesignTokens.grid20),

          // Font Family
          Text('Font Family', style: theme.textTheme.labelLarge),
          const SizedBox(height: DesignTokens.grid8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _fontFamilies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final family = _fontFamilies[index];
                final selected = widget.fontFamily == family;
                return FilterChip(
                  label: Text(family, style: const TextStyle(fontSize: 12)),
                  selected: selected,
                  onSelected: (_) => widget.onFontFamilyChanged(family),
                );
              },
            ),
          ),
          const SizedBox(height: DesignTokens.grid20),

          // Font Size
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Size', style: theme.textTheme.labelLarge),
              Text('${widget.fontSize.round()}', style: theme.textTheme.titleMedium),
            ],
          ),
          Slider(
            value: widget.fontSize,
            min: 12,
            max: 36,
            divisions: _fontSizes.length - 1,
            onChanged: widget.onFontSizeChanged,
          ),

          // Line Height
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Line Height', style: theme.textTheme.labelLarge),
              Text(widget.lineHeight.toStringAsFixed(1), style: theme.textTheme.titleMedium),
            ],
          ),
          Slider(
            value: widget.lineHeight,
            min: 1.0,
            max: 2.0,
            divisions: 10,
            onChanged: widget.onLineHeightChanged,
          ),

          // Paragraph Spacing
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Paragraph Spacing', style: theme.textTheme.labelLarge),
              Text('${widget.paragraphSpacing.round()}', style: theme.textTheme.titleMedium),
            ],
          ),
          Slider(
            value: widget.paragraphSpacing,
            min: 0,
            max: 20,
            divisions: 10,
            onChanged: widget.onParagraphSpacingChanged,
          ),

          // Justification
          SwitchListTile(
            title: const Text('Justification'),
            value: widget.justification,
            onChanged: widget.onJustificationChanged,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: DesignTokens.grid16),
        ],
      ),
    );
  }
}

// Sort Bottom Sheet
class SortBottomSheet extends StatelessWidget {
  final String currentSort;
  final ValueChanged<String> onSortChanged;

  const SortBottomSheet({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortOptions = [
      ('Recent', Icons.access_time),
      ('Title', Icons.sort_by_alpha),
      ('Author', Icons.person),
      ('Progress', Icons.trending_up),
    ];

    return Padding(
      padding: const EdgeInsets.all(DesignTokens.grid24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sort By', style: theme.textTheme.titleLarge),
          const SizedBox(height: DesignTokens.grid16),
          ...sortOptions.map((option) => ListTile(
            leading: Icon(option.$2),
            title: Text(option.$1),
            trailing: currentSort == option.$1
                ? Icon(Icons.check, color: theme.colorScheme.primary)
                : null,
            onTap: () => onSortChanged(option.$1),
          )),
        ],
      ),
    );
  }
}

// Filter Bottom Sheet
class FilterBottomSheet extends StatelessWidget {
  final String? selectedTag;
  final List<String> availableTags;
  final ValueChanged<String?> onTagSelected;

  const FilterBottomSheet({
    super.key,
    this.selectedTag,
    required this.availableTags,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(DesignTokens.grid24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filter by Tag', style: theme.textTheme.titleLarge),
          const SizedBox(height: DesignTokens.grid16),
          if (selectedTag != null)
            TextButton(
              onPressed: () => onTagSelected(null),
              child: const Text('Clear Filter'),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableTags.map((tag) => FilterChip(
              label: Text(tag),
              selected: selectedTag == tag,
              onSelected: (_) => onTagSelected(selectedTag == tag ? null : tag),
            )).toList(),
          ),
          const SizedBox(height: DesignTokens.grid24),
        ],
      ),
    );
  }
}
