import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reader_provider.dart';
import '../../theme/design_tokens.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  bool _sortNewest = true;

  List<String> get _sortedBookmarks {
    final bookmarks = context.read<ReaderProvider>().bookmarkedPages.toList();
    if (_sortNewest) {
      // Newest first: sort by page number descending (higher page = later in book)
      bookmarks.sort((a, b) {
        final pageA = int.parse(a.split('_').last);
        final pageB = int.parse(b.split('_').last);
        return pageB.compareTo(pageA);
      });
    } else {
      // Oldest first: sort by page number ascending
      bookmarks.sort((a, b) {
        final pageA = int.parse(a.split('_').last);
        final pageB = int.parse(b.split('_').last);
        return pageA.compareTo(pageB);
      });
    }
    return bookmarks;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookmarks = _sortedBookmarks;

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
                  Expanded(
                    child: Text('Bookmarks',
                        style: theme.textTheme.displaySmall),
                  ),
                  // Sort dropdown
                  GestureDetector(
                    onTap: () {
                      setState(() => _sortNewest = !_sortNewest);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.grid12,
                        vertical: DesignTokens.grid8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius:
                            BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _sortNewest ? 'Newest' : 'Oldest',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ────────────────────────────────────────
            if (bookmarks.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 56,
                        color: theme.textTheme.bodySmall?.color
                            ?.withAlpha(80),
                      ),
                      const SizedBox(height: DesignTokens.grid16),
                      Text('No bookmarks yet',
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: DesignTokens.grid8),
                      Text(
                        'Tap the bookmark icon while reading to save pages',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withAlpha(120),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.grid24,
                  ),
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks[index];
                    final parts = bookmark.split('_');
                    final pageNumber = parts.length > 1 ? parts.last : '?';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (index > 0)
                          const Divider(thickness: 0.5, height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: DesignTokens.grid16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Page $pageNumber',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.textTheme.labelSmall?.color
                                      ?.withAlpha(140),
                                ),
                              ),
                              const SizedBox(height: DesignTokens.grid8),
                              Text(
                                'Bookmarked content will appear here.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withAlpha(200),
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // ── Add Bookmark button ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DesignTokens.grid24,
                DesignTokens.grid16,
                DesignTokens.grid24,
                DesignTokens.grid32,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<ReaderProvider>().toggleBookmark();
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Bookmark added'),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Add Bookmark',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.grid16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
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
