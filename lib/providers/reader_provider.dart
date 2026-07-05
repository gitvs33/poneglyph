import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/highlight.dart';
import '../models/reading_session.dart';

enum ReadingMode { pagination, continuousScroll, twoColumnLandscape }

/// Ephemeral reading session state. Persistent reading settings
/// (font, margins, brightness, etc.) live in [SettingsProvider].
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

  // ── Session lifecycle ──────────────────────────────────

  void openBook(Book book) {
    _currentBook = book;
    _totalPages = book.totalPages;
    _currentPage = book.currentPage;
    _currentSession = ReadingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: book.id,
      startTime: DateTime.now(),
    );
    _highlights = [];
    _showBars = true;
    _isSearching = false;
    _isTocOpen = false;
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
    _currentPage = page.clamp(0, _totalPages);
    notifyListeners();
  }

  void nextPage() {
    if (_currentPage < _totalPages) {
      _currentPage++;
      notifyListeners();
    }
  }

  void previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
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
    final pageKey = '${_currentBook?.id}_$_currentPage';
    if (_bookmarkedPages.contains(pageKey)) {
      _bookmarkedPages.remove(pageKey);
    } else {
      _bookmarkedPages.add(pageKey);
    }
    notifyListeners();
  }

  bool isCurrentPageBookmarked() {
    final pageKey = '${_currentBook?.id}_$_currentPage';
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
