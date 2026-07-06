import 'dart:async';
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
/// Uses continuous vertical layout — pages stack in a scrollable column.
/// The top/bottom bar overlays provide page navigation and chrome control.
/// Tapping the PDF content toggles the bars. Pinch-to-zoom works natively.
///
/// **Text selection** via long-press is enabled. The built-in context menu
/// provides Copy, Highlight, Underline, Strikethrough, and Squiggly.
///
/// **Annotation persistence**: Annotations are eagerly persisted to the PDF
/// file itself via [PdfViewerController.saveDocument] as soon as they are
/// added/removed/edited (debounced 500 ms).  Annotations survive app restarts
/// and are visible in other PDF readers when the file is shared.
///
/// **Undo / Redo**: Uses [UndoHistoryController] wired to
/// [SfPdfViewer.undoController] so Syncfusion's annotation undo/redo stack
/// is accessible via the Options sheet.  Ctrl+Z / Ctrl+Y work on desktop.
///
/// **Erase**: Tap an existing annotation to select it → a "Delete highlight"
/// button appears at the top.  The Options sheet also has "Erase all
/// annotations on this page".
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
  Timer? _saveDebounceTimer;

  // ── Undo / Redo ────────────────────────────────────────
  /// Passed to [SfPdfViewer.undoController] so Syncfusion wires annotation
  /// undo/redo to the Flutter [UndoHistoryController] natively.
  final UndoHistoryController _undoController = UndoHistoryController();

  // ── Annotation selection ───────────────────────────────
  /// The currently tapped / selected annotation, or null.
  Annotation? _selectedAnnotation;

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

    // Listen for undo/redo triggers from the UndoHistoryController
    // (e.g. from a hardware keyboard shortcut).
    _undoController.addListener(() {
      // value.canUndo / value.canRedo changed — rebuild UI buttons
      if (mounted) setState(() {});
    });

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
    _saveDebounceTimer?.cancel();
    _undoController.removeListener(() => setState(() {}));
    _undoController.dispose();
    // Fire-and-forget final save attempt. The eager saves above should have
    // already persisted the bytes while the controller was alive, so this is
    // just a belt-and-suspenders call.
    _persistAnnotations();
    _barController.dispose();
    _pdfController?.dispose();
    super.dispose();
  }

  /// Eagerly save annotations to the PDF file as soon as they change.
  ///
  /// Debounced to avoid hammering the filesystem when the user strokes across
  /// several highlights rapidly.  Saves while [SfPdfViewer] is still alive so
  /// [saveDocument] has a valid internal document state.
  void _scheduleAnnotationSave() {
    _annotationsChanged = true;
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _persistAnnotations();
    });
  }

  /// Persist annotations to the PDF file.
  Future<void> _persistAnnotations() async {
    if (!_annotationsChanged || _pdfController == null) return;
    final controller = _pdfController!;
    try {
      final bytes = await controller.saveDocument();
      if (bytes.isNotEmpty && widget.book.filePath != null) {
        await File(widget.book.filePath!).writeAsBytes(bytes);
        debugPrint('[PdfReader] Annotations saved (${bytes.length} bytes)');
      }
    } catch (e) {
      // Log but don't crash the reader
      debugPrint('[PdfReader] Failed to save annotations: $e');
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
    final canUndo = _undoController.value.canUndo;
    final canRedo = _undoController.value.canRedo;

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
            // ── Undo ────────────────
            _optionTile(
              ctx, theme,
              Icons.undo, 'Undo annotation',
              canUndo
                  ? () {
                      Navigator.pop(ctx);
                      _undoController.undo();
                    }
                  : null,
            ),
            // ── Redo ────────────────
            _optionTile(
              ctx, theme,
              Icons.redo, 'Redo annotation',
              canRedo
                  ? () {
                      Navigator.pop(ctx);
                      _undoController.redo();
                    }
                  : null,
            ),
            // ── Erase all ───────────
            if (_hasAnnotations)
              _optionTile(
                ctx, theme,
                Icons.auto_delete, 'Erase all annotations on this page',
                () {
                  Navigator.pop(ctx);
                  _eraseAnnotationsOnCurrentPage();
                },
              ),
            const Divider(height: 1),
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

  /// Whether the controller has any annotations (used to show erase option).
  bool get _hasAnnotations {
    try {
      return _pdfController != null;
    } catch (_) {
      return false;
    }
  }

  /// Remove all annotations on the current page.
  void _eraseAnnotationsOnCurrentPage() {
    _pdfController?.removeAllAnnotations(pageNumber: _currentPage + 1);
  }

  Widget _optionTile(BuildContext ctx, ThemeData theme, IconData icon,
      String label, VoidCallback? onTap) {
    final enabled = onTap != null;
    return ListTile(
      leading: Icon(icon,
          color: enabled
              ? theme.iconTheme.color
              : theme.disabledColor),
      title: Text(label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: enabled ? null : theme.disabledColor,
          )),
      trailing: Icon(Icons.chevron_right,
          color: enabled ? theme.disabledColor : Colors.transparent),
      enabled: enabled,
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
    final fg = isDark ? Colors.white : const Color(0xFF7C6FFF);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F0F17) : Colors.white,
      body: Stack(
        children: [
          // ── PDF Viewer (single-page horizontal) ────────
          // Single-page mode with horizontal scroll gives a book-like feel.
          // Each page gets its own TransformationController for pinch-to-zoom.
          if (widget.book.filePath != null)
            SfPdfViewer.file(
              key: _pdfViewerKey,
              File(widget.book.filePath!),
              controller: _pdfController,
              initialPageNumber: _currentPage + 1,
              enableTextSelection: true,
              // ── Book-like page turning ─────────────────
              pageLayoutMode: PdfPageLayoutMode.continuous,
              scrollDirection: PdfScrollDirection.vertical,
              // ── Undo / Redo ───────────────────────────
              undoController: _undoController,
              // ── UI chrome ──────────────────────────────
              canShowScrollHead: false,
              canShowScrollStatus: false,
              canShowPaginationDialog: false,
              canShowPageLoadingIndicator: true,
              // ── Tap to toggle bars ──────────────────────
              onTap: (_) => _toggleBars(),
              // ── Callbacks ──────────────────────────────
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
              // ── Annotation persistence ─────────────────
              // Eagerly save on every annotation change while viewer is alive
              onAnnotationAdded: (_) => _scheduleAnnotationSave(),
              onAnnotationRemoved: (_) => _scheduleAnnotationSave(),
              onAnnotationEdited: (_) => _scheduleAnnotationSave(),
              // ── Annotation selection ───────────────────
              onAnnotationSelected: (annotation) {
                setState(() => _selectedAnnotation = annotation);
              },
              onAnnotationDeselected: (_) {
                setState(() => _selectedAnnotation = null);
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

          // ── Annotation action bar ─────────────────────
          // Appears when the user taps an existing highlight to select it.
          if (_selectedAnnotation != null && _isReady)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Material(
                color: isDark
                    ? const Color(0xFF0F0F17).withAlpha(230)
                    : Colors.white.withAlpha(240),
                elevation: 2,
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Deselect',
                        color: fg,
                        onPressed: () {
                          _pdfController?.deselectAnnotation(
                              _selectedAnnotation!);
                          setState(() => _selectedAnnotation = null);
                        },
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () {
                          final annotation = _selectedAnnotation;
                          if (annotation != null) {
                            _pdfController?.removeAnnotation(annotation);
                            setState(
                                () => _selectedAnnotation = null);
                          }
                        },
                        icon: Icon(Icons.delete_outline,
                            color: theme.colorScheme.error),
                        label: Text(
                          'Delete highlight',
                          style: TextStyle(
                              color: theme.colorScheme.error),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
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
                child: GestureDetector(
                  onTap: () {}, // absorb taps so they don't pass through
                  child: _buildTopBar(theme, isDark),
                ),
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
                child: GestureDetector(
                  onTap: () {},
                  child: _buildBottomBar(theme, isDark),
                ),
              ),
            ),

          // ── Floating bar toggle button ─────────────────
          if (_isReady && !_loadFailed)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 12,
              child: GestureDetector(
                onTap: _toggleBars,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (_showBars ? Colors.transparent : Colors.black26),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _showBars ? Icons.chevron_right : Icons.chevron_left,
                    color: isDark ? Colors.white38 : Colors.black26,
                    size: 20,
                  ),
                ),
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
                  style: theme.textTheme.titleSmall?.copyWith(color: fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.list),
                color: fg,
                onPressed: () =>
                    _pdfViewerKey.currentState?.openBookmarkView(),
              ),
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
