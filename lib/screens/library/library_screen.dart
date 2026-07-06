import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import '../../theme/design_tokens.dart';
import '../../providers/library_provider.dart';
import '../../providers/collections_provider.dart';
import '../../models/book.dart';
import '../reader/pdf_reader_screen.dart';
import '../reader/reader_screen.dart';
import '../filter_and_sort_screen.dart';
import '../../services/cover_cache.dart';
enum _LibraryTab { all, books, collections, authors }

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  _LibraryTab _selectedTab = _LibraryTab.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final library = context.read<LibraryProvider>();
      await library.initialize();
      // After the library loads, extract covers for existing EPUB books.
      _seedMissingCovers();
    });
  }

  /// Extract and cache covers for existing EPUB books that don't have one.
  void _seedMissingCovers() {
    final library = context.read<LibraryProvider>();
    for (final book in library.allBooks) {
      if (book.format == BookFormat.epub &&
          (book.coverUrl == null || book.coverUrl!.isEmpty) &&
          book.filePath != null &&
          book.filePath!.isNotEmpty &&
          !book.filePath!.startsWith('http')) {
        CoverCache.cacheCover(book.id, book.filePath!).then((coverUrl) {
          if (coverUrl != null) {
            library.updateBookCover(book.id, coverUrl);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final bg = theme.scaffoldBackgroundColor;

    return Consumer<LibraryProvider>(
      builder: (context, library, _) {
        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
                  child: Row(
                    children: [
                      // Hamburger
                      Icon(Icons.menu,
                          color: theme.textTheme.bodyLarge?.color, size: 24),
                      const Spacer(),
                      // Title centered
                      Text(
                        'Library',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      // Search icon
                      IconButton(
                        icon: Icon(Icons.search,
                            color: theme.textTheme.bodyLarge?.color),
                        onPressed: () => _showSearchDialog(context, library),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 36, minHeight: 36),
                      ),
                      // Filter icon
                      IconButton(
                        icon: Icon(Icons.filter_list,
                            color: theme.textTheme.bodyLarge?.color),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const FilterAndSortScreen()),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 36, minHeight: 36),
                      ),
                      // Add icon
                      IconButton(
                        icon: Icon(Icons.add,
                            color: theme.textTheme.bodyLarge?.color),
                        onPressed: () => _showImportOptions(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                            minWidth: 36, minHeight: 36),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // ── Filter tabs (All / Books / Collections / Authors)
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _tab('All', _LibraryTab.all, primary, theme),
                      _tab('Books', _LibraryTab.books, primary, theme),
                      _tab('Collections', _LibraryTab.collections, primary, theme),
                      _tab('Authors', _LibraryTab.authors, primary, theme),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Book grid / content
                Expanded(
                  child: _buildContent(context, library, theme, primary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tab(String label, _LibraryTab tab, Color primary, ThemeData theme) {
    final isSelected = _selectedTab == tab;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tab),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? primary : primary.withAlpha(20),
          borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : primary,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LibraryProvider library,
      ThemeData theme, Color primary) {
    if (library.isLoading) {
      return _buildLoadingGrid();
    }
    if (library.error != null) {
      return _buildError(library, theme);
    }
    if (library.books.isEmpty) {
      return _buildEmpty(context, library, theme, primary);
    }

    final books = library.books;

    // Authors tab – grouped list
    if (_selectedTab == _LibraryTab.authors) {
      return _buildAuthorsView(books, theme, library, context);
    }

    // Collections tab
    if (_selectedTab == _LibraryTab.collections) {
      return _buildCollectionsView(
          context.read<CollectionsProvider>().collections, theme, context);
    }

    // All / Books – 3-column grid
    return RefreshIndicator(
      onRefresh: library.initialize,
      color: primary,
      backgroundColor: theme.cardColor,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.62,
          crossAxisSpacing: 10,
          mainAxisSpacing: 14,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _BookGridItem(
            book: book,
            onTap: () => _openBook(context, book),
            onLongPress: () => _showBookContextMenu(context, library, book),
          );
        },
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.62,
        crossAxisSpacing: 10,
        mainAxisSpacing: 14,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        final theme = Theme.of(context);
        return Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
        );
      },
    );
  }

  Widget _buildError(LibraryProvider library, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 48, color: theme.colorScheme.error),
          const SizedBox(height: 12),
          Text(library.error!, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          TextButton(
              onPressed: library.initialize, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, LibraryProvider library,
      ThemeData theme, Color primary) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined,
              size: 64, color: primary.withAlpha(80)),
          const SizedBox(height: 16),
          Text('Your library is empty',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(150),
              )),
          const SizedBox(height: 8),
          Text('Import your first book to get started',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(100),
              )),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showImportOptions(context),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Import Book'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorsView(List<Book> books, ThemeData theme,
      LibraryProvider library, BuildContext context) {
    final authors = <String, List<Book>>{};
    for (final b in books) {
      authors.putIfAbsent(b.author, () => []).add(b);
    }
    final sortedAuthors = authors.keys.toList()..sort();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: sortedAuthors.length,
      separatorBuilder: (_, _) => Divider(
          height: 1, color: Colors.white.withAlpha(15)),
      itemBuilder: (context, i) {
        final author = sortedAuthors[i];
        final authorBooks = authors[author]!;
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withAlpha(40),
            child: Text(
              author.isNotEmpty ? author[0].toUpperCase() : '?',
              style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(author,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(
              '${authorBooks.length} book${authorBooks.length == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(130),
              )),
          trailing: Icon(Icons.chevron_right,
              color: theme.textTheme.bodySmall?.color?.withAlpha(100)),
          onTap: () => _openBook(context, authorBooks.first),
        );
      },
    );
  }

  Widget _buildCollectionsView(List<dynamic> collections, ThemeData theme,
      BuildContext context) {

    if (collections.isEmpty) {
      return Center(
        child: Text('No collections yet',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withAlpha(130),
            )),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: collections.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, color: Colors.white.withAlpha(15)),
      itemBuilder: (context, i) {
        final c = collections[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.folder_outlined,
                color: theme.colorScheme.primary, size: 22),
          ),
          title: Text(c.name,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text('${c.bookCount} books',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withAlpha(130),
              )),
          trailing: Icon(Icons.chevron_right,
              color: theme.textTheme.bodySmall?.color?.withAlpha(100)),
        );
      },
    );
  }

  void _openBook(BuildContext context, Book book) {
    if (book.format == BookFormat.pdf) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PdfReaderScreen(book: book)),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ReaderScreen(book: book)),
      );
    }
  }

  void _showSearchDialog(BuildContext context, LibraryProvider library) {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.cardColor,
          title: Text('Search Library', style: theme.textTheme.titleLarge),
          content: TextField(
            autofocus: true,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Search by title or author…',
              prefixIcon: Icon(Icons.search,
                  color: theme.textTheme.bodySmall?.color?.withAlpha(120)),
            ),
            onChanged: library.setSearchQuery,
          ),
          actions: [
            TextButton(
              onPressed: () {
                library.setSearchQuery('');
                Navigator.pop(ctx);
              },
              child: const Text('Clear'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  void _showBookContextMenu(
      BuildContext context, LibraryProvider library, Book book) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(book.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border),
              title: Text(
                  book.isFavorite
                      ? 'Remove from Favorites'
                      : 'Add to Favorites',
                  style: theme.textTheme.bodyMedium),
              onTap: () {
                library.toggleFavorite(book.id);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text('Share', style: theme.textTheme.bodyMedium),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red[400]),
              title: Text('Delete',
                  style: TextStyle(color: Colors.red[400])),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, library, book);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, LibraryProvider library, Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Delete "${book.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              library.deleteBook(book.id);
              Navigator.pop(ctx);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );
  }

  void _showImportOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child:
                  Text('Import Book', style: theme.textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: Text('From Device', style: theme.textTheme.bodyMedium),
              subtitle: Text('Browse files on your device',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(130),
                  )),
              onTap: () {
                Navigator.pop(ctx);
                _importFromDevice();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: Text('From URL', style: theme.textTheme.bodyMedium),
              subtitle: Text('Download from a web link',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withAlpha(130),
                  )),
              onTap: () {
                Navigator.pop(ctx);
                _importFromUrl();
              },
            ),
            ListTile(
              leading: const Icon(Icons.drive_file_move_outlined),
              title: Text('Google Drive', style: theme.textTheme.bodyMedium),
              onTap: () => Navigator.pop(ctx),
            ),
            ListTile(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: Text('Dropbox', style: theme.textTheme.bodyMedium),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _importFromDevice() async {
    try {
      final xFiles = await openFiles(
        acceptedTypeGroups: [
          XTypeGroup(
            label: 'eBooks',
            extensions: ['epub', 'pdf', 'mobi'],
          ),
        ],
      );

      if (xFiles.isEmpty) return;

      if (!mounted) return;
      final library = context.read<LibraryProvider>();

      // Get app documents directory for local file storage
      final docsDir = await getApplicationDocumentsDirectory();
      final booksDir = Directory('${docsDir.path}/books');
      if (!await booksDir.exists()) {
        await booksDir.create(recursive: true);
      }

      int added = 0;

      for (final xf in xFiles) {
        final path = xf.path;
        if (path.isEmpty) continue;

        final name = xf.name;
        final title = name.replaceAll(RegExp(r'\.[^.]+$'), '');

        // Copy file to local storage (content:// URIs from file_selector
        // cannot be read via File() — only via XFile.readAsBytes()).
        final bytes = await xf.readAsBytes();
        final localPath = '${booksDir.path}/${DateTime.now().millisecondsSinceEpoch}_$name';
        final localFile = File(localPath);
        await localFile.writeAsBytes(bytes);

        // Detect format by magic bytes — more reliable than extension.
        // EPUB is a ZIP (PK\3\4), PDF starts with %PDF, MOBI uses PalmDB.
        BookFormat format = BookFormat.epub;
        if (bytes.length >= 4) {
          if (bytes[0] == 0x25 && bytes[1] == 0x50 &&
              bytes[2] == 0x44 && bytes[3] == 0x46) {
            format = BookFormat.pdf;
          } else if (bytes.length >= 8) {
            // Check for MOBI/PRC/AZW (BOOKMOBI or TEXtREAd)
            if ((bytes[0] == 0x42 && bytes[1] == 0x4F &&
                 bytes[2] == 0x4F && bytes[3] == 0x4B &&
                 bytes[4] == 0x4D && bytes[5] == 0x4F &&
                 bytes[6] == 0x42 && bytes[7] == 0x49) ||
                (bytes[0] == 0x54 && bytes[1] == 0x45 &&
                 bytes[2] == 0x78 && bytes[3] == 0x74 &&
                 bytes[4] == 0x52 && bytes[5] == 0x45 &&
                 bytes[6] == 0x41 && bytes[7] == 0x64)) {
              format = BookFormat.mobi;
            }
          }
        }

        const int defaultPages = 300;

        await library.addBook(Book(
          id: 'import_${DateTime.now().millisecondsSinceEpoch}_$added',
          title: title,
          author: 'Unknown',
          format: format,
          source: BookSource.device,
          filePath: localPath,
          totalPages: defaultPages,
        ));
        added++;

        // Asynchronously extract and cache cover image for EPUB books.
        if (format == BookFormat.epub) {
          final book =
              library.allBooks.lastWhere((b) => b.filePath == localPath);
          _cacheCoverAsync(book.id, localPath, library);
        }
      }


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              added == 1 ? 'Imported 1 book' : 'Imported $added books',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import error: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  Future<void> _importFromUrl() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import from URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'https://example.com/book.epub',
            labelText: 'Book URL',
          ),
          keyboardType: TextInputType.url,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    final pathSegments = uri?.pathSegments ?? [];
    final fileName = pathSegments.isNotEmpty ? pathSegments.last : 'book';
    final title = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'epub';

    BookFormat format;
    switch (ext) {
      case 'pdf':
        format = BookFormat.pdf;
        break;
      case 'mobi':
        format = BookFormat.mobi;
        break;
      default:
        format = BookFormat.epub;
    }

    final id = 'book_url_${DateTime.now().millisecondsSinceEpoch}';
    final book = Book(
      id: id,
      title: title,
      author: 'Unknown',
      format: format,
      source: BookSource.url,
      filePath: url,
      description: 'Imported from URL: $url',
      totalPages: 0,
    );

    await context.read<LibraryProvider>().addBook(book);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added "$title" to library'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Extract and cache the cover image for an imported book.
  Future<void> _cacheCoverAsync(
      String bookId, String filePath, LibraryProvider library) async {
    final coverUrl = await CoverCache.cacheCover(bookId, filePath);
    if (coverUrl != null && mounted) {
      library.updateBookCover(bookId, coverUrl);
    }
  }
}

// ──────────────────────────────────────────────────────────────
// Book grid item widget – matches design
// ──────────────────────────────────────────────────────────────
class _BookGridItem extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _BookGridItem({
    required this.book,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPct = (book.progress * 100).round();

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cover
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (book.format == BookFormat.pdf)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.radiusMd),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD44141), Color(0xFFB83230)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.picture_as_pdf,
                              size: 32,
                              color: Colors.white.withAlpha(160)),
                          const SizedBox(height: 4),
                          Text(
                            _coverInitials(book.title),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withAlpha(200),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (book.coverUrl != null && book.coverUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(DesignTokens.radiusMd),
                    child: Image.file(
                      File(book.coverUrl!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _a, _b) => _buildInitialsCard(book),
                    ),
                  )
                else
                  _buildInitialsCard(book),
                // Progress badge in bottom-right
                if (book.progress > 0)
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$progressPct%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // Favorite heart
                if (book.isFavorite)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(Icons.favorite,
                        color: Colors.red[400], size: 16),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // ── Title
          Text(
            book.title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          // ── Author
          Text(
            book.author,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withAlpha(140),
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // ── Progress %
          if (book.progress > 0) ...[
            const SizedBox(height: 3),
            Text(
              '$progressPct%',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _coverInitials(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return '?';
    final words = trimmed.split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return trimmed.length >= 2
        ? trimmed.substring(0, 2).toUpperCase()
        : trimmed[0].toUpperCase();
  }

  Color _coverColor(String title) {
    const colors = [
      Color(0xFF2D2D5A), // deep navy
      Color(0xFF3D2E1E), // dark brown
      Color(0xFF1E3A2F), // dark green
      Color(0xFF3A1E2E), // dark plum
      Color(0xFF1E2C3A), // dark steel
      Color(0xFF2E1E3A), // dark purple
      Color(0xFF3A2E1E), // dark amber
      Color(0xFF1E3A3A), // dark teal
    ];
    return colors[title.length % colors.length];
  }

  /// Fallback card with colored background and initials.
  Widget _buildInitialsCard(Book book) {
    return Container(
      decoration: BoxDecoration(
        color: _coverColor(book.title),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      ),
      child: Center(
        child: Text(
          _coverInitials(book.title),
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white.withAlpha(200),
          ),
        ),
      ),
    );
  }
}
