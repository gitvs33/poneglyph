import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/highlight.dart';
import '../models/reading_session.dart';
import '../services/ebook_content_service.dart';

enum ReadingMode { pagination, continuousScroll, twoColumnLandscape }

/// Ephemeral reading session state that now holds real ebook content
/// parsed from the actual file (via [EbookContentService]).
class ReaderProvider extends ChangeNotifier {
  // ── Session state ──────────────────────────────────────

  Book? _currentBook;
  ReadingMode _mode = ReadingMode.pagination;
  int _currentPage = 0;
  int _totalPages = 0;
  double _scrollPosition = 0.0;
  bool _isTTSActive = false;
  List<Highlight> _highlights = [];
  ReadingSession? _currentSession;
  Set<String> _bookmarkedPages = {};

  // Toolbar / overlay state
  bool _showBars = true;
  bool _isSearching = false;
  bool _isTocOpen = false;

  // ── Ebook content ──────────────────────────────────────

  List<EbookChapter> _chapters = [];
  int _currentChapterIndex = 0;

  // ── Getters ────────────────────────────────────────────

  Book? get currentBook => _currentBook;
  ReadingMode get mode => _mode;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  double get scrollPosition => _scrollPosition;
  bool get isTTSActive => _isTTSActive;
  List<Highlight> get highlights => _highlights;
  ReadingSession? get currentSession => _currentSession;
  Set<String> get bookmarkedPages => _bookmarkedPages;
  bool get showBars => _showBars;
  bool get isSearching => _isSearching;
  bool get isTocOpen => _isTocOpen;
  double get readingProgress =>
      _totalPages > 0 ? _currentPage / _totalPages : 0.0;

  // ── New content getters ────────────────────────────────

  List<EbookChapter> get chapters => _chapters;
  int get currentChapterIndex => _currentChapterIndex;

  EbookChapter? get currentChapter =>
      _chapters.isNotEmpty && _currentChapterIndex < _chapters.length
          ? _chapters[_currentChapterIndex]
          : null;

  String get currentChapterTitle =>
      currentChapter?.title ?? _currentBook?.title ?? '';

  // ── Content loading ────────────────────────────────────

  /// Load parsed ebook content into the reader.
  void loadContent(EbookContent content) {
    _chapters = content.chapters;
    _currentChapterIndex = 0;
    _currentPage = 0;
    _totalPages = _chapters.isNotEmpty ? _chapters[0].estimatedPages : 0;
    notifyListeners();
  }

  // ── Session lifecycle ──────────────────────────────────

  void openBook(Book book) {
    _currentBook = book;
    _totalPages = book.totalPages > 0 ? book.totalPages : 1;
    _currentPage = book.currentPage.clamp(0, _totalPages);
    _currentSession = ReadingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: book.id,
      startTime: DateTime.now(),
    );
    _highlights = [];
    _showBars = true;
    _isSearching = false;
    _isTocOpen = false;
    _chapters = [];
    _currentChapterIndex = 0;
    notifyListeners();
  }

  void closeBook() {
    _currentSession = _currentSession?.end();
    _currentBook = null;
    notifyListeners();
  }

  // ── Navigation ─────────────────────────────────────────

  void setReadingMode(ReadingMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void goToPage(int page) {
    if (_totalPages <= 0) return;
    _currentPage = page.clamp(0, _totalPages);
    notifyListeners();
  }

  void nextPage() {
    if (_chapters.isEmpty) {
      // No loaded content – just increment page if possible
      if (_currentPage < _totalPages) {
        _currentPage++;
        notifyListeners();
      }
      return;
    }

    if (_currentPage < _totalPages - 1) {
      // Still in current chapter
      _currentPage++;
      notifyListeners();
    } else if (_currentChapterIndex < _chapters.length - 1) {
      // Move to next chapter
      _currentChapterIndex++;
      _currentPage = 0;
      _totalPages = _chapters[_currentChapterIndex].estimatedPages;
      notifyListeners();
    }
    // else – end of book, do nothing
  }

  void previousPage() {
    if (_chapters.isEmpty) {
      if (_currentPage > 0) {
        _currentPage--;
        notifyListeners();
      }
      return;
    }

    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    } else if (_currentChapterIndex > 0) {
      // Move to previous chapter, last page
      _currentChapterIndex--;
      final prevCh = _chapters[_currentChapterIndex];
      _totalPages = prevCh.estimatedPages;
      _currentPage = _totalPages - 1;
      notifyListeners();
    }
  }

  /// Jump to a specific chapter by index.
  void navigateToChapter(int index) {
    if (index < 0 || index >= _chapters.length) return;
    _currentChapterIndex = index;
    _currentPage = 0;
    _totalPages = _chapters[index].estimatedPages;
    notifyListeners();
  }

  void setScrollPosition(double position) {
    _scrollPosition = position;
    notifyListeners();
  }

  // ── Toolbar ────────────────────────────────────────────

  void toggleBars() {
    _showBars = !_showBars;
    notifyListeners();
  }

  void setShowBars(bool value) {
    _showBars = value;
    notifyListeners();
  }

  // ── Bookmarks ──────────────────────────────────────────

  void toggleBookmark() {
    final pageKey = '${_currentBook?.id}_$_currentChapterIndex:$_currentPage';
    if (_bookmarkedPages.contains(pageKey)) {
      _bookmarkedPages.remove(pageKey);
    } else {
      _bookmarkedPages.add(pageKey);
    }
    notifyListeners();
  }

  bool isCurrentPageBookmarked() {
    final pageKey = '${_currentBook?.id}_$_currentChapterIndex:$_currentPage';
    return _bookmarkedPages.contains(pageKey);
  }

  // ── TTS ────────────────────────────────────────────────

  void setTTSActive(bool active) {
    _isTTSActive = active;
    notifyListeners();
  }

  // ── Overlays ───────────────────────────────────────────

  void setSearching(bool value) {
    _isSearching = value;
    notifyListeners();
  }

  void setTocOpen(bool value) {
    _isTocOpen = value;
    notifyListeners();
  }
}
