import 'dart:async';
import '../models/book.dart';
import '../models/collection.dart';
import '../models/highlight.dart';
import '../models/reading_progress.dart';

class DatabaseService {
  // In-memory storage for demo purposes
  final List<Book> _books = [];
  final List<Collection> _collections = [];
  final List<Highlight> _highlights = [];
  final Map<String, ReadingProgress> _progress = {};

  // Future implementation will use sqflite

  // Books
  Future<List<Book>> getBooks() async => List.unmodifiable(_books);

  Future<List<Book>> getBooksByCollection(String collectionId) async =>
      _books.where((b) => b.collectionId == collectionId).toList();

  Future<Book?> getBook(String id) async {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addBook(Book book) async {
    _books.add(book);
  }

  Future<void> updateBook(Book book) async {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book;
    }
  }

  Future<void> deleteBook(String id) async {
    _books.removeWhere((b) => b.id == id);
  }

  // Collections
  Future<List<Collection>> getCollections() async => List.unmodifiable(_collections);

  Future<void> addCollection(Collection collection) async {
    _collections.add(collection);
  }

  Future<void> updateCollection(Collection collection) async {
    final index = _collections.indexWhere((c) => c.id == collection.id);
    if (index != -1) {
      _collections[index] = collection;
    }
  }

  Future<void> deleteCollection(String id) async {
    _collections.removeWhere((c) => c.id == id);
  }

  // Highlights
  Future<List<Highlight>> getHighlights(String bookId) async =>
      _highlights.where((h) => h.bookId == bookId).toList();

  Future<List<Highlight>> getAllHighlights() async => List.unmodifiable(_highlights);

  Future<void> addHighlight(Highlight highlight) async {
    _highlights.add(highlight);
  }

  Future<void> updateHighlight(Highlight highlight) async {
    final index = _highlights.indexWhere((h) => h.id == highlight.id);
    if (index != -1) {
      _highlights[index] = highlight;
    }
  }

  Future<void> deleteHighlight(String id) async {
    _highlights.removeWhere((h) => h.id == id);
  }

  // Reading Progress
  Future<ReadingProgress?> getProgress(String bookId) async => _progress[bookId];

  Future<void> saveProgress(ReadingProgress progress) async {
    _progress[progress.bookId] = progress;
  }

  // Seed data for demo
  Future<void> seedDemoData() async {
    if (_books.isNotEmpty) return;

    final demoBooks = [
      Book(
        id: '1',
        title: 'The Great Gatsby',
        author: 'F. Scott Fitzgerald',
        format: BookFormat.epub,
        totalPages: 180,
        currentPage: 120,
        progress: 0.67,
        tags: ['Classic', 'Fiction'],
        isFavorite: true,
      ),
      Book(
        id: '2',
        title: 'To Kill a Mockingbird',
        author: 'Harper Lee',
        format: BookFormat.pdf,
        totalPages: 324,
        currentPage: 200,
        progress: 0.62,
        tags: ['Classic', 'Drama'],
      ),
      Book(
        id: '3',
        title: '1984',
        author: 'George Orwell',
        format: BookFormat.epub,
        totalPages: 328,
        currentPage: 50,
        progress: 0.15,
        tags: ['Dystopian', 'Fiction'],
      ),
      Book(
        id: '4',
        title: 'Pride and Prejudice',
        author: 'Jane Austen',
        format: BookFormat.mobi,
        totalPages: 432,
        currentPage: 432,
        progress: 1.0,
        tags: ['Classic', 'Romance'],
        isFavorite: true,
      ),
      Book(
        id: '5',
        title: 'The Hobbit',
        author: 'J.R.R. Tolkien',
        format: BookFormat.epub,
        totalPages: 310,
        currentPage: 0,
        tags: ['Fantasy', 'Adventure'],
      ),
      Book(
        id: '6',
        title: 'Dune',
        author: 'Frank Herbert',
        format: BookFormat.pdf,
        totalPages: 688,
        currentPage: 100,
        progress: 0.15,
        tags: ['Sci-Fi', 'Epic'],
      ),
      Book(
        id: '7',
        title: 'The Catcher in the Rye',
        author: 'J.D. Salinger',
        format: BookFormat.epub,
        totalPages: 240,
        tags: ['Classic', 'Coming of Age'],
      ),
      Book(
        id: '8',
        title: 'Brave New World',
        author: 'Aldous Huxley',
        format: BookFormat.mobi,
        totalPages: 311,
        currentPage: 311,
        progress: 1.0,
        tags: ['Dystopian', 'Classic'],
      ),
    ];

    for (final book in demoBooks) {
      await addBook(book);
    }

    final demoCollections = [
      Collection(id: 'c1', name: 'Favorites', icon: 'star', bookIds: ['1', '4']),
      Collection(id: 'c2', name: 'Classics', icon: 'book', bookIds: ['1', '2', '4', '7']),
      Collection(id: 'c3', name: 'Sci-Fi & Fantasy', icon: 'rocket', bookIds: ['5', '6']),
      Collection(id: 'c4', name: 'To Read', icon: 'playlist_add', bookIds: ['7']),
    ];

    for (final collection in demoCollections) {
      await addCollection(collection);
    }
  }
}
