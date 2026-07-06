import 'dart:convert';
import 'dart:io';

import '../models/book.dart';
import '../models/collection.dart';
import '../models/highlight.dart';
import '../models/reading_progress.dart';
import 'book_repo.dart';
import 'collection_repo.dart';
import 'highlight_repo.dart';
import 'progress_repo.dart';

/// Disk-backed adapter that persists each entity type as a separate
/// JSON file in the app's documents directory.
///
/// This validates the repository seam with a real second adapter.
/// Each write overwrites the entire corresponding file (simple,
/// crash-safe for the data volumes expected in a personal reader app).
class FileBackedRepository
    implements BookRepo, CollectionRepo, HighlightRepo, ProgressRepo {
  final Directory _dir;

  FileBackedRepository(this._dir);

  // ── File paths ─────────────────────────────────────────

  File get _booksFile => File('${_dir.path}/repo_books.json');
  File get _collectionsFile => File('${_dir.path}/repo_collections.json');
  File get _highlightsFile => File('${_dir.path}/repo_highlights.json');
  File get _progressFile => File('${_dir.path}/repo_progress.json');

  // ── BookRepo ───────────────────────────────────────────

  @override
  Future<List<Book>> getBooks() async {
    if (!await _booksFile.exists()) return [];
    final raw = await _booksFile.readAsString();
    final list = jsonDecode(raw) as List;
    return list.map((e) => Book.fromJson(e)).toList();
  }

  @override
  Future<List<Book>> getBooksByCollection(String collectionId) async {
    final collections = await getCollections();
    final col = collections.where((c) => c.id == collectionId).firstOrNull;
    if (col == null) return [];
    final books = await getBooks();
    return books.where((b) => col.bookIds.contains(b.id)).toList();
  }

  @override
  Future<Book?> getBook(String id) async {
    final books = await getBooks();
    return books.where((b) => b.id == id).firstOrNull;
  }

  @override
  Future<void> saveBook(Book book) async {
    final books = await getBooks();
    final index = books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      final list = [...books];
      list[index] = book;
      await _writeBooks(list);
    } else {
      await _writeBooks([...books, book]);
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    final books = await getBooks();
    books.removeWhere((b) => b.id == id);
    await _writeBooks(books);
  }

  Future<void> _writeBooks(List<Book> books) async {
    final list = books.map((b) => b.toJson()).toList();
    await _booksFile.writeAsString(jsonEncode(list));
  }

  // ── CollectionRepo ─────────────────────────────────────

  @override
  Future<List<Collection>> getCollections() async {
    if (!await _collectionsFile.exists()) return [];
    final raw = await _collectionsFile.readAsString();
    final list = jsonDecode(raw) as List;
    return list.map((e) => Collection.fromJson(e)).toList();
  }

  @override
  Future<void> saveCollection(Collection collection) async {
    final cols = await getCollections();
    final index = cols.indexWhere((c) => c.id == collection.id);
    if (index != -1) {
      final list = [...cols];
      list[index] = collection;
      await _writeCollections(list);
    } else {
      await _writeCollections([...cols, collection]);
    }
  }

  @override
  Future<void> deleteCollection(String id) async {
    final cols = await getCollections();
    cols.removeWhere((c) => c.id == id);
    await _writeCollections(cols);
  }

  Future<void> _writeCollections(List<Collection> collections) async {
    final list = collections.map((c) => c.toJson()).toList();
    await _collectionsFile.writeAsString(jsonEncode(list));
  }

  // ── HighlightRepo ──────────────────────────────────────

  @override
  Future<List<Highlight>> getHighlights(String bookId) async {
    final all = await getAllHighlights();
    return all.where((h) => h.bookId == bookId).toList();
  }

  @override
  Future<List<Highlight>> getAllHighlights() async {
    if (!await _highlightsFile.exists()) return [];
    final raw = await _highlightsFile.readAsString();
    final list = jsonDecode(raw) as List;
    return list.map((e) => Highlight.fromJson(e)).toList();
  }

  @override
  Future<void> saveHighlight(Highlight highlight) async {
    final all = await getAllHighlights();
    final index = all.indexWhere((h) => h.id == highlight.id);
    if (index != -1) {
      final list = [...all];
      list[index] = highlight;
      await _writeHighlights(list);
    } else {
      await _writeHighlights([...all, highlight]);
    }
  }

  @override
  Future<void> deleteHighlight(String id) async {
    final all = await getAllHighlights();
    all.removeWhere((h) => h.id == id);
    await _writeHighlights(all);
  }

  Future<void> _writeHighlights(List<Highlight> highlights) async {
    final list = highlights.map((h) => h.toJson()).toList();
    await _highlightsFile.writeAsString(jsonEncode(list));
  }

  // ── ProgressRepo ───────────────────────────────────────

  @override
  Future<ReadingProgress?> getProgress(String bookId) async {
    if (!await _progressFile.exists()) return null;
    final raw = await _progressFile.readAsString();
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map[bookId] != null
        ? ReadingProgress.fromJson(map[bookId])
        : null;
  }

  @override
  Future<void> saveProgress(ReadingProgress progress) async {
    final map = <String, dynamic>{};
    if (await _progressFile.exists()) {
      final raw = await _progressFile.readAsString();
      final existing = jsonDecode(raw) as Map<String, dynamic>;
      for (final entry in existing.entries) {
        map[entry.key] = entry.value;
      }
    }
    map[progress.bookId] = progress.toJson();
    await _progressFile.writeAsString(jsonEncode(map));
  }
}
