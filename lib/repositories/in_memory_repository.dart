import '../models/book.dart';
import '../models/collection.dart';
import '../models/highlight.dart';
import '../models/reading_progress.dart';
import 'book_repository.dart';

/// In-memory adapter for development and testing.
/// No disk I/O, no persistence across restarts.
class InMemoryRepository implements BookRepository {
  final List<Book> _books = [];
  final List<Collection> _collections = [];
  final List<Highlight> _highlights = [];
  final Map<String, ReadingProgress> _progress = {};

  // ── Books ──────────────────────────────────────────────

  @override
  Future<List<Book>> getBooks() async => List.unmodifiable(_books);

  @override
  Future<List<Book>> getBooksByCollection(String collectionId) async {
    final col = _collections.where((c) => c.id == collectionId).firstOrNull;
    if (col == null) return [];
    return _books.where((b) => col.bookIds.contains(b.id)).toList();
  }

  @override
  Future<Book?> getBook(String id) async {
    return _books.where((b) => b.id == id).firstOrNull;
  }

  @override
  Future<void> saveBook(Book book) async {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book;
    } else {
      _books.add(book);
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    _books.removeWhere((b) => b.id == id);
  }

  // ── Collections ────────────────────────────────────────

  @override
  Future<List<Collection>> getCollections() async =>
      List.unmodifiable(_collections);

  @override
  Future<void> saveCollection(Collection collection) async {
    final index = _collections.indexWhere((c) => c.id == collection.id);
    if (index != -1) {
      _collections[index] = collection;
    } else {
      _collections.add(collection);
    }
  }

  @override
  Future<void> deleteCollection(String id) async {
    _collections.removeWhere((c) => c.id == id);
  }

  // ── Highlights ─────────────────────────────────────────

  @override
  Future<List<Highlight>> getHighlights(String bookId) async =>
      _highlights.where((h) => h.bookId == bookId).toList();

  @override
  Future<List<Highlight>> getAllHighlights() async =>
      List.unmodifiable(_highlights);

  @override
  Future<void> saveHighlight(Highlight highlight) async {
    final index = _highlights.indexWhere((h) => h.id == highlight.id);
    if (index != -1) {
      _highlights[index] = highlight;
    } else {
      _highlights.add(highlight);
    }
  }

  @override
  Future<void> deleteHighlight(String id) async {
    _highlights.removeWhere((h) => h.id == id);
  }

  // ── Reading Progress ───────────────────────────────────

  @override
  Future<ReadingProgress?> getProgress(String bookId) async =>
      _progress[bookId];

  @override
  Future<void> saveProgress(ReadingProgress progress) async {
    _progress[progress.bookId] = progress;
  }

}
