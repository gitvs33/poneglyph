import 'package:flutter/material.dart';
import '../models/book.dart';
import '../repositories/book_repo.dart';

/// Search state. Searches the actual book collection
/// via [BookRepo] instead of hardcoded mock data.
class SearchProvider extends ChangeNotifier {
  final BookRepo _repo;

  String _query = '';
  bool _isSearching = false;
  List<String> _recentSearches = [];
  List<SearchResult> _results = [];

  SearchProvider({required BookRepo repo}) : _repo = repo;

  String get query => _query;
  bool get isSearching => _isSearching;
  List<String> get recentSearches => List.unmodifiable(_recentSearches);
  List<SearchResult> get results => List.unmodifiable(_results);

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _isSearching = true;
    _query = query;
    notifyListeners();

    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.sublist(0, 10);
      }
    }

    // Search real books from the repository
    final allBooks = await _repo.getBooks();
    _results = _searchBooks(allBooks, query);

    _isSearching = false;
    notifyListeners();
  }

  void clearSearch() {
    _query = '';
    _results = [];
    notifyListeners();
  }

  void removeRecentSearch(String search) {
    _recentSearches.remove(search);
    notifyListeners();
  }

  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  List<SearchResult> _searchBooks(List<Book> books, String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();

    return books
        .where((b) =>
            b.title.toLowerCase().contains(lowerQuery) ||
            b.author.toLowerCase().contains(lowerQuery) ||
            b.tags.any((t) => t.toLowerCase().contains(lowerQuery)))
        .take(20)
        .map((b) => SearchResult(
              title: b.title,
              author: b.author,
              snippet: 'Book in your library (${b.format.name.toUpperCase()})',
              chapter: 'Page ${b.currentPage} of ${b.totalPages}',
              bookId: b.id,
            ))
        .toList();
  }
}

class SearchResult {
  final String title;
  final String author;
  final String snippet;
  final String chapter;
  final String bookId;

  SearchResult({
    required this.title,
    required this.author,
    required this.snippet,
    required this.chapter,
    required this.bookId,
  });
}
