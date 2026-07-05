import 'package:flutter/material.dart';
import '../../theme/design_tokens.dart';
import '../../models/highlight.dart';

class HighlightsScreen extends StatefulWidget {
  const HighlightsScreen({super.key});

  @override
  State<HighlightsScreen> createState() => _HighlightsScreenState();
}

class _HighlightsScreenState extends State<HighlightsScreen> {
  // Mock highlights
  final List<Highlight> _highlights = [
    Highlight(
      id: '1',
      bookId: '1',
      chapterId: 'ch1',
      text: 'In my younger and more vulnerable years my father gave me some advice...',
      note: 'Great opening line',
      color: HighlightColor.yellow,
      startOffset: 0,
      endOffset: 80,
    ),
    Highlight(
      id: '2',
      bookId: '1',
      chapterId: 'ch3',
      text: 'He smiled understandingly-much more than understandingly...',
      color: HighlightColor.green,
      startOffset: 0,
      endOffset: 60,
    ),
    Highlight(
      id: '3',
      bookId: '2',
      chapterId: 'ch1',
      text: 'When he was nearly thirteen, my brother Jem got his arm badly broken...',
      note: 'To Kill a Mockingbird',
      color: HighlightColor.blue,
      startOffset: 0,
      endOffset: 75,
    ),
    Highlight(
      id: '4',
      bookId: '2',
      chapterId: 'ch5',
      text: 'Atticus, he was real nice...',
      color: HighlightColor.pink,
      startOffset: 0,
      endOffset: 30,
    ),
    Highlight(
      id: '5',
      bookId: '3',
      chapterId: 'ch1',
      text: 'It was a bright cold day in April, and the clocks were striking thirteen.',
      note: 'Iconic opening',
      color: HighlightColor.yellow,
      startOffset: 0,
      endOffset: 70,
    ),
  ];

  String? _selectedBook;
  HighlightColor? _selectedColor;
  bool _showNotes = false;

  List<Highlight> get _filteredHighlights {
    var result = List<Highlight>.from(_highlights);
    if (_showNotes) {
      result = result.where((h) => h.note != null).toList();
    } else {
      if (_selectedBook != null) {
        result = result.where((h) => h.bookId == _selectedBook).toList();
      }
      if (_selectedColor != null) {
        result = result.where((h) => h.color == _selectedColor).toList();
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlights = _filteredHighlights;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid24,
                DesignTokens.grid16,
                DesignTokens.grid24,
                DesignTokens.grid8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Highlights', style: theme.textTheme.displaySmall),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => _showFilters(context),
                  ),
                ],
              ),
            ),

            // Segmented control: Highlights | Notes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16, vertical: DesignTokens.grid8),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showNotes = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_showNotes
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary.withAlpha(20),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                        ),
                        child: Text(
                          'Highlights',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: !_showNotes ? Colors.white : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showNotes = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _showNotes
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary.withAlpha(20),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                        ),
                        child: Text(
                          'Notes',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _showNotes ? Colors.white : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Color filter chips (only in highlights mode)
            if (!_showNotes)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: DesignTokens.grid16),
                  children: [
                    _filterChip('All', null, () => setState(() => _selectedColor = null)),
                    _filterChip('Yellow', HighlightColor.yellow, () => setState(() => _selectedColor = HighlightColor.yellow)),
                    _filterChip('Green', HighlightColor.green, () => setState(() => _selectedColor = HighlightColor.green)),
                    _filterChip('Blue', HighlightColor.blue, () => setState(() => _selectedColor = HighlightColor.blue)),
                    _filterChip('Pink', HighlightColor.pink, () => setState(() => _selectedColor = HighlightColor.pink)),
                    _filterChip('Underline', HighlightColor.underline, () => setState(() => _selectedColor = HighlightColor.underline)),
                  ],
                ),
              ),

            if (highlights.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_showNotes ? Icons.note_outlined : Icons.highlight_off, size: 56,
                          color: theme.textTheme.bodySmall?.color?.withAlpha(80)),
                      const SizedBox(height: 16),
                      Text(_showNotes ? 'No notes yet' : 'No highlights yet',
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 8),
                      Text(_showNotes ? 'Add notes to your highlights while reading'
                              : 'Select text while reading to add highlights',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                          )),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(DesignTokens.grid16),
                  itemCount: highlights.length,
                  itemBuilder: (context, index) {
                    final highlight = highlights[index];
                    if (_showNotes) {
                      final bookTitles = {
                        '1': 'The Great Gatsby',
                        '2': 'To Kill a Mockingbird',
                        '3': '1984',
                      };
                      return Card(
                        margin: const EdgeInsets.only(bottom: DesignTokens.grid12),
                        child: Padding(
                          padding: const EdgeInsets.all(DesignTokens.grid16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(Icons.note, size: 18,
                                        color: theme.colorScheme.primary),
                                  ),
                                  const SizedBox(width: DesignTokens.grid12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          highlight.note ?? '',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Page ${highlight.startOffset ~/ 50 + 1} · ${bookTitles[highlight.bookId] ?? 'Unknown Book'}',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.textTheme.bodySmall?.color?.withAlpha(120),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Card(
                      margin: const EdgeInsets.only(bottom: DesignTokens.grid12),
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.grid16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _highlightColor(highlight.color),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: DesignTokens.grid12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        highlight.text,
                                        style: theme.textTheme.bodyMedium,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (highlight.note != null) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withAlpha(10),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.note, size: 14,
                                                  color: theme.textTheme.bodySmall?.color?.withAlpha(100)),
                                              const SizedBox(width: 6),
                                              Text(highlight.note!,
                                                  style: theme.textTheme.bodySmall),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: DesignTokens.grid12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Page ${highlight.startOffset ~/ 50 + 1}',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.textTheme.labelSmall?.color?.withAlpha(120),
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.share, size: 16),
                                      onPressed: () {},
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 16),
                                      onPressed: () {
                                        setState(() => _highlights.remove(highlight));
                                      },
                                      constraints: const BoxConstraints(),
                                      padding: const EdgeInsets.all(4),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, HighlightColor? color, VoidCallback onTap) {
    final isSelected = _selectedColor == color;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? (color != null ? _highlightColor(color) : Theme.of(context).colorScheme.primary)
                : Theme.of(context).colorScheme.primary.withAlpha(15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Color _highlightColor(HighlightColor color) {
    switch (color) {
      case HighlightColor.yellow: return const Color(0xFFFFD54F);
      case HighlightColor.green: return const Color(0xFF81C784);
      case HighlightColor.blue: return const Color(0xFF64B5F6);
      case HighlightColor.pink: return const Color(0xFFF06292);
      case HighlightColor.underline: return const Color(0xFF4FC3F7);
    }
  }

  void _showFilters(BuildContext context) {
    final bookTitles = {
      '1': 'The Great Gatsby',
      '2': 'To Kill a Mockingbird',
      '3': '1984',
    };

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Filter Highlights', style: Theme.of(context).textTheme.titleLarge),
            ),
            ListTile(
              title: const Text('All Books'),
              leading: Icon(Icons.book, color: _selectedBook == null
                  ? Theme.of(context).colorScheme.primary
                  : null),
              onTap: () {
                setState(() => _selectedBook = null);
                Navigator.pop(ctx);
              },
            ),
            ...bookTitles.entries.map((entry) => ListTile(
              title: Text(entry.value),
              leading: Icon(Icons.menu_book, color: _selectedBook == entry.key
                  ? Theme.of(context).colorScheme.primary
                  : null),
              onTap: () {
                setState(() => _selectedBook = entry.key);
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }
}
