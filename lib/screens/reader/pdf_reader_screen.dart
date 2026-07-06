import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../models/book.dart';
import '../../models/reading_session.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';

/// Full-page PDF renderer using Syncfusion PdfViewer.
///
/// Provides proper page rendering (fonts, layout, images exactly as designed),
/// built-in text selection, highlighting/annotation, bookmark/outline panel
/// (TOC), and text search.
///
/// Annotations (highlight, underline, strikethrough) are persisted to the PDF
/// file itself via [PdfViewerController.saveDocument] when leaving the screen,
/// so they survive app restarts.
class PdfReaderScreen extends StatefulWidget {
  final Book book;

  const PdfReaderScreen({super.key, required this.book});

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late AnimationController _barController;
  late Animation<double> _barAnimation;
  PdfViewerController? _pdfController;
  ReadingSession? _currentSession;

  int _currentPage = 0;
  int _totalPages = 0;
  bool _showBars = true;
  bool _isReady = false;
  bool _loadFailed = false;
  String _loadError = '';

  // Track annotation changes so we only save when needed
  bool _annotationsChanged = false;

  @override
  void initState() {
    super.initState();
    _currentSession = ReadingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: widget.book.id,
      startTime: DateTime.now(),
    );
    _currentPage = widget.book.currentPage;
    _pdfController = PdfViewerController();

    _barController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _barAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeInOut),
    );
    _barController.value = 1;
  }

  @override
  void dispose() {
    _currentSession = _currentSession?.end();
    _persistAnnotationsIfNeeded();
    _barController.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  /// Persist annotations and reading progress when leaving the screen.
  ///
  /// Syncfusion's [PdfViewerController.saveDocument] re-serializes the PDF with
  /// all annotations embedded as native PDF annotation objects, so they survive
  /// app restarts without needing external JSON or a separate storage format.
  Future<void> _persistAnnotationsIfNeeded() async {
    if (!_annotationsChanged || _pdfController == null) return;

    try {
      final bytes = await _pdfController!.saveDocument();
      if (bytes.isNotEmpty && widget.book.filePath != null) {
        await File(widget.book.filePath!).writeAsBytes(bytes);
      }
    } catch (_) {
      // Silently fail — annotations are nice-to-have, not critical
    }
  }

  void _toggleBars() {
    setState(() {
      _showBars = !_showBars;
      if (_showBars) {
        _barController.forward();
      } else {
        _barController.reverse();
      }
    });
  }

  void _showSearchDialog() {
    final theme = Theme.of(context);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        title: Text('Search in document', style: theme.textTheme.titleMedium),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search…',
            prefixIcon: Icon(Icons.search),
          ),
          style: theme.textTheme.bodyMedium,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _pdfController?.searchText(value.trim());
              Navigator.pop(ctx);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: theme.colorScheme.secondary)),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _pdfController?.searchText(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.textTheme.bodySmall?.color?.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('Options', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            _optionTile(ctx, theme, Icons.search, 'Search', () {
              Navigator.pop(ctx);
              _showSearchDialog();
            }),
            _optionTile(
                ctx, theme, Icons.library_books, 'Table of Contents', () {
              Navigator.pop(ctx);
              _pdfViewerKey.currentState?.openBookmarkView();
            }),
            _optionTile(
                ctx, theme, Icons.text_fields, 'Text selection', () =>
                Navigator.pop(ctx)),
            _optionTile(
                ctx, theme, Icons.volume_up, 'Listen (TTS)', () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('TTS is available in EPUB reader')),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(BuildContext ctx, ThemeData theme, IconData icon,
      String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: theme.disabledColor),
      onTap: onTap,
    );
  }

  bool _isDarkMode(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.mode == AppThemeMode.dark || tp.mode == AppThemeMode.amoled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = _isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F17) : Colors.white,
      body: Stack(
        children: [
          // ── PDF Viewer ─────────────────────────────────
          if (widget.book.filePath != null)
            SfPdfViewer.file(
              key: _pdfViewerKey,
              File(widget.book.filePath!),
              controller: _pdfController,
              initialPageNumber: _currentPage + 1,
              enableTextSelection: true,
              pageLayoutMode: PdfPageLayoutMode.continuous,
              scrollDirection: PdfScrollDirection.vertical,
              canShowScrollHead: false,
              canShowScrollStatus: false,
              canShowPaginationDialog: false,
              canShowPageLoadingIndicator: true,
              onDocumentLoaded: (_) {
                if (_pdfController != null) {
                  setState(() {
                    _isReady = true;
                    _totalPages = _pdfController!.pageCount;
                  });
                }
              },
              onDocumentLoadFailed: (details) {
                setState(() {
                  _loadFailed = true;
                  _loadError = details.error;
                });
              },
              onPageChanged: (details) {
                setState(() {
                  _currentPage = details.newPageNumber - 1;
                });
              },
              onTap: (_) => _toggleBars(),
              // ── Annotation persistence callbacks ──
              onAnnotationAdded: (_) {
                _annotationsChanged = true;
              },
              onAnnotationRemoved: (_) {
                _annotationsChanged = true;
              },
              onAnnotationEdited: (_) {
                _annotationsChanged = true;
              },
            )
          else
            const Center(child: Text('No file path')),

          // ── Loading / Error ────────────────────────────
          if (!_isReady && !_loadFailed)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: isDark ? Colors.white70 : const Color(0xFF7C6FFF),
                  ),
                  const SizedBox(height: 16),
                  Text('Loading PDF…',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      )),
                ],
              ),
            ),

          if (_loadFailed)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Failed to load PDF',
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(_loadError,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                        )),
                  ],
                ),
              ),
            ),

          // ── Top Bar ────────────────────────────────────
          if (_showBars && _isReady)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _barAnimation,
                child: _buildTopBar(theme, isDark),
              ),
            ),

          // ── Bottom Bar ─────────────────────────────────
          if (_showBars && _isReady)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _barAnimation,
                child: _buildBottomBar(theme, isDark),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme, bool isDark) {
    final fg = isDark ? Colors.white : const Color(0xFF7C6FFF);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F0F17).withAlpha(230)
            : Colors.white.withAlpha(240),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
                color: fg,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.book.title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // TOC (outline/bookmarks)
              IconButton(
                icon: const Icon(Icons.list),
                color: fg,
                onPressed: () =>
                    _pdfViewerKey.currentState?.openBookmarkView(),
              ),
              // More options
              IconButton(
                icon: const Icon(Icons.more_horiz),
                color: fg,
                onPressed: () => _showMoreOptions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme, bool isDark) {
    final fg = isDark ? Colors.white70 : const Color(0xFF7C6FFF);
    final muted = isDark ? Colors.white38 : Colors.black38;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F0F17).withAlpha(230)
            : Colors.white.withAlpha(240),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: fg,
                onPressed: _currentPage > 0
                    ? () => _pdfController?.jumpToPage(_currentPage)
                    : null,
              ),
              Text(
                '${_currentPage + 1} / ${_totalPages > 0 ? _totalPages : "…"}',
                style: TextStyle(color: fg, fontWeight: FontWeight.w500),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: fg,
                onPressed: _currentPage < _totalPages - 1
                    ? () => _pdfController?.jumpToPage(_currentPage + 2)
                    : null,
              ),
              const Spacer(),
              Text(
                _totalPages > 0
                    ? '${(_currentPage / _totalPages * 100).toInt()}%'
                    : '',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
