import '../models/book.dart';
import '../models/collection.dart';
import '../models/highlight.dart';
import '../models/reading_progress.dart';

/// Abstract persistence interface. Implementations provide
/// storage backends (in-memory, SQLite, cloud, etc.).
abstract class BookRepository {
  // Books
  Future<List<Book>> getBooks();
  Future<List<Book>> getBooksByCollection(String collectionId);
  Future<Book?> getBook(String id);
  Future<void> saveBook(Book book);
  Future<void> deleteBook(String id);

  // Collections
  Future<List<Collection>> getCollections();
  Future<void> saveCollection(Collection collection);
  Future<void> deleteCollection(String id);

  // Highlights
  Future<List<Highlight>> getHighlights(String bookId);
  Future<List<Highlight>> getAllHighlights();
  Future<void> saveHighlight(Highlight highlight);
  Future<void> deleteHighlight(String id);

  // Reading Progress
  Future<ReadingProgress?> getProgress(String bookId);
  Future<void> saveProgress(ReadingProgress progress);
}
