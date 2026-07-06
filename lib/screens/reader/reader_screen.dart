import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/design_tokens.dart';
import '../../theme/theme_provider.dart';
import '../../providers/reader_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/library_provider.dart';
import '../../models/book.dart';
import '../../models/highlight.dart';
import '../../services/ebook_content_service.dart';
import '../../widgets/bottom_sheets.dart';
import '../bookmarks_screen.dart';
import '../import_backup_screen.dart';

class ReaderScreen extends StatefulWidget {
  final Book book;

  const ReaderScreen({super.key, required this.book});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen>
    with SingleTickerProviderStateMixin {
  late ReaderProvider _reader;
  late AnimationController _barController;
  late Animation<double> _barAnimation;
  final TextEditingController _searchController = TextEditingController();
  final EbookContentService _contentService = EbookContentService();
  bool _loadingError = false;
  String _loadingErrorMessage = '';

  @override
  void initState() {
    super.initState();
    _reader = ReaderProvider();
    _reader.openBook(widget.book);

    _barController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _barAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeInOut),
    );
    _barController.value = 1;
    _searchController.addListener(() => setState(() {}));

    // Load real ebook content asynchronously
    _loadBookContent();
  }

  Future<void> _loadBookContent() async {
    try {
      final format = widget.book.format;
      final path = widget.book.filePath;
      if (path == null || path.isEmpty) {
        _loadingError = true;
        _loadingErrorMessage = 'No file path for this book.';
        return;
      }

      final content = await _contentService.readBook(path, format);
      if (!mounted) return;

      if (content == null) {
        _loadingError = true;
        _loadingErrorMessage = 'File not found at: $path';
        setState(() {});
        return;
      }

      _reader.loadContent(content);
      setState(() {});
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      _loadingError = true;
      final format = widget.book.format;
      final path = widget.book.filePath ?? 'null';
      _loadingErrorMessage = '${e.toString()}\n\nFormat: $format\nPath: $path';
      setState(() {});
    }
  }

  @override
  void dispose() {
    _reader.closeBook();
    _barController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final library = context.read<LibraryProvider>();

    return ChangeNotifierProvider.value(
      value: _reader,
      child: Consumer2<ReaderProvider, SettingsProvider>(
        builder: (context, reader, settings, _) {
          return Scaffold(
            body: Stack(
              children: [
                // Reading content area (tap to toggle bars)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () {
                      reader.toggleBars();
                      if (reader.showBars) {
                        _barController.forward();
                      } else {
                        _barController.reverse();
                      }
                    },
                    child: _buildReadingContent(context, reader, settings),
                  ),
                ),

                // Top Bar
                if (reader.showBars)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _barAnimation,
                      child: _buildTopBar(context, reader, theme, library),
                    ),
                  ),

                // Bottom Bar
                if (reader.showBars)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: FadeTransition(
                      opacity: _barAnimation,
                      child: _buildBottomBar(context, reader, settings, theme),
                    ),
                  ),

                // TOC Panel
                if (reader.isTocOpen)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildTocPanel(context, reader, theme),
                  ),

                // Search Panel
                if (reader.isSearching)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildSearchPanel(context, reader, theme),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadingContent(
      BuildContext context, ReaderProvider reader, SettingsProvider settings) {
    final theme = Theme.of(context);

    // Show loading/error states
    if (reader.chapters.isEmpty && !_loadingError) {
      return Container(
        color: theme.scaffoldBackgroundColor,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (reader.chapters.isEmpty && _loadingError) {
      return Container(
        color: theme.scaffoldBackgroundColor,
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Could not load book content',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _loadingErrorMessage,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  _loadingError = false;
                  setState(() {});
                  _loadBookContent();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Real content
    final pageContent = reader.currentPageContent;
    final chapterTitle = reader.currentChapterTitle;

    final bodyTextStyle = TextStyle(
      fontSize: settings.readingFontSize,
      fontFamily: settings.readingFontFamily == 'System'
          ? null
          : settings.readingFontFamily,
      fontWeight:
          FontWeight.values[(settings.readingFontWeight * 9).round()],
      height: settings.readingLineHeight,
      color: theme.textTheme.bodyLarge?.color,
    );

    final textAlign =
        settings.readingJustification ? TextAlign.justify : TextAlign.start;

    // Build the body content — either SelectableText or two-column landscape
    Widget bodyContent;
    if (reader.mode == ReadingMode.twoColumnLandscape) {
      // D4: Two-column landscape — split text into two columns
      final paragraphs = pageContent.split('\n\n');
      final mid = (paragraphs.length / 2).ceil();
      final leftText = paragraphs.take(mid).join('\n\n');
      final rightText = paragraphs.skip(mid).join('\n\n');

      bodyContent = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText.rich(
              TextSpan(text: leftText, style: bodyTextStyle),
              textAlign: textAlign,
              contextMenuBuilder: (context, state) =>
                  _buildSelectionContextMenu(context, state),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SelectableText.rich(
              TextSpan(text: rightText, style: bodyTextStyle),
              textAlign: textAlign,
              contextMenuBuilder: (context, state) =>
                  _buildSelectionContextMenu(context, state),
            ),
          ),
        ],
      );
    } else {
      bodyContent = SelectableText.rich(
        TextSpan(text: pageContent, style: bodyTextStyle),
        textAlign: textAlign,
        contextMenuBuilder: (context, state) =>
            _buildSelectionContextMenu(context, state),
      );
    }

    final showChapterTitle = chapterTitle.isNotEmpty &&
        chapterTitle != widget.book.title;

    return Container(
      color: theme.scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(
        horizontal: settings.readingMargins,
        vertical: DesignTokens.grid16,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (1 - settings.readingLineWidth) * 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Chapter title (only shown if different from book title)
              if (showChapterTitle)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: settings.readingParagraphSpacing * 2,
                  ),
                  child: Text(
                    chapterTitle,
                    style: TextStyle(
                      fontSize: settings.readingFontSize * 1.3,
                      fontWeight: FontWeight.bold,
                      fontFamily: settings.readingFontFamily == 'System'
                          ? null
                          : settings.readingFontFamily,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              bodyContent,
              // Page indicator at bottom
              if (reader.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Center(
                    child: Text(
                      '— Page ${reader.currentPage + 1} of ${reader.totalPages} —',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color
                            ?.withAlpha(100),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ReaderProvider reader,
      ThemeData theme, LibraryProvider library) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: DesignTokens.grid8,
        right: DesignTokens.grid8,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withAlpha(240),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              library.updateBookProgress(
                widget.book.id,
                reader.readingProgress,
                reader.currentPage,
              );
              Navigator.of(context).pop();
            },
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reader.currentChapterTitle.isNotEmpty
                      ? reader.currentChapterTitle
                      : widget.book.title,
                  style: theme.textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  reader.chapters.isNotEmpty
                      ? 'Chapter ${reader.currentChapterIndex + 1} of ${reader.chapters.length} · Page ${reader.currentPage + 1} of ${reader.totalPages}'
                      : 'Page ${reader.currentPage} of ${reader.totalPages}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.textTheme.labelSmall?.color?.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(reader.isTocOpen ? Icons.close : Icons.list),
            onPressed: () => reader.setTocOpen(!reader.isTocOpen),
          ),
          IconButton(
            icon: Icon(
              reader.isCurrentPageBookmarked()
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            onPressed: reader.toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => reader.setSearching(true),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreMenu(context, reader),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, ReaderProvider reader,
      SettingsProvider settings, ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom,
        left: DesignTokens.grid16,
        right: DesignTokens.grid16,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withAlpha(240),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: reader.currentPage.toDouble(),
              min: 0,
              max: reader.totalPages.toDouble(),
              divisions: reader.totalPages > 0 ? reader.totalPages : null,
              onChanged: (value) => reader.goToPage(value.round()),
            ),
          ),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _bottomButton(Icons.chevron_left, 'Prev',
                  () => reader.previousPage()),
              _bottomButton(Icons.format_size, 'Font',
                  () => _showFontSettings(context, settings)),
              _bottomButton(Icons.palette, 'Theme',
                  () => _showThemeSettings(context)),
              _bottomButton(Icons.volume_up, 'TTS',
                  () => reader.setTTSActive(!reader.isTTSActive)),
              _bottomButton(Icons.brightness_6, 'Brightness',
                  () => _showBrightnessSlider(context, settings)),
              _bottomButton(
                  Icons.chevron_right, 'Next', () => reader.nextPage()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 9)),
          ],
        ),
      ),
    );
  }

  // ── More Options Sheet ─────────────────────────────────

  Widget _moreOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.primary),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 11))
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  // ── Table of Contents ──────────────────────────────────

  Widget _buildTocPanel(
      BuildContext context, ReaderProvider reader, ThemeData theme) {
    final chapters = reader.chapters;

    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.grid16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => reader.setTocOpen(false),
                  ),
                  const SizedBox(width: 8),
                  Text('Table of Contents',
                      style: theme.textTheme.titleLarge),
                ],
              ),
            ),
            Expanded(
              child: chapters.isEmpty
                  ? Center(
                      child: Text(
                        'No table of contents available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withAlpha(100),
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: chapters.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final chapter = chapters[index];
                        final isCurrent =
                            index == reader.currentChapterIndex;
                        return ListTile(
                          selected: isCurrent,
                          selectedTileColor:
                              theme.colorScheme.primary.withAlpha(15),
                          title: Text(
                            chapter.title.isNotEmpty
                                ? chapter.title
                                : 'Chapter ${index + 1}',
                            style: TextStyle(
                              fontWeight: isCurrent
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                          ),
                          subtitle: Text(
                            '${chapter.estimatedPages} page${chapter.estimatedPages == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.textTheme.bodySmall?.color
                                  ?.withAlpha(150),
                            ),
                          ),
                          onTap: () {
                            reader.navigateToChapter(index);
                            reader.setTocOpen(false);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search ─────────────────────────────────────────────

  Widget _buildSearchPanel(
      BuildContext context, ReaderProvider reader, ThemeData theme) {
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.grid16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => reader.setSearching(false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search in book…',
                        border: InputBorder.none,
                        filled: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _searchController.text.isEmpty
                  ? Center(
                      child: Text(
                        'Start typing to search',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color
                              ?.withAlpha(100),
                        ),
                      ),
                    )
                  : _buildSearchResults(theme, reader),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getSearchResults(
      String query, ReaderProvider reader) {
    if (query.isEmpty) return [];
    final results = <Map<String, dynamic>>[];
    final q = query.toLowerCase();

    for (int ci = 0; ci < reader.chapters.length; ci++) {
      final chapter = reader.chapters[ci];
      if (chapter.content.isEmpty) continue;

      // Find all occurrences in this chapter
      final text = chapter.content;
      int start = 0;
      while (true) {
        final idx = text.toLowerCase().indexOf(q, start);
        if (idx == -1) break;

        // Extract surrounding context
        final ctxStart = (idx - 40).clamp(0, text.length);
        final ctxEnd = (idx + q.length + 40).clamp(0, text.length);
        final excerpt = text.substring(ctxStart, ctxEnd);

        // Calculate which "page" this would be on
        final page = (idx / 1500).floor();

        results.add({
          'chapter': ci,
          'chapterTitle': chapter.title,
          'page': page,
          'offset': idx,
          'excerpt': excerpt,
        });
        start = idx + 1;
      }
    }

    return results;
  }

  Widget _buildSearchResults(ThemeData theme, ReaderProvider reader) {
    final query = _searchController.text;
    final results = _getSearchResults(query, reader);
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodyMedium?.color?.withAlpha(100),
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        return ListTile(
          title: Text.rich(
            TextSpan(
              children: _buildBoldedText(result['excerpt'] as String, query),
            ),
          ),
          subtitle: Text(
            '${result['chapterTitle']} · Page ${result['page']}',
          ),
          onTap: () {
            // Navigate to the chapter and page
            reader.navigateToChapter(result['chapter'] as int);
            reader.goToPage(result['page'] as int);
            reader.setSearching(false);
          },
        );
      },
    );
  }

  // ── Context Menu, Dialogs, etc. ────────────────────────

  void _showMoreMenu(BuildContext context, ReaderProvider reader) {
    final settings = context.read<SettingsProvider>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final sheetTheme = Theme.of(context);
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _moreOptionTile(context,
                  icon: Icons.phone_android,
                  title: 'Screen On While Reading',
                  trailing: Switch(
                    value: settings.keepScreenOn,
                    onChanged: (v) {
                      settings.setKeepScreenOn(v);
                      setSheetState(() {});
                    },
                  ),
                ),
                _moreOptionTile(context,
                  icon: Icons.nights_stay,
                  title: 'Night Mode by Time',
                  subtitle:
                      '${settings.nightModeStart} – ${settings.nightModeEnd}',
                  trailing: Switch(
                    value: settings.autoNightMode,
                    onChanged: (v) {
                      settings.setAutoNightMode(v);
                      setSheetState(() {});
                    },
                  ),
                ),
                _moreOptionTile(context,
                  icon: Icons.lock,
                  title: 'Lock Library',
                  trailing: Switch(
                    value: settings.appLockEnabled,
                    onChanged: (v) {
                      settings.setAppLockEnabled(v);
                      setSheetState(() {});
                    },
                  ),
                ),
                _moreOptionTile(context,
                  icon: Icons.upload_file,
                  title: 'Import/Export Annotations',
                  trailing: Icon(Icons.chevron_right,
                      color: sheetTheme.textTheme.bodySmall?.color
                          ?.withAlpha(120)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ImportBackupScreen()),
                    );
                  },
                ),
                _moreOptionTile(context,
                  icon: Icons.bookmark,
                  title: 'View All Bookmarks',
                  trailing: Icon(Icons.chevron_right,
                      color: sheetTheme.textTheme.bodySmall?.color
                          ?.withAlpha(120)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BookmarksScreen()),
                    );
                  },
                ),
                _moreOptionTile(context,
                  icon: Icons.menu_book,
                  title: 'Reading Mode',
                  trailing: DropdownButton<ReadingMode>(
                    value: reader.mode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(
                          value: ReadingMode.pagination,
                          child: Text('Pagination')),
                      DropdownMenuItem(
                          value: ReadingMode.continuousScroll,
                          child: Text('Scroll')),
                      DropdownMenuItem(
                          value: ReadingMode.twoColumnLandscape,
                          child: Text('Two Column')),
                    ],
                    onChanged: (mode) {
                      if (mode != null) reader.setReadingMode(mode);
                      setSheetState(() {});
                    },
                  ),
                ),
                _moreOptionTile(context,
                  icon: Icons.translate,
                  title: 'Language',
                  trailing: Text('English >',
                      style: TextStyle(
                          fontSize: 13,
                          color: sheetTheme.textTheme.bodySmall?.color
                              ?.withAlpha(120))),
                  onTap: () => Navigator.pop(context),
                ),
                _moreOptionTile(context,
                  icon: Icons.accessibility,
                  title: 'Accessibility',
                  trailing: Icon(Icons.chevron_right,
                      color: sheetTheme.textTheme.bodySmall?.color
                          ?.withAlpha(120)),
                  onTap: () => Navigator.pop(context),
                ),
                _moreOptionTile(context,
                  icon: Icons.settings,
                  title: 'Advanced Settings',
                  trailing: Icon(Icons.chevron_right,
                      color: sheetTheme.textTheme.bodySmall?.color
                          ?.withAlpha(120)),
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: DesignTokens.grid16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFontSettings(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: FontBottomSheet(
          fontSize: settings.readingFontSize,
          fontFamily: settings.readingFontFamily,
          lineHeight: settings.readingLineHeight,
          paragraphSpacing: settings.readingParagraphSpacing,
          justification: settings.readingJustification,
          onFontSizeChanged: settings.setReadingFontSize,
          onFontFamilyChanged: settings.setReadingFontFamily,
          onLineHeightChanged: settings.setReadingLineHeight,
          onParagraphSpacingChanged: settings.setReadingParagraphSpacing,
          onJustificationChanged: settings.setReadingJustification,
        ),
      ),
    );
  }

  void _showThemeSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: ThemeBottomSheet(
          currentMode: context.read<ThemeProvider>().mode,
          onThemeChanged: (mode) {
            context.read<ThemeProvider>().setTheme(mode);
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }

  void _showBrightnessSlider(
      BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.grid24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Brightness',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: DesignTokens.grid20),
              Row(
                children: [
                  const Icon(Icons.brightness_low),
                  Expanded(
                    child: Slider(
                      value: settings.readingBrightness,
                      onChanged: settings.setReadingBrightness,
                    ),
                  ),
                  const Icon(Icons.brightness_high),
                ],
              ),
              const SizedBox(height: DesignTokens.grid16),
              SwitchListTile(
                title: const Text('Keep Screen On'),
                value: settings.keepScreenOn,
                onChanged: settings.setKeepScreenOn,
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('Auto Night Mode'),
                value: settings.autoNightMode,
                onChanged: settings.setAutoNightMode,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionContextMenu(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.buttonItems(
      anchors: editableTextState.contextMenuAnchors,
      buttonItems: [
        ContextMenuButtonItem(
          label: 'Highlight',
          onPressed: () {
            final selectedText = editableTextState.textEditingValue.selection
                .textInside(editableTextState.textEditingValue.text);
            if (selectedText.isNotEmpty) {
              _addHighlight(selectedText,
                  editableTextState.textEditingValue.selection.start,
                  editableTextState.textEditingValue.selection.end);
            }
            editableTextState.hideToolbar();
          },
        ),
        ContextMenuButtonItem(
          label: 'Dictionary',
          onPressed: () {
            final selectedText = editableTextState.textEditingValue.selection
                .textInside(editableTextState.textEditingValue.text);
            if (selectedText.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Dictionary: $selectedText')),
              );
            }
            editableTextState.hideToolbar();
          },
        ),
        ContextMenuButtonItem(
          label: 'Copy',
          onPressed: () {
            editableTextState.copySelection(SelectionChangedCause.toolbar);
            editableTextState.hideToolbar();
          },
        ),
        ContextMenuButtonItem(
          label: 'Note',
          onPressed: () {
            final selectedText = editableTextState.textEditingValue.selection
                .textInside(editableTextState.textEditingValue.text);
            if (selectedText.isNotEmpty) {
              _showAddNoteDialog(selectedText);
            }
            editableTextState.hideToolbar();
          },
        ),
      ],
    );
  }

  void _addHighlight(String text, int start, int end) {
    // ignore: unused_local_variable
    final highlight = Highlight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: widget.book.id,
      chapterId: 'ch_${_reader.currentPage}',
      text: text,
      startOffset: start,
      endOffset: end,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Text highlighted'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showAddNoteDialog(String selectedText) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedText,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withAlpha(180),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                hintText: 'Write your note…',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(noteController.text.isEmpty
                      ? 'Note saved'
                      : 'Note: ${noteController.text}'),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildBoldedText(String text, String query) {
    if (query.isEmpty) return [TextSpan(text: text)];
    final baseStyle = TextStyle(
      fontSize: 14,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );
    final boldStyle = baseStyle.copyWith(
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (index > start) {
        spans.add(
            TextSpan(text: text.substring(start, index), style: baseStyle));
      }
      spans.add(TextSpan(
          text: text.substring(index, index + query.length),
          style: boldStyle));
      start = index + query.length;
    }
    return spans;
  }
}
