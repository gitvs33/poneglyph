import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/library_provider.dart';
import '../../theme/design_tokens.dart';

class FilterAndSortScreen extends StatefulWidget {
  const FilterAndSortScreen({super.key});

  @override
  State<FilterAndSortScreen> createState() => _FilterAndSortScreenState();
}

class _FilterAndSortScreenState extends State<FilterAndSortScreen> {
  int _selectedSort = 0;
  bool _filterBooks = true;
  bool _filterDocuments = false;

  // Maps UI sort option index to LibrarySortBy
  static const _sortOptions = [
    'Title',
    'Author',
    'Recently Read',
    'Date Added',
  ];

  void _apply() {
    final library = context.read<LibraryProvider>();

    // Map UI sort selection to provider's sort enum
    switch (_selectedSort) {
      case 0:
        library.setSortBy(LibrarySortBy.title);
      case 1:
        library.setSortBy(LibrarySortBy.author);
      case 2:
      case 3:
        library.setSortBy(LibrarySortBy.recent);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid4,
                DesignTokens.grid16,
                DesignTokens.grid24,
                DesignTokens.grid8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text('Filter & Sort',
                      style: theme.textTheme.displaySmall),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.grid24,
                ),
                children: [
                  // ── Sort By section ─────────────────────────
                  const SizedBox(height: DesignTokens.grid16),
                  Text('Sort By', style: theme.textTheme.titleMedium),
                  const SizedBox(height: DesignTokens.grid8),
                  ...List.generate(_sortOptions.length, (index) {
                    final isSelected = _selectedSort == index;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedSort = index),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: DesignTokens.grid4,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? primary
                                      : theme.textTheme.bodySmall
                                              ?.color
                                              ?.withAlpha(80) ??
                                          Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: DesignTokens.grid12),
                            Text(
                              _sortOptions[index],
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // ── Filter section ──────────────────────────
                  const SizedBox(height: DesignTokens.grid32),
                  Text('Filter', style: theme.textTheme.titleMedium),
                  const SizedBox(height: DesignTokens.grid8),
                  _FilterCheckbox(
                    label: 'Books',
                    value: _filterBooks,
                    activeColor: primary,
                    onChanged: (v) =>
                        setState(() => _filterBooks = v ?? false),
                  ),
                  _FilterCheckbox(
                    label: 'Documents',
                    value: _filterDocuments,
                    activeColor: primary,
                    onChanged: (v) =>
                        setState(() => _filterDocuments = v ?? false),
                  ),

                  // ── Tags section ────────────────────────────
                  const SizedBox(height: DesignTokens.grid32),
                  Text('Tags', style: theme.textTheme.titleMedium),
                  const SizedBox(height: DesignTokens.grid8),
                  GestureDetector(
                    onTap: () {
                      // Navigate to tag selection
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: DesignTokens.grid12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'All Tags',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.textTheme.bodyLarge?.color
                                  ?.withAlpha(180),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: theme.textTheme.bodySmall?.color
                                ?.withAlpha(100),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Apply button ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid24,
                DesignTokens.grid16,
                DesignTokens.grid24,
                DesignTokens.grid32,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.grid16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool?> onChanged;

  const _FilterCheckbox({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: DesignTokens.grid4,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: activeColor,
                checkColor: Colors.white,
                side: BorderSide(
                  color: theme.textTheme.bodySmall?.color?.withAlpha(80) ??
                      Colors.grey,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    DesignTokens.radiusXs,
                  ),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: DesignTokens.grid12),
            Text(
              label,
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
