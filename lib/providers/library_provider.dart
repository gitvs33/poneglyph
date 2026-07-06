import 'package:flutter/material.dart';
import '../models/book.dart';
import '../repositories/book_repo.dart';
import '../utils/initializable.dart';

enum LibraryViewMode { grid, list }
enum LibrarySortBy { title, author, recent, progress }

/// Manages the book library. Collections are managed by
/// [CollectionsProvider] — this provider delegates to it.
class LibraryProvider extends ChangeNotifier implements Initializable {
  final BookRepo _repo;

  List<Book> _books = [];
  Book? _continueReading;
  bool _isLoading = false;
  String? _error;
  LibraryViewMode _viewMode = LibraryViewMode.grid;
  LibrarySortBy _sortBy = LibrarySortBy.recent;
  String _searchQuery = '';
  String? _selectedTag;
  bool _isInitialized = false;

  LibraryProvider({required BookRepo repo}) : _repo = repo;

  // ── Public state ───────────────────────────────────────

  List<Book> get books => _filteredAndSortedBooks;
  Book? get continueReading => _continueReading;
  bool get isLoading => _isLoading;
  String? get error => _error;
  LibraryViewMode get viewMode => _viewMode;
  LibrarySortBy get sortBy => _sortBy;
  String get searchQuery => _searchQuery;
  String? get selectedTag => _selectedTag;
  bool get isInitialized => _isInitialized;

  List<String> get allTags {
    final tags = <String>{};
    for (final book in _books) {
      tags.addAll(book.tags);
    }
    return tags.toList()..sort();
  }

  List<String> get allAuthors {
    final authors = <String>{};
    for (final book in _books) {
      authors.add(book.author);
    }
    return authors.toList()..sort();
  }

  List<Book> get recentlyAdded {
    final sorted = List<Book>.from(_books)
      ..sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return sorted.take(5).toList();
  }

  /// Raw unfiltered list — used by SearchProvider.
  List<Book> get allBooks => List.unmodifiable(_books);

  // ── Filtering / sorting ────────────────────────────────

  List<Book> get _filteredAndSortedBooks {
    var result = List<Book>.from(_books);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((b) =>
              b.title.toLowerCase().contains(query) ||
              b.author.toLowerCase().contains(query) ||
              b.tags.any((t) => t.toLowerCase().contains(query)))
          .toList();
    }

    if (_selectedTag != null) {
      result = result.where((b) => b.tags.contains(_selectedTag)).toList();
    }

    switch (_sortBy) {
      case LibrarySortBy.title:
        result.sort((a, b) => a.title.compareTo(b.title));
      case LibrarySortBy.author:
        result.sort((a, b) => a.author.compareTo(b.author));
      case LibrarySortBy.recent:
        result.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      case LibrarySortBy.progress:
        result.sort((a, b) => b.progress.compareTo(a.progress));
    }

    return result;
  }

  // ── Lifecycle ──────────────────────────────────────────

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isLoading = true;
    notifyListeners();

    try {
      _books = List<Book>.from(await _repo.getBooks());
      _recalcContinueReading();
      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = 'Failed to load library';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Mutations ──────────────────────────────────────────

  void setViewMode(LibraryViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSortBy(LibrarySortBy sort) {
    _sortBy = sort;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedTag(String? tag) {
    _selectedTag = tag;
    notifyListeners();
  }

  void updateBookProgress(String bookId, double progress, int currentPage) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index] = _books[index].copyWith(
        progress: progress,
        currentPage: currentPage,
        lastOpenedAt: DateTime.now(),
      );
      _recalcContinueReading();
      notifyListeners();
    }
  }

  void toggleFavorite(String bookId) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index] = _books[index].copyWith(
        isFavorite: !_books[index].isFavorite,
      );
      notifyListeners();
    }
  }

  Future<void> deleteBook(String bookId) async {
    final books = List<Book>.from(_books);
    books.removeWhere((b) => b.id == bookId);
    _books = books;
    await _repo.deleteBook(bookId);
    notifyListeners();
  }

  Future<void> addBook(Book book) async {
    await _repo.saveBook(book);
    _books = List<Book>.from(_books)..add(book);
    notifyListeners();
  }

  /// Update the book's cover image URL (called from cover cache).
  void updateBookCover(String bookId, String? coverUrl) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      _books[index] = _books[index].copyWith(coverUrl: coverUrl);
      notifyListeners();
    }
  }

  void _recalcContinueReading() {
    final inProgress = _books
        .where((b) => b.progress > 0 && b.progress < 1.0)
        .toList();
    _continueReading = inProgress.isEmpty
        ? null
        : inProgress.reduce((a, b) =>
            (a.lastOpenedAt ?? DateTime(2000))
                .compareTo(b.lastOpenedAt ?? DateTime(2000)) >
            0
                ? a
                : b);
  }
}
